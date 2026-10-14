-- Rebuild AssetWorkshop in Edit mode. Self-contained, baked local meshes; no uploads.
-- Run via Command Bar / Studio MCP, never against the gameplay place.
local GeometryService = game:GetService("GeometryService")
local V = Vector3.new
local C = Color3.fromRGB
local palette = {leaf=C(79,119,42),stem=C(65,99,36),red=C(222,43,28),gold=C(239,167,25),green=C(120,156,44),soil=C(104,70,44)}
local templates = Instance.new("Folder")
templates.Name = "PumpkinMeshTemplates"

-- Bake closed faceted shells into native UnionOperations. These carry local
-- MeshData in rbxlx, unlike transient EditableMesh-backed MeshParts.
local function mesh(name, vertices, faces, color)
    local pieces={}
    local function wedge(a,b,c)
        local ab,ac,bc=b-a,c-a,c-b
        if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c
        elseif ac:Dot(ac)>ab:Dot(ab) and ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
        ab,ac,bc=b-a,c-a,c-b
        local right=ac:Cross(ab).Unit; local back=bc.Unit; local up=bc:Cross(right).Unit
        local height=math.abs(ab:Dot(up))
        for _,s in {{(a+b)/2,right,up,back,math.abs(ab:Dot(back))},{(a+c)/2,-right,up,-back,math.abs(ac:Dot(back))}} do
            if s[5]>.00001 then
                local p=Instance.new("WedgePart"); p.Size=V(.003,height,s[5]); p.CFrame=CFrame.fromMatrix(s[1],s[2],s[3],s[4]); p.Color=color; p.Anchored=true
                table.insert(pieces,p)
            end
        end
    end
    for i,t in faces do
        local a,b,c=vertices[t[1]],vertices[t[2]],vertices[t[3]]
        local n=(b-a):Cross(c-a)
        assert(n.Magnitude>0.0000001, name.." degenerate face")
        wedge(a,b,c)
    end
    -- CSG inherits the first operand's axes. Keep them canonical so nonuniform
    -- leaf/stem scaling cannot skew the geometry or detach branches.
    local center=V(0,0,0)
    for _,v in vertices do center+=v end
    center/=#vertices
    local first=Instance.new("Part"); first.Size=V(.002,.002,.002); first.CFrame=CFrame.new(center); first.Color=color; first.Anchored=true
    local baked=GeometryService:UnionAsync(first,pieces, {SplitApart=false,CollisionFidelity=Enum.CollisionFidelity.Box,RenderFidelity=Enum.RenderFidelity.Precise})
    assert(#baked==1,"Expected one baked mesh")
    local p=baked[1]
    p.Name=name; p.Color=color; p.Material=Enum.Material.SmoothPlastic
    p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
    p.UsePartColor=true; p.SmoothingAngle=0; p:SetAttribute("DesignTriangles",#faces)
    p.Parent=templates
    first:Destroy(); for _,q in pieces do q:Destroy() end
    task.wait()
    return p
end

local function rings(name, rows, sides, color, lobe)
    local verts,faces={},{}
    for k,row in rows do
        for j=0,sides-1 do
            local angle=j*math.pi*2/sides
            local wave=math.cos(angle*8)
            local radius=row[2]*(1+(lobe or 0)*wave)
            table.insert(verts,V(math.cos(angle)*radius,row[1]+(row[3] or 0)*wave,math.sin(angle)*radius))
        end
    end
    for k=0,#rows-2 do for j=0,sides-1 do
        local a=k*sides+j+1; local b=k*sides+(j+1)%sides+1
        table.insert(faces,{a,a+sides,b}); table.insert(faces,{b,a+sides,b+sides})
    end end
    table.insert(verts,V(0,rows[1][1]+.045,0)); local bottom=#verts
    table.insert(verts,V(0,rows[#rows][1]-.015,0)); local top=#verts
    for j=0,sides-1 do
        table.insert(faces,{bottom,j+1,(j+1)%sides+1})
        local a=(#rows-1)*sides+j+1; local b=(#rows-1)*sides+(j+1)%sides+1
        table.insert(faces,{top,b,a})
    end
    return mesh(name,verts,faces,color)
end

local function tube(name,points,radii,color)
    local verts,faces={},{}
    local sides=6
    for k,center in points do
        local d=(points[math.min(k+1,#points)]-points[math.max(k-1,1)]).Unit
        local side=d:Cross(V(0,0,1)).Unit; local other=d:Cross(side).Unit
        for j=0,sides-1 do local a=j*math.pi*2/sides; table.insert(verts,center+(side*math.cos(a)+other*math.sin(a))*radii[k]) end
    end
    for k=0,#points-2 do for j=0,sides-1 do
        local a=k*sides+j+1; local b=k*sides+(j+1)%sides+1
        table.insert(faces,{a,b,a+sides}); table.insert(faces,{b,b+sides,a+sides})
    end end
    for j=2,sides-1 do table.insert(faces,{1,j+1,j}); local a=(#points-1)*sides; table.insert(faces,{a+1,a+j,a+j+1}) end
    return mesh(name,verts,faces,color)
end

-- A broad eight-lobed shell: sparse rings preserve the deliberate faceted finish.
local orange=C(225,113,27)
local body=rings("PumpkinBody",{{.04,.24,0},{.13,.57,0},{.36,.79,0},{.68,.84,0},{.94,.67,0},{1.065,.39,0},{1.01,.13,0}},32,orange,.115)
local stalk=tube("PumpkinStalk",{V(0,1.0,0),V(-.035,1.17,0),V(.07,1.34,.015),V(.17,1.39,.03)},{.12,.105,.08,.055},C(103,105,46))
local vine=tube("VineSegment",{V(0,0,0),V(0,1,0)},{.5,.36},palette.stem)
local outline={V(0,0,0),V(-.23,-.02,.11),V(-.50,-.025,.09),V(-.43,-.02,.32),V(-.66,-.06,.47),V(-.38,-.045,.58),V(-.35,-.09,.84),V(-.15,-.09,.76),V(0,-.16,1.07),V(.16,-.085,.77),V(.38,-.07,.87),V(.38,-.035,.57),V(.66,-.04,.46),V(.43,-.015,.30),V(.49,-.005,.10),V(.23,0,.12)}
local verts=table.clone(outline)
table.insert(verts,V(0,.14,.43)); table.insert(verts,V(0,.10,.43))
local faces={}
for j=1,#outline do local k=j%#outline+1; table.insert(faces,{17,k,j}); table.insert(faces,{18,j,k}) end
local leaf=mesh("LobedPumpkinLeaf",verts,faces,C(75,117,43))
local library=game.ReplicatedStorage:FindFirstChild("AssetLibrary")
assert(library and library:FindFirstChild("PepperMeshTemplates"),"Run only in the pepper AssetWorkshop")
local soil=library.PepperMeshTemplates.SoilMound
local seedLeaf=library.PepperMeshTemplates.FoldedLeaf
local function folder(name,parent)
    local f=Instance.new("Folder"); f.Name=name; f.Parent=parent; return f
end
local function model(name,parent)
    local m=Instance.new("Model"); m.Name=name; m.WorldPivot=CFrame.identity; m.Parent=parent; return m
end
local function place(t,parent,frame,scale,color)
    scale=scale or V(1,1,1)
    local p=t:Clone(); p.Size=t.Size*scale
    p.CFrame=frame*(CFrame.new(t.Position*scale)*t.CFrame.Rotation)
    if color then p.Color=color end
    p.Parent=parent; return p
end
local function branch(parent,a,b,width)
    local y=(b-a).Unit; local x=y:Cross(V(0,0,1)).Unit; local z=x:Cross(y)
    return place(vine,parent,CFrame.fromMatrix(a-y*.01,x,y,z),V(width,(b-a).Magnitude+.025,width))
end
local function fruit(parent,pos,size,yaw,color,name)
    local m=model(name or "Pumpkin",parent)
    local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
    local s=V(size,size,size*.94)
    place(body,m,cf,s,color); place(stalk,m,cf,s)
    m:SetAttribute("CropType","Pumpkin"); m:SetAttribute("AssetVersion",1)
    return m
end
-- Prepare replacements separately; never rebuild or reposition the approved peppers.
local stages=folder("PumpkinGrowthStages",nil)
local display=folder("PumpkinWorkshop",nil)
local captions=folder("Pumpkin",nil)
local function plant(stage)
    local m=model(stage,stages); m:SetAttribute("CropType","Pumpkin"); m:SetAttribute("VisualStage",stage)
    local stems=model("Vines",m); local leaves=model("Foliage",m); local fruits=model("Fruit",m)
    if stage=="Planted" then
        branch(stems,V(0,0,0),V(.02,.29,0),.065)
        for _,a in {-78,95} do place(seedLeaf,leaves,CFrame.new(0,.27,0)*CFrame.Angles(0,math.rad(a),0)*CFrame.Angles(-.3,0,.12),V(.30,.4,.4),C(99,139,54)) end
    else
        local young=stage=="Developing"
        local s=young and .6 or 1
        local paths={{V(0,.07,0),V(-.48,.10,.06),V(-.93,.10,.48),V(-1.45,.12,.53)},{V(0,.07,0),V(.46,.10,-.13),V(.91,.11,.15),V(1.34,.13,.32)},{V(0,.07,0),V(-.10,.12,-.55),V(.30,.14,-1.1)}}
        for _,path in paths do for j=1,#path-1 do branch(stems,path[j]*s,path[j+1]*s,.085*s) end end
        local specs={{-.30,.06,-65,.88,.40,-13},{.45,-.13,65,.91,.47,-7},{-.93,.48,-85,.78,.38,-13},{.91,.15,65,.77,.43,2},{-.10,-.55,-120,.88,.56,14},{.30,-1.10,45,.72,.57,22},{.03,.02,170,.93,.67,19}}
        for i,v in specs do
            if not young or i==1 or i==2 or i==5 then
                local x,z,a,l,h,p=table.unpack(v)
                local base=V(x,.10,z)*s; local tip=V(x*.92,h,z*.94)*s
                branch(stems,base,tip,.052*s)
                place(leaf,leaves,CFrame.new(tip)*CFrame.Angles(0,math.rad(a),0)*CFrame.Angles(math.rad(-p),0,math.rad((i%2==0) and 12 or -13)),V(l*s,l*s,l*s),C(75,117,43):Lerp(C(106,140,51),(i%3)*.15))
            end
        end
        if not young then
            local ripe=stage=="Ready"
            for i,v in {{-.92,.98,.91,-15},{.90,.81,.72,22}} do
                local x,z,size,yaw=table.unpack(v)
                local pos=V(x,.035,z)
                branch(stems,V(x*.72,.12,.37),pos+V(0,.1,0),.065)
                fruit(fruits,pos,ripe and size or size*.46,yaw,ripe and (i==1 and orange or C(236,141,36)) or C(134,151,48),"Pumpkin"..i)
            end
        end
    end
    return m
end
local captionTemplate=workspace.WorkshopLabels.Pepper:FindFirstChildWhichIsA("BasePart")
assert(captionTemplate,"Pepper captions must be separate first")
local function label(name,pos,title,subtitle)
    local b=captionTemplate:Clone(); b.Name=name
    b.CFrame=CFrame.new(pos)*CFrame.Angles(math.rad(-20),0,0)
    local texts=b:FindFirstChildWhichIsA("SurfaceGui"):GetChildren()
    table.sort(texts,function(a,b) return a.Position.Y.Scale<b.Position.Y.Scale end)
    texts[1].Text=title; texts[2].Text=subtitle
    b.Parent=captions
end
local rowZ=-11
for i,s in {{"Planted","01  PLANTED","paired seed leaves"},{"Developing","02  DEVELOPING","young spreading vines"},{"Mature","03  MATURING","small green pumpkins"},{"Ready","04  HARVEST READY","warm orange / broad lobes"}} do
    local template=plant(s[1]); local x=(i-2.5)*5.3
    local study=model("Study_"..s[1],display)
    place(soil,study,CFrame.new(x,0,rowZ),V(1.95,1,1.60))
    local p=template:Clone(); p.Parent=study; p:PivotTo(CFrame.new(x,.18,rowZ))
    label(s[1].."_Caption",V(x,.30,rowZ+2.25),s[2],s[3]); task.wait()
end
local fruitStudy=model("FruitStudy",display)
fruit(fruitStudy,V(11.9,.06,rowZ+.2),1.15,18,orange,"PumpkinFruit")
label("Fruit_Caption",V(11.9,.30,rowZ+2.25),"PUMPKIN","fruit study / actual asset scale")
local fruitTemplate=fruit(nil,V(0,0,0),1,0,orange,"PumpkinFruitTemplate")
for _,spec in {{library,"PumpkinMeshTemplates",templates},{library,"PumpkinGrowthStages",stages},{library,"PumpkinFruitTemplate",fruitTemplate},{workspace,"PumpkinWorkshop",display},{workspace.WorkshopLabels,"Pumpkin",captions}} do
    local old=spec[1]:FindFirstChild(spec[2]); if old then old:Destroy() end
    spec[3].Parent=spec[1]
end
return "Built pumpkin row 11 studs behind peppers: four stages, standalone fruit, separate captions."
