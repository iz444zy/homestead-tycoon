"""Build a standalone, unpublished Roblox place using only standard-library Python.

Coordinates/dimensions are prototype values. Run: python3 studio/build_plot.py
"""
from pathlib import Path
import math
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "build"
OUT.mkdir(exist_ok=True)
doc = ET.Element("roblox", version="4")
nodes = []

def item(cls, name, parent, **props):
    node = ET.SubElement(parent, "Item", {"class": cls, "referent": f"RBX{len(nodes)+1}"})
    pr = ET.SubElement(node,"Properties")
    nodes.append(node)
    values = dict(Name=("string", name), **props)
    for key,(kind,val) in values.items():
        e = ET.SubElement(pr, kind, name=key)
        if kind == "Vector3":
            for tag,v in zip("XYZ", val): ET.SubElement(e,tag).text=str(v)
        elif kind == "CoordinateFrame":
            for tag,v in zip(["X","Y","Z","R00","R01","R02","R10","R11","R12","R20","R21","R22"],val): ET.SubElement(e,tag).text=str(v)
        elif kind == "Color3":
            for tag,v in zip("RGB",val): ET.SubElement(e,tag).text=str(v/255)
        elif kind in ("Vector2","UDim2","UDim"):
            tags={"Vector2":["X","Y"],"UDim2":["XS","XO","YS","YO"],"UDim":["S","O"]}[kind]
            for tag,v in zip(tags,val): ET.SubElement(e,tag).text=str(v)
        else: e.text = str(val).lower() if isinstance(val,bool) else str(val)
    return node

def folder(name,parent): return item("Folder",name,parent)
def cf(pos,angle=0,axis="y"):
    c,s=math.cos(angle),math.sin(angle)
    r= [c,0,s,0,1,0,-s,0,c] if axis=="y" else [1,0,0,0,c,-s,0,s,c] if axis=="x" else [c,-s,0,s,c,0,0,0,1]
    return [*pos,*r]

WOOD=(155,121,82); TRIM=(112,85,58); CREAM=(194,180,145)
GRASS=(66,105,55); SOIL=(105,77,56); ROOF=(156,86,63)
def part(name,parent,size,pos,color,angle=0,axis="y",collide=True,transparent=0,cls="Part",**extra):
    return item(cls,name,parent,Size=("Vector3",size),CFrame=("CoordinateFrame",cf(pos,angle,axis)),Color=("Color3",color),Material=("token",272),Anchored=("bool",True),CanCollide=("bool",collide),CanTouch=("bool",False),Transparency=("float",transparent),TopSurface=("token",0),BottomSurface=("token",0),**extra)

def prompt(name,parent,action,obj,enabled=True):
    return item("ProximityPrompt",name,parent,ActionText=("string",action),ObjectText=("string",obj),HoldDuration=("float",0.3),MaxActivationDistance=("float",10),RequiresLineOfSight=("bool",False),Enabled=("bool",enabled))

def sign(name,parent,pos,text,width=12,post=True):
    if post: part(name+"Post",parent,(0.8,pos[1],0.8),(pos[0],pos[1]/2,pos[2]-.7),TRIM)
    board=part(name,parent,(width,3.8,0.5),pos,WOOD)
    gui=item("SurfaceGui","Lettering",board,Face=("token",5),CanvasSize=("Vector2", ""))
    props=gui.find("Properties")
    props.remove(props.find("Vector2"))
    sz=ET.SubElement(props,"Vector2",name="CanvasSize")
    ET.SubElement(sz,"X").text="720"; ET.SubElement(sz,"Y").text="220"
    label=item("TextLabel","Text",gui,Text=("string",text),TextSize=("float",36),TextScaled=("bool",True),TextColor3=("Color3",(245,233,207)),BackgroundTransparency=("float",1),TextWrapped=("bool",True),Font=("token",20))
    ud=ET.SubElement(label.find("Properties"),"UDim2",name="Size")
    for k,v in [("XS",.9),("XO",0),("YS",.8),("YO",0)]: ET.SubElement(ud,k).text=str(v)
    ud=ET.SubElement(label.find("Properties"),"UDim2",name="Position")
    for k,v in [("XS",.05),("XO",0),("YS",.1),("YO",0)]: ET.SubElement(ud,k).text=str(v)
    return board

workspace=item("Workspace","Workspace",doc)
plot=item("Model","LunaLandingFirstPlot",workspace)
ground=folder("Ground",plot)
part("FlatProperty",ground,(220,2,196),(0,-1,0),GRASS)
part("SurroundingGround",ground,(2048,2,2048),(0,-1.04,0),(71,108,57))
paths=folder("Paths",plot)
def path_segment(name,a,b,width=10):
    dx,dz=b[0]-a[0],b[1]-a[1]
    length=math.hypot(dx,dz)
    part(name,paths,(width,0.16,length+1),( (a[0]+b[0])/2,0.08,(a[1]+b[1])/2),CREAM,math.atan2(dx,dz))
def curved_path(name,points,width):
    # Catmull-Rom centerline. Overlapping flat discs round the joins; no gravel parts.
    extended=[points[0],*points,points[-1]]
    samples=[]
    for i in range(1,len(extended)-2):
        p0,p1,p2,p3=extended[i-1:i+3]
        for step in range(4):
            t=step/4
            xy=[]
            for axis in range(2):
                a,b,c,d=p0[axis],p1[axis],p2[axis],p3[axis]
                xy.append(.5*(2*b+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t))
            samples.append(xy)
    samples.append(points[-1])
    for i,(x,z) in enumerate(samples):
        w=width*(1+.025*math.sin(i*.7))
        part(name+"RoundJoin",paths,(.16,w,w),(x,.08,z),CREAM,math.pi/2,"z",Shape=("token",2))
        if i: path_segment(name+"Walk",samples[i-1],(x,z),min(w,width))
curved_path("CottageWalk",[(-17,114),(-17,98),(-14,77),(-15,52),(-13,28),(-17,9),(-20,-11),(-31,-29),(-51,-39),(-70,-39)],10)
curved_path("FutureGardenWalk",[(-20,-11),(-16,-29),(6,-30),(37,-30),(60,-32),(78,-39)],10)
curved_path("BedWalk",[(-13,28),(-36,26),(-59,23),(-83,19)],8)
curved_path("DigWalk",[(-14,77),(-35,79),(-51,77),(-61,77)],8)

boundary=folder("Boundary",plot)
def fence(a,b):
    dx,dz=b[0]-a[0],b[1]-a[1]
    length=math.hypot(dx,dz)
    n=math.ceil(length/14)
    angle=math.atan2(dx,dz)
    for i in range(n+1):
        x,z=a[0]+dx*i/n,a[1]+dz*i/n
        part("Post",boundary,(1.3,4.2,1.3),(x,2.1,z),WOOD)
        if i<n:
            x,z=a[0]+dx*(i+.5)/n,a[1]+dz*(i+.5)/n
            for y in (1.3,3): part("Rail",boundary,(0.55,0.65,length/n),(x,y,z),WOOD,angle)
fence((-109,-97),(-30,-97)); fence((-4,-97),(109,-97))
for x in (-109,109):
    fence((x,-97),(x,-10)); fence((x,16),(x,97))
fence((-109,97),(-25,97)); fence((-9,97),(109,97))

cottage=item("Model","Cottage",plot)
# Occupies NW zone; open doorway, accessible interior, stairs and functional porch.
part("Foundation",cottage,(36,1.4,30),(-48,.7,-46),(128,125,106))
part("Floor",cottage,(34,.5,28),(-48,1.65,-46),WOOD)
part("BackWall",cottage,(34,11,1),(-48,7.4,-59.5),(200,186,149))
for x in (-64.5,-31.5): part("SideWall",cottage,(1,11,28),(x,7.4,-46),(200,186,149))
for x in (-59,-37): part("FrontWall",cottage,(12,11,1),(x,7.4,-32.5),(200,186,149))
part("DoorHeader",cottage,(10,3,1),(-48,11.4,-32.5),(200,186,149))
# Open recessed threshold: no invisible collision or decorative fake door.
for x in (-53,-43): part("DoorJamb",cottage,(.7,8.4,1.2),(x,6,-32.1),TRIM)
part("DoorLintel",cottage,(10.7,.8,1.2),(-48,10.2,-32.1),TRIM)
part("OpenDoor",cottage,(.65,8,4.4),(-52.8,6,-35.5),(131,86,57))
for x in (-64.2,-31.8):
    for z in (-59.2,-32.8): part("CornerBeam",cottage,(1,11.3,1),(x,7.4,z),WOOD)
for x in (-59,-37):
    part("Window",cottage,(5,4,.18),(x,7.1,-31.92),(105,133,130))
    for dx in (-2.65,2.65): part("WindowFrame",cottage,(.45,4.6,.55),(x+dx,7.1,-31.7),TRIM)
    for y in (4.85,9.35): part("WindowFrame",cottage,(5.8,.45,.55),(x,y,-31.7),TRIM)
    part("WindowMullion",cottage,(.3,4,.35),(x,7.1,-31.65),WOOD)
    part("Sill",cottage,(6,.5,1.3),(x,4.7,-31.4),WOOD)
for dx,angle in [(-9.2,math.radians(28)),(9.2,math.radians(-28))]:
    part("RoofPlane",cottage,(21.2,1.1,33),(-48+dx,17.4,-46),ROOF,angle,"z")
part("Ridge",cottage,(1.25,1.0,34),(-48,22.3,-46),(139,77,55))
# Gable fills use simple wedges, broad planes without shingle detail.
for z in (-31.5,-60.5):
    for dx,angle in [(-8.5,0),(8.5,math.pi)]:
        part("Gable",cottage,(1,9,17),(-48+dx,16.9,z),WOOD,math.pi/2+angle,cls="WedgePart")
part("PorchDeck",cottage,(36,1.2,9),(-48,1.25,-27),WOOD)
for x in (-64,-32):
    part("PorchPost",cottage,(1.1,10.5,1.1),(x,6.8,-23.3),WOOD)
    part("PorchFoot",cottage,(1.6,.7,1.6),(x,2.1,-23.3),TRIM)
part("PorchBeam",cottage,(36,1,1.3),(-48,11.5,-23.3),WOOD)
part("PorchRoof",cottage,(38,.9,11),(-48,12.4,-26.5),ROOF,math.radians(9),"x")
for i in range(3): part("Step",cottage,(13,.5*(i+1),2.1),(-48,.25*(i+1),-17.7-i*1.8),WOOD)
for x in (-61,-35): part("PorchRail",cottage,(7,.65,.6),(x,4,-23.2),TRIM)
part("Chimney",cottage,(3,8,3),(-58,21,-53),(148,144,126))
part("ChimneyCap",cottage,(3.8,.6,3.8),(-58,25,-53),(133,132,116))

areas=folder("GrowingAreas",plot)
positions=[(-45,48),(-83,43),(-85,-3),(-46,3),(-6,-49),(30,-52),(-8,-79),(29,-80)]
for i,(x,z) in enumerate(positions,1):
    area=item("Model",f"Area{i:02}",areas)
    item("BoolValue","Unlocked",area,Value=("bool",i==1))
    part("ReservedFootprint",area,(20,.08,18),(x,.05,z),(151,157,105),collide=False,transparent=1 if i==1 else .55)
    if i==1:
        part("Soil",area,(19,.8,17),(x,.45,z),SOIL)
        for dx in (-10,10): part("BedBorder",area,(1,1.4,19),(x+dx,.8,z),WOOD)
        for dz in (-9,9): part("BedBorder",area,(21,1.4,1),(x,.8,z+dz),WOOD)
        for dx in (-10,10):
            for dz in (-9,9): part("CornerPost",area,(1.4,1.8,1.4),(x+dx,.9,z+dz),TRIM)
        slots=folder("Slots",area)
        for j,(dx,dz) in enumerate([(-4.8,-4.3),(4.8,-4.3),(-4.8,4.3),(4.8,4.3)],1):
            slot=part(f"Slot{j}",slots,(5,.18,5),(x+dx,.95,z+dz),(125,91,64),collide=False)
            prompt("Plant",slot,"Plant pepper",f"Pepper slot {j}",False)
    else:
        for dx in (-10,10):
            for dz in (-9,9): part("ReservationStake",area,(.6,1,.6),(x+dx,.5,z+dz),WOOD)

reserved=folder("FutureSpace",plot)
part("GreenhouseFootprint",reserved,(27,.1,32),(78,.06,-63),(166,170,129),collide=False,transparent=.4)
for x in (64.5,91.5):
    for z in (-79,-47): part("GreenhouseStake",reserved,(.75,1.5,.75),(x,.75,z),WOOD)
sign("GreenhouseSign",reserved,(82,3,-45),"FUTURE\nGREENHOUSE",13)
# Uninterrupted lawn clear of paths: 12,528 square studs / 39,856 usable = 31.43%.
part("CustomizationLawn",reserved,(108,.1,116),(50,.08,34),GRASS,collide=False,transparent=1)

digging=folder("Digging",plot)
dirt=part("Dirt",digging,(22,.16,14),(-48,.09,53),(112,86,61),transparent=1,Shape=("token",0))
part("PitSoilBridge",digging,(8,.16,14),(-48,.09,53),(112,86,61))
for x in (-52,-44):
    part("PitSoilRound",digging,(.16,14,14),(x,.09,53),(112,86,61),math.pi/2,"z",Shape=("token",2))
dig_prompt=prompt("Dig",dirt,"Claim at the gate first", "Welcome sign by the entrance",True)
dig_prompt.find("Properties/float[@name='MaxActivationDistance']").text="14"
offset=ET.SubElement(dig_prompt.find("Properties"),"Vector2",name="UIOffset")
ET.SubElement(offset,"X").text="0"; ET.SubElement(offset,"Y").text="-65"
for dx,dz,a in [(-9,-4,.3),(9,-4,-.4),(-8,5,-.2),(8,5,.2)]:
    part("PitEdgeRock",digging,(2.6,.55,1.7),(-48+dx,.28,53+dz),(146,134,106),a,cls="WedgePart")
dig_board=sign("DigSign",digging,(-51,4.5,44),"DIG HERE\nClaim at gate · then hold E\nOr equip Shovel + click",15)
dig_gui=dig_board.find("Item")
dig_gui.find("Item/Properties/string[@name='Text']").text="DIG HERE"
for field,vals in [("Position",(0,0,0,4)),("Size",(1,0,0,48))]:
    prop=dig_gui.find(f"Item/Properties/UDim2[@name='{field}']")
    for e,v in zip(prop,vals): e.text=str(v)
coin=item("ImageLabel","SterneIcon",dig_gui,BackgroundTransparency=("float",1),ScaleType=("token",3),Position=("UDim2",(0,130,0,60)),Size=("UDim2",(0,64,0,64)))
ET.SubElement(ET.SubElement(coin.find("Properties"),"Content",name="Image"),"url").text="rbxassetid://79465188173312"
item("TextLabel","Reward",dig_gui,Text=("string","+1 Sterne · possible seed"),TextSize=("float",32),TextColor3=("Color3",(245,233,207)),BackgroundTransparency=("float",1),Font=("token",20),Position=("UDim2",(0,202,0,60)),Size=("UDim2",(0,445,0,64)))
item("TextLabel","Controls",dig_gui,Text=("string","Claim at gate · then hold E\nOr equip Shovel + click"),TextSize=("float",27),TextColor3=("Color3",(245,233,207)),BackgroundTransparency=("float",1),Font=("token",20),Position=("UDim2",(0,10,0,132)),Size=("UDim2",(1,-20,0,78)))
# The path approaches the opposite face of this board.
import copy
dig_back=copy.deepcopy(dig_board.find("Item"))
for n in dig_back.iter("Item"):
    n.attrib["referent"] += "Back"
dig_back.find("Properties/string[@name='Name']").text="BackLettering"
dig_back.find("Properties/token[@name='Face']").text="5"
dig_board.append(dig_back)
part("DarkSoilBridge",digging,(8,.07,9),(-48,.21,53),(95,70,51))
for x in (-52,-44):
    part("DarkSoilRound",digging,(.07,9,9),(x,.21,53),(95,70,51),math.pi/2,"z",Shape=("token",2))
for x,z,a in [(-54,51,.4),(-44,55,-.7),(-49,56,.1)]:
    part("EarthClod",digging,(2.4,.45,1.6),(x,.31,z),(124,91,61),a,cls="WedgePart")
for i in range(10):
    a=i*math.pi/5
    x,z=-48+9.4*math.cos(a),53+5.55*math.sin(a)
    tangent=math.atan2(-5.55*math.cos(a),-9.4*math.sin(a))
    part("SoilShoulder",digging,(3.5,.4,1.25),(x,.3,z),(121,94,65),tangent,cls="WedgePart")
# A large ordinary shovel planted beside the earth, separate from crop reservations.
part("ShovelBlade",digging,(2,2.2,.4),(-58,1.2,50),(108,116,111),-.2,"z")
part("ShovelHandle",digging,(.4,5.5,.4),(-57.3,4.4,50),WOOD,-.2,"z")
part("ShovelGrip",digging,(1.7,.45,.5),(-56.75,7.05,50),TRIM,-.2,"z")
arrival=folder("Arrival",plot)
# Exact approved PNG, uploaded with the user's explicit authorization.
LOGO_ASSET="rbxassetid://106918218372175"
NAVY=(36,56,72)
def set_prop(node,name,kind,value):
    props=node.find("Properties")
    old=props.find(f"*[@name='{name}']")
    if old is not None: props.remove(old)
    e=ET.SubElement(props,kind,name=name)
    if kind in ("Color3","Vector3"):
        for k,v in zip("RGB" if kind=="Color3" else "XYZ",value): ET.SubElement(e,k).text=str(v/255 if kind=="Color3" else v)
    else: e.text=str(value).lower() if isinstance(value,bool) else str(value)
part("ClaimSignPost",arrival,(1,8,1),(-3.4,4,73.3),WOOD)
part("WelcomeRightPost",arrival,(1,8,1),(7.4,4,73.3),WOOD)
part("WelcomeTimberBacking",arrival,(14.3,9.8,.7),(2,7,73.7),WOOD)
board=sign("ClaimSign",arrival,(2,7,74.15),"",13.5,False)
set_prop(board,"Size","Vector3",(13.5,9,.5)); set_prop(board,"Color","Color3",NAVY)
gui=board.find('Item')
gui.remove(gui.find('Item'))
canvas=gui.find("Properties/Vector2[@name='CanvasSize']")
canvas.find('X').text='1536'; canvas.find('Y').text='1024'
logo=item("ImageLabel","ApprovedLogo",gui,BackgroundTransparency=("float",1),ScaleType=("token",3))
content=ET.SubElement(logo.find("Properties"),"Content",name="Image")
ET.SubElement(content,"url").text=LOGO_ASSET
ud=ET.SubElement(logo.find("Properties"),"UDim2",name="Size")
for k,v in [("XS",1),("XO",0),("YS",1),("YO",0)]: ET.SubElement(ud,k).text=str(v)
guidance=sign("ClaimGuidance",arrival,(2,1.7,74.2),"Claim your homestead",12.2,False)
set_prop(guidance,"Size","Vector3",(12.2,.95,.4))
canvas=guidance.find("Item/Properties/Vector2[@name='CanvasSize']")
canvas.find('X').text='976'; canvas.find('Y').text='76'
claim_prompt=prompt("Claim",board,"Claim free homestead","Welcome to Luna Landing")
offset=ET.SubElement(claim_prompt.find("Properties"),"Vector2",name="UIOffset")
ET.SubElement(offset,"X").text="0"; ET.SubElement(offset,"Y").text="130"
part("ArrivalSpawn",arrival,(6,.2,6),(-14,.2,82),CREAM,cls="SpawnLocation",Neutral=("bool",True),Duration=("float",0),Transparency_override=("float",1))
# Remove synthetic convenience property; actual Transparency is overridden in XML.
spawn=nodes[-1].find("Properties")
spawn.remove(spawn.find("float[@name='Transparency_override']"))
spawn.find("float[@name='Transparency']").text="1"

# Sparse layered accents. All are placed outside planting/greenhouse/lawn reservations.
accents=folder("VisualAccents",plot)
for x in (-64,-32):
    part("PorchPostCap",accents,(1.8,.65,1.8),(x,10.75,-23.3),WOOD)
    part("PorchPostBase",accents,(1.8,1.3,1.8),(x,2.3,-23.3),TRIM)
    for dx in (-1,1):
        part("PorchBrace",accents,(.6,2.6,.8),(x+dx*.85,10.3,-23.3),WOOD,dx*math.radians(38),"z")
for dx,angle in [(-9.2,math.radians(28)),(9.2,math.radians(-28))]:
    part("FrontRoofFascia",accents,(21.5,1.3,.9),(-48+dx,17.35,-29.3),(173,104,70),angle,"z")
part("GableKingPost",accents,(1.3,7.5,.8),(-48,16.6,-30.75),TRIM)
part("GableCrossbeam",accents,(32,1.2,.8),(-48,13.25,-30.75),WOOD)
for x in (-59,-37):
    part("WindowCrossbar",accents,(5.2,.35,.4),(x,7,-31.55),WOOD)
    part("WindowHood",accents,(6.3,.65,1),(x,9.65,-31.55),WOOD)
for x in (-62,-34):
    part("PorchRailEnd",accents,(.8,2.6,.8),(x,3.1,-23.2),WOOD)
part("DoorstepMat",accents,(7,.09,3),(-48,1.9,-29),(123,112,82),collide=False)
# Broad faceted foliage: eight simple corner wedges per clump, no textures or mesh uploads.
def shrub(x,z,s=1):
    for ox,oz,scale,color in [(0,0,s,(105,127,70)),(1.8*s,.8*s,s*.65,(119,138,78))]:
        for bottom in (False,True):
            for i in range(4):
                a=i*math.pi/2+.22
                dx=(math.cos(a)+math.sin(a))*scale
                dz=(-math.sin(a)+math.cos(a))*scale
                angle=a+math.pi/2
                pos=(x+ox+dx,(.7 if bottom else 2.1)*scale,z+oz+(-dz if bottom else dz))
                node=part("FoliageClump",accents,(2*scale,1.4*scale,2*scale),pos,color,angle,collide=False,cls="CornerWedgePart")
                if bottom:
                    c,ss=math.cos(angle),math.sin(angle)
                    values=[*pos,c,0,ss,0,-1,0,ss,0,-c]
                    for e,v in zip(node.find("Properties/CoordinateFrame"),values): e.text=str(v)
for x,z,s in [(-91,-49,1.4),(-88,-40,1),(-52,-45,1.2),(-89,-76,1.1),(-103,90,1.2),(102,90,1.2),(102,-90,1.1),(-102,-90,1.2),(-29,90,.8),(0,90,.85)]: shrub(x,z,s)
# Two squat porch planters and simple, broad leaf sprays.
for x in (-61,-35):
    part("TerracottaPot",accents,(2.5,2,2.5),(x,2.8,-27),(158,100,72))
    part("PotRim",accents,(2.9,.4,2.9),(x,3.9,-27),(181,119,80))
    part("PotSoil",accents,(2.3,.15,2.3),(x,4.15,-27),SOIL)
    for j in range(3):
        part("PlanterLeaf",accents,(.45,2.4,1.2),(x+(j-1)*.55,5,-27),(105+j*6,130+j*4,73),math.radians((j-1)*28),"z",False,cls="WedgePart")
# Chunky gate caps, not extra systems or decorative clutter across the lawn.
for x in (-25,-9): part("GateCap",accents,(2,.6,2),(x,4.45,97),(159,153,128))

def translate(node,dx,dz):
    for c in node.iter("CoordinateFrame"):
        c.find('X').text=str(float(c.find('X').text)+dx)
        c.find('Z').text=str(float(c.find('Z').text)+dz)
translate(cottage,-22,-19)
translate(digging,-24,24)
translate(arrival,-3,26)
for node in accents.findall('Item'):
    name=node.find("Properties/string[@name='Name']").text
    if name not in ('FoliageClump','GateCap'): translate(node,-22,-19)

# Slightly varied reservation orientations reinforce loose garden groups.
for area,angle,(cx,cz) in zip(areas.findall('Item'),[0,-.07,.06,-.04,.05,-.06,.04,-.05],positions):
    co,si=math.cos(angle),math.sin(angle)
    for frame in area.iter('CoordinateFrame'):
        x,z=float(frame.find('X').text)-cx,float(frame.find('Z').text)-cz
        frame.find('X').text=str(cx+co*x+si*z)
        frame.find('Z').text=str(cz-si*x+co*z)
        for col in range(3):
            r0=float(frame.find(f'R0{col}').text); r2=float(frame.find(f'R2{col}').text)
            frame.find(f'R0{col}').text=str(co*r0+si*r2)
            frame.find(f'R2{col}').text=str(-si*r0+co*r2)

# One shared produce box sits outside the farm gate, beside the approach path.
commerce=folder("Commerce",plot)
sell_box=item("Model","SellBox",commerce)
part("BoxBase",sell_box,(4.4,2.4,3.6),(-29,1.3,102),(155,121,82))
box_lid=part("BoxLid",sell_box,(4.8,.45,4),(-29,2.7,102),(112,85,58))
for x in (-31.05,-29,-26.95):
    part("LidSlat",sell_box,(.14,.5,3.7),(x,2.98,102),(178,139,91))
garden_status=folder("GardenStatusDisplay",areas.find("Item"))
display=part("StatusDisplay",garden_status,(10.8,4.2,.3),(-45,10.4,62),(48,54,56),0,collide=False,transparent=.12)
display.find("Properties/token[@name='Material']").text="272"  # Dark glass-like status pane.
display_gui=item("SurfaceGui","Lettering",display,Face=("token",5),CanvasSize=("Vector2",(1200,450)),AlwaysOnTop=("bool",True),LightInfluence=("float",0))
label=item("TextLabel","Preview",display_gui,Text=("string","GROW BOX\nFOUR SLOT GROWTH STATUS"),TextSize=("float",44),TextScaled=("bool",True),TextColor3=("Color3",(247,236,211)),BackgroundTransparency=("float",1),TextWrapped=("bool",True),Font=("token",20))
ud=ET.SubElement(label.find("Properties"),"UDim2",name="Size")
for k,v in [("XS",.94),("XO",0),("YS",.84),("YO",0)]: ET.SubElement(ud,k).text=str(v)
ud=ET.SubElement(label.find("Properties"),"UDim2",name="Position")
for k,v in [("XS",.03),("XO",0),("YS",.07),("YO",0)]: ET.SubElement(ud,k).text=str(v)
prompt("Sell",box_lid, "Sell produce", "Shared box · Sterne for all harvests")

from autumn_world import enrich_world
enrich_world(plot, workspace, part, item, folder)

service=item("ServerScriptService","ServerScriptService",doc)
item("Script","LunaPrototype",service,Source=("ProtectedString",(ROOT/"src/Prototype.server.luau").read_text()))
starter=item("StarterPlayer","StarterPlayer",doc)
starter_scripts=item("StarterPlayerScripts","StarterPlayerScripts",starter)
item("LocalScript","LunaInterface",starter_scripts,Source=("ProtectedString",(ROOT/"src/Interface.client.luau").read_text()))
lighting=item("Lighting","Lighting",doc,ClockTime=("float",15.3),Brightness=("float",2.2),GlobalShadows=("bool",True),Ambient=("Color3",(91,87,80)),OutdoorAmbient=("Color3",(128,139,150)))
item("Atmosphere","AutumnDistance",lighting,Density=("float",.22),Offset=("float",.12),Color=("Color3",(213,224,235)),Decay=("Color3",(151,170,184)),Haze=("float",.8),Glare=("float",0))
def look_at(eye,target):
    def norm(v):
        l=math.sqrt(sum(x*x for x in v)); return [x/l for x in v]
    def cross(a,b): return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
    back=norm([a-b for a,b in zip(eye,target)])
    right=norm(cross([0,1,0],back)); up=cross(back,right)
    return [*eye,*[v for row in zip(right,up,back) for v in row]]
camera=item("Camera","Camera",workspace,CFrame=("CoordinateFrame",look_at((128,105,182),(-12,12,-38))))
ET.SubElement(workspace.find("Properties"),"Ref",name="CurrentCamera").text=camera.attrib["referent"]
ET.indent(doc)
target=OUT/"LunaLanding-FirstPlot.rbxlx"
ET.ElementTree(doc).write(target,encoding="utf-8",xml_declaration=True)
print(f"Wrote {target}: {len(nodes)} instances, {sum(n.attrib['class'] in ('Part','WedgePart','CornerWedgePart','SpawnLocation') for n in nodes)} parts")

# Apply a rebuilt visual pass to this prototype in Edit mode without replacing scripts,
# unrelated workspace content, or the plot model. Names plus sibling ordinal resolve
# repeated rails/boards. Newly introduced objects are created as needed.
def lua_value(e):
    if e.tag=="Content": return json.dumps(e.find("url").text)
    if e.tag in ("string","ProtectedString"): return json.dumps(e.text or "",ensure_ascii=False)
    if e.tag=="bool": return e.text
    if e.tag in ("float","int","token"): return e.text
    if e.tag=="Vector3": return "Vector3.new("+",".join(c.text for c in e)+")"
    if e.tag=="Color3": return "Color3.new("+",".join(c.text for c in e)+")"
    if e.tag=="CoordinateFrame": return "CFrame.new("+",".join(c.text for c in e)+")"
    if e.tag=="Vector2": return "Vector2.new("+",".join(c.text for c in e)+")"
    if e.tag=="UDim2": return "UDim2.new("+",".join(c.text for c in e)+")"
    if e.tag=="UDim": return "UDim.new("+",".join(c.text for c in e)+")"
    raise ValueError(e.tag)

lines=["assert(not game:GetService('RunService'):IsRunning(), 'Stop Play first')", "local root=workspace:FindFirstChild('LunaLandingFirstPlot')", "assert(root, 'Expected prototype missing')", "local function child(parent,name,class,ordinal)", "local found=0 for _,c in parent:GetChildren() do if c.Name==name and c.ClassName==class then found+=1 if found==ordinal then return c end end end", "local c=Instance.new(class) c.Name=name c.Parent=parent return c end"]
def emit(parent,parent_var):
    counts={}
    for node in parent.findall("Item"):
        props=node.find("Properties")
        name=props.find("string[@name='Name']").text
        cls=node.attrib['class']; key=(name,cls); counts[key]=counts.get(key,0)+1
        var="n"+node.attrib['referent'][3:]
        lines.append(f"local {var}=child({parent_var},{json.dumps(name)},{json.dumps(cls)},{counts[key]})")
        for e in props:
            if e.attrib['name']=="Name": continue
            lines.append(f"{var}.{e.attrib['name']}={lua_value(e)}")
        # Every subtree gets its own local scope, including the larger forest.
        lines.append("do")
        emit(node,var)
        lines.append("end")
lines.append("-- Boundary is generator-owned: rebuild it so removed rails do not seal new passages.")
lines.append("for _,c in root.Boundary:GetChildren() do c:Destroy() end")
emit(plot,"root")
lines.append("local light=game:GetService('Lighting')")
for e in lighting.find('Properties'):
    if e.attrib['name'] != 'Name': lines.append(f"light.{e.attrib['name']}={lua_value(e)}")
emit(lighting,"light")
lines.append("return 'Visual geometry synchronized'")
# Lua local-register limit: isolate each top-level folder/model in its own do block.
# Each block uses fewer than 200 locals, including repeated fence parts.
source="\n".join(lines)
for node in plot.findall('Item'):
    marker=f"local n{node.attrib['referent'][3:]}="
    source=source.replace(marker,"end\ndo\n"+marker,1)
source=source.replace("end\ndo\nlocal n", "do\nlocal n",1)
source=source.replace("return 'Visual geometry synchronized'","end\nreturn 'Visual geometry synchronized'")
(OUT/"SyncVisuals.luau").write_text(source)
# Narrow sign update for live Studio, preserving the rest of the existing place.
lines=lines[:6]
lines.append("local arrival=root.Arrival")
emit(arrival,"arrival")
lines.append("return 'Welcome sign updated'")
(OUT/"SyncWelcomeSign.luau").write_text("\n".join(lines))
