"""Authenticated HTTP adapter for a local ClamAV Unix socket. Expose through HTTPS only."""
from datetime import datetime, timezone
import hashlib
import hmac
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
import re
import socket
import struct
import threading

LIMIT = 5242880
SLOTS = threading.BoundedSemaphore(2)


def clamd(command, data=None, socket_path=None):
    path = socket_path or os.environ.get('CLAMD_SOCKET', '/run/clamav/clamd.sock')
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(15)
        client.connect(path)
        client.sendall(b'z' + command + b'\0')
        if data is not None:
            for start in range(0, len(data), 65536):
                chunk = data[start:start + 65536]
                client.sendall(struct.pack('>I', len(chunk)) + chunk)
            client.sendall(struct.pack('>I', 0))
        result = bytearray()
        while not result.endswith(b'\0'):
            chunk = client.recv(1024)
            if not chunk or len(result) + len(chunk) > 2048:
                raise ValueError('invalid_clamd_response')
            result.extend(chunk)
        return result[:-1].decode('ascii', 'strict')


def engine_version(version, now=None):
    match = re.fullmatch(r'ClamAV ([A-Za-z0-9.+_-]+)/([0-9]+)/(.+)', version)
    if not match:
        raise ValueError('invalid_clamd_version')
    date = datetime.strptime(match[3], '%a %b %d %H:%M:%S %Y').replace(tzinfo=timezone.utc)
    age = ((now or datetime.now(timezone.utc)) - date).total_seconds()
    if not -3600 <= age <= 48 * 3600:
        raise ValueError('clamd_database_stale')
    return f'ClamAV {match[1]}/{match[2]}'


def scan(data):
    if not 1 <= len(data) <= LIMIT:
        raise ValueError('invalid_size')
    engine = engine_version(clamd(b'VERSION'))
    verdict = clamd(b'INSTREAM', data)
    if verdict == 'stream: OK':
        status = 'CLEAN'
    elif re.fullmatch(r'stream: [\x20-\x7e]{1,180} FOUND', verdict):
        # Includes heuristic encrypted/limit findings when the supplied ClamAV configuration is used.
        status = 'INFECTED'
    else:
        raise ValueError('clamd_scan_failed')
    return {'status': status, 'engine': engine, 'sha256': hashlib.sha256(data).hexdigest()}


class Handler(BaseHTTPRequestHandler):
    def setup(self):
        super().setup()
        self.connection.settimeout(20)

    def log_message(self, *args):
        pass  # Never log file bytes, credentials, request headers or provider responses.

    def reply(self, code, result):
        self.close_connection = True
        body = json.dumps(result).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Connection', 'close')
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        expected = self.server.scan_token
        supplied = self.headers.get('Authorization', '')
        if not re.fullmatch(r'Bearer [A-Za-z0-9_-]{80,200}', supplied) or not hmac.compare_digest(supplied, 'Bearer ' + expected):
            return self.reply(401, {'error': 'authentication_required'})
        length = self.headers.get('Content-Length', '')
        if self.path != '/v1/scan' or self.headers.get('Transfer-Encoding') is not None or not re.fullmatch(r'[0-9]{1,8}', length) or not 1 <= int(length) <= LIMIT:
            return self.reply(422, {'error': 'invalid_request'})
        if not SLOTS.acquire(blocking=False):
            return self.reply(503, {'error': 'scanner_busy'})
        try:
            data = self.rfile.read(int(length))
            if len(data) != int(length):
                return self.reply(422, {'error': 'incomplete_body'})
            return self.reply(200, scan(data))
        except (OSError, ValueError, UnicodeError):
            return self.reply(503, {'error': 'scanner_unavailable'})
        finally:
            SLOTS.release()


if __name__ == '__main__':
    token = os.environ.get('MBN_SCANNER_TOKEN', '')
    if not re.fullmatch(r'[A-Za-z0-9_-]{80,200}', token):
        raise SystemExit('Set a random MBN_SCANNER_TOKEN of 80 to 200 base64url characters')
    server = ThreadingHTTPServer(('127.0.0.1', 8080), Handler)
    server.scan_token = token
    server.serve_forever()
