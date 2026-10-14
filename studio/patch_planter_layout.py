"""Enlarge only the planter board and its UI; retain the board's bottom edge."""
import xml.etree.ElementTree as E
from pathlib import Path
from build_farming import child, prop
base=Path(__file__).resolve().parent
target=base/'build/LunaLanding-AutumnReview.rbxlx'
root=E.parse(target).getroot()
module=child(child(child(root,'ReplicatedStorage'),'Farming'),'PlanterStatus')
prop(module,'ProtectedString','Source',(base/'src/ui/PlanterStatus.luau').read_text(encoding='utf-8'))
board=child(child(child(child(child(child(root,'Workspace'),'LunaLandingFirstPlot'),'GrowingAreas'),'Area01'),'GardenStatusDisplay'),'StatusDisplay')
props=board.find('Properties')
size=next(p for p in props if p.get('name')=='size' or p.get('name')=='Size')
size.find('Y').text='8.05'
cf=next(p for p in props if p.get('name')=='CFrame')
cf.find('Y').text='10.925'
E.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
print('Saved planter height 8.05, center Y 10.925 and updated UI.')
