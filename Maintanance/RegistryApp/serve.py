#!/usr/bin/env python3
"""Serve Registry Studio locally; POST /sync runs only the fixed sync.py command."""
import argparse
import json
import subprocess
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

APP = Path(__file__).resolve().parent
ROOT = APP.parent.parent
OUTPUT = ROOT / "Maintanance/Cache/RegistryStudio"
SYNC_LOCK = threading.Lock()


class Handler(BaseHTTPRequestHandler):
    def reply(self, status, body, content_type='application/json; charset=utf-8'):
        if isinstance(body, dict):
            body = json.dumps(body, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)

    def local_request(self):
        host = f'127.0.0.1:{self.server.server_port}'
        return self.headers.get('Host') == host

    def do_GET(self):
        if not self.local_request():
            return self.reply(403, {'error': 'Local host required'})
        if self.path not in ('/', '/index.html', '/registry.json'):
            return self.reply(404, {'error': 'Not found'})
        name = 'registry.json' if self.path == '/registry.json' else 'index.html'
        mime = 'application/json; charset=utf-8' if name.endswith('.json') else 'text/html; charset=utf-8'
        self.reply(200, (OUTPUT / name).read_bytes(), mime)

    def do_POST(self):
        origin = f'http://127.0.0.1:{self.server.server_port}'
        if (not self.local_request() or self.headers.get('Origin') != origin
                or self.headers.get('X-Registry-Studio') != 'sync'):
            return self.reply(403, {'error': 'Same-origin Studio request required'})
        if self.path != '/sync':
            return self.reply(404, {'error': 'Not found'})
        if not SYNC_LOCK.acquire(blocking=False):
            return self.reply(409, {'error': '更新中です。完了を待ってください。'})
        try:
            result = subprocess.run([sys.executable, str(APP / 'sync.py')], cwd=ROOT,
                                    capture_output=True, text=True, timeout=300)
            output = result.stdout + result.stderr
            self.reply(200 if result.returncode == 0 else 500,
                       {'ok': result.returncode == 0, 'output': output})
        except subprocess.TimeoutExpired:
            self.reply(504, {'error': '更新がタイムアウトしました。ターミナルで状態を確認してください。'})
        except OSError as error:
            self.reply(500, {'error': str(error)})
        finally:
            SYNC_LOCK.release()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8088)
    args = parser.parse_args()
    subprocess.run([sys.executable, str(APP / 'sync.py')], cwd=ROOT, check=True)
    server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
    print(f'Registry Studio: http://127.0.0.1:{args.port}/  (Ctrl+C to stop)', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
