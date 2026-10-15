#!/usr/bin/env python3
"""Task history SQLite index (prototype).

Indexes where Task Registry IDs appear in Git history: commit messages and the
added / removed lines of each commit's diff. The index is a regenerable search
aid. It never decides task state, completion, ownership, or numbering.

Procedure (adopted 2026-10-15): Maintanance/ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md
Rules and evidence:             Maintanance/ProgressV2/TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md
Semantics and limits:           Maintanance/ProgressV2/TASK_RULES_V2.md (履歴の照合とSQLite索引)

Usage from the repository root:
  python3 Utilities/Maintenance/TaskHistoryIndex.py build   [--db PATH] [--ref REF] [--replace]
  python3 Utilities/Maintenance/TaskHistoryIndex.py update  [--db PATH] [--ref REF]
  python3 Utilities/Maintenance/TaskHistoryIndex.py status  [--db PATH]
  python3 Utilities/Maintenance/TaskHistoryIndex.py verify  [--db PATH]
  python3 Utilities/Maintenance/TaskHistoryIndex.py search  [--db PATH] TASK-ID
  python3 Utilities/Maintenance/TaskHistoryIndex.py changes [--db PATH] [--grade GRADE] [--task TASK-ID]

Maintenance operations:
  routine       [--db PATH] [--ref REF]                    通常メンテ: update, verify, report the added range
  archive-check [REV | --worktree]                         アーカイブ時メンテ: Registry rows removed by the change
                                                           are preserved verbatim in Archived and linked (no DB)
  intervention  [--db PATH] [--ref REF] [--since REV]      介入後メンテ: update, then list structural / candidate
  intervention  --worktree                                 Registry row changes (uncommitted: no DB write)

Fixed extraction rules (RULE_VERSION 2):
  - Commit set: every commit reachable from the target ref, resolved to a SHA at start.
  - Diff: merge commits are compared with their first parent; root commits with the
    empty tree. The parent used is stored with each diff occurrence.
  - Diffs are read with zero context lines, so context-only appearances are never
    recorded as changes. Renames are not detected (a rename is a removal plus an addition).
  - Binary diffs are skipped.
  - IDs match TASK_ID_PATTERN below. Adding a prefix changes the rule version and
    requires a rebuild; update refuses to mix rule versions.

Registry row changes (reference material):
  - For each non-merge commit, Registry rows ("| `ID` | `STATE` | ...") removed from a
    Registry file are paired with the same ID's row added anywhere in that commit
    (another Registry file first, then e.g. an Archived file). Only rows that were
    ACTIVE or FROZEN before the commit are recorded, and only if the state or the row
    text changed. Merge commits are skipped because their first-parent diff repeats the
    branch commits.
  - Grades are a fixed classification rule, not a judgment about each change:
      structural  FROZEN to another state, or ACTIVE to FROZEN (the rules require an
                  explicit user instruction to restart or stop)
      routine     ACTIVE to DONE
      candidate   every other change, including text-only changes; read the source
  - Every row is marked as 参考資料. It never decides whether an intervention happened.
"""

import argparse
import datetime
import os
import re
import sqlite3
import subprocess
import sys

SCHEMA_VERSION = "3"
RULE_VERSION = "2"

# Prefixes from TASK_RULES_V2.md「Task ID採番状態」as of 2026-10-15.
TASK_PREFIXES = (
    "API", "ARRAY", "BARE", "BENCH", "CPP", "DOC", "EVAL", "FIT", "GRAPH",
    "HIST", "OPS", "OPT", "PERF", "PERM", "QUALITY", "RBT", "RELEASE", "TEST",
)
TASK_ID_PATTERN = re.compile(
    r"(?<![A-Za-z0-9_-])(?:" + "|".join(TASK_PREFIXES) + r")-[0-9]{3}(?![0-9])"
)

DEFAULT_DB = os.path.join("Maintanance", "TaskHistoryIndex", "task_history.sqlite3")
BATCH_SIZE = 200
HUNK_PATTERN = re.compile(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@")

REGISTRY_PATHS = (
    "Maintanance/PROGRESS_OVERVIEW.md",
    "Maintanance/ProgressV2/TASK_REGISTRY_V2.md",
)
REGISTRY_ROW_PATTERN = re.compile(r"^\| `(" + TASK_ID_PATTERN.pattern + r")` \| `([A-Z_]+)` \|(.*)$")
USER_MARKER_PATTERN = re.compile(r"ユーザー(?:の)?(?:指示|明示|判断|確認|依頼|指定|が「|「)|差し戻")
TRACKED_STATES = ("ACTIVE", "FROZEN")

SCHEMA = """
CREATE TABLE meta (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
CREATE TABLE commits (
    sha         TEXT PRIMARY KEY,
    parents     TEXT NOT NULL,
    diff_parent TEXT,
    author_date TEXT NOT NULL,
    subject     TEXT NOT NULL,
    run_id      INTEGER NOT NULL
);
CREATE TABLE occurrences (
    commit_sha  TEXT NOT NULL REFERENCES commits(sha),
    task_id     TEXT NOT NULL,
    location    TEXT NOT NULL CHECK (location IN ('message', 'added', 'removed')),
    path        TEXT NOT NULL,
    line        INTEGER NOT NULL,
    diff_parent TEXT,
    UNIQUE (commit_sha, task_id, location, path, line)
);
CREATE INDEX occurrences_task ON occurrences(task_id);
CREATE TABLE registry_changes (
    commit_sha   TEXT NOT NULL REFERENCES commits(sha),
    task_id      TEXT NOT NULL,
    from_state   TEXT NOT NULL,
    to_state     TEXT,
    from_path    TEXT NOT NULL,
    from_line    INTEGER NOT NULL,
    to_path      TEXT,
    to_line      INTEGER,
    text_changed INTEGER NOT NULL,
    user_marker  INTEGER NOT NULL,
    grade        TEXT NOT NULL CHECK (grade IN ('structural', 'routine', 'candidate')),
    mark         TEXT NOT NULL DEFAULT '参考資料',
    UNIQUE (commit_sha, task_id)
);
CREATE INDEX registry_changes_task ON registry_changes(task_id);
CREATE TABLE runs (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    command     TEXT NOT NULL,
    target_ref  TEXT NOT NULL,
    target_sha  TEXT NOT NULL,
    started_at  TEXT NOT NULL,
    finished_at TEXT,
    added       INTEGER,
    status      TEXT NOT NULL
);
"""


class IndexError_(Exception):
    pass


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")


def git(*args, input_text=None):
    result = subprocess.run(
        ["git", "-c", "core.quotePath=false", *args],
        input=input_text, capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    if result.returncode != 0:
        raise IndexError_("git %s failed: %s" % (" ".join(args), result.stderr.strip()))
    return result.stdout


def repo_identity():
    """Root commits identify the repository independently of its local path."""
    roots = git("rev-list", "--max-parents=0", "HEAD").split()
    return ",".join(sorted(roots))


def resolve(ref):
    return git("rev-parse", "--verify", ref + "^{commit}").strip()


def reachable(sha):
    return set(git("rev-list", sha).split())


def open_readonly(path):
    if not os.path.exists(path):
        raise IndexError_("索引がありません（初回作成は未実施）: %s" % path)
    return sqlite3.connect("file:%s?mode=ro" % path, uri=True)


def meta(conn):
    return dict(conn.execute("SELECT key, value FROM meta"))


class Lock:
    """Single writer per database path."""

    def __init__(self, db_path):
        self.path = db_path + ".lock"
        self.fd = None

    def __enter__(self):
        try:
            self.fd = os.open(self.path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        except FileExistsError:
            raise IndexError_(
                "別の更新が動いているか、前回の更新が中断しています: %s\n"
                "更新元が動いていないことを確かめてから、このlock fileを消して再実行してください。" % self.path
            )
        os.write(self.fd, ("%d %s\n" % (os.getpid(), now())).encode())
        return self

    def __exit__(self, *exc):
        os.close(self.fd)
        os.unlink(self.path)


def parse_log(stream):
    """Yield (sha, parents, author_date, message, diff_text) from the log stream."""
    for record in stream.split("\x00\x01")[1:]:
        header, message, diff = record.split("\x00", 2)
        fields = header.split(" ")
        sha, author_date, parents = fields[0], fields[1], fields[2:]
        yield sha, [p for p in parents if p], author_date, message, diff


def diff_occurrences(diff):
    """Yield (location, path, line, text) for added and removed lines only."""
    old_path = new_path = None
    old_line = new_line = 0
    in_header = False
    for raw in diff.split("\n"):
        if raw.startswith("diff --git "):
            in_header = True
            old_path = new_path = None
            continue
        if in_header:
            # File header lines ("--- a/x", "+++ b/x", index, mode, Binary) are not content.
            if raw.startswith("--- "):
                old_path = None if raw[4:] == "/dev/null" else raw[6:]
            elif raw.startswith("+++ "):
                new_path = None if raw[4:] == "/dev/null" else raw[6:]
            if not raw.startswith("@@"):
                continue
            in_header = False
        if raw.startswith("@@"):
            match = HUNK_PATTERN.match(raw)
            if match:
                old_line, new_line = int(match.group(1)), int(match.group(2))
            continue
        if raw.startswith("+") and new_path is not None:
            yield "added", new_path, new_line, raw[1:]
            new_line += 1
        elif raw.startswith("-") and old_path is not None:
            yield "removed", old_path, old_line, raw[1:]
            old_line += 1


def grade_change(from_state, to_state):
    if from_state == "FROZEN" and to_state not in (None, "FROZEN"):
        return "structural"
    if from_state == "ACTIVE" and to_state == "FROZEN":
        return "structural"
    if from_state == "ACTIVE" and to_state == "DONE":
        return "routine"
    return "candidate"


def registry_changes(sha, changed_lines):
    """Pair removed Registry rows with the same ID's added row in one commit."""
    removed = {}
    added = {}
    for location, path, line, text in changed_lines:
        match = REGISTRY_ROW_PATTERN.match(text)
        if not match:
            continue
        task_id, state, rest = match.group(1), match.group(2), " ".join(match.group(3).split())
        if location == "removed":
            if path in REGISTRY_PATHS and state in TRACKED_STATES:
                removed.setdefault(task_id, (state, rest, path, line))
        else:
            # Prefer the row that stays in a Registry file over a copy elsewhere.
            rank = 0 if path in REGISTRY_PATHS else 1
            if task_id not in added or rank < added[task_id][0]:
                added[task_id] = (rank, state, rest, path, line)
    result = []
    for task_id, (from_state, from_rest, from_path, from_line) in removed.items():
        if task_id in added:
            _, to_state, to_rest, to_path, to_line = added[task_id]
        else:
            to_state = to_rest = to_path = to_line = None
        text_changed = int(to_rest != from_rest)
        if to_state == from_state and not text_changed:
            continue
        user_marker = int(
            bool(to_rest and USER_MARKER_PATTERN.search(to_rest))
            and not USER_MARKER_PATTERN.search(from_rest)
        )
        result.append((
            sha, task_id, from_state, to_state, from_path, from_line, to_path, to_line,
            text_changed, user_marker, grade_change(from_state, to_state),
        ))
    return result


def index_commits(conn, shas, run_id):
    """Extract the given commits. Each batch commits occurrences and processed marks together."""
    added = 0
    for start in range(0, len(shas), BATCH_SIZE):
        batch = shas[start:start + BATCH_SIZE]
        stream = git(
            "log", "--stdin", "--no-walk=unsorted", "-p", "-U0", "--no-renames",
            "--diff-merges=first-parent", "--no-color", "--no-ext-diff", "--no-textconv",
            "--format=%x00%x01%H %aI %P%x00%B%x00",
            input_text="\n".join(batch) + "\n",
        )
        rows = []
        commits = []
        changes = []
        for sha, parents, author_date, message, diff in parse_log(stream):
            diff_parent = parents[0] if parents else None
            subject = message.split("\n", 1)[0]
            commits.append((sha, " ".join(parents), diff_parent, author_date, subject, run_id))
            for number, text in enumerate(message.split("\n"), start=1):
                for task_id in set(TASK_ID_PATTERN.findall(text)):
                    rows.append((sha, task_id, "message", "", number, None))
            changed_lines = list(diff_occurrences(diff))
            for location, path, line, text in changed_lines:
                for task_id in set(TASK_ID_PATTERN.findall(text)):
                    rows.append((sha, task_id, location, path, line, diff_parent))
            if len(parents) <= 1:
                changes.extend(registry_changes(sha, changed_lines))
        missing = set(batch) - {c[0] for c in commits}
        if missing:
            raise IndexError_("git logが返さなかったcommitがあります: %s" % ", ".join(sorted(missing)[:5]))
        with conn:
            conn.executemany("INSERT OR IGNORE INTO occurrences VALUES (?, ?, ?, ?, ?, ?)", rows)
            conn.executemany("INSERT OR IGNORE INTO commits VALUES (?, ?, ?, ?, ?, ?)", commits)
            conn.executemany(
                "INSERT OR IGNORE INTO registry_changes "
                "(commit_sha, task_id, from_state, to_state, from_path, from_line, to_path, to_line,"
                " text_changed, user_marker, grade) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                changes,
            )
        added += len(commits)
        print("  %d / %d commits" % (start + len(batch), len(shas)), file=sys.stderr)
    return added


def start_run(conn, command, ref, sha):
    with conn:
        cursor = conn.execute(
            "INSERT INTO runs (command, target_ref, target_sha, started_at, status) VALUES (?, ?, ?, ?, 'running')",
            (command, ref, sha, now()),
        )
    return cursor.lastrowid


def finish_run(conn, run_id, added, status):
    with conn:
        conn.execute(
            "UPDATE runs SET finished_at = ?, added = ?, status = ? WHERE id = ?",
            (now(), added, status, run_id),
        )


def check_coverage(conn, target_sha):
    """Return (missing, extra) between the reachable set and processed commits."""
    expected = reachable(target_sha)
    processed = {row[0] for row in conn.execute("SELECT sha FROM commits")}
    return expected - processed, processed - expected


def verify_connection(conn):
    problems = []
    result = conn.execute("PRAGMA quick_check").fetchone()[0]
    if result != "ok":
        problems.append("quick_check: %s" % result)
    info = meta(conn)
    for key, expected in (("schema_version", SCHEMA_VERSION), ("rule_version", RULE_VERSION)):
        if info.get(key) != expected:
            problems.append("%s が違います（DB %s / script %s）" % (key, info.get(key), expected))
    if info.get("repository") != repo_identity():
        problems.append("別のrepositoryの索引です")
    orphan = conn.execute(
        "SELECT COUNT(*) FROM occurrences WHERE commit_sha NOT IN (SELECT sha FROM commits)"
    ).fetchone()[0]
    if orphan:
        problems.append("処理済みcommitに属さない出現が%d件あります" % orphan)
    orphan_changes = conn.execute(
        "SELECT COUNT(*) FROM registry_changes WHERE commit_sha NOT IN (SELECT sha FROM commits)"
    ).fetchone()[0]
    if orphan_changes:
        problems.append("処理済みcommitに属さないRegistry行変化が%d件あります" % orphan_changes)
    unfinished = conn.execute("SELECT COUNT(*) FROM runs WHERE status != 'ok'").fetchone()[0]
    if unfinished:
        problems.append("正常終了していない実行記録が%d件あります" % unfinished)
    missing, extra = check_coverage(conn, info.get("target_sha", ""))
    if missing:
        problems.append("収録範囲のうち未処理のcommitが%d件あります" % len(missing))
    if extra:
        problems.append("収録範囲外の処理済みcommitが%d件あります" % len(extra))
    return problems


def cmd_build(args):
    db = args.db
    if os.path.exists(db) and not args.replace:
        raise IndexError_("索引が既にあります。再作成する場合は --replace を付けてください: %s" % db)
    os.makedirs(os.path.dirname(os.path.abspath(db)), exist_ok=True)
    temp = "%s.building-%d" % (db, os.getpid())
    with Lock(db):
        target_sha = resolve(args.ref)
        conn = sqlite3.connect(temp)
        try:
            conn.executescript(SCHEMA)
            with conn:
                conn.executemany("INSERT INTO meta VALUES (?, ?)", [
                    ("schema_version", SCHEMA_VERSION),
                    ("rule_version", RULE_VERSION),
                    ("repository", repo_identity()),
                    ("target_ref", args.ref),
                    ("target_sha", target_sha),
                    ("shallow", git("rev-parse", "--is-shallow-repository").strip()),
                ])
            run_id = start_run(conn, "build", args.ref, target_sha)
            shas = git("rev-list", "--reverse", target_sha).split()
            added = index_commits(conn, shas, run_id)
            finish_run(conn, run_id, added, "ok")
            problems = verify_connection(conn)
        finally:
            conn.close()
        if problems:
            raise IndexError_("作成した一時DBの検査に失敗しました（%s を残します）:\n  %s" % (temp, "\n  ".join(problems)))
        # Rollback journal mode: once closed, the database is a single file and can be replaced atomically.
        os.replace(temp, db)
    print("作成しました: %s（%s まで %d commits）" % (db, target_sha[:12], added))


def cmd_update(args):
    _, added, target_sha = update_index(args.db, args.ref)
    print("更新しました: %s（%s まで、今回 %d commits を追加）" % (args.db, target_sha[:12], added))


def update_index(db, ref):
    """Add unprocessed commits. Returns (run_id, added, target_sha)."""
    if not os.path.exists(db):
        raise IndexError_("索引がありません。先に build を実行してください: %s" % db)
    with Lock(db):
        conn = sqlite3.connect(db)
        try:
            problems = [p for p in verify_connection(conn) if not p.startswith("収録範囲のうち未処理")]
            if problems:
                raise IndexError_("差分更新できません。build --replace で再作成してください:\n  %s" % "\n  ".join(problems))
            target_sha = resolve(ref)
            processed = {row[0] for row in conn.execute("SELECT sha FROM commits")}
            expected = reachable(target_sha)
            if processed - expected:
                raise IndexError_(
                    "新しい対象範囲に含まれない処理済みcommitが%d件あります（rebaseやref付け替え）。"
                    "build --replace で再作成してください。" % len(processed - expected)
                )
            ordered = [sha for sha in git("rev-list", "--reverse", target_sha).split() if sha not in processed]
            run_id = start_run(conn, "update", ref, target_sha)
            added = index_commits(conn, ordered, run_id)
            with conn:
                conn.execute("UPDATE meta SET value = ? WHERE key = 'target_ref'", (ref,))
                conn.execute("UPDATE meta SET value = ? WHERE key = 'target_sha'", (target_sha,))
            finish_run(conn, run_id, added, "ok")
        finally:
            conn.close()
    return run_id, added, target_sha


def cmd_status(args):
    conn = open_readonly(args.db)
    try:
        info = meta(conn)
        commits = conn.execute("SELECT COUNT(*) FROM commits").fetchone()[0]
        occurrences = conn.execute("SELECT COUNT(*) FROM occurrences").fetchone()[0]
        changes = conn.execute("SELECT COUNT(*) FROM registry_changes").fetchone()[0]
        last = conn.execute(
            "SELECT command, target_sha, finished_at, added, status FROM runs ORDER BY id DESC LIMIT 1"
        ).fetchone()
    finally:
        conn.close()
    print("索引: %s" % args.db)
    print("収録範囲: %s（%s）" % (info.get("target_sha", "?")[:12], info.get("target_ref")))
    print("処理済みcommit: %d / 出現: %d / Registry行変化（参考資料）: %d" % (commits, occurrences, changes))
    print("schema %s / rule %s / shallow %s" % (info.get("schema_version"), info.get("rule_version"), info.get("shallow")))
    if last:
        print("最終実行: %s %s %s 追加%s %s" % (last[0], last[1][:12], last[2], last[3], last[4]))
    head = resolve("HEAD")
    if head != info.get("target_sha"):
        print("注意: HEAD %s は収録範囲の外です。必要なら update を実行してください。" % head[:12])


def cmd_verify(args):
    conn = open_readonly(args.db)
    try:
        problems = verify_connection(conn)
    finally:
        conn.close()
    if problems:
        print("問題があります:\n  " + "\n  ".join(problems))
        return 1
    print("ok（DB整合と収録範囲の一致を確認。抽出の正しさは原文との照合で確かめる）")
    return 0


def cmd_search(args):
    conn = open_readonly(args.db)
    try:
        rows = conn.execute(
            """
            SELECT c.sha, c.author_date, o.location, o.path, o.line, c.subject
            FROM occurrences o JOIN commits c ON c.sha = o.commit_sha
            WHERE o.task_id = ?
            ORDER BY c.author_date, c.sha, o.location, o.path, o.line
            """,
            (args.task_id,),
        ).fetchall()
        target = meta(conn).get("target_sha", "?")
    finally:
        conn.close()
    for sha, date, location, path, line, subject in rows:
        where = "message:%d" % line if location == "message" else "%s %s:%d" % (location, path, line)
        print("%s %s %-28s %s" % (sha[:10], date[:10], where, subject))
    print("%d件（収録範囲 %s まで。出現がないことは未使用の証拠にならない）" % (len(rows), target[:12]), file=sys.stderr)


def cmd_changes(args):
    conn = open_readonly(args.db)
    try:
        query = """
            SELECT c.sha, c.author_date, r.task_id, r.from_state, ifnull(r.to_state, '(削除)'),
                   r.grade, r.text_changed, r.user_marker, r.mark, c.subject
            FROM registry_changes r JOIN commits c ON c.sha = r.commit_sha
            WHERE (? IS NULL OR r.grade = ?) AND (? IS NULL OR r.task_id = ?)
            ORDER BY c.author_date, c.sha, r.task_id
        """
        rows = conn.execute(query, (args.grade, args.grade, args.task, args.task)).fetchall()
        summary = conn.execute(
            "SELECT grade, COUNT(*) FROM registry_changes GROUP BY grade ORDER BY grade"
        ).fetchall()
    finally:
        conn.close()
    for sha, date, task_id, from_state, to_state, grade, text_changed, user_marker, mark, subject in rows:
        notes = ("本文" if text_changed else "") + (" 指示語" if user_marker else "")
        print("%s %s %-12s %s→%-16s %-10s %-8s [%s] %s" % (
            sha[:10], date[:10], task_id, from_state, to_state, grade, notes.strip(), mark, subject))
    print("%d件 / 全体: %s（参考資料。介入の有無は原文で判断する）" % (
        len(rows), ", ".join("%s %d" % row for row in summary)), file=sys.stderr)


ARCHIVED_PREFIX = "Maintanance/Archived/"
TABLE_ROW_PATTERN = re.compile(r"^\| `([^`]+)` \| `([^`]+)` \|")


def commit_changed_lines(sha):
    diff = git(
        "show", "--format=", "-p", "-U0", "--no-renames", "--diff-merges=first-parent",
        "--no-color", "--no-ext-diff", "--no-textconv", sha,
    )
    return list(diff_occurrences(diff))


def worktree_changed_lines():
    """Changes from HEAD to the working tree, including untracked files under Maintanance/."""
    lines = list(diff_occurrences(git(
        "diff", "-p", "-U0", "--no-renames", "--no-color", "--no-ext-diff", "--no-textconv", "HEAD",
    )))
    untracked = git("ls-files", "--others", "--exclude-standard", "-z", "--", "Maintanance").split("\x00")
    for path in filter(None, untracked):
        if not path.endswith(".md"):
            continue
        with open(path, encoding="utf-8", errors="replace") as handle:
            for number, text in enumerate(handle.read().split("\n"), start=1):
                lines.append(("added", path, number, text))
    return lines


def registry_text_after(sha):
    """Registry files as they are after the change (a commit, or the working tree for None)."""
    texts = []
    for path in REGISTRY_PATHS:
        if sha is None:
            if os.path.exists(path):
                with open(path, encoding="utf-8") as handle:
                    texts.append(handle.read())
        else:
            try:
                texts.append(git("show", "%s:%s" % (sha, path)))
            except IndexError_:
                pass
    return "\n".join(texts)


def archive_problems(changed_lines, registry_text):
    """Check TASK_REGISTRY_ARCHIVE.md step 4 for Registry table rows.

    Every row removed from a Registry file must either stay in a Registry file or be
    added verbatim to an Archived file, and each Archived file that received rows must
    be linked from the Registry. Prose and headings are not checked.
    """
    def key(text):
        # Task rows are keyed by ID (the state cell may change); precedence rows by both IDs.
        match = TABLE_ROW_PATTERN.match(text)
        if not match:
            return None
        first, second = match.groups()
        return (first, second) if TASK_ID_PATTERN.fullmatch(second) else (first,)

    def normalize(text):
        return text.rstrip()

    registry_added = set()
    registry_keys = set()
    archived_added = {}
    archived_keys = {}
    removed = []
    for location, path, line, text in changed_lines:
        if not text.startswith("| `"):
            continue
        if location == "removed" and path in REGISTRY_PATHS:
            removed.append((path, line, normalize(text)))
        elif location == "added" and path in REGISTRY_PATHS:
            registry_added.add(normalize(text))
            registry_keys.add(key(text))
        elif location == "added" and path.startswith(ARCHIVED_PREFIX):
            archived_added.setdefault(normalize(text), path)
            archived_keys.setdefault(key(text), path)

    preserved = {}
    problems = []
    for path, line, text in removed:
        if text in registry_added or key(text) in registry_keys:
            continue  # kept or edited in place; not an archive move
        if text in archived_added:
            target = archived_added[text]
            preserved[target] = preserved.get(target, 0) + 1
        elif key(text) in archived_keys:
            problems.append("移動と同時に書き換え（移す前の内容との照合が必要）: %s:%d → %s\n    %s" % (
                path, line, archived_keys[key(text)], text[:120]))
        elif len(key(text) or ()) == 2:
            problems.append("外した依存辺がArchivedにない（前提充足の証拠か不要の理由を辿れるか確認）: %s:%d\n    %s" % (
                path, line, text[:120]))
        else:
            problems.append("Archivedに原文がない: %s:%d\n    %s" % (path, line, text[:120]))
    for target in sorted(preserved):
        if os.path.basename(target) not in registry_text:
            problems.append("Registryから辿れない保存先: %s" % target)
    return preserved, problems


def cmd_archive_check(args):
    if args.worktree:
        label, lines, after = "作業ツリー（HEADとの差分）", worktree_changed_lines(), registry_text_after(None)
    else:
        sha = resolve(args.rev)
        label, lines, after = "commit %s" % sha[:12], commit_changed_lines(sha), registry_text_after(sha)
    preserved, problems = archive_problems(lines, after)
    print("対象: %s" % label)
    for target, count in sorted(preserved.items()):
        print("  保存を確認: %s（%d行）" % (target, count))
    if problems:
        print("問題があります:\n  " + "\n  ".join(problems))
        return 1
    if not preserved:
        print("Registryから外した表の行はありません。")
    print("ok（表の行だけを照合。本文・見出しの保存と意味の確認は手順書どおり人が行う）")
    return 0


def print_changes(rows):
    for task_id, from_state, to_state, grade, text_changed, user_marker, where in rows:
        notes = ("本文" if text_changed else "") + (" 指示語" if user_marker else "")
        print("  %-10s %-12s %s→%-16s %-8s [参考資料] %s" % (
            grade, task_id, from_state, to_state or "(削除)", notes.strip(), where))


def cmd_routine(args):
    """通常メンテ: 差分更新、検査、今回追加した範囲の報告。"""
    run_id, added, target_sha = update_index(args.db, args.ref)
    conn = open_readonly(args.db)
    try:
        problems = verify_connection(conn)
        occurrences = conn.execute(
            "SELECT COUNT(*) FROM occurrences o JOIN commits c ON c.sha = o.commit_sha WHERE c.run_id = ?",
            (run_id,),
        ).fetchone()[0]
        grades = conn.execute(
            "SELECT r.grade, COUNT(*) FROM registry_changes r JOIN commits c ON c.sha = r.commit_sha"
            " WHERE c.run_id = ? GROUP BY r.grade ORDER BY r.grade", (run_id,),
        ).fetchall()
    finally:
        conn.close()
    print("通常メンテ: %s まで検索できます（今回 %d commits、出現 %d件、Registry行変化 %s）" % (
        target_sha[:12], added, occurrences, ", ".join("%s %d" % g for g in grades) or "0件"))
    if problems:
        print("問題があります:\n  " + "\n  ".join(problems))
        return 1
    if grades and any(g[0] != "routine" for g in grades):
        print("structural・candidateの変化があります。介入の確認は intervention で一覧できます。")
    return 0


def cmd_intervention(args):
    """介入後メンテ: 介入が触れたACTIVE・FROZEN taskのRegistry行変化を一覧する。"""
    if args.worktree:
        rows = [
            (task_id, f, t, grade, tc, um, "未commit")
            for _, task_id, f, t, _, _, _, _, tc, um, grade in registry_changes(None, worktree_changed_lines())
        ]
        print("介入後メンテ（作業ツリー、DBへは書かない）: %d件" % len(rows))
        print_changes(sorted(rows, key=lambda r: (r[3] == "routine", r[0])))
        print("commit後に intervention（--worktreeなし）でDBへ反映する。")
        return 0
    run_id, added, target_sha = update_index(args.db, args.ref)
    conn = open_readonly(args.db)
    try:
        since = args.since and resolve(args.since)
        if since:
            scope = set(git("rev-list", "%s..%s" % (since, target_sha)).split())
            label = "%s..%s" % (since[:12], target_sha[:12])
        else:
            scope = {row[0] for row in conn.execute("SELECT sha FROM commits WHERE run_id = ?", (run_id,))}
            label = "今回追加した %d commits" % added
        rows = [
            (task_id, f, t, grade, tc, um, "%s %s %s" % (sha[:10], date[:10], subject))
            for task_id, f, t, grade, tc, um, sha, date, subject in conn.execute(
                "SELECT r.task_id, r.from_state, r.to_state, r.grade, r.text_changed, r.user_marker,"
                " c.sha, c.author_date, c.subject FROM registry_changes r JOIN commits c ON c.sha = r.commit_sha"
                " ORDER BY c.author_date, c.sha, r.task_id"
            )
            if sha in scope
        ]
    finally:
        conn.close()
    shown = [r for r in rows if r[3] != "routine"]
    print("介入後メンテ（%s）: 変化 %d件、うち structural・candidate %d件" % (label, len(rows), len(shown)))
    print_changes(shown)
    if not added and not since:
        print("新しいcommitはありません。未commitの介入は --worktree で確認できます。")
    return 0


def main():
    parser = argparse.ArgumentParser(description="Task history SQLite index (prototype)")
    sub = parser.add_subparsers(dest="command", required=True)
    names = ("build", "update", "status", "verify", "search", "changes", "routine", "archive-check", "intervention")
    for name in names:
        p = sub.add_parser(name)
        p.add_argument("--db", default=DEFAULT_DB)
        if name in ("build", "update", "routine", "intervention"):
            p.add_argument("--ref", default="HEAD")
        if name == "archive-check":
            p.add_argument("rev", nargs="?", default="HEAD")
        if name in ("archive-check", "intervention"):
            p.add_argument("--worktree", action="store_true")
        if name == "intervention":
            p.add_argument("--since")
        if name == "build":
            p.add_argument("--replace", action="store_true")
        if name == "search":
            p.add_argument("task_id")
        if name == "changes":
            p.add_argument("--grade", choices=("structural", "routine", "candidate"))
            p.add_argument("--task")
    args = parser.parse_args()
    handlers = {
        "build": cmd_build, "update": cmd_update, "status": cmd_status,
        "verify": cmd_verify, "search": cmd_search, "changes": cmd_changes,
        "routine": cmd_routine, "archive-check": cmd_archive_check, "intervention": cmd_intervention,
    }
    try:
        return handlers[args.command](args) or 0
    except IndexError_ as error:
        print(str(error), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
