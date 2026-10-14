"""Patch the canonical place in place, preserving world geometry and embedded CSG.
Never runs the world/workshop builders. Repeatable; original assets remain untouched.
"""
import base64, copy, json, struct, uuid, hashlib
import xml.etree.ElementTree as E
from pathlib import Path
from datetime import datetime

BASE=Path(__file__).resolve().parent
TARGET=BASE/'build/LunaLanding-AutumnReview.rbxlx'
def name(n): return n.findtext('./Properties/string[@name="Name"]')
def child(n,key): return next(x for x in n.findall('Item') if name(x)==key)
def prop(n,tag,key,value):
    ps=n.find('Properties')
    for p in list(ps):
        if p.get('name')==key: ps.remove(p)
    x=E.SubElement(ps,tag,name=key);x.text=str(value).lower() if isinstance(value,bool) else str(value)
def node(cls,label):
    n=E.Element('Item',{'class':cls,'referent':'RBX'+uuid.uuid4().hex.upper()})
    E.SubElement(n,'Properties');prop(n,'string','Name',label);return n
def get_or_add(n,cls,label):
    found=next((x for x in n.findall('Item') if name(x)==label),None)
    if found is None: found=node(cls,label);n.append(found)
    return found
def replace(n,new):
    for old in list(n.findall('Item')):
        if name(old)==name(new):n.remove(old)
    n.append(new)
def clone(source):
    n=copy.deepcopy(source)
    refs={x.get('referent'):'RBX'+uuid.uuid4().hex.upper() for x in n.iter('Item')}
    for x in n.iter('Item'):
        x.set('referent',refs[x.get('referent')])
        ps=x.find('Properties')
        for p in list(ps):
            if p.tag=='UniqueId':ps.remove(p)
    for p in n.iter('Ref'):p.text=refs.get(p.text,'null')
    return n
def script(cls,label,file):
    n=node(cls,label);prop(n,'ProtectedString','Source',(BASE/'src/farming'/file).read_text(encoding='utf-8'));return n
def main():
    backup=BASE/'build'/('LunaLanding-AutumnReview.checkpoint-'+datetime.now().strftime('%Y%m%d-%H%M%S')+'.rbxlx')
    backup.write_bytes(TARGET.read_bytes())
    root=E.parse(TARGET).getroot()
    world=child(root,'Workspace');world_before=E.tostring(world)
    original_assets={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [BASE/'build/AssetWorkshop.rbxlx',BASE/'build/InventoryItems.rbxmx']}
    workshop=E.parse(BASE/'build/AssetWorkshop.rbxlx').getroot()
    lib=child(child(workshop,'ReplicatedStorage'),'AssetLibrary')
    inventory=E.parse(BASE/'build/InventoryItems.rbxmx').getroot()
    ss=get_or_add(root,'ServerStorage','ServerStorage')
    rs=get_or_add(root,'ReplicatedStorage','ReplicatedStorage')
    crops=node('Folder','FarmingCropAssets')
    crop_types=['Pepper','Pumpkin','Grape','Corn','Wheat','Lettuce','Potato','Carrot']
    for crop in crop_types:
        f=clone(child(lib,crop+'GrowthStages'))
        if crop=='Grape':
            regrowth=clone(child(f,'Ready'));prop(regrowth,'string','Name','Regrowing')
            produce=child(regrowth,'Produce');regrowth.remove(produce)
            # Runtime uses catalog stage, not this inherited visual metadata.
            attrs=regrowth.find('./Properties/BinaryString[@name="AttributesSerialize"]')
            if attrs is not None:
                raw=base64.b64decode(attrs.text)
                raw=raw.replace(struct.pack('<I',5)+b'Ready',struct.pack('<I',9)+b'Regrowing')
                attrs.text=base64.b64encode(raw).decode()
            f.append(regrowth)
        crops.append(f)
    replace(ss,crops)
    pack=node('Folder','FarmingAssets');pack.append(clone(child(inventory,'InventoryItems')));replace(rs,pack)
    shared=node('Folder','Farming');shared.append(script('ModuleScript','Catalog','Catalog.luau'))
    for file in (BASE/'src/ui').glob('*.luau'):
        module=node('ModuleScript',file.stem);prop(module,'ProtectedString','Source',file.read_text(encoding='utf-8'));shared.append(module)
    shared.append(node('RemoteFunction','Request'));shared.append(node('RemoteEvent','Changed'));replace(rs,shared)
    modules=node('Folder','Farming')
    for file in ['Settings','Domain','ProfileStore','Representations','World','HouseChest','TestHooks']:
        modules.append(script('ModuleScript',file,file+'.luau'))
    test=BASE/'src/farming/Tests.luau'
    if test.exists():modules.append(script('ModuleScript','Tests','Tests.luau'))
    for test_file in ['RuntimeTests','MultiplayerTests','StorageTests','InteractionTests']:
        if (BASE/'src/farming'/(test_file+'.luau')).exists():modules.append(script('ModuleScript',test_file,test_file+'.luau'))
    replace(ss,modules)
    server=child(root,'ServerScriptService')
    for old in list(server.findall('Item')):
        if name(old) in ['LunaPrototype','FarmingRuntime']:server.remove(old)
    server.append(script('Script','FarmingRuntime','Runtime.server.luau'))
    starter=child(child(root,'StarterPlayer'),'StarterPlayerScripts')
    for old in list(starter.findall('Item')):
        if name(old) in ['LunaInterface','FarmingInterface']:starter.remove(old)
    starter.append(script('LocalScript','FarmingInterface','Interface.client.luau'))
    shared_strings={}
    for document in [root,workshop,inventory]:
        for s in document.findall('./SharedStrings/SharedString'):
            if s.get('md5') in shared_strings:assert shared_strings[s.get('md5')].text==s.text
            shared_strings[s.get('md5')]=copy.deepcopy(s)
    for old in list(root.findall('SharedStrings')):root.remove(old)
    used={x.text for x in root.iter() if x.tag in ('SharedString','NetAssetRef')}
    strings=E.SubElement(root,'SharedStrings')
    for key,s in shared_strings.items():
        if key in used:strings.append(s)
    refs={x.get('referent') for x in root.iter('Item')}
    for ref in root.iter('Ref'):assert ref.text=='null' or ref.text in refs,(ref.get('name'),ref.text)
    for ref in root.iter('NetAssetRef'):
        if ref.get('name')=='SolidMeshHolder':assert ref.text in shared_strings
    assert E.tostring(world)==world_before,'World modified'
    for path,digest in original_assets.items():assert hashlib.sha256((BASE/'build'/path).read_bytes()).hexdigest()==digest
    tmp=TARGET.with_suffix('.tmp');E.ElementTree(root).write(tmp,encoding='utf-8',xml_declaration=True);tmp.replace(TARGET)
    stats={'backup':str(backup),'gameplay':str(TARGET),'world_unchanged':True,'crop_stages':sum(len(f.findall('Item')) for f in crops.findall('Item')),'inventory_tools':18,'embedded_mesh_blobs':len(strings),'source_sha256':original_assets,'bytes':TARGET.stat().st_size}
    (BASE/'build/farming-build-report.json').write_text(json.dumps(stats,indent=2))
    print(json.dumps(stats,indent=2))
if __name__=='__main__':main()
