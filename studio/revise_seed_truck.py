"""Revise only the truck, preserving the saved market and crop studies."""
from pathlib import Path
import copy, math, random, datetime, shutil, json
import xml.etree.ElementTree as E
raise SystemExit("Historical builder disabled: stage alternatives inside MarketWorkshop-v2.rbxlx and wait for approval before replacement. See AGENTS.md.")
import build_market_assets as b

ROOT=Path(__file__).parent; out=ROOT/'build'; stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
checkpoint=out/('truck-before-'+stamp);checkpoint.mkdir()
for p in [out/'MarketWorkshop.rbxlx',out/'MarketAssets.rbxmx',ROOT/'build_market_assets.py']:
 shutil.copy2(p,checkpoint/p.name)
tree=E.parse(out/'MarketWorkshop.rbxlx');root=tree.getroot();ws=next(n for n in root.findall('Item') if n.get('class')=='Workspace')
old=b.child(ws,'SeedTruck')
truck=b.truck();truck=b.clone(truck,E.Element('temp'),'SeedTruck')
def remove(n):
 for parent in truck.iter('Item'):
  if n in list(parent):parent.remove(n);return
remove_names={'Cargo','SideFootboard','GrabRail','GrabRailMount','SideRideSeat','RoofRideSeat','RoofGrabRail','RoofRailPost','RearLadderRung','RearLadderRail','DropShelf'}
for n in list(truck.iter('Item')):
 if b.name(n) in remove_names or n.get('class') in ['WeldConstraint','Attachment']:remove(n)
# Enlarge the cab and wheel forms uniformly; extend the wheelbase independently.
for p in truck.iter('Item'):
 cf=p.find('./Properties/CoordinateFrame[@name="CFrame"]');s=p.find('./Properties/Vector3[@name="size"]')
 if cf is not None and s is not None:
  vals=[float(v.text) for v in cf];pos=[v*1.25 for v in vals[:3]]
  if pos[2]>2:pos[2]+=4.8
  b.prop(p,'CoordinateFrame','CFrame',pos+vals[3:]);b.prop(p,'Vector3','size',[float(v.text)*1.25 for v in s])
  b.prop(p,'bool','Anchored',True)
chassis=b.child(truck,'Chassis');b.prop(chassis,'Vector3','size',[8.2,.7,21]);b.prop(chassis,'CoordinateFrame','CFrame',[0,2.35,2.3]+b.I)
cargo=b.node('Model','OverflowingCargo',truck)
b.part(cargo,'Bed',(8.2,.4,14.3),(0,3.1,5),b.wood)
for x in [-3.95,3.95]:
 for z in [-1.7,8.7]:b.part(cargo,'CanopyPost',(.55,7,.55),(x,6.8,z),b.edge)
 for y in [3.7,4.4]:b.part(cargo,'BedRail',(.3,.6,14),(x,y,5),b.wood)
b.canopy(cargo,9.1,11.8,11.1,3.6);b.sign(cargo,3.7,11.8,-2.0)

def transform(model,center,angles):
 R=b.rot(*angles)
 for p in model.iter('Item'):
  cf=p.find('./Properties/CoordinateFrame[@name="CFrame"]')
  if cf is None:continue
  v=[float(c.text) for c in cf];local=[v[i]-center[i] for i in range(3)]
  pos=[sum(R[i*3+j]*local[j] for j in range(3))+center[i] for i in range(3)]
  matrix=[sum(R[i*3+k]*v[3+k*3+j] for k in range(3)) for i in range(3) for j in range(3)]
  b.prop(p,'CoordinateFrame','CFrame',pos+matrix)

def packet(kind,pos,angles,scale=1):
 source=b.child(b.child(b.ws,'InventoryWorkshop'),kind+'_seeds');q=b.clone(b.child(source,'Visual'),cargo,kind.title()+'SeedEnvelope')
 parts=[n for n in q.iter('Item') if n.find('./Properties/CoordinateFrame[@name="CFrame"]') is not None]
 first=[float(v.text) for v in parts[0].find('./Properties/CoordinateFrame[@name="CFrame"]')][:3]
 for p in parts:
  cf=[float(v.text) for v in p.find('./Properties/CoordinateFrame[@name="CFrame"]')]
  b.prop(p,'CoordinateFrame','CFrame',[(cf[i]-first[i])*scale+pos[i] for i in range(3)]+cf[3:])
  sz=p.find('./Properties/Vector3[@name="size"]')
  if sz is not None:b.prop(p,'Vector3','size',[float(v.text)*scale for v in sz])
 transform(q,pos,angles)

# Uneven stacks with different angles and heights; large heaps are supported by crates.
for x,y,z,w,d,h,yaw in [(-1.8,3.3,-.1,3.4,3,1.9,-12),(1.7,3.3,1.7,3.5,3.5,2.4,9),(-1.4,3.3,4,3.6,3.2,2.8,-8),(1.8,3.3,6.2,3.1,3.1,2.1,14),(-1.1,3.3,8.2,3.8,2.4,2.1,-5)]:
 c=b.crate(cargo,x,y,z,w,d,h);b.part(c,'PackedCrateInterior',(w-.3,h-.7,d-.3),(x,y+(h-.7)/2+.2,z),b.dark);transform(c,(x,y,z),(0,yaw,0))
rng=random.Random(814)
heaps=[(-1.8,4.6,-.1),(1.7,5.1,1.7),(-1.4,5.5,4),(1.8,4.9,6.2),(-1.1,4.9,8.2)]
kinds=['pepper','pumpkin','grape','lettuce']
for i in range(38):
 x,y,z=heaps[i%len(heaps)];pos=(x+rng.uniform(-1.1,1.1),y+rng.uniform(-.1,.2)+(.45 if i>27 else 0),z+rng.uniform(-.9,.9))
 kind=kinds[i%4];q=b.produce(cargo,kind,pos,rng.uniform(.85,1.6));transform(q,pos,(rng.uniform(-17,17),rng.uniform(-180,180),rng.uniform(-18,18)))
for i in range(27):
 x,y,z=heaps[(i+2)%len(heaps)];pos=(x+rng.uniform(-1.15,1.15),y+rng.uniform(.2,.9),z+rng.uniform(-1,1))
 packet(['pepper','pumpkin','grape','corn','carrot'][i%5],pos,(rng.uniform(-28,28),rng.uniform(-170,170),rng.uniform(-35,35)),rng.uniform(.95,1.25))
# A handful of packets slipping over the rear lip, not a display row.
for i in range(3):packet(['pepper','pumpkin','corn'][i],(-.7+i*.65,4.3,11.1+i*.35),(15,20+i*35,-25+i*20),1.1)

rides=b.node('Model','RearPassengerDecks',truck)
# Two visibly cushioned seats on the upper rear deck, clear of the canvas.
b.part(rides,'UpperRearDeck',(8.1,.4,4.0),(0,10.9,10.1),b.edge)
for x in [-3.6,3.6]:
 for z in [8.5,11.6]:b.beam(rides,'DeckSupport',(x,3.3,z),(x,10.7,z),.45,b.wood)
 b.beam(rides,'DeckSideRail',(x,12.3,8.3),(x,12.3,11.8),.22,b.metal)
 for z in [8.3,11.8]:b.beam(rides,'RailPost',(x,11,z),(x,12.3,z),.22,b.metal)
for x in [-2,2]:
 b.part(rides,'UpperRearSeat',(2.5,.38,2.1),(x,11.35,10.5),b.sage,b.rot(0,180),cls='Seat')
 b.part(rides,'UpperSeatBack',(2.5,1.3,.28),(x,12,9.35),b.sage)
 for xx in [-1.3,1.3]:b.part(rides,'UpperArmrest',(.18,.18,1.9),(x+xx,12,10.5),b.wood)
# Two tailgate seats with an obvious backrest and dangling-foot step.
b.part(rides,'TailgatePlatform',(8.3,.35,2.9),(0,3.5,13),b.edge)
b.part(rides,'RearFootstep',(7.8,.25,1.1),(0,2.4,14.3),b.dark)
for x in [-2,2]:
 b.part(rides,'TailgateSeat',(2.5,.38,2),(x,4,13.2),b.sage,b.rot(0,180),cls='Seat')
 b.part(rides,'TailgateBackrest',(2.5,1.3,.3),(x,4.7,12.1),b.sage)
 for xx in [-1.3,1.3]:b.part(rides,'TailgateArmrest',(.18,.18,1.8),(x+xx,4.8,13.2),b.wood)
# Ladder occupies the left rear corner, outside the seat footprints.
for x in [-4.1,-2.9]:b.beam(rides,'RearLadderRail',(x,2.7,11.95),(x,11.8,11.95),.2,b.metal)
for i in range(10):b.beam(rides,'RearLadderRung',(-4.1,3+i*.85,11.95),(-2.9,3+i*.85,11.95),.2,b.metal)
holds=b.node('Folder','HoldPoints',truck)
for side in [-1,1]:
 for i,z in enumerate([.5,6]):
  b.part(truck,'StandingFootboard',(1.65,.25,2.6),(side*4.65,2.8,z),b.dark)
  for zz in [-.75,.75]:
   b.beam(truck,'SideGrabHandle',(side*4.28,5.7,z+zz),(side*4.28,7.15,z+zz),.2,b.metal)
   b.beam(truck,'HandleMount',(side*3.95,5.7,z+zz),(side*4.28,5.7,z+zz),.16,b.metal)
  point=b.part(holds,('Left' if side<0 else 'Right')+'Hold'+str(i+1),(1.3,.12,1.8),(side*4.85,2.99,z),b.sage,b.rot(0,side*90),collide=False)
  prompt=b.node('ProximityPrompt','HoldPrompt',point);b.prop(prompt,'string','ActionText','Hold on');b.prop(prompt,'string','ObjectText','Ride');b.prop(prompt,'float','MaxActivationDistance',8);b.prop(prompt,'bool','RequiresLineOfSight',False);b.prop(prompt,'float','HoldDuration',.15)
b.part(truck,'DropShelf',(2.1,.25,1.1),(0,4.7,12),b.edge)
a=b.node('Attachment','SeedDropOrigin',chassis);b.prop(a,'CoordinateFrame','CFrame',[0,2.8,10.7]+b.I)
b.node('RemoteEvent','ReleaseHold',truck)
for filename,context in [('TruckRiders.server.luau',1),('TruckRiders.client.luau',2)]:
 script=b.node('Script',filename.split('.')[0]+('Server' if context==1 else 'Client'),truck);b.prop(script,'ProtectedString','Source',(ROOT/'src'/filename).read_text());b.prop(script,'token','RunContext',context)
for p in list(truck.iter('Item')):
 if p is not chassis and p.get('class') in ('Part','UnionOperation','Seat','WedgePart'):
  b.prop(p,'bool','Anchored',False);b.prop(p,'bool','Massless',True)
  w=b.node('WeldConstraint','AssemblyWeld',chassis);b.prop(w,'Ref','Part0',chassis.get('referent'));b.prop(w,'Ref','Part1',p.get('referent'))
# Canonical pack remains centered; scene keeps the established truck position.
packtree=E.parse(out/'MarketAssets.rbxmx');folder=packtree.getroot().find('Item');folder.remove(b.child(folder,'SeedTruck'));b.clone(truck,folder,'SeedTruck')
packtree.write(out/'MarketAssets.rbxmx',encoding='utf-8',xml_declaration=True)
ws.remove(old);b.translate(truck,(2,0,39));ws.append(truck)
tree.write(out/'MarketWorkshop.rbxlx',encoding='utf-8',xml_declaration=True)
tree.write(out/'MarketWorkshop-v2.rbxlx',encoding='utf-8',xml_declaration=True)
report={'passengerSeats':4,'standingHoldPoints':4,'seedEnvelopes':30,'looseProduce':38,'vehicleSeats':0,'revision':'larger eight-rider seed truck'}
(out/'truck-v2-report.json').write_text(json.dumps(report,indent=2))
after=out/('truck-after-'+stamp);after.mkdir()
for p in [out/'MarketWorkshop.rbxlx',out/'MarketAssets.rbxmx',Path(__file__),ROOT/'src/TruckRiders.server.luau',ROOT/'src/TruckRiders.client.luau']:shutil.copy2(p,after/p.name)
print(json.dumps(report));print(out/'MarketWorkshop-v2.rbxlx')
