"""Run the task-canonical browser checks with isolated documents and records."""
import json
import re
import subprocess
import tempfile
import threading
from pathlib import Path
from http.server import ThreadingHTTPServer
from unittest.mock import patch, Mock

import activity
import serve
import sync


def main():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        serve.OUTPUT = serve.ROOT = activity.ROOT = root
        folder = root / 'Maintanance/Current'
        folder.mkdir(parents=True)
        (folder / 'first.md').write_text('# First live')
        (folder / 'second.md').write_text('# Second live')
        fixture = json.loads((serve.APP / 'task-view-model-fixture-b.json').read_text())
        first, second = fixture['tasks'][:2]
        first['detail'] = '`Maintanance/Current/first.md` `Maintanance/Current/second.md` `Maintanance/Current/missing.md`'
        second['detail'] = 'Maintanance/Current/second.md'
        (root / 'registry.json').write_text(json.dumps(fixture))
        page = sync.assemble_template()
        for name, value in [('seed', fixture), ('documents', {'files': {}, 'generatedAt': '2026-10-21T00:00:00Z'}), ('pendingSeed', {'entries': [], 'requests': []})]:
            page = re.sub(r'<script id="' + name + r'" type="application/json">.*?</script>', lambda m: '<script id="' + name + '" type="application/json">' + json.dumps(value).replace('<', '\\u003c') + '</script>', page, flags=re.S)
        (root / 'index.html').write_text(page)

        class Handler(serve.Handler):
            def do_GET(self):
                if self.path in ('/', '/task-state', '/task-state/events') or self.path.startswith(('/document-state', '/task-context')):
                    return super().do_GET()
                if self.path == '/workspace':
                    return self.reply(200, {'save': None})
                if self.path == '/server-status':
                    return self.reply(200, {'restartRecommended': False})
                return self.reply(404, {'error': 'isolated'})

            def log_message(self, *args):
                pass

        store = Mock()
        store.task_letters.return_value = {'letters': [{'id': 'LTR-fixture', 'sender': 'fixture sender', 'recipient': 'fixture recipient', 'stateLabel': '関連記録'}]}
        with patch('serve.studio_store.Store', return_value=store):
            server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
            threading.Thread(target=server.serve_forever, daemon=True).start()
            try:
                subprocess.run(['/opt/homebrew/bin/node', str(serve.APP / 'test-document-tab.cjs'), f'http://127.0.0.1:{server.server_port}', str(root), first['id'], second['id']], check=True, timeout=70)
            finally:
                server.shutdown()
                server.server_close()
                if serve._TASK_VIEW:
                    serve._TASK_VIEW.close()
                if serve.work_notifications._registry_observer:
                    serve.work_notifications._registry_observer.close()


if __name__ == '__main__':
    main()
