"""Replace only the two background folders in the current saved gameplay scene.

Self-contained faceted geometry: native wedges, no uploads or runtime generation.
Run from any directory with Python. Keeps a dated backup and verifies all other
saved scene data is identical. Never invokes the old standalone world builder.
"""
import copy
import json
import math
import random
import uuid
import xml.etree.ElementTree as E
from collections import Counter
from datetime import datetime
from pathlib import Path

BASE = Path(__file__).resolve().parent
TARGET = BASE / 'build/LunaLanding-AutumnReview.rbxlx'
V = lambda x, y, z: (x, y, z)
def add(a,b): return tuple(x+y for x,y in zip(a,b))
def sub(a,b): return tuple(x-y for x,y in zip(a,b))
def mul(a,s): return tuple(x*s for x in a)
def dot(a,b): return sum(x*y for x,y in zip(a,b))
def cross(a,b): return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def length(a): return math.sqrt(dot(a,a))
def unit(a): return mul(a,1/length(a))
def name(n): return n.findtext('./Properties/string[@name="Name"]')
def child(n,s): return next(x for x in n.findall('Item') if name(x)==s)
def prop(n,kind,key,value):
    p=E.SubElement(n.find('Properties'),kind,name=key)
    tags={'Vector3':['X','Y','Z'],'Color3':['R','G','B'],
          'CoordinateFrame':['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22']}
    if kind in tags:
        for tag,v in zip(tags[kind],value): E.SubElement(p,tag).text=str(round(v,7))
    else: p.text=str(value).lower() if isinstance(value,bool) else str(value)
def node(cls,label,parent=None):
    n=E.Element('Item',{'class':cls,'referent':'RBX'+uuid.uuid4().hex.upper()})
    E.SubElement(n,'Properties');prop(n,'string','Name',label)
    if parent is not None: parent.append(n)
    return n
def frame(pos,right=(1,0,0),up=(0,1,0),back=(0,0,1)):
    return [*pos,*[v for i in range(3) for v in (right[i],up[i],back[i])]]
def part(parent,label,size,cf,color,cls='Part',material=272):
    n=node(cls,label,parent)
    for k,v in [('Anchored',True),('CanCollide',False),('CanTouch',False),('CanQuery',False)]:prop(n,'bool',k,v)
    prop(n,'Vector3','Size',size);prop(n,'CoordinateFrame','CFrame',cf)
    prop(n,'Color3','Color',tuple(c/255 for c in color));prop(n,'token','Material',material)
    prop(n,'token','TopSurface',0);prop(n,'token','BottomSurface',0)
    return n
def tint(c,d): return tuple(max(0,min(255,x+d)) for x in c)
def triangle(parent,label,a,b,c,color,thickness=.025):
    # Split on the longest edge so both pieces are right triangles.
    ab,ac,bc=sub(b,a),sub(c,a),sub(c,b)
    if dot(ab,ab)>dot(ac,ac) and dot(ab,ab)>dot(bc,bc): a,c=c,a
    elif dot(ac,ac)>dot(bc,bc): a,b=b,a
    ab,ac,bc=sub(b,a),sub(c,a),sub(c,b)
    if length(cross(ab,ac))<1e-7:return
    right=unit(cross(ac,ab));back=unit(bc);up=unit(cross(bc,right))
    h=abs(dot(ab,up))
    for p,q,r,z in [(a,b,right,back),(a,c,mul(right,-1),mul(back,-1))]:
        w=abs(dot(sub(q,p),back))
        if w>.001:part(parent,label,(thickness,h,w),frame(mul(add(p,q),.5),r,up,z),color,'WedgePart')

PHI=(1+math.sqrt(5))/2
ICO=[(-1,PHI,0),(1,PHI,0),(-1,-PHI,0),(1,-PHI,0),(0,-1,PHI),(0,1,PHI),(0,-1,-PHI),(0,1,-PHI),(PHI,0,-1),(PHI,0,1),(-PHI,0,-1),(-PHI,0,1)]
FACES=[(0,11,5),(0,5,1),(0,1,7),(0,7,10),(0,10,11),(1,5,9),(5,11,4),(11,10,2),(10,7,6),(7,1,8),(3,9,4),(3,4,2),(3,2,6),(3,6,8),(3,8,9),(4,9,5),(2,4,11),(6,2,10),(8,6,7),(9,8,1)]
def crown(parent,center,radii,col,yaw):
    co,si=math.cos(yaw),math.sin(yaw)
    vertices=[]
    for v in ICO:
        x,y,z=(v[i]/PHI*radii[i] for i in range(3))
        vertices.append(add(center,(x*co+z*si,y,-x*si+z*co)))
    for i,f in enumerate(FACES):triangle(parent,'CanopyFacet',*(vertices[j] for j in f),tint(col,(-4,0,3,0,5)[i%5]))
def limb(parent,a,b,width,col):
    up=unit(sub(b,a));ref=(0,0,1) if abs(up[2])<.9 else (1,0,0)
    right=unit(cross(up,ref));back=cross(right,up)
    return part(parent,'Branch',(width,length(sub(b,a)),width*.86),frame(mul(add(a,b),.5),right,up,back),col)

def tree(parent,species,x,z,scale,yaw,index):
    m=node('Model',f'{species}_{index:02}',parent)
    co,si=math.cos(yaw),math.sin(yaw)
    def p(a):
        dx,y,dz=mul(a,scale)
        return (x+dx*co+dz*si,y,-dx*si+dz*co+z)
    wood=(103,77,54)
    specs={
        'Oak':((91,116,62),[(0,19,0,8.4,7,7),(-6,16,1,6.7,5.8,6),(5,17,-3,7.4,6.2,6),(1,23,1,5.6,5.2,5)]),
        'Maple':((174,91,49),[(0,21,0,7,8,6),(-5,17,1,6,6,5.5),(5,18,-1,6.2,6.4,5.7),(1,26,0,4.4,5,4)]),
        'Birch':((190,155,66),[(-1,22,0,4.5,7,4),(2,28,0,4,6,3.6),(-4,18,1,4,5,3.4)]),
        'Aspen':((156,166,74),[(0,19,0,4.4,8,4),(-2,25,0,4,6.5,3.8),(1,30,-1,3.1,4.5,3)]),
    }
    if species in ('Fir','Pine'):
        tall=34 if species=='Fir' else 27
        limb(m,p((0,0,0)),p((.4,tall-3,0)),1.25*scale,wood)
        col=(49,87,68) if species=='Fir' else (76,105,69)
        for level,(cy,r,h) in enumerate([(11,8,12),(18,6.4,11),(25,4.5,10)] if species=='Fir' else [(10,9,10),(16,7,10),(22,4.8,9)]):
            tip=p((.35,cy+h*.63,-.2));bottom=p((0,cy-h*.32,0))
            ring=[p((math.cos(j*math.pi/3+.22*level)*r,cy-h*.24+(j%2)*.7,math.sin(j*math.pi/3+.22*level)*r)) for j in range(6)]
            for j in range(6):
                triangle(m,'NeedleTier',ring[j],ring[(j+1)%6],tip,tint(col,level*5+(j%3)*2))
                triangle(m,'TierUnderside',ring[(j+1)%6],ring[j],bottom,tint(col,-7+level*5))
    else:
        col,clusters=specs[species]
        col=tint(col,(index%3-1)*5)
        wood=(192,184,158) if species in ('Birch','Aspen') else wood
        height=24 if species in ('Birch','Aspen') else 18
        limb(m,p((0,0,0)),p((.7,height,0)),(1.05 if species in ('Birch','Aspen') else 2)*scale,wood)
        for j,(cx,cy,cz,rx,ry,rz) in enumerate(clusters):
            limb(m,p((.4,10+j*2,0)),p((cx,cy,cz)),(.62 if species in ('Birch','Aspen') else 1)*scale,wood)
            crown(m,p((cx,cy,cz)),mul((rx,ry,rz),scale),tint(col,(j%3-1)*7),yaw+j*.65)
        if species in ('Birch','Aspen'):
            for j in range(4):
                part(m,'BarkMark',(.65*scale,.23*scale,.07*scale),frame(p((.04+j*.08,3+j*3,-.47)),(co,0,-si),(0,1,0),(si,0,co)),(111,111,94))
    return m

def ridge(parent,label,cx,cz,width,depth,height,col,seed):
    """Uneven ridge with broad shoulders and offset summits, closed to the ground."""
    rng=random.Random(seed);m=node('Model',label,parent)
    # Five irregular sections; a meandering crest between front and back slopes.
    profiles=[
        ([ -.5,-.29,-.06,.24,.5],[.04,.88,.52,1,.03]), # twin summits
        ([ -.5,-.25,.02,.29,.5],[.04,.86,1,.81,.04]), # broad high shoulder
        ([ -.5,-.30,-.09,.19,.5],[.03,.43,1,.38,.03]), # offset sharp summit
        ([ -.5,-.23,.05,.31,.5],[.04,1,.88,.48,.03]), # long descending ridge
    ]
    xs,tops=profiles[seed%len(profiles)]
    rows=[]
    for i,x in enumerate(xs):
        crest=cz+rng.uniform(-.12,.12)*depth
        h=height*tops[i]*rng.uniform(.86,1.13)
        rows.append([(cx+x*width,-2,cz-depth*.48),
                     (cx+(x-.025)*width,h*.38,crest-depth*.20),
                     (cx+x*width,h,crest),
                     (cx+(x+.025)*width,h*.29,crest+depth*.25),
                     (cx+x*width,-2,cz+depth*.5)])
    for i in range(4):
        for j in range(4):
            a,b,c,d=rows[i][j],rows[i+1][j],rows[i+1][j+1],rows[i][j+1]
            shade=tint(col,[-3,3,-1,5][j]+(i%2)*3)
            for tri in ((a,b,d),(b,c,d)) if (i+j)%2 else ((a,b,c),(a,c,d)):
                triangle(m,'RockPlane',*tri,shade,.08)
    for i in (0,4):
        for j in range(1,4):triangle(m,'RidgeEnd',rows[i][0],rows[i][j],rows[i][j+1],col,.08)
    triangle(m,'Base',rows[0][0],rows[4][0],rows[4][4],col,.08)
    triangle(m,'Base',rows[0][0],rows[4][4],rows[0][4],col,.08)
    return m

def generate():
    forest=node('Folder','AutumnForest');mountains=node('Folder','DistantMountains')
    rng=random.Random(1014);positions=[]
    # Irregular groves replace the old evenly spaced rows. Keep the north lane open.
    for gx,gz,count in [(-305,-215,7),(-174,-260,7),(125,-230,7),(284,-265,8),(-330,-365,5),(80,-390,6),(330,-410,5)]:
        for j in range(count):
            a=j*2.399;radius=12+math.sqrt(j)*20
            x=gx+math.cos(a)*radius;z=gz+math.sin(a)*radius*.8
            if abs(x+17)>35:positions.append((x,z))
    positions += [(-128,-69),(129,-76),(-133,76),(137,77),(-206,-104),(209,-112),(-215,65),(228,64),(-225,205),(228,204),(-193,268),(207,275)]
    species=['Oak','Maple','Birch','Fir','Oak','Pine','Maple','Aspen']
    for i,(x,z) in enumerate(positions):
        tree(forest,species[i%len(species)],x,z,rng.uniform(.82,1.24),rng.uniform(0,math.tau),i+1)
    # Offset rock groups leave open horizons instead of encircling the village.
    specs=[(-590,-840,380,225,151),(-300,-970,440,230,196),(65,-1000,470,270,176),(430,-905,410,225,183),(720,-800,350,240,135)]
    for i,(x,z,w,d,h) in enumerate(specs):ridge(mountains,f'BlueRidge_{i+1:02}',x,z,w,d,h,(126+i%2*5,145+i%2*4,155+i%2*4),100+i)
    for i,(x,z,w,d,h) in enumerate([(-480,-695,325,210,95),(-180,-770,360,200,112),(195,-745,370,210,89),(490,-670,330,225,105)]):
        ridge(mountains,f'SageFoothill_{i+1:02}',x,z,w,d,h,(102+i%2*7,125+i%2*6,111+i%2*7),210+i)
    return forest,mountains

def main():
    original=TARGET.read_bytes();root=E.fromstring(original)
    plot=child(child(root,'Workspace'),'LunaLandingFirstPlot');art=child(plot,'AutumnDetails')
    old={key:child(art,key) for key in ('AutumnForest','DistantMountains')}
    untouched=copy.deepcopy(root)
    ua=child(child(child(untouched,'Workspace'),'LunaLandingFirstPlot'),'AutumnDetails')
    for key in old:ua.remove(child(ua,key))
    new=generate()
    for group in new:
        art.remove(old[name(group)]);art.append(group)
    check=copy.deepcopy(root);ca=child(child(child(check,'Workspace'),'LunaLandingFirstPlot'),'AutumnDetails')
    for key in old:ca.remove(child(ca,key))
    assert E.tostring(check)==E.tostring(untouched),'Unrelated scene data changed'
    parts=[n for g in new for n in g.iter('Item') if n.get('class') in ('Part','WedgePart')]
    for n in parts:
        for key in ('CanCollide','CanTouch','CanQuery'):assert n.findtext(f'./Properties/bool[@name="{key}"]')=='false'
        assert min(float(v.text) for v in n.find('./Properties/Vector3[@name="Size"]'))>0
    backup=TARGET.with_name('LunaLanding-AutumnReview.before-background-'+datetime.now().strftime('%Y%m%d-%H%M%S')+'.rbxlx')
    backup.write_bytes(original)
    E.ElementTree(root).write(TARGET,encoding='utf-8',xml_declaration=True)
    pack=E.Element('roblox',version='4')
    for g in new:pack.append(copy.deepcopy(g))
    E.ElementTree(pack).write(BASE/'build/BackgroundScenery.rbxmx',encoding='utf-8',xml_declaration=True)
    # Distinct filename lets Studio open current saved content without reusing an old tab.
    preview=BASE/'build/LunaLanding-BackgroundReview.rbxlx';preview.write_bytes(TARGET.read_bytes())
    report={'trees':len(new[0].findall('Item')),'species':dict(Counter(name(n).split('_')[0] for n in new[0].findall('Item'))),
            'ridges':len(new[1].findall('Item')),'native_parts':len(parts),'unrelated_scene_preserved':True,'all_scenery_nonblocking':True,'backup':str(backup)}
    (BASE/'build/background-verification.json').write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
