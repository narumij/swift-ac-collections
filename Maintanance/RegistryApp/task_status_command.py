"""Narrow user command: update one task state through the existing V3 writer CLI."""
import json
from contextlib import closing
import sqlite3
import subprocess
import sys
import threading
import uuid
from pathlib import Path

LOCK = threading.Lock()
STATES = {'ACTIVE', 'WAITING_USER', 'WAITING_EXTERNAL', 'FROZEN', 'USER_ONLY', 'PROPOSED', 'DONE', 'EXCLUDED', 'ARCHIVED'}


def change(db, root, backups, body):
    if not isinstance(body, dict) or set(body) != {'taskId', 'baseState', 'state', 'generation', 'operationId'}:
        raise ValueError('Expected taskId, baseState, state, generation and operationId')
    if not all(isinstance(body[k], str) and body[k] for k in body):
        raise ValueError('Expected non-empty strings')
    if body['state'] not in STATES or body['baseState'] not in STATES:
        raise ValueError('Unknown task state')
    uuid.UUID(body['operationId'])
    tools = Path(__file__).parent / 'v3'
    if str(tools) not in sys.path:
        sys.path.insert(0, str(tools))
    import registry_v3_recovery as recovery
    import registry_v3_views as views
    request = {'kind': 'update_task', 'id': body['taskId'], 'base': {'state': body['baseState']},
               'changes': {'state': body['state']}, 'generation': body['generation'],
               'actor': 'ユーザー', 'evidence': ['Registry Studio 正本タブの状態変更']}
    with LOCK:
        backups = Path(backups)
        backups.mkdir(parents=True, exist_ok=True)
        token = uuid.uuid4().hex
        with closing(sqlite3.connect(Path(db).resolve().as_uri() + '?mode=rw', uri=True)) as conn:
            before = backups / (token + '-before.sqlite3')
            recovery.backup(conn, before)
            recovery.validate(before)
            result = subprocess.run([sys.executable, '-B', str(tools / 'registry_v3_cli.py'), 'apply',
                '--db', str(db), '--op', body['operationId'], '--request', '-'],
                input=json.dumps(request), text=True, capture_output=True)
            reply = json.loads(result.stdout)
            if result.returncode:
                return 409, {'error': reply.get('message') or reply.get('error') or '状態が更新されています。再選択してください。', 'detail': reply}
            # The DB is already committed. Distinguish a failed generated view from a failed write.
            warning = ''
            try:
                views.replace_in_place(Path(root), conn, 'Maintanance/ProgressV2/STRUCTURE.generated.md')
            except Exception as error:
                warning = '状態は保存済みですが、生成文書の更新に失敗しました：' + str(error)
            after = backups / (token + '-after.sqlite3')
            recovery.backup(conn, after)
            recovery.validate(after)
            return 200, {'ok': True, 'taskId': body['taskId'], 'state': body['state'], 'warning': warning}
