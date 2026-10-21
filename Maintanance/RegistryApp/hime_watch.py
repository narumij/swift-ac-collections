#!/usr/bin/env python3
"""Hime's timed TL reader: unread text first, then live text, then return to thinking.
Does not start a server. The running Studio server owns the text log.
"""
import argparse
import fcntl
import math
import os
from pathlib import Path
import sys
import time

DEFAULT_LOG = Path(__file__).resolve().parents[1] / 'Cache/RegistryStudio/notifications.log'


def watch(path, cursor, seconds, output=sys.stdout):
    path, cursor = Path(path), Path(cursor)
    if path.resolve() == cursor.resolve():
        raise ValueError('ログと既読位置は別のファイルを指定してください。')
    if not path.is_file():
        raise ValueError('TLログがありません。新しいコードでStudioを起動してください。')
    cursor.parent.mkdir(parents=True, exist_ok=True)
    with Path(str(cursor) + '.lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise ValueError('姫用の閲覧コマンドは既に実行中です。') from None
        with path.open('rb') as stream:
            stat = os.fstat(stream.fileno())
            identity = f'{stat.st_dev}:{stat.st_ino}'
            offset = 0
            if cursor.exists():
                previous, number = cursor.read_text().strip().split()
                if previous == identity:
                    offset = int(number)
                    if offset < 0:
                        raise ValueError('既読位置が不正です。')
                    if offset > stat.st_size:
                        offset = 0
            stream.seek(offset)

            def drain(limit=None, deadline=None):
                while limit is None or stream.tell() < limit:
                    if deadline is not None and time.monotonic() >= deadline:
                        return
                    start = stream.tell()
                    line = stream.readline()
                    if not line or not line.endswith(b'\n'):
                        stream.seek(start)
                        return
                    output.write(line.decode('utf-8'))
                    output.flush()
                    temporary = Path(str(cursor) + '.tmp')
                    temporary.write_text(f'{identity} {stream.tell()}\n')
                    temporary.replace(cursor)

            # All unread text present at entry is shown before the observation timer.
            drain(stat.st_size)
            deadline = time.monotonic() + seconds
            while time.monotonic() < deadline:
                # Bound each pass so a busy producer cannot prevent the timer ending.
                drain(os.fstat(stream.fileno()).st_size, deadline)
                time.sleep(min(.1, max(0, deadline - time.monotonic())))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seconds', type=float, default=30, help='未読表示後の観察時間（秒、既定30）')
    parser.add_argument('--log', type=Path, default=DEFAULT_LOG)
    parser.add_argument('--cursor', type=Path, help='姫の既読位置（既定はログの隣）')
    args = parser.parse_args()
    if not math.isfinite(args.seconds) or args.seconds <= 0:
        parser.error('--seconds must be finite and positive')
    cursor = args.cursor or args.log.with_name('hime-read.offset')
    try:
        watch(args.log, cursor, args.seconds)
    except KeyboardInterrupt:
        return 0
    except (OSError, ValueError) as error:
        print(f'閲覧できません: {error}', file=sys.stderr)
        return 1
    print('観察時間が終了しました。要求に対して何が進み、何が止まっているかを考えて報告してください。\n再実行すると、その間の未読ログから表示します。', file=sys.stderr)
    return 0


if __name__ == '__main__':
    sys.exit(main())
