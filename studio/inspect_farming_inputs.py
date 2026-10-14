import xml.etree.ElementTree as E
from pathlib import Path

BASE=Path(__file__).resolve().parent
def name(x): return x.findtext('./Properties/string[@name="Name"]')
def walk(x,path='',depth=0):
    for n in x.findall('Item'):
        p=path+'/'+str(name(n))
        if depth<2 or n.get('class') in ('Tool','Script','LocalScript','ProximityPrompt') or '/Slots/' in p:
            print(p,n.get('class'),len(list(n.iter('Item'))))
        if n.get('class') in ('Script','LocalScript'):
            out=BASE/'build'/(str(name(n))+'.before-farming.luau')
            if not out.exists():out.write_text(n.findtext('./Properties/ProtectedString[@name="Source"]') or '',encoding='utf-8')
        walk(n,p,depth+1)
if __name__=='__main__':
    for file in ('LunaLanding-AutumnReview.rbxlx','AssetWorkshop.rbxlx','InventoryItems.rbxmx'):
        print('\nFILE',file)
        root=E.parse(BASE/'build'/file).getroot()
        if file=='AssetWorkshop.rbxlx':
            rs=next(n for n in root.findall('Item') if name(n)=='ReplicatedStorage')
            walk(rs)
        else:walk(root)
