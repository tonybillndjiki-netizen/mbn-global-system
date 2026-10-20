import importlib.util
from datetime import datetime, timezone, timedelta
import hashlib
from io import BytesIO
from pathlib import Path
import socket
import struct
import tempfile
import threading
import unittest
from types import SimpleNamespace
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('mbn_scanner', Path(__file__).resolve().parents[1] / 'scanner/server.py')
scanner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scanner)


class ScannerAdapter(unittest.TestCase):
    def test_http_authentication_and_size_are_checked_before_reading_private_bytes(self):
        for authorization, length, expected in [('Bearer invalid', '9', 401), ('Bearer é', '9', 401), ('Bearer ' + 't' * 90, '5242881', 422)]:
            handler = scanner.Handler.__new__(scanner.Handler)
            handler.server = SimpleNamespace(scan_token='t' * 90)
            handler.headers = {'Authorization': authorization, 'Content-Length': length}
            handler.path = '/v1/scan'
            handler.rfile = BytesIO(b'synthetic')
            replies = []
            handler.reply = lambda code, result: replies.append((code, result))
            handler.do_POST()
            self.assertEqual(replies[0][0], expected)
            self.assertEqual(handler.rfile.tell(), 0)

    def test_only_an_explicit_clean_daemon_reply_is_clean(self):
        version = 'ClamAV 1.0.0/123/' + datetime.now(timezone.utc).strftime('%a %b %d %H:%M:%S %Y')
        for reply, expected in [('stream: OK', 'CLEAN'), ('stream: Synthetic-Test FOUND', 'INFECTED')]:
            with self.subTest(reply=reply), patch.object(scanner, 'clamd', side_effect=[version, reply]):
                result = scanner.scan(b'synthetic')
                self.assertEqual(result['status'], expected)
                self.assertEqual(result['sha256'], hashlib.sha256(b'synthetic').hexdigest())
        for reply in ['stream: timeout ERROR', 'INSTREAM size limit exceeded. ERROR', 'OK', 'stream: OK\nextra']:
            with self.subTest(reply=reply), patch.object(scanner, 'clamd', side_effect=[version, reply]), self.assertRaises(ValueError):
                scanner.scan(b'synthetic')

    def test_stale_or_unrecognized_signature_database_blocks_scanning(self):
        now = datetime(2026, 10, 20, tzinfo=timezone.utc)
        for date in [now - timedelta(hours=49), now + timedelta(hours=2)]:
            with self.assertRaises(ValueError):
                scanner.engine_version('ClamAV 1.0.0/123/' + date.strftime('%a %b %d %H:%M:%S %Y'), now)
        with self.assertRaises(ValueError):
            scanner.engine_version('unrecognized', now)

    def test_instream_really_sends_length_prefixed_bytes_over_a_local_socket(self):
        received = []
        def exact(connection, size):
            data = bytearray()
            while len(data) < size:
                block = connection.recv(size - len(data))
                if not block:
                    raise ValueError('incomplete_test_stream')
                data.extend(block)
            return bytes(data)
        with tempfile.TemporaryDirectory() as directory:
            path = str(Path(directory) / 'clamd.sock')
            try:
                listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            except PermissionError:
                self.skipTest('Unix sockets are unavailable in this runtime; CI executes this integration test')
            listener.bind(path)
            listener.listen(1)
            def daemon():
                with listener.accept()[0] as connection:
                    received.append(exact(connection, len(b'zINSTREAM\0')))
                    data = bytearray()
                    while True:
                        length = struct.unpack('>I', exact(connection, 4))[0]
                        if not length:
                            break
                        data.extend(exact(connection, length))
                    received.append(bytes(data))
                    connection.sendall(b'stream: OK\0')
            worker = threading.Thread(target=daemon, daemon=True)
            worker.start()
            try:
                payload = b'synthetic' * 10000
                self.assertEqual(scanner.clamd(b'INSTREAM', payload, path), 'stream: OK')
                worker.join(timeout=2)
                self.assertEqual(received, [b'zINSTREAM\0', payload])
            finally:
                listener.close()

    def test_instream_framing_and_fragmented_daemon_reply_without_network(self):
        class Connection:
            def __init__(self):
                self.sent = bytearray()
                self.responses = iter([b'stream:', b' O', b'K\0'])
            def __enter__(self):
                return self
            def __exit__(self, *args):
                pass
            def settimeout(self, value):
                self.timeout = value
            def connect(self, path):
                self.path = path
            def sendall(self, data):
                self.sent.extend(data)
            def recv(self, size):
                return next(self.responses, b'')
        connection = Connection()
        payload = b'synthetic' * 10000
        with patch.object(scanner.socket, 'socket', return_value=connection):
            self.assertEqual(scanner.clamd(b'INSTREAM', payload, '/private/clamd.sock'), 'stream: OK')
        self.assertEqual(connection.path, '/private/clamd.sock')
        wire = bytes(connection.sent)
        self.assertTrue(wire.startswith(b'zINSTREAM\0'))
        wire = wire[len(b'zINSTREAM\0'):]
        decoded = bytearray()
        while True:
            size = struct.unpack('>I', wire[:4])[0]
            wire = wire[4:]
            if size == 0:
                break
            decoded.extend(wire[:size])
            wire = wire[size:]
        self.assertEqual(decoded, payload)
        self.assertEqual(wire, b'')


if __name__ == '__main__':
    unittest.main()
