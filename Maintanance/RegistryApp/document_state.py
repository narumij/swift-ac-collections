"""Observable, safely-scoped view of one canonical Markdown document."""
import hashlib
import os
from pathlib import Path
import threading

from task_state import TaskStateBinding
from work_notifications import Changes, FileObserver


class DocumentStateBinding:
    """Render a Markdown file when its vnode changes and publish useful state."""

    def __init__(self, root, path, render):
        self.root = Path(root).resolve(strict=True)
        if not self.root.is_dir():
            raise ValueError('Document root must be a directory')
        self.path = self._validate_relative(path)
        if not callable(render):
            raise TypeError('render must be callable')
        self._render = render
        self._lock = threading.Lock()
        self._last_stamp = None
        self._last_html = ''
        target = self._resolve()
        self._changes = Changes()
        self._observer = FileObserver(target, self._changes)
        try:
            self._binding = TaskStateBinding(self._changes, self._read_document)
            self.model = self._binding.model
        except Exception:
            self._observer.close()
            raise

    def _validate_relative(self, path):
        if not isinstance(path, str) or not path or '\x00' in path:
            raise ValueError('Document path must be a relative Markdown path')
        candidate = Path(path)
        if candidate.is_absolute() or candidate.suffix.lower() != '.md':
            raise ValueError('Document path must be a relative Markdown path')
        if any(part.startswith('.') for part in candidate.parts if part not in ('.', '..')):
            raise ValueError('Hidden document paths are not allowed')
        return candidate

    def _resolve(self):
        target = (self.root / self.path).resolve(strict=False)
        try:
            target.relative_to(self.root)
        except ValueError:
            raise ValueError('Document path escapes the document root')
        if any(part.startswith('.') for part in target.relative_to(self.root).parts):
            raise ValueError('Hidden document paths are not allowed')
        return target

    def _read_document(self):
        with self._lock:
            target = self._resolve()
            try:
                fd = os.open(target, os.O_RDONLY)
            except FileNotFoundError:
                self._last_stamp = None
                self._last_html = ''
                return {'path': self.path.as_posix(), 'html': '', 'stamp': '',
                        'status': 'missing', 'message': '正本が見つかりません。再作成されると自動で表示します。'}
            try:
                opened = os.fstat(fd)
                current = self._resolve()
                current_stat = current.stat()
                if current != target or (opened.st_dev, opened.st_ino) != (current_stat.st_dev, current_stat.st_ino):
                    raise ValueError('Document changed while opening')
                chunks = []
                while True:
                    chunk = os.read(fd, 65536)
                    if not chunk:
                        break
                    chunks.append(chunk)
            finally:
                os.close(fd)
            raw = b''.join(chunks)
            stamp = hashlib.sha256(raw).hexdigest()
            if stamp != self._last_stamp:
                rendered = self._render(raw.decode('utf-8'))
                if not isinstance(rendered, str):
                    raise ValueError('Document renderer must return text')
                self._last_stamp, self._last_html = stamp, rendered
            return {'path': self.path.as_posix(), 'html': self._last_html,
                    'stamp': stamp, 'status': 'ready', 'message': ''}

    def close(self):
        self._binding.close()
        self._observer.close()

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()
