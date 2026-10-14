"""Save an Edit-mode pepper snapshot using AssetWorkshop's embedded geometry.

Run after exporting build/pepper-workshop-snapshot.json from Studio. This keeps
the live arrangement, including manually moved studies. No asset upload occurs.
"""
import base64
import copy
import json
import struct
import uuid
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
path = ROOT / 'build/AssetWorkshop.rbxlx'
tree = ET.parse(path)
root = tree.getroot()
data = json.loads((ROOT / 'build/pepper-workshop-snapshot.json').read_text())

def name(node):
    return node.find('./Properties/string[@name="Name"]').text

def child(node, wanted):
    return next(n for n in node.findall('Item') if name(n) == wanted)

workspace = next(n for n in root.findall('Item') if n.get('class') == 'Workspace')
replicated = next(n for n in root.findall('Item') if n.get('class') == 'ReplicatedStorage')
library = child(replicated, 'AssetLibrary')
templates = {name(n): n for n in child(library, 'PepperMeshTemplates').findall('Item')}
part_template = child(workspace, 'WorkshopGround')
class_templates = {cls:next(n for n in root.iter('Item') if n.get('class')==cls) for cls in ('SurfaceGui','TextLabel')}

def prop(properties, tag, key, value):
    old = next((n for n in properties if n.get('name') == key), None)
    if old is not None: properties.remove(old)
    p = ET.SubElement(properties, tag, name=key)
    if tag in ('CoordinateFrame', 'Vector3','Vector2','UDim2','Color3'):
        keys = {'CoordinateFrame':['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'],'Vector3':['X','Y','Z'],'Vector2':['X','Y'],'UDim2':['XS','XO','YS','YO'],'Color3':['R','G','B']}[tag]
        for k,v in zip(keys,value): ET.SubElement(p,k).text = str(v)
    else: p.text = str(value).lower() if isinstance(value,bool) else str(value)
    return p

def attributes(values):
    values = values or {}
    result = struct.pack('<I',len(values))
    def string(s):
        b=s.encode(); return struct.pack('<I',len(b))+b
    for k,v in values.items():
        result += string(k)
        if isinstance(v,str): result += bytes([2])+string(v)
        elif isinstance(v,bool): result += bytes([3,int(v)])
        else: result += bytes([6])+struct.pack('<d',v)
    return base64.b64encode(result).decode()

def build(s):
    node = ET.Element('Item',{'class':s['class'],'referent':'RBX'+uuid.uuid4().hex.upper()})
    if s['class'] == 'UnionOperation': props=copy.deepcopy(templates[s['name']].find('Properties'))
    elif s['class'] == 'Part': props=copy.deepcopy(part_template.find('Properties'))
    elif s['class'] in class_templates: props=copy.deepcopy(class_templates[s['class']].find('Properties'))
    else: props=ET.Element('Properties')
    node.append(props)
    for p in list(props):
        if p.tag=='UniqueId': props.remove(p)
    prop(props,'string','Name',s['name'])
    prop(props,'BinaryString','AttributesSerialize',attributes(s['attributes']))
    if 'text' in s:
        prop(props,'string','Text',s['text'])
        prop(props,'float','TextSize',s['textsize'])
        prop(props,'token','Font',s['font'])
        prop(props,'Color3','TextColor3',s['textcolor'])
        prop(props,'UDim2','Size',s['uisize'])
        prop(props,'UDim2','Position',s['uipos'])
    if 'face' in s:
        prop(props,'token','Face',s['face'])
        prop(props,'Vector2','CanvasSize',s['canvas'])
    if 'cf' in s:
        prop(props,'CoordinateFrame','CFrame',s['cf'])
        prop(props,'Vector3','size',s['size'])
        rgb=[round(v*255) for v in s['color']]
        prop(props,'Color3uint8','Color3uint8',0xff000000+(rgb[0]<<16)+(rgb[1]<<8)+rgb[2])
        prop(props,'token','Material',s['material'])
        for k,v in [('Anchored',True),('CanCollide',False),('CanTouch',False),('CanQuery',False),('Locked',False)]: prop(props,'bool',k,v)
    if 'pivot' in s:
        p=ET.SubElement(props,'OptionalCoordinateFrame',name='WorldPivotData')
        cf=ET.SubElement(p,'CFrame')
        for k,v in zip(['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'],s['pivot']): ET.SubElement(cf,k).text=str(v)
    for c in s['children']: node.append(build(c))
    return node

stages=child(library,'PepperGrowthStages')
for n in list(stages.findall('Item')): stages.remove(n)
for s in data['library']: stages.append(build(s))
display=child(workspace,'PepperWorkshop')
for study in list(display.findall('Item')): display.remove(study)
for s in data['display']: display.append(build(s))
server=next(n for n in root.findall('Item') if n.get('class')=='ServerStorage')
for n in list(server.findall('Item')):
    if name(n)=='PersistenceProbe': server.remove(n)
source=child(server,'PepperWorkshopBuilder').find('./Properties/ProtectedString[@name="Source"]')
source.text=(ROOT/'src/PepperWorkshop.luau').read_text(encoding='utf-8')
assert len(child(child(stages,'Ready'),'Fruit').findall('Item'))==5
shared={n.get('md5'):base64.b64decode(n.text or '') for n in root.findall('./SharedStrings/SharedString')}
for n in root.iter('NetAssetRef'):
    if n.get('name')=='SolidMeshHolder': assert len(shared[n.text])>100
tree.write(path,encoding='utf-8',xml_declaration=True)
print('Saved five ripe peppers, taller support stakes, current source, and verified embedded geometry.')
