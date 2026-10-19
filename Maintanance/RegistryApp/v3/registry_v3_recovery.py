#!/usr/bin/env python3
"""OPS-164 isolated recovery experiment: consistent backup, validation and restore into a new generation.

Experiment only (TASK_REGISTRY_V3_RECOVERY_EXPERIMENT.md). Files are new paths in a temporary directory; nothing is
overwritten. No live DB, server, Studio or Inbox.

- backup(conn, path): the SQLite backup API writes a consistent snapshot to a new file, and a manifest next to it
  (<path>.manifest.json) records schema version, generation, revision, size and SHA-256. Existing files are refused.
- validate(path): the bytes match the manifest, PRAGMA integrity_check is ok, and the DB's own schema version,
  generation and revision match the manifest. Anything else is refused.
- restore(path, new_path, actor, evidence): from a validated backup into a new file, with a new generation. The origin
  (generation, revision, backup hash) is recorded as lineage. Writes start CLOSED: a backup can lag behind numbers issued
  after it, so the restored highwater is not claimed to be safe. Old operation records stay queryable
  (registry_v3_write.operation); requests of the old generation are refused, never replayed.
- enable_writes(conn, actor, evidence, issued_through): the explicit reopening used by the tests. The caller states the
  last issued number per prefix; it may only raise the highwater. Where that boundary comes from in a real recovery is
  NOT decided here (open decision), and nothing reopens writes automatically.
"""
import hashlib
import json
import os
import re
import sqlite3
from pathlib import Path

import registry_v3_write as w3


class BackupInvalid(ValueError):
    """The backup or its manifest does not check out; nothing was restored."""


def _sha256(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def manifest_path(path):
    return Path(str(path) + '.manifest.json')


def _state(conn):
    schema, gen = conn.execute('SELECT schema_version, generation FROM db_meta').fetchone()
    rev = conn.execute('SELECT COALESCE(MAX(revision), 0) FROM revisions WHERE generation = ?', (gen,)).fetchone()[0]
    return schema, gen, rev


def _reserve(path, hook=None):
    """Create path exclusively (O_EXCL) and return its descriptor: nobody else's file is ever opened or overwritten, even
    when it appears between a check and the creation. hook(path) is a test-only interleaving point just before."""
    if hook:
        hook(Path(path))
    return os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o644)


def _write_all(fd, data):
    view = memoryview(data)
    while view:
        view = view[os.write(fd, view):]
    os.fsync(fd)


def backup(conn, path, _before_reserve=None):
    """Consistent snapshot (SQLite backup API into memory, then serialized) written to newly reserved files; the
    manifest hashes exactly the bytes that were written."""
    path, mpath = Path(path), manifest_path(path)
    if conn.in_transaction:
        raise ValueError('back up outside a transaction of this connection')
    mem = sqlite3.connect(':memory:')
    try:
        conn.backup(mem)
        schema, gen, rev = _state(mem)
        data = mem.serialize()
    finally:
        mem.close()
    manifest = {'schemaVersion': schema, 'generation': gen, 'revision': rev, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest(), 'file': path.name}
    mine = []
    try:
        fd = _reserve(path, _before_reserve)
        mine.append(path)
        try:
            _write_all(fd, data)
        finally:
            os.close(fd)
        fd = _reserve(mpath, _before_reserve)
        mine.append(mpath)
        try:
            _write_all(fd, (json.dumps(manifest, ensure_ascii=False, indent=1) + '\n').encode('utf-8'))
        finally:
            os.close(fd)
    except BaseException:
        for p in mine:  # only the files this call created
            p.unlink(missing_ok=True)
        raise
    return manifest


def _pinned(path):
    """(manifest, in-memory connection) of a backup: the bytes are read once, checked against the manifest and opened
    from memory, so later changes of the file cannot reach what was validated."""
    path, mpath = Path(path), manifest_path(path)
    try:
        manifest = json.loads(mpath.read_text(encoding='utf-8'))
    except (OSError, ValueError) as error:
        raise BackupInvalid(f'manifest unreadable: {error}') from None
    try:
        data = path.read_bytes()
    except OSError as error:
        raise BackupInvalid(f'backup unreadable: {error}') from None
    if len(data) != manifest.get('bytes') or hashlib.sha256(data).hexdigest() != manifest.get('sha256'):
        raise BackupInvalid('backup bytes do not match the manifest')
    if manifest.get('schemaVersion') != w3.SCHEMA_VERSION:
        raise BackupInvalid(f"schema version {manifest.get('schemaVersion')} is not {w3.SCHEMA_VERSION}")
    mem = sqlite3.connect(':memory:')
    try:
        try:
            mem.deserialize(data)
            ok = mem.execute('PRAGMA integrity_check').fetchone()[0]
            state = _state(mem)
        except sqlite3.DatabaseError as error:
            raise BackupInvalid(f'not a readable experiment DB: {error}') from None
        if ok != 'ok':
            raise BackupInvalid(f'integrity_check: {ok}')
        if state != (manifest['schemaVersion'], manifest['generation'], manifest['revision']):
            raise BackupInvalid(f'DB says schema/generation/revision {state}, manifest says '
                                f"{(manifest['schemaVersion'], manifest['generation'], manifest['revision'])}")
    except BaseException:
        mem.close()
        raise
    return manifest, mem


def validate(path):
    manifest, mem = _pinned(path)
    mem.close()
    return manifest


def restore(path, new_path, actor, evidence, _before_reserve=None, _after_validate=None):
    """Restore the validated bytes (pinned in memory) into a newly reserved file with a new generation. The _ hooks are
    test-only interleaving points."""
    if not isinstance(actor, str) or not actor or not isinstance(evidence, list):
        raise ValueError('restore needs actor (self-declared) and evidence (a list of references)')
    new_path = Path(new_path)
    manifest, source = _pinned(path)
    try:
        if _after_validate:
            _after_validate(Path(path))  # whatever happens to the file now, only the pinned bytes are used
        os.close(_reserve(new_path, _before_reserve))
        try:
            target = sqlite3.connect(new_path, isolation_level=None)
            try:
                source.backup(target)
                gen = w3.new_generation()
                target.execute('BEGIN IMMEDIATE')
                target.execute('UPDATE db_meta SET generation = ?, write_enabled = 0', (gen,))
                target.execute('INSERT INTO lineage (generation, event, detail) VALUES (?, ?, ?)', (gen, 'restored', json.dumps(
                    {'fromGeneration': manifest['generation'], 'fromRevision': manifest['revision'], 'backupSha256': manifest['sha256'],
                     'actor': actor, 'evidence': evidence, 'writes': 'closed: the backup may lag numbers issued after it'}, ensure_ascii=False)))
                target.execute('COMMIT')
            finally:
                target.close()
        except BaseException:
            new_path.unlink(missing_ok=True)  # reserved by this call, so it is ours
            raise
    finally:
        source.close()
    return {'generation': gen, 'fromGeneration': manifest['generation'], 'fromRevision': manifest['revision']}


def lineage(conn):
    return [{'generation': g, 'event': e, **json.loads(d)} for g, e, d in conn.execute('SELECT generation, event, detail FROM lineage ORDER BY sequence')]


def enable_writes(conn, actor, evidence, issued_through):
    """Reopen writes of the current generation. issued_through {PREFIX: n} must cover every prefix the DB knows and may
    only raise a highwater; it is recorded with the actor and evidence. The source of these numbers is an open decision."""
    if not isinstance(actor, str) or not actor or not isinstance(evidence, list) or not evidence:
        raise ValueError('enable_writes needs actor and at least one evidence reference')
    conn.execute('BEGIN IMMEDIATE')
    try:
        gen, enabled = conn.execute('SELECT generation, write_enabled FROM db_meta').fetchone()
        if enabled:
            raise ValueError(f'writes are already open in {gen}')
        current = dict(conn.execute('SELECT prefix, highwater FROM id_allocations'))
        if set(current) - set(issued_through):
            raise ValueError('issued_through must state every known prefix: missing ' + ', '.join(sorted(set(current) - set(issued_through))))
        for prefix, n in issued_through.items():
            if not re.fullmatch(r'[A-Z]+', prefix) or type(n) is not int or n < current.get(prefix, 0):
                raise ValueError(f'issued_through {prefix}={n!r} must be an integer not below the restored highwater {current.get(prefix, 0)}')
        for prefix, n in issued_through.items():
            conn.execute('INSERT INTO id_allocations VALUES (?, ?) ON CONFLICT (prefix) DO UPDATE SET highwater = excluded.highwater', (prefix, n))
        conn.execute('UPDATE db_meta SET write_enabled = 1')
        conn.execute('INSERT INTO lineage (generation, event, detail) VALUES (?, ?, ?)', (gen, 'writes enabled', json.dumps(
            {'actor': actor, 'evidence': evidence, 'issuedThrough': issued_through, 'restoredHighwater': current}, ensure_ascii=False)))
        conn.execute('COMMIT')
    except BaseException:
        if conn.in_transaction:
            conn.execute('ROLLBACK')
        raise
