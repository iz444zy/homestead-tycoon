-- Rebuild AssetWorkshop in Edit mode. Self-contained, baked local meshes; no uploads.
-- Run via Command Bar / Studio MCP, never against the gameplay place.
local GeometryService = game:GetService("GeometryService")
local V = Vector3.new
local C = Color3.fromRGB
local palette = {leaf=C(79,119,42),stem=C(65,99,36),red=C(222,43,28),gold=C(239,167,25),green=C(120,156,44),soil=C(104,70,44)}
local templates = Instance.new("Folder")
templates.Name = "PepperMeshTemplates"

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
            local wave=math.cos(angle*4)
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

local body=rings("BellPepperBody",{{.085,.19,-.028},{.20,.315,-.012},{.56,.395,0},{.83,.365,.038},{.855,.205,.03},{.81,.085,0}},16,palette.red,.14)
local fruitStem=tube("BentFruitStem",{V(0,.83,0),V(0,1.0,0),V(.095,1.13,0),V(.20,1.17,0)},{.064,.053,.043,.035},palette.stem)
local calyx=rings("StarCalyx",{{.825,.15,0},{.87,.10,0}},8,palette.stem,.40)
local lv={V(0,0,0),V(-.29,-.01,.18),V(-.5,-.035,.43),V(-.32,-.08,.73),V(0,-.18,1),V(.32,-.065,.73),V(.5,-.02,.43),V(.29,.0,.18),V(0,.105,.42),V(0,.067,.42)}
local lf={}
for j=1,8 do local k=j%8+1; table.insert(lf,{9,k,j,j<=4 and .96 or 1.04}); table.insert(lf,{10,j,k,.88}) end
local leaf=mesh("FoldedLeaf",lv,lf,palette.leaf)
local stem=tube("StemSegment",{V(0,0,0),V(0,1,0)},{.5,.37},palette.stem)
local soil=rings("SoilMound",{{0,1,0},{.12,.86,.02},{.22,.42,.018}},12,palette.soil,.035)

local function place(template,parent,frame,scale,color)
    local p=template:Clone(); scale=scale or V(1,1,1)
    p.Size=template.Size*scale
    p.CFrame=frame*(CFrame.new(template.Position*scale)*template.CFrame.Rotation)
    if color then p.Color=color end
    p.Parent=parent; return p
end
local function model(name,parent,pivot)
    local m=Instance.new("Model"); m.Name=name; m.WorldPivot=pivot or CFrame.identity; m.Parent=parent; return m
end
local function branch(parent,a,b,width)
    local y=(b-a).Unit; a-=y*.012; b+=y*.035
    local x=y:Cross(V(0,0,1)).Unit; local z=x:Cross(y)
    return place(stem,parent,CFrame.fromMatrix(a,x,y,z),V(width,(b-a).Magnitude,width))
end
local function foliage(parent,origin,angle,length,width,pitch,roll,shade)
    -- Leaf local +Z points outward; pitch bends the point upward or downward.
    local frame=CFrame.new(origin)*CFrame.Angles(0,math.rad(angle),0)*CFrame.Angles(math.rad(-pitch),0,math.rad(roll))
    return place(leaf,parent,frame,V(width,length,length),palette.leaf:Lerp(C(112,148,57),shade or 0))
end
local function fruit(parent,frame,scale,color,name)
    local f=model(name or "Pepper",parent,frame)
    local s=V(scale,scale,scale)
    place(body,f,frame,s,color); place(calyx,f,frame,s); place(fruitStem,f,frame,s)
    f:SetAttribute("CropType","Pepper"); f:SetAttribute("AssetVersion",2)
    return f
end

-- Clear only the AssetWorkshop's old asset experiments, after template creation succeeds.
for _,v in workspace:GetChildren() do if not v:IsA("Camera") and not v:IsA("Terrain") then v:Destroy() end end
local library=game.ReplicatedStorage:FindFirstChild("AssetLibrary")
if library then library:Destroy() end
library=Instance.new("Folder"); library.Name="AssetLibrary"; library.Parent=game.ReplicatedStorage
templates.Parent=library
local stages=Instance.new("Folder"); stages.Name="PepperGrowthStages"; stages.Parent=library
local display=Instance.new("Folder"); display.Name="PepperWorkshop"; display.Parent=workspace
local captions=Instance.new("Folder"); captions.Name="WorkshopLabels"; captions.Parent=workspace
local pepperCaptions=Instance.new("Folder"); pepperCaptions.Name="Pepper"; pepperCaptions.Parent=captions

local function plant(stage)
    local m=model(stage,stages)
    m:SetAttribute("CropType","Pepper"); m:SetAttribute("VisualStage",stage)
    local leaves=model("Foliage",m); local stems=model("Stems",m); local fruits=model("Fruit",m)
    if stage=="Planted" then
        branch(stems,V(0,0,0),V(.015,.34,0),.062)
        foliage(leaves,V(0,.26,0),-85,.36,.24,15,-6,.25)
        foliage(leaves,V(.01,.32,0),85,.34,.23,24,7,.4)
    elseif stage=="Developing" then
        branch(stems,V(0,0,0),V(0,.68,0),.085)
        branch(stems,V(0,.68,0),V(.02,1.25,0),.067)
        for _,s in {{.48,-85,.59,.40,-5,-35},{.68,80,.64,.43,8,35},{.92,-120,.48,.35,24,-30},{1.1,55,.47,.33,28,25},{1.23,-35,.34,.25,60,-10}} do
            local y,a,l,w,p,r=table.unpack(s)
            local o=V(math.sin(math.rad(a))*.11,y,math.cos(math.rad(a))*.11)
            branch(stems,V(0,y-.10,0),o,.038); foliage(leaves,o,a,l,w,p,r,.18)
        end
    else
        local fork=V(.01,.94,0)
        branch(stems,V(0,0,0),fork,.125)
        branch(stems,fork,V(-.12,1.78,-.04),.098)
        branch(stems,V(-.12,1.78,-.04),V(.04,2.38,-.10),.069)
        -- Asymmetric upright crown, with open pockets for the hanging produce.
        for i,s in {{.73,-113,.84,.58,-15,-38},{1.02,108,.86,.60,-17,38},{1.40,-86,.95,.66,-5,-40},{1.65,76,.94,.67,-7,38},{1.83,-132,.82,.58,10,-32},{2.04,112,.74,.55,7,32},{2.16,-60,.69,.51,19,-27},{2.35,48,.53,.40,48,16},{2.33,-48,.50,.38,58,-22},{1.59,176,.77,.56,20,-12},{1.10,-15,.70,.52,-26,8},{2.38,175,.35,.26,67,0}} do
            local y,a,l,w,p,r=table.unpack(s)
            local o=V(math.sin(math.rad(a))*.32,y,math.cos(math.rad(a))*.32-.04)
            branch(stems,V(-.02,y-.18,-.04),o,.049)
            foliage(leaves,o,a,l,w,p,r,(i%3)*.10)
        end
        if stage~="Regrowing" then
            local ripe=stage=="Ready"
            for i,s in {{-.73,.56,.43,-15,.79},{.69,.86,.31,28,.70},{.12,.33,.72,12,.75},{-.48,1.75,.36,-20,.54},{.48,1.93,.26,25,.50}} do
                if ripe or i<3 then
                    local x,y,z,yaw,size=table.unpack(s)
                    local scale=ripe and size or size*.60
                    local root=V(x,y+(ripe and 0 or .36),z)
                    local frame=CFrame.new(root)*CFrame.Angles(0,math.rad(yaw),math.rad(i==1 and -7 or 5))
                    local tip=frame:PointToWorldSpace(V(.2,1.17,0)*scale)
                    branch(stems,V(-.02,i>3 and 2.35 or 1.65,-.04),tip+V(0,.11,-.07),.05)
                    branch(stems,tip+V(0,.11,-.07),tip,.038)
                    fruit(fruits,frame,scale,ripe and ((i==2 or i==4) and palette.gold or palette.red) or palette.green,"Pepper"..i)
                end
            end
        end
        local support=model("SupportStake",m)
        local stake=Instance.new("Part"); stake.Name="TimberStake"; stake.Size=V(.09,2.92,.09)
        stake.CFrame=CFrame.new(.13,1.21,-.18)*CFrame.Angles(0,0,math.rad(-2))*CFrame.new(0,.25,0)
        stake.Color=C(143,110,66); stake.Material=Enum.Material.Wood
        stake.Anchored=true; stake.CanCollide=false; stake.CanTouch=false; stake.CanQuery=false; stake.Parent=support
        for _,y in {.89,1.73} do
            local tie=Instance.new("Part"); tie.Name="SoftGardenTie"; tie.Size=V(.26,.032,.25)
            tie.CFrame=CFrame.new(.045,y,-.085); tie.Color=C(155,145,95); tie.Material=Enum.Material.Fabric
            tie.Anchored=true; tie.CanCollide=false; tie.CanTouch=false; tie.CanQuery=false; tie.Parent=support
        end
    end
    return m
end

local function part(name,parent,size,cf,color)
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=Enum.Material.SmoothPlastic; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=parent; return p
end
local function label(parent,position,title,subtitle)
    local board=part("Caption",parent,V(3.7,.60,.055),CFrame.new(position)*CFrame.Angles(math.rad(-20),0,0),C(231,218,193))
    local ui=Instance.new("SurfaceGui"); ui.Face=Enum.NormalId.Back; ui.CanvasSize=Vector2.new(740,120); ui.Parent=board
    for i,txt in {title,subtitle} do
        local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Size=UDim2.fromScale(1,i==1 and .58 or .38); t.Position=UDim2.fromScale(0,i==1 and 0 or .58); t.Text=txt; t.Font=Enum.Font.GothamMedium; t.TextSize=i==1 and 32 or 23; t.TextColor3=C(63,67,45); t.Parent=ui
    end
end
local labels={{"Planted","01  PLANTED","paired seed leaves"},{"Developing","02  DEVELOPING","branching young plant"},{"Mature","03  MATURING","small green fruit"},{"Ready","04  HARVEST READY","red + golden bell peppers"}}
for i,s in labels do
    local template=plant(s[1]); local x=(i-2.5)*4.6
    local study=model("Study_"..s[1],display,CFrame.new(x,0,0))
    place(soil,study,CFrame.new(x,0,0),V(1.55,1,1.13))
    local p=template:Clone(); p.Parent=study; p:PivotTo(CFrame.new(x,.18,0))
    label(pepperCaptions,V(x,.35,1.75),s[2],s[3])
    task.wait()
end
plant("Regrowing")
local study=model("FruitStudy",display)
fruit(study,CFrame.new(-1.5,.10,4.1)*CFrame.Angles(0,.45,0),1,palette.red,"RedBellPepper")
fruit(study,CFrame.new(0,.10,4.1)*CFrame.Angles(0,-.2,.06),.95,palette.gold,"GoldenBellPepper")
fruit(study,CFrame.new(1.4,.10,4.1)*CFrame.Angles(0,.2,-.06),.67,palette.green,"UnripeBellPepper")
label(pepperCaptions,V(0,.24,5.3),"BELL PEPPER","fruit study / actual asset scale")
fruit(library,CFrame.identity,1,palette.red,"PepperFruitTemplate")
local ground=part("WorkshopGround",workspace,V(500,.3,500),CFrame.new(0,-.19,0),C(228,216,191)); ground.CanCollide=true; ground.Locked=true
local light=game:GetService("Lighting")
for _,v in light:GetChildren() do if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end end
light.ClockTime=14; light.Brightness=2; light.Ambient=C(124,128,115); light.OutdoorAmbient=C(143,143,130); light.ExposureCompensation=0; light.GlobalShadows=true
workspace.CurrentCamera.FieldOfView=36
workspace.CurrentCamera.CFrame=CFrame.lookAt(V(3,12,34),V(0,1,1.3))
game:GetService("Selection"):Set({})
return "Pepper workshop rebuilt: four growth studies, reusable regrowth stage, and fruit templates."
