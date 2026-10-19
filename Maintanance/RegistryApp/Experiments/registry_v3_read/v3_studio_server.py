#!/usr/bin/env python3
"""OPS-166 isolated Studio server for the headless-browser round trip. Experiment only.

Binds 127.0.0.1 on an OS-assigned port, keeps every state in the caller's directory (fixture DB, saves/), and is started
and stopped by the test. It never imports serve.py, sync.py or inbox.py and never writes the template.

- GET /            the page, built in memory from a read-only copy of index.template.html: the seed is a fresh
                   studio_adapter.export_doc (so reopening shows the latest DB), documents and the pending queue are empty, and the
                   OPS-165 compatibility patches P1-P3 are applied (each must match exactly once).
- POST /save       the page's own save call: stores the JSON as a new file under saves/ (parent/series as inbox.py does)
                   and answers in serve.py's shape. It NEVER writes the DB. A document without the V3 base is refused.
- GET /workspace   the latest save, as inbox.latest, so the page's own resumeWorkspace() runs.
- POST /v3/apply   an explicit DB write: studio_adapter.apply_save on a stored save (single task, OPS-166).
- POST /v3/apply-groups  an explicit DB write with selected groups and resolutions: studio_adapter.apply_groups (OPS-173),
                   with the document_root given to the constructor (OPS-176; none: new cards and acknowledgements stay pending).
- GET /v3/latest   a fresh export, for assertions.
- anything else    404 (logged); /sync, /registry.json, the pollers and approvals are not served.
"""
import datetime
import json
import re
import secrets
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import registry_v3_write as w3
import studio_adapter as sa

TEMPLATE = Path(__file__).resolve().parent.parent.parent / 'index.template.html'
PATCHES = [
    ("typeof d.source.sha256!=='string'",
     "(d.source.kind==='v3-export'?!(d.v3&&typeof d.source.generation==='string'&&Number.isInteger(d.source.revision)&&d.source.sha256===undefined):typeof d.source.sha256!=='string')",
     'P1 check(): a V3 export has no source.sha256; accepted only with source.kind v3-export, a generation and an integer revision'),
    ("'生成元 '+doc.source.path+' · HEAD '+doc.source.head.slice(0,8)+' · '+doc.source.generatedAt+'\\nSHA-256 '+doc.source.sha256+' · '+(doc.source.dirty?'未コミット差分を含む':'コミット済み版')",
     "(doc.source.kind==='v3-export'?'V3 DB '+doc.source.path+' · 世代 '+doc.source.generation+' · 改訂 '+doc.source.revision+'\\npayloadHash '+doc.source.payloadHash.slice(0,12)+'（'+doc.source.payloadHashOf+'）':'生成元 '+doc.source.path+' · HEAD '+doc.source.head.slice(0,8)+' · '+doc.source.generatedAt+'\\nSHA-256 '+doc.source.sha256+' · '+(doc.source.dirty?'未コミット差分を含む':'コミット済み版'))",
     'P2 banner(): a V3 export shows its DB generation, revision and the named payloadHash; no Git HEAD, no committed/uncommitted label'),
    ("(doc.source.sha256!==canonical.sha256?",
     "(doc.source.kind==='v3-export'?(doc.source.generation!==canonical.generation||doc.source.revision!==canonical.revision?'\\nDBが更新されています：この編集版の土台 世代 '+doc.source.generation+' 改訂 '+doc.source.revision+' → 最新 世代 '+canonical.generation+' 改訂 '+canonical.revision:''):'')+(doc.source.kind!=='v3-export'&&doc.source.sha256!==canonical.sha256?",
     'P3 banner(): the base comparison of a V3 export uses generation and revision'),
    ("const PLAN_DIR='Maintanance/Milestones/',PLAN_SOURCE='Maintanance/Milestones/README.md';",
     "const PLAN_DIR='Maintanance/Milestones/',PLAN_SOURCE='Maintanance/Milestones/README.md';const PLAN_SOURCE_FILE=PLAN_SOURCE;",
     'P4a keeps the file source under a second name for P4'),
    ('function planRebuild(d,versions){',
     "function planRebuild(d,versions){const PLAN_SOURCE=(d.source&&d.source.kind==='v3-export')?'v3-db:skeleton':PLAN_SOURCE_FILE;",
     'P4 planRebuild(): for a V3 export the derived chain lines are the export\'s v3-db:skeleton lines (not Milestones/README.md), so a replan replaces them (OPS-172/173)'),
    ("const addVer=el('button','版を追加');box.append(addVer);addVer.onclick=()=>{if(formDirty){report('先に入力の「変更を適用」を押してください。',true);return;}try{const name=vn.value.trim();doc=planAddVersion(doc,vn.value);",
     "const after=el('select');after.id='planAddVersionAfter';options(after,['（先頭）'].concat(versions),versions[versions.length-1]);const la=el('label','追加する位置（この版の後）');la.append(after);box.append(la);const addVer=el('button','版を追加');box.append(addVer);addVer.onclick=()=>{if(formDirty){report('先に入力の「変更を適用」を押してください。',true);return;}try{const name=vn.value.trim();doc=planAddVersion(doc,vn.value);{const s=doc.milestones.find(m=>m.id==='START-'+name);if(s)s.planPosition={after:after.value==='（先頭）'?null:after.value};}",
     'P5 renderPlanTools(): an explicit position select for 版を追加, kept as planPosition on the new START (OPS-176)'),
]


def build_page(conn):
    html = TEMPLATE.read_text(encoding='utf-8')
    for old, new, _ in PATCHES:
        n = html.count(old)
        if n != 1:
            raise ValueError(f'patch matched {n} times; the template changed: {old[:40]}')
        html = html.replace(old, new)
    empty_queue = {'source': '（隔離V3実験：採番待ちqueueは読まない）', 'sources': [], 'generatedAt': '', 'entries': [], 'requests': []}
    for name, value in (('seed', sa.export_doc(conn)), ('documents', {'generatedAt': '', 'files': {}}), ('pendingSeed', empty_queue)):
        block = f'<script id="{name}" type="application/json">' + json.dumps(value, ensure_ascii=False).replace('<', '\\u003c') + '</script>'
        html, n = re.subn(rf'<script id="{name}" type="application/json">.*?</script>', lambda m: block, html, count=1, flags=re.S)
        if n != 1:
            raise ValueError(f'{name} block not found')
    return html


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass  # requests are recorded in server.requests

    def reply(self, status, body, ctype='application/json; charset=utf-8'):
        data = body if isinstance(body, bytes) else json.dumps(body, ensure_ascii=False).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(data)

    def body(self):
        return json.loads(self.rfile.read(int(self.headers.get('Content-Length', '0'))).decode('utf-8'))

    def do_GET(self):
        s = self.server
        s.requests.append(('GET', self.path))
        if self.path == '/':
            conn = w3.open_db(s.db_path)
            try:
                page = build_page(conn)
            finally:
                conn.close()
            s.pages.append(page)
            return self.reply(200, page.encode('utf-8'), 'text/html; charset=utf-8')
        if self.path == '/workspace':
            return self.reply(200, s.latest())
        if self.path == '/v3/latest':
            conn = w3.open_db(s.db_path)
            try:
                return self.reply(200, sa.export_doc(conn))
            finally:
                conn.close()
        return self.reply(404, {'error': 'not served by the isolated V3 server'})

    def do_POST(self):
        s = self.server
        s.requests.append(('POST', self.path))
        if self.path == '/save':
            data = self.body()
            if not isinstance(data, dict) or (data.get('source') or {}).get('kind') != 'v3-export' or not isinstance(data.get('v3'), dict):
                return self.reply(400, {'error': 'only a V3 export can be saved here'})
            return self.reply(200, {'ok': True, **s.store(data)})
        if self.path == '/v3/apply':
            req = self.body()
            save = s.load(req['saveId'])
            conn = w3.open_db(s.db_path)
            try:
                op, result = sa.apply_save(conn, save, req['actor'], req['evidence'])
                return self.reply(200, {'ok': True, 'operationId': op, 'result': result})
            except (sa.SaveRejected, w3.Refused, w3.GenerationMismatch, w3.WriteDisabled, w3.OperationMismatch) as error:
                return self.reply(409, {'ok': False, 'kind': type(error).__name__, 'error': str(error)})
            finally:
                conn.close()
        if self.path == '/v3/apply-groups':
            req = self.body()
            save = s.load(req['saveId'])
            conn = w3.open_db(s.db_path)
            try:
                out = sa.apply_groups(conn, save, req['selected'], req['actor'], req['evidence'], req.get('resolutions'), req.get('ancestry'),
                                      document_root=s.document_root)
                return self.reply(200, {'ok': True, **out})
            except (sa.SaveRejected, w3.GenerationMismatch, w3.WriteDisabled) as error:
                return self.reply(409, {'ok': False, 'kind': type(error).__name__, 'error': str(error)})
            finally:
                conn.close()
        return self.reply(404, {'error': 'not served by the isolated V3 server'})


class V3StudioServer(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, db_path, saves_dir, document_root=None):
        super().__init__(('127.0.0.1', 0), Handler)
        self.db_path, self.saves = str(db_path), Path(saves_dir)
        # OPS-176: the canonical documents new cards and acknowledgements are checked against; given explicitly by the
        # caller (a test fixture of prepared temporary documents). None (the default): they stay pending, never the repo.
        self.document_root = None if document_root is None else Path(document_root)
        self.saves.mkdir(parents=True, exist_ok=True)
        self.requests, self.pages, self.lock = [], [], threading.Lock()
        self.thread = None

    @property
    def origin(self):
        return f'http://127.0.0.1:{self.server_address[1]}'

    def saves_list(self):
        return sorted((json.loads(p.read_text(encoding='utf-8')) for p in self.saves.glob('*.json')), key=lambda d: d['studioSave']['savedAt'])

    def store(self, data):
        with self.lock:
            saves = self.saves_list()
            parent = (data.pop('studioSave', None) or {}).get('parent')
            by_id = {d['studioSave']['saveId']: d for d in saves}
            stale = parent is not None and any(d['studioSave'].get('parent') == parent for d in saves)
            now = datetime.datetime.now(datetime.timezone.utc)
            save_id = now.strftime('%Y%m%dT%H%M%S%fZ') + '-' + secrets.token_hex(4)
            series = save_id if parent is None or stale or parent not in by_id else by_id[parent]['studioSave']['series']
            meta = {'saveId': save_id, 'savedAt': now.isoformat(), 'series': series, 'parent': parent}
            with open(self.saves / f'v3-save-{save_id}.json', 'x', encoding='utf-8') as out:
                out.write(json.dumps(dict(data, studioSave=meta), ensure_ascii=False, indent=1) + '\n')
            return {'file': f'v3-save-{save_id}.json', 'folder': str(self.saves), 'save': dict(meta, branched=stale)}

    def load(self, save_id):
        return json.loads((self.saves / f'v3-save-{save_id}.json').read_text(encoding='utf-8'))

    def latest(self):
        saves = self.saves_list()
        if not saves:
            return None
        parents = {d['studioSave'].get('parent') for d in saves}
        return {'save': saves[-1], 'heads': sum(1 for d in saves if d['studioSave']['saveId'] not in parents), 'saves': len(saves)}

    def start(self):
        self.thread = threading.Thread(target=self.serve_forever, daemon=True)
        self.thread.start()
        return self

    def stop(self):
        self.shutdown()
        self.server_close()
        if self.thread:
            self.thread.join(5)
