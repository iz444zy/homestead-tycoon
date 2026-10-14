"""Persist the inventory workshop, retaining embedded source CSG geometry."""
import base64, copy, json, struct, uuid
import xml.etree.ElementTree as ET
from pathlib import Path
ROOT = Path(__file__).resolve().parent
path = ROOT / 'build/AssetWorkshop.rbxlx'
tree = ET.parse(path)
root = tree.getroot()
def name(n): return n.find('./Properties/string[@name="Name"]').text
def child(n, wanted): return next(x for x in n.findall('Item') if name(x)==wanted)
def source(path):
    node=root
    for segment in path.removeprefix('game.').split('.'): node=child(node,segment)
    return node
keys={'CoordinateFrame':['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'], 'Vector3':['X','Y','Z'],'Vector2':['X','Y'],'Color3':['R','G','B'],'UDim2':['XS','XO','YS','YO']}
def prop(ps,tag,key,value):
    for p in list(ps):
        if p.get('name')==key: ps.remove(p)
    p=ET.SubElement(ps,tag,name=key)
    if tag in keys:
        for k,v in zip(keys[tag],value): ET.SubElement(p,k).text=str(v)
    else: p.text=str(value).lower() if isinstance(value,bool) else str(value)
def attributes(values):
    values = values or {}
    def string(s):
        b=s.encode();return struct.pack('<I',len(b))+b
    b=struct.pack('<I',len(values))
    for k,v in values.items():
        b+=string(k)
        if isinstance(v,str): b+=bytes([2])+string(v)
        elif isinstance(v,bool): b+=bytes([3,int(v)])
        else: b+=bytes([6])+struct.pack('<d',v)
    return base64.b64encode(b).decode()
data=json.loads((ROOT/'build/inventory-workshop-snapshot.json').read_text(encoding='utf-8'))
refs={}
def allocate(s):
    refs[s['id']]='RBX'+uuid.uuid4().hex.upper()
    for c in s['children']: allocate(c)
for s in data: allocate(s)
def build(s):
    n=ET.Element('Item',{'class':s['class'],'referent':refs[s['id']]})
    ps=copy.deepcopy(source(s['attributes']['MeshSource']).find('Properties')) if s['class']=='UnionOperation' else ET.Element('Properties')
    n.append(ps)
    for p in list(ps):
        if p.tag=='UniqueId':ps.remove(p)
    prop(ps,'string','Name',s['name']);prop(ps,'BinaryString','AttributesSerialize',attributes(s['attributes']))
    for k,(tag,value) in (s['props'] or {}).items():
        if tag=='Ref': value=refs.get(value,'null')
        if k=='Color':
            tag,k,value='Color3uint8','Color3uint8',0xff000000+sum(round(v*255)<<shift for v,shift in zip(value,[16,8,0]))
        prop(ps,tag,k,value)
    for c in s['children']: n.append(build(c))
    return n
parents=[source('ReplicatedStorage.AssetLibrary'),source('Workspace'),source('ServerScriptService')]
for parent,s in zip(parents,data):
    for old in list(parent.findall('Item')):
        if name(old)==s['name']:parent.remove(old)
    parent.append(build(s))
server=source('ServerStorage')
for old in list(server.findall('Item')):
    if name(old)=='InventoryWorkshopBuilder':server.remove(old)
builder=ET.SubElement(server,'Item',{'class':'ModuleScript','referent':'RBX'+uuid.uuid4().hex.upper()})
ps=ET.SubElement(builder,'Properties');prop(ps,'string','Name','InventoryWorkshopBuilder');prop(ps,'ProtectedString','Source',(ROOT/'src/InventoryWorkshop.luau').read_text())
tree.write(path,encoding='utf-8',xml_declaration=True)
pack=ET.Element('roblox',{'version':'4'})
pack.append(copy.deepcopy(child(parents[0],'InventoryItems')))
shared=root.find('SharedStrings')
if shared is not None:pack.append(copy.deepcopy(shared))
ET.ElementTree(pack).write(ROOT/'build/InventoryItems.rbxmx',encoding='utf-8',xml_declaration=True)
assert len(child(parents[0],'InventoryItems').findall('Item'))==18
print('Saved 18 Tools, display, demo, builder, and standalone InventoryItems.rbxmx with embedded geometry.')
