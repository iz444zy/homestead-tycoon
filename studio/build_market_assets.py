"""Build native reusable market studies without modifying the approved crop workshop."""
from pathlib import Path
import xml.etree.ElementTree as E
import copy, math, uuid, json, hashlib, shutil, datetime

ROOT=Path(__file__).parent
SOURCE=ROOT/'build/AssetWorkshop.rbxlx'
tree=E.parse(SOURCE); root=tree.getroot()
def name(n): return n.findtext('./Properties/string[@name="Name"]')
def child(n,s):return next(c for c in n.findall('Item') if name(c)==s)
ws=next(n for n in root.findall('Item') if n.get('class')=='Workspace')
lib=child(next(n for n in root.findall('Item') if n.get('class')=='ReplicatedStorage'),'AssetLibrary')
I=[1,0,0,0,1,0,0,0,1]
def prop(n,tag,key,v):
 p=n.find('Properties')
 old=next((x for x in p if x.get('name')==key),None)
 if old is not None:p.remove(old)
 q=E.SubElement(p,tag,name=key)
 keys={'Vector3':['X','Y','Z'],'CoordinateFrame':['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22']}
 if tag in keys:
  for k,val in zip(keys[tag],v):E.SubElement(q,k).text=str(val)
 else:q.text=str(v).lower() if isinstance(v,bool) else str(v)
 return q
def node(cls,n,parent):
 q=E.SubElement(parent,'Item',{'class':cls,'referent':'RBX'+uuid.uuid4().hex})
 E.SubElement(q,'Properties');prop(q,'string','Name',n);return q
def rot(rx=0,ry=0,rz=0):
 a,b,c=map(math.radians,(rx,ry,rz)); ca,sa,cb,sb,cc,sc=math.cos(a),math.sin(a),math.cos(b),math.sin(b),math.cos(c),math.sin(c)
 return [cc*cb,cc*sb*sa-sc*ca,cc*sb*ca+sc*sa,sc*cb,sc*sb*sa+cc*ca,sc*sb*ca-cc*sa,-sb,cb*sa,cb*ca]
wood=(151,102,58); edge=(177,124,70); dark=(98,68,45); cream=(235,215,172); terra=(179,83,56); sage=(117,139,91); metal=(81,81,73); glass=(65,91,99)
def part(m,n,s,p,col=wood,r=None,cls='Part',collide=True):
 q=node(cls,n,m);prop(q,'Vector3','size',s);prop(q,'CoordinateFrame','CFrame',list(p)+(r or I));prop(q,'Color3uint8','Color3uint8',0xff000000+(col[0]<<16)+(col[1]<<8)+col[2]);prop(q,'token','Material',272)
 for k,v in [('Anchored',True),('CanCollide',collide),('CanTouch',cls=='Seat'),('CanQuery',True)]:prop(q,'bool',k,v)
 if cls=='Part':prop(q,'token','shape',1)
 prop(q,'token','TopSurface',0);prop(q,'token','BottomSurface',0)
 return q
def beam(m,n,a,b,w=.3,col=wood):
 d=[b[i]-a[i] for i in range(3)]; length=math.sqrt(sum(v*v for v in d)); y=[v/length for v in d]
 ref=[0,0,1] if abs(y[2])<.95 else [1,0,0]
 x=[y[1]*ref[2]-y[2]*ref[1],y[2]*ref[0]-y[0]*ref[2],y[0]*ref[1]-y[1]*ref[0]]; l=math.sqrt(sum(v*v for v in x));x=[v/l for v in x]
 z=[x[1]*y[2]-x[2]*y[1],x[2]*y[0]-x[0]*y[2],x[0]*y[1]-x[1]*y[0]]
 return part(m,n,(w,length,w),[(a[i]+b[i])/2 for i in range(3)],col,[x[0],y[0],z[0],x[1],y[1],z[1],x[2],y[2],z[2]])
def translate(m,offset):
 for n in m.iter('Item'):
  p=n.find('./Properties/CoordinateFrame[@name="CFrame"]')
  if p is not None:
   for k,v in zip(['X','Y','Z'],offset):p.find(k).text=str(float(p.findtext(k))+v)
def clone(src,parent,newname):
 q=copy.deepcopy(src); mapping={}
 for n in q.iter('Item'):
  old=n.get('referent');new='RBX'+uuid.uuid4().hex;mapping[old]=new;n.set('referent',new)
  for p in list(n.find('Properties')):
   if p.tag=='UniqueId':n.find('Properties').remove(p)
 for p in q.iter('Ref'):
  if p.text in mapping:p.text=mapping[p.text]
 prop(q,'string','Name',newname);parent.append(q);return q
def produce(m,kind,pos,height=1):
 src=child(lib,{'pepper':'PepperFruitTemplate','pumpkin':'PumpkinFruitTemplate','grape':'GrapeHarvest','lettuce':'LettuceHarvest'}[kind])
 q=clone(src,m,kind.title());parts=[n for n in q.iter('Item') if n.get('class') in ('Part','UnionOperation')]
 bounds=[]
 for n in parts:
  cf=[float(x.text) for x in n.find('./Properties/CoordinateFrame[@name="CFrame"]')];s=[float(x.text) for x in n.find('./Properties/Vector3[@name="size"]')]
  ext=[sum(abs(cf[3+i*3+j])*s[j]/2 for j in range(3)) for i in range(3)]
  bounds.append((cf,s,ext,n))
 lo=[min(cf[i]-ex[i] for cf,s,ex,n in bounds) for i in range(3)];hi=[max(cf[i]+ex[i] for cf,s,ex,n in bounds) for i in range(3)];scale=height/(hi[1]-lo[1]);center=[(lo[0]+hi[0])/2,lo[1],(lo[2]+hi[2])/2]
 for cf,s,ex,n in bounds:
  prop(n,'Vector3','size',[v*scale for v in s]);prop(n,'CoordinateFrame','CFrame',[(cf[i]-center[i])*scale+pos[i] for i in range(3)]+cf[3:]);prop(n,'bool','CanCollide',False)
 return q
def crate(m,x,y,z,w=2.5,d=2,h=1.5):
 c=node('Model','ProduceCrate',m);part(c,'Base',(w,.2,d),(x,y+.1,z),dark)
 for level in range(2):
  yy=y+.4+level*(h-.4)/2
  for zz in [-d/2,d/2]:part(c,'SideBoard',(w,.42,.16),(x,yy,z+zz),wood)
  for xx in [-w/2,w/2]:part(c,'EndBoard',(.16,.42,d),(x+xx,yy,z),edge)
 for xx in [-w/2,w/2]:
  for zz in [-d/2,d/2]:part(c,'Corner',(.2,h,.2),(x+xx,y+h/2,z+zz),edge)
 return c
def canopy(m,w,d,y,z=0):
 # Two broad sloping panels; alternating cloth strips, thick scallop-free valance.
 rise=1.05;half=d/2;length=math.hypot(half,rise);angle=math.degrees(math.atan2(rise,half))
 for i in range(6):
  x=-w/2+w/6*(i+.5);col=terra if i%2==0 else cream
  for side in [-1,1]:
   part(m,'CanvasPanel',(w/6+.012,.16,length),(x,y-rise/2,z+side*half/2),col,rot(side*angle))
   part(m,'CanvasHem',(w/6+.012,.48,.18),(x,y-rise-.16,z+side*half),col)
 part(m,'RidgeBeam',(w,.27,.3),(0,y-.1,z),dark)
def sign(m,w,y,z):
 part(m,'SignFrame',(w,1.55,.24),(0,y,z),wood)
 part(m,'SignInset',(w-.34,1.2,.08),(0,y,z-.17),cream)
 beam(m,'SproutStem',(0,y-.35,z-.23),(0,y+.15,z-.23),.09,sage)
 for side in [-1,1]:part(m,'SproutLeaf',(.48,.23,.10),(side*.22,y+.13,z-.24),sage,rot(0,0,side*35))
def stall(stock=True):
 m=node('Model','SellStallStocked' if stock else 'SellStallEmpty',ws)
 for x in [-4.6,4.6]:
  for z in [-1.7,1.7]:
   part(m,'Post',(.5,7.8,.5),(x,3.9,z),wood);part(m,'PostFoot',(.69,.55,.69),(x,.28,z),edge)
   beam(m,'KneeBrace',(x,6.05,z),(x-math.copysign(1,x),7.15,z),.3,dark)
 for z in [-1.7,1.7]:part(m,'Lintel',(9.5,.4,.4),(0,7.25,z),edge)
 part(m,'Counter',(9.8,.35,3.6),(0,3.15,0),edge)
 for i in range(3):part(m,'FrontBoard',(9.1,.72,.22),(0,.9+i*.76,-1.65),wood if i%2 else edge)
 part(m,'LowerShelf',(8.8,.22,1.7),(0,.8,.6),dark)
 # Sloped trays face the customer; rear remains open.
 for i in range(4):
  x=-3.45+i*2.3
  part(m,'DisplayTray',(2.12,.15,2.7),(x,3.65,0),wood,rot(-13))
  for side in [-1,1]:part(m,'TrayDivider',(.13,.48,2.75),(x+side*1.08,3.85,0),dark,rot(-13))
  part(m,'TrayLip',(2.16,.4,.18),(x,3.52,-1.35),edge)
  part(m,'OfferCard',(0.72,.48,.08),(x,4.3,1.1),cream,rot(-13),collide=False)
  if stock:
   kind=['pepper','pumpkin','grape','lettuce'][i]
   for j in range(2):produce(m,kind,(x+(-.42 if j==0 else .42),3.75+j*.16,-.4+j*.8),.95 if kind!='grape' else .7)
 canopy(m,10.7,5.6,8.5);sign(m,3.1,9,-2.0)
 crate(m,3.2,0,-3.1,2.5,1.8,1.4)
 if stock:produce(m,'pumpkin',(3.2,1,-3.1),1.2)
 part(m,'InteractionPlaque',(1.3,1.0,.16),(-3.6,2.1,-1.86),cream)
 return m
def truck():
 m=node('Model','SeedTruck',ws)
 chassis=part(m,'Chassis',(6.5,.55,13),(0,1.9,0),metal);prop(m,'Ref','PrimaryPart',chassis.get('referent'))
 part(m,'CabLower',(6.5,2.5,4.5),(0,3.45,-4.2),sage)
 part(m,'Hood',(6.4,.65,2.1),(0,4.65,-5.45),sage,rot(7))
 part(m,'CabBack',(6.25,2.5,.25),(0,5.35,-2.05),sage)
 part(m,'Windshield',(5.5,2,.18),(0,5.85,-4.55),glass,rot(-12))
 for x in [-2.98,2.98]:
  beam(m,'WindowPillar',(x,4.6,-4.8),(x,7,-4.28),.34,sage)
  part(m,'DoorWindow',(.13,1.9,1.8),(x,5.8,-3.15),glass)
  part(m,'DoorHandle',(.16,.16,.6),(x*1.1,4.4,-2.7),metal)
  beam(m,'MirrorArm',(x,5,-4.1),(x*1.23,5,-4.1),.16,metal)
  part(m,'Mirror',(.26,.85,.6),(x*1.23,5.2,-4.1),metal)
 part(m,'WindshieldDivider',(.13,2,.22),(0,5.85,-4.59),sage,rot(-12))
 part(m,'CabRoof',(6.8,.42,3.25),(0,7,-3.2),cream)
 part(m,'FrontBumper',(7.25,.65,.55),(0,2.25,-6.7),metal)
 part(m,'Grille',(2.65,1.3,.15),(0,3.5,-6.5),dark)
 for i in range(3):part(m,'GrilleSlat',(2.4,.12,.15),(0,3.1+i*.35,-6.62),metal)
 for x in [-2.35,2.35]:
  p=part(m,'HeadlightRim',(.28,1.08,1.08),(x,3.65,-6.55),metal,rot(0,90));prop(p,'token','shape',2)
  p=part(m,'Headlight',(.30,.78,.78),(x,3.65,-6.7),(242,214,136),rot(0,90));prop(p,'token','shape',2)
 for x in [-3.35,3.35]:
  for z in [-4.6,4.35]:
   wheel=node('Model','Wheel',m)
   p=part(wheel,'TireCore',(1.05,2.75,2.75),(x,1.5,z),(48,47,43));prop(p,'token','shape',2)
   # Broad perimeter facets instead of tiny tread detail.
   for i in range(12):
    a=i*math.pi/6;part(wheel,'TireFacet',(1.13,.38,.82),(x,1.5+1.24*math.cos(a),z+1.24*math.sin(a)),(55+i%2*4,53+i%2*4,47+i%2*4),rot(math.degrees(a)))
   p=part(wheel,'Hub',(1.18,1.35,1.35),(x,1.5,z),(165,151,120));prop(p,'token','shape',2)
   for side in [-1,1]:part(m,'FenderShoulder',(.6,.34,1.4),(x,2.9,z+side*.9),sage,rot(side*35))
   part(m,'FenderTop',(.65,.35,1.25),(x,3.2,z),sage)
 cargo=node('Model','Cargo',m)
 part(cargo,'Bed',(6.5,.35,7.8),(0,2.5,2.3),wood)
 for x in [-3.1,3.1]:
  for z in [-1.25,5.85]:part(cargo,'CanopyPost',(.45,5.8,.45),(x,5.4,z),edge)
  for y in [3.05,3.65]:part(cargo,'BedRail',(.24,.52,7.5),(x,y,2.3),wood)
  # A useful running board and chest-height handrail on each side.
  part(m,'SideFootboard',(1.15,.22,4.7),(x*1.2,2.3,1.2),dark)
  beam(m,'GrabRail',(x*1.12,5.6,-.8),(x*1.12,5.6,3.1),.18,metal)
  for z in [-.8,3.1]:beam(m,'GrabRailMount',(x,5.6,z),(x*1.12,5.6,z),.16,metal)
  seat=part(m,'SideRideSeat',(1.7,.25,1.6),(x*1.15,3.15,1.7),wood,rot(0,-90 if x<0 else 90),cls='Seat')
 canopy(cargo,7.4,8.4,9.2,2.3)
 sign(cargo,3.2,9.75,-1.75)
 # Dedicated roof perch on the solid cab, independent from the fabric canopy.
 for x in [-1.25,1.25]:
  part(m,'RoofRideSeat',(1.8,.25,1.7),(x,7.35,-3.1),wood,cls='Seat')
 beam(m,'RoofGrabRail',(-2.6,8.1,-2.05),(2.6,8.1,-2.05),.16,metal)
 for x in [-2.6,2.6]:beam(m,'RoofRailPost',(x,7.2,-2.05),(x,8.1,-2.05),.16,metal)
 for y in [3,3.8,4.6,5.4,6.2]:beam(m,'RearLadderRung',(-2.6,y,6.4),(-1.3,y,6.4),.18,metal)
 for x in [-2.7,-1.2]:beam(m,'RearLadderRail',(x,2.4,6.4),(x,7,6.4),.19,metal)
 part(m,'DropShelf',(3,.25,1.2),(1,3.2,6.7),edge)
 a=node('Attachment','SeedDropOrigin',chassis);prop(a,'CoordinateFrame','CFrame',[1,1.6,7.1]+I)
 for i,kind in enumerate(['pepper','pumpkin','grape']):
  crate(cargo,0,2.7,-.1+i*2.1,4.5,1.8,1)
  produce(cargo,kind,(-1,3.5,-.1+i*2.1),1.1)
  # Existing sealed-envelope visual, copied without the inventory Tool/scripts.
  src=child(child(ws,'InventoryWorkshop'),kind+'_seeds');visual=child(src,'Visual')
  q=clone(visual,cargo,kind.title()+'SeedPackets')
  ps=[n for n in q.iter('Item') if n.find('./Properties/CoordinateFrame[@name="CFrame"]') is not None]
  if ps:
   cf=ps[0].find('./Properties/CoordinateFrame[@name="CFrame"]');base=[float(cf.findtext(k)) for k in ['X','Y','Z']]
   translate(q,[1-base[0],4.1-base[1],-.1+i*2.1-base[2]])
 # One anchored, script-driven assembly. Passenger Seats never grant steering.
 for p in list(m.iter('Item')):
  if p is not chassis and p.get('class') in ('Part','UnionOperation','Seat'):
   prop(p,'bool','Anchored',False);prop(p,'bool','Massless',True)
   w=node('WeldConstraint','AssemblyWeld',chassis)
   prop(w,'Ref','Part0',chassis.get('referent'));prop(w,'Ref','Part1',p.get('referent'))
 return m
def grocery():
 m=node('Model','CommunityMarket',ws)
 part(m,'Foundation',(22,1.1,15),(0,.55,0),(111,112,102))
 part(m,'Floor',(21,.35,14),(0,1.25,0),wood)
 part(m,'BackWall',(21,8.5,.5),(0,5.6,6.6),cream)
 for x in [-10.25,10.25]:part(m,'SideWall',(.5,8.5,11),(x,5.6,1.1),cream)
 # Front has an actual doorway and a large open selling window.
 part(m,'FrontLeft',(4.2,8.5,.4),(-8.1,5.6,-4.6),cream)
 part(m,'CounterApron',(10.8,3.3,.4),(4.5,2.95,-4.6),cream)
 part(m,'FrontLintel',(21,1.2,.5),(0,9.3,-4.6),cream)
 for z in [-4.6,6.6]:
  for side in [-1,1]:part(m,'GablePlaster',(.45,4.35,10.5),(side*5.25,12.075,z),cream,rot(0,-side*90),cls='WedgePart')
  part(m,'GableTie',(21,.4,.6),(0,9.9,z),wood)
 for x in [-10,-5.8,-1.2,10]:part(m,'WallTimber',(.48,8.7,.6),(x,5.7,-4.8),wood)
 part(m,'Counter',(11.5,.4,2.5),(4.4,4.65,-5.4),edge)
 for i in range(7):part(m,'CounterBoard',(1.5,2.7,.2),(-.3+i*1.55,3.1,-6.25),wood if i%2 else edge)
 part(m,'Porch',(23,.4,5),(0,1.4,-6.5),edge)
 for i in range(3):part(m,'Step',(8,.38,1.1),( -3,.19+i*.38,-10+i*1.05),wood)
 for x in [-10.3,-1.5,10.3]:
  part(m,'PorchPost',(.65,8.8,.65),(x,5.9,-8.3),edge)
  part(m,'PostFoot',(.9,1,.9),(x,2.05,-8.3),wood)
  for side in [-1,1]:beam(m,'PorchBrace',(x,8.2,-8.3),(x+side*1.3,9.65,-8.3),.4,wood)
 part(m,'PorchHeader',(23,.7,.7),(0,10,-8.3),wood)
 # Roof ridge runs along Z; broad planes, deep eaves, exposed front truss.
 rise=5;run=12;angle=math.degrees(math.atan2(rise,run))
 for side in [-1,1]:
  part(m,'RoofPlane',(math.hypot(run,rise),.42,18.5),(side*run/2,12.5,-.7),terra,rot(0,0,-side*angle))
  beam(m,'GableFascia',(0,15.1,-10),(side*12.2,10,-10),.5,edge)
  beam(m,'Truss',(0,14.6,-8.3),(side*8.8,10,-8.3),.4,wood)
 beam(m,'KingPost',(0,10,-8.3),(0,14.7,-8.3),.5,wood)
 part(m,'RidgeCap',(.6,.4,18.8),(0,15.1,-.7),terra)
 part(m,'Chimney',(1.4,5,1.6),(-7,12.1,3.7),(159,151,128));part(m,'ChimneyCap',(1.85,.4,2),(-7,14.6,3.7),metal)
 # Side window is inset behind separate frame and sill.
 for x in [-10.55,10.55]:
  part(m,'SideGlass',(.12,3.1,3.4),(x,6.2,.5),glass)
  for z in [-1.3,2.3]:part(m,'WindowJamb',(.28,3.5,.25),(x,6.2,z),wood)
  for y in [4.5,7.9]:part(m,'WindowFrame',(.35,.28,3.9),(x,y,.5),edge)
  part(m,'WindowMullion',(.22,3.1,.18),(x,6.2,.5),wood);part(m,'WindowCrossbar',(.22,.18,3.4),(x,6.2,.5),wood)
 for i,kind in enumerate(['pepper','pumpkin','grape','lettuce']):
  x=.15+i*2.65;crate(m,x,4.85,-5.4,2.3,1.7,.65);produce(m,kind,(x,5.2,-5.4),1.05)
 for x,kind in [(-8.3,'pepper'),(7.8,'grape')]:crate(m,x,0,-10.2,3.1,2.4,1.9);produce(m,kind,(x,1.4,-10.2),1.4)
 for y in [3,5,7]:part(m,'InteriorShelf',(8,.25,1.4),(3,y,5.7),wood)
 for x in [0,2,4,6]:produce(m,'pumpkin',(x,3.2,5.7),.8)
 sign(m,3,11.2,-8.8)
 # Blank service-board insert: no invented prices or market behavior.
 part(m,'MarketBoardFrame',(5.4,2.1,.25),(5.7,8,-6.1),wood);part(m,'MarketBoardInsert',(5.05,1.75,.08),(5.7,8,-6.28),cream)
 for i,kind in enumerate(['pepper','pumpkin','grape','lettuce']):produce(m,kind,(3.9+i*1.2,7.65,-6.5),.7)
 return m

if __name__ == "__main__":
 raise SystemExit("Disabled: edit MarketWorkshop-v2.rbxlx in place. New experience files require explicit user permission; see AGENTS.md.")
 models=[grocery(),truck(),stall(True),stall(False)]
 offsets=[(-27,0,40),(2,0,39),(21,0,39),(35,0,39)]
 pack=E.Element('roblox',{'version':'4'});templates=node('Folder','MarketAssets',pack)
 for m,off in zip(models,offsets):
  clone(m,templates,name(m));translate(m,off)
 ground=child(ws,'WorkshopGround');prop(ground,'Vector3','size',[160,.3,200]);prop(ground,'CoordinateFrame','CFrame',[0,-.2,0]+I)
 # Straightforward neutral workshop light, retaining the original plants.
 cam=child(ws,'Camera');prop(cam,'float','FieldOfView',48)
 def look(eye,target):
  z=[eye[i]-target[i] for i in range(3)];l=math.sqrt(sum(v*v for v in z));z=[v/l for v in z];x=[z[2],0,-z[0]];l=math.sqrt(sum(v*v for v in x));x=[v/l for v in x];y=[z[1]*x[2]-z[2]*x[1],z[2]*x[0]-z[0]*x[2],z[0]*x[1]-z[1]*x[0]]
  return list(eye)+[x[0],y[0],z[0],x[1],y[1],z[1],x[2],y[2],z[2]]
 prop(cam,'CoordinateFrame','CFrame',look((55,43,-26),(0,4,39)))
 shared=root.find('SharedStrings');pack.append(copy.deepcopy(shared))
 out=ROOT/'build/MarketWorkshop.rbxlx';tree.write(out,encoding='utf-8',xml_declaration=True)
 E.ElementTree(pack).write(ROOT/'build/MarketAssets.rbxmx',encoding='utf-8',xml_declaration=True)
 report={name(m):{'parts':sum(n.get('class') in ['Part','WedgePart','UnionOperation','Seat'] for n in m.iter('Item')),'seats':sum(n.get('class')=='Seat' for n in m.iter('Item'))} for m in models}
 report['source_sha256']=hashlib.sha256(SOURCE.read_bytes()).hexdigest()
 (ROOT/'build/market-assets-report.json').write_text(json.dumps(report,indent=2))
 stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S');checkpoint=ROOT/'build'/('market-checkpoint-'+stamp);checkpoint.mkdir()
 for p in [out,ROOT/'build/MarketAssets.rbxmx',Path(__file__)]:shutil.copy2(p,checkpoint/p.name)
 print(json.dumps(report,indent=2));print(out)
 
