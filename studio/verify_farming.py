"""Read-only structural verification of the shipped farming place."""
import hashlib, json, re
import xml.etree.ElementTree as E
from pathlib import Path
from build_farming import name,child

BASE=Path(__file__).resolve().parent
def main():
    root=E.parse(BASE/'build/LunaLanding-AutumnReview.rbxlx').getroot()
    baseline=next((BASE/'build').glob('LunaLanding-AutumnReview.before-farming-*.rbxlx'))
    before=E.parse(baseline).getroot()
    assert E.tostring(child(root,'Workspace'))==E.tostring(child(before,'Workspace'))
    refs=[x.get('referent') for x in root.iter('Item')]
    assert len(set(refs))==len(refs)
    for x in root.iter('Ref'):assert x.text=='null' or x.text in refs
    blobs={x.get('md5') for x in root.findall('./SharedStrings/SharedString')}
    for x in root.iter('NetAssetRef'):
        if x.get('name')=='SolidMeshHolder':assert x.text in blobs
    rs=child(root,'ReplicatedStorage');ss=child(root,'ServerStorage')
    modules=child(ss,'Farming');catalog=child(child(rs,'Farming'),'Catalog')
    source=catalog.findtext('./Properties/ProtectedString[@name="Source"]')
    assert source==(BASE/'src/farming/Catalog.luau').read_text(encoding='utf-8')
    for n in modules.findall('Item'):
        assert n.findtext('./Properties/ProtectedString[@name="Source"]')==(BASE/'src/farming'/(name(n)+'.luau')).read_text(encoding='utf-8')
    for parent,label,file in [(child(root,'ServerScriptService'),'FarmingRuntime','Runtime.server.luau'),(child(child(root,'StarterPlayer'),'StarterPlayerScripts'),'FarmingInterface','Interface.client.luau')]:
        assert child(parent,label).findtext('./Properties/ProtectedString[@name="Source"]')==(BASE/'src/farming'/file).read_text(encoding='utf-8')
    settings=child(modules,'Settings').findtext('./Properties/ProtectedString[@name="Source"]')
    assert 'Enabled=false, UseMemoryStore=false, TimeScale=1, StartingSterne=0' in settings
    crop_assets=child(ss,'FarmingCropAssets')
    paths=re.findall(r'(?:Planted|Developing|Mature|Ready|Regrowing)="([^"]+)"',source)
    assert len(paths)==34
    for path in paths:
        n=crop_assets
        for segment in path.split('/'):n=child(n,segment)
        assert n.get('class')=='Model'
    grapes=child(crop_assets,'GrapeGrowthStages')
    ready=child(grapes,'Ready');regrow=child(grapes,'Regrowing')
    assert not any(name(n)=='Produce' for n in regrow.findall('Item'))
    assert child(regrow,'Trellis') is not None
    for field in ['Foliage','Stems','Trellis']:
        a,b=child(ready,field),child(regrow,field)
        for x,y in zip(a.iter('Item'),b.iter('Item')):
            assert E.tostring(x.find('Properties'))==E.tostring(y.find('Properties'))
    tools=child(child(rs,'FarmingAssets'),'InventoryItems').findall('Item')
    assert len(tools)==18
    welds=0
    for tool in tools:
        assert tool.get('class')=='Tool'
        assert tool.findtext('./Properties/bool[@name="CanBeDropped"]')=='false'
        assert child(tool,'Handle') is not None
        for n in tool.iter('Item'):
            if n.get('class') in ['Part','UnionOperation','MeshPart','WedgePart']:
                for key,value in [('Anchored','false'),('CanCollide','false'),('CanTouch','false'),('CanQuery','false'),('Massless','true')]:
                    assert n.findtext('./Properties/bool[@name="'+key+'"]')==value,(name(tool),name(n),key)
            if n.get('class')=='WeldConstraint':
                welds+=1
                for key in ['Part0','Part1']:assert n.findtext('./Properties/Ref[@name="'+key+'"]') in refs
    report=json.loads((BASE/'build/farming-build-report.json').read_text())
    for file,digest in report['source_sha256'].items():assert hashlib.sha256((BASE/'build'/file).read_bytes()).hexdigest()==digest
    print(json.dumps({'world_matches_original_backup':True,'embedded_meshes':len(blobs),'explicit_stage_references':len(paths),'tools':len(tools),'resolved_tool_welds':welds,'sources_match_disk':True,'studio_test_disabled':True,'source_assets_unchanged':True}))
if __name__=='__main__':main()
