#!/usr/bin/env python3
"""Print live Studio notifications. Connects to an existing server; never starts one."""
import argparse
import sys
import urllib.error
import urllib.request


def display(stream, output):
    lines = []
    kind = ''
    for raw in stream:
        line = raw.decode('utf-8').rstrip('\r\n')
        if line.startswith('data:'):
            lines.append(line[5:].removeprefix(' '))
        elif line.startswith('event:'):
            kind = line[6:].strip()
        elif not line:
            if kind == 'overflow':
                raise RuntimeError('通知の受信が追いつかず切断されました。再接続してください。')
            if lines:
                print('\n'.join(lines), file=output, flush=True)
            lines, kind = [], ''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8088', help='既に起動しているStudioのURL')
    args = parser.parse_args()
    try:
        with urllib.request.urlopen(args.url.rstrip('/') + '/notifications/events', timeout=10) as response:
            if 'text/event-stream' not in response.headers.get('Content-Type', ''):
                raise RuntimeError('通知ストリームではない応答です。')
            print('通知を購読中（Ctrl+Cで終了）', file=sys.stderr, flush=True)
            display(response, sys.stdout)
        print('通知接続が終了しました。', file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 0
    except (OSError, urllib.error.URLError, RuntimeError) as error:
        print(f'通知を受信できません: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
