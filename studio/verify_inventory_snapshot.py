"""Verify preservation of existing assets and integrity of saved item references."""
import xml.etree.ElementTree as ET
from pathlib import Path
p=Path(__file__).resolve().parent/'build'
before=ET.parse(p/'AssetWorkshop.before-inventory-items.rbxlx').getroot()
after=ET.parse(p/'AssetWorkshop.rbxlx').getroot()
def name(n):return n.find('./Properties/string[@name="Name"]').text
def compare(a,b):
    assert ET.tostring(a.find('Properties'))==ET.tostring(b.find('Properties')),name(a)
    lookup={name(c):c for c in b.findall('Item')}
    for c in a.findall('Item'):
        # Existing source tree is unchanged; duplicate sibling geometry names
        # are compared by referent rather than label.
        candidate=next((x for x in b.findall('Item') if x.get('referent')==c.get('referent')),None)
        assert candidate is not None,name(c)
        compare(c,candidate)
for a in before.findall('Item'):
    b=next(x for x in after.findall('Item') if x.get('referent')==a.get('referent'))
    compare(a,b)
pack=ET.parse(p/'InventoryItems.rbxmx').getroot()
refs={x.get('referent') for x in pack.iter('Item')}
tools=[x for x in pack.iter('Item') if x.get('class')=='Tool']
assert len(tools)==18
for x in pack.iter('Ref'):
    assert x.text=='null' or x.text in refs,x.text
for t in tools:
    assert any(name(c)=='Handle' for c in t.findall('Item')),name(t)
shared={x.get('md5') for x in pack.findall('./SharedStrings/SharedString')}
for n in pack.iter('NetAssetRef'):
    if n.get('name')=='SolidMeshHolder':assert n.text in shared
print('PASS: original scene preserved; 18 Tools; internal references and embedded meshes resolved.')
