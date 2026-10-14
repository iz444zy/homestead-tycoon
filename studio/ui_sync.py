"""Local Studio source bridge and preflight. No world replacement or publishing."""
import json, pathlib, hashlib, shutil, datetime
import xml.etree.ElementTree as E
from http.server import HTTPServer, BaseHTTPRequestHandler
ROOT=pathlib.Path(__file__).resolve().parent
def bundle():
    out={}
    for p in (ROOT/'src/farming').glob('*.luau'):
        name=p.name
        target=('ServerScriptService.FarmingRuntime' if name=='Runtime.server.luau' else 'StarterPlayer.StarterPlayerScripts.FarmingInterface' if name=='Interface.client.luau' else 'ReplicatedStorage.Farming.Catalog' if name=='Catalog.luau' else 'ServerStorage.Farming.'+p.stem)
        out[target]=p.read_text(encoding='utf-8')
    for p in (ROOT/'src/ui').glob('*.luau'):out['ReplicatedStorage.Farming.'+p.stem]=p.read_text(encoding='utf-8')
    return out
def preflight():
    live=json.loads((ROOT/'build/ui-live-before-20261014.json').read_text())
    root=E.parse(ROOT/'build/LunaLanding-AutumnReview.rbxlx').getroot()
    disk={}
    def walk(n,path=''):
        name=n.findtext('./Properties/string[@name="Name"]')
        path=path+'.'+name if path else name or ''
        source=n.find('./Properties/ProtectedString[@name="Source"]')
        if source is not None:disk[path]=(source.text or '').replace('\r\n','\n')
        for c in n.findall('Item'):walk(c,path)
    walk(root)
    for s in live['Scripts']:
        print(s['Path'], 'MATCH' if disk.get(s['Path'])==s['Source'].replace('\r\n','\n') else 'DIFF')
    stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    dst=ROOT/'build'/('ui-checkpoint-'+stamp);dst.mkdir()
    shutil.copytree(ROOT/'src',dst/'src')
    shutil.copy2(ROOT/'build/LunaLanding-AutumnReview.rbxlx',dst/'LunaLanding-AutumnReview.rbxlx')
    print('Checkpoint',dst)
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        data=json.dumps(bundle()).encode() if self.path=='/bundle' else b'{}'
        self.send_response(200);self.end_headers();self.wfile.write(data)
    def do_POST(self):
        allowed={'/world':'ui-live-world-before.json','/evidence':'ui-verification.json'}
        if self.path not in allowed:self.send_error(404);return
        data=self.rfile.read(int(self.headers['Content-Length']))
        json.loads(data)
        (ROOT/'build'/allowed[self.path]).write_bytes(data)
        self.send_response(200);self.end_headers();self.wfile.write(b'ok')
if __name__=='__main__':
    import sys
    if '--serve' in sys.argv:HTTPServer(('127.0.0.1',8766),Handler).serve_forever()
    else:preflight()
