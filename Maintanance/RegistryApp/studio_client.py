#!/usr/bin/env python3
"""OPS-156: the one HTTP client of the Studio command lines (approvals.py, comm.py). Only the server opens the database.

The server is http://127.0.0.1:8088 unless REGISTRY_STUDIO_URL names another local port (isolated tests). The URL is
parsed and must be exactly http://127.0.0.1:<port> (no user info, path, query or fragment); redirects are never followed,
so nothing is sent to another host. The headers (same Origin and the X-Registry-Studio value of the path) are the
server's same-origin guard; they are not authentication: anything on this machine can send them, so a record made
through them is a local self-report of the named member.

Two failures are told apart (H22 相当):
- not sent: the connection could not be opened, so nothing reached the server and nothing was recorded;
- result unknown: the request was sent but no answer came back, so it may or may not have been stored. Check with
  `list` before sending again (a PING resent with the same operation ID is safe; an ACK resent becomes a duplicate).
Nothing is ever written anywhere else instead.
"""
import http.client
import json
import os
import socket
import urllib.parse

DEFAULT_URL = 'http://127.0.0.1:8088'


class StudioError(RuntimeError):
    """`outcome` is 'refused' (the server answered with an error), 'not-sent' or 'unknown'."""
    def __init__(self, message, outcome):
        super().__init__(message)
        self.outcome = outcome


def server_address():
    raw = os.environ.get('REGISTRY_STUDIO_URL', DEFAULT_URL)
    try:
        url = urllib.parse.urlsplit(raw)
        port = url.port
    except ValueError:
        port, url = None, None
    if (url is None or url.scheme != 'http' or url.hostname != '127.0.0.1' or url.username is not None or url.password is not None
            or port is None or url.netloc != f'127.0.0.1:{port}' or url.path not in ('', '/') or url.query or url.fragment):
        raise StudioError('REGISTRY_STUDIO_URL must be exactly http://127.0.0.1:<port>; nothing was sent', 'not-sent')
    return port


def _call(method, path, action=None, body=None, timeout=15):
    port = server_address()
    origin = f'http://127.0.0.1:{port}'
    headers = {'Accept': 'application/json', 'Host': f'127.0.0.1:{port}'}
    data = None
    if method == 'POST':
        data = json.dumps(body, ensure_ascii=False).encode('utf-8')
        headers |= {'Content-Type': 'application/json', 'Origin': origin, 'X-Registry-Studio': action}
    connection = http.client.HTTPConnection('127.0.0.1', port, timeout=timeout)
    try:
        try:
            connection.connect()
        except OSError as error:
            raise StudioError(f'Studio server not reachable at {origin}; nothing was sent or recorded ({error})', 'not-sent') from None
        try:
            connection.request(method, path, body=data, headers=headers)
            response = connection.getresponse()
            raw = response.read()
        except (OSError, http.client.HTTPException) as error:
            raise StudioError(f'The request reached {origin} but no answer came back; the result is unknown — it may have been '
                              f'recorded. Check the list before sending again ({error.__class__.__name__})', 'unknown') from None
    finally:
        connection.close()
    if 300 <= response.status < 400:
        raise StudioError(f'Studio server answered with a redirect ({response.status}); it was not followed', 'refused')
    try:
        value = json.loads(raw.decode('utf-8'))
    except (ValueError, UnicodeDecodeError):
        raise StudioError(f'Studio server answered {response.status} without JSON', 'refused' if response.status >= 400 else 'unknown') from None
    if response.status >= 400:
        raise StudioError(f'Studio server refused ({response.status}): {value.get("error", "") if isinstance(value, dict) else ""}', 'refused')
    return value


def post(path, action, body):
    return _call('POST', path, action, body)


def get(path):
    return _call('GET', path)
