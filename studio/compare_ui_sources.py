import json,difflib
from ui_sync import ROOT,bundle
sources=bundle()
live=json.loads((ROOT/'build/ui-live-before-20261014.json').read_text())
for s in live['Scripts']:
    current=s['Source'].replace('\r\n','\n')
    local=sources.get(s['Path'])
    if local is not None and current!=local:
        print('\nLIVE / SOURCE:',s['Path'])
        print(''.join(difflib.unified_diff(local.splitlines(True),current.splitlines(True),fromfile='source',tofile='live')))
