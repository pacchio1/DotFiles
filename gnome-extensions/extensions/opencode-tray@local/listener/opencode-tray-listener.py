#!/usr/bin/env python3
"""
Listener bridge per opencode-tray su Linux.
Ascolta su 127.0.0.1:47110 (o OPENCODE_TRAY_PORT) i POST del plugin
opencode-tray.js e scrive lo stato in /tmp/opencode-tray-state.json.

Non tocca la logica del plugin: il plugin continua a inviare POST
esattamente come su Windows.
"""
import os, sys, json, http.server, socketserver, threading

PORT = int(os.getenv("OPENCODE_TRAY_PORT", "47110"))
OUT = "/tmp/opencode-tray-state.json"

class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        # silenzioso per non disturbare
        pass

    def do_POST(self):
        try:
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length) if length > 0 else b"{}"
            data = json.loads(body)
            # Scrittura atomica
            tmp = OUT + ".tmp"
            with open(tmp, "w") as f:
                f.write(json.dumps(data, ensure_ascii=False))
            os.rename(tmp, OUT)
            # Risposta OK (il plugin ignora la risposta)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"{\"ok\":true}")
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode())

    def do_GET(self):
        # Per debug / verifica
        self.send_response(200)
        self.end_headers()
        try:
            with open(OUT) as f:
                self.wfile.write(f.read().encode())
        except:
            self.wfile.write(b"{}")

def main():
    with ReusableTCPServer(("127.0.0.1", PORT), Handler) as httpd:
        print(f"opencode-tray-listener: 127.0.0.1:{PORT} -> {OUT}", file=sys.stderr)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass

if __name__ == "__main__":
    main()
