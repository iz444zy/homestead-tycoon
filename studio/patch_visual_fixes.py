"""Surgical patch: preserve the saved world and embedded crop geometry."""
import xml.etree.ElementTree as E
from pathlib import Path
from build_farming import child, prop, node
BASE=Path(__file__).resolve().parent
target=BASE/'build/LunaLanding-AutumnReview.rbxlx'
root=E.parse(target).getroot()
for path,file in [
    ('ServerStorage/Farming/World','farming/World.luau'),
    ('StarterPlayer/StarterPlayerScripts/FarmingInterface','farming/Interface.client.luau'),
    ('ReplicatedStorage/Farming/PlanterStatus','ui/PlanterStatus.luau'),
]:
    parent=root
    parts=path.split('/')
    for key in parts[:-1]: parent=child(parent,key)
    try: item=child(parent,parts[-1])
    except StopIteration:
        item=node('ModuleScript',parts[-1]); parent.append(item)
    prop(item,'ProtectedString','Source',(BASE/'src'/file).read_text(encoding='utf-8'))
plot=child(child(root,'Workspace'),'LunaLandingFirstPlot')
guidance=child(child(child(plot,'Arrival'),'ClaimGuidance'),'Lettering')
prop(guidance,'token','Face',2) # Back, facing the gate approach (+Z).
board=child(child(child(child(plot,'GrowingAreas'),'Area01'),'GardenStatusDisplay'),'StatusDisplay')
prop(board,'float','Transparency',.32)
prop(child(board,'Lettering'),'token','Face',2)
E.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
print('Patched three scripts, claim face, planter face and transparency; all assets preserved.')
