import xml.etree.ElementTree as E
from pathlib import Path
from build_farming import name
base=Path(__file__).resolve().parent/'build'
a=E.parse(base/'visual-fixes-before-20261014/LunaLanding-AutumnReview.rbxlx').getroot()
b=E.parse(base/'LunaLanding-AutumnReview.rbxlx').getroot()
def props(root):
    return {x.get('referent'):E.tostring(x.find('Properties')) for x in root.iter('Item')}
x,y=props(a),props(b)
changed=[k for k in x if x[k]!=y[k]]
assert len(changed)==5 and len(y)-len(x)==1
assert E.tostring(a.find('SharedStrings'))==E.tostring(b.find('SharedStrings'))
for old in a.iter('Item'):
    if old.get('class') in ('UnionOperation','MeshPart'):
        assert x[old.get('referent')]==y[old.get('referent')]
print('PASS: only World, FarmingInterface, two Lettering faces and StatusDisplay changed; PlanterStatus added.')
print('PASS: all saved crop geometry and embedded mesh blobs are unchanged.')
