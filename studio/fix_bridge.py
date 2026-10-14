from http.server import HTTPServer,BaseHTTPRequestHandler
from pathlib import Path
import json
root=Path(__file__).resolve().parent
class H(BaseHTTPRequestHandler):
 def do_GET(self):
  p=root/self.path.lstrip('/')
  data=p.read_bytes(); self.send_response(200); self.end_headers(); self.wfile.write(data)
 def do_POST(self):
  data=self.rfile.read(int(self.headers['Content-Length'])); (root/'build'/self.path.lstrip('/')).write_bytes(data); self.send_response(200); self.end_headers(); self.wfile.write(b'ok')
HTTPServer(('127.0.0.1',8771),H).serve_forever()
