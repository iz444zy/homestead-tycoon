-- Extend AssetWorkshop in Edit mode. Self-contained, baked local meshes; no uploads.
-- Run via Command Bar / Studio MCP, never against the gameplay place.
local GeometryService = game:GetService("GeometryService")
local V = Vector3.new
local C = Color3.fromRGB
local palette = {leaf=C(79,119,42),stem=C(65,99,36),red=C(222,43,28),gold=C(239,167,25),green=C(120,156,44),soil=C(104,70,44)}
local templates = Instance.new("Folder")
templates.Name = "CropMeshTemplates"

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
            local wave=math.cos(angle*3)
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

local library=game.ReplicatedStorage:FindFirstChild("AssetLibrary")
assert(library and library:FindFirstChild("PepperMeshTemplates") and workspace:FindFirstChild("WorkshopLabels"),"Run only in AssetWorkshop")
local pepper=library.PepperMeshTemplates
local leaf=pepper.FoldedLeaf
local lobed=library.PumpkinMeshTemplates.LobedPumpkinLeaf
local stem=pepper.StemSegment
local soil=pepper.SoilMound
local grape=rings("FacetedGrape",{{-.21,.085,0},{-.13,.185,0},{.025,.218,0},{.16,.16,0},{.215,.06,0}},10,C(108,66,145),0)
local kernel=rings("Grain",{{-.16,.04,0},{-.08,.105,0},{.075,.105,0},{.16,.035,0}},6,C(231,179,58),0)
local potato=rings("PotatoTuber",{{-.25,.15,0},{-.16,.35,0},{.09,.39,0},{.28,.26,0},{.32,.10,0}},9,C(175,130,74),.045)
local carrot=rings("CarrotRoot",{{-1.13,.018,0},{-.88,.072,0},{-.44,.15,0},{-.08,.21,0},{.13,.19,0},{.19,.075,0}},9,C(230,121,34),.035)
local cob=rings("CornCob",{{0,.11,0},{.15,.19,0},{.62,.19,0},{.84,.12,0},{.92,.035,0}},10,C(227,174,42),0)
local lv={V(0,0,0),V(-.24,.03,.15),V(-.49,.15,.39),V(-.51,.40,.66),V(-.30,.60,.86),V(0,.64,.94),V(.32,.57,.87),V(.53,.38,.64),V(.48,.12,.37),V(.22,.02,.13),V(0,.08,.43),V(0,.045,.43)}
local lf={} for j=1,10 do local k=j%10+1; table.insert(lf,{11,k,j}); table.insert(lf,{12,j,k}) end
local lettuceLeaf=mesh("CuppedLettuceLeaf",lv,lf,C(103,152,60))
-- Broad folded blade with a raised shoulder and drooping tip, not a straight spear.
local cv,cf={},{}
for _,v in {{0,0,.025},{.23,.17,.14},{.57,.22,.18},{.92,.07,.12},{1.20,-.19,.012}} do
    table.insert(cv,V(-v[3],v[2],v[1]));table.insert(cv,V(0,v[2]+.045,v[1]));table.insert(cv,V(v[3],v[2],v[1]))
end
for k=0,3 do for j=1,2 do local a=k*3+j;table.insert(cf,{a,a+3,a+1});table.insert(cf,{a+1,a+3,a+4}) end end
local topCount=#cv
for i=1,topCount do table.insert(cv,cv[i]-V(0,.012,0)) end
local topFaces=#cf
for i=1,topFaces do local f=cf[i];table.insert(cf,{f[3]+topCount,f[2]+topCount,f[1]+topCount}) end
local edge={1,2,3,6,9,12,15,14,13,10,7,4}
for i,a in edge do local b=edge[i%#edge+1];table.insert(cf,{a,b,a+topCount});table.insert(cf,{b,b+topCount,a+topCount}) end
local cornBlade=mesh("ArchingCornBlade",cv,cf,C(82,127,43))
-- Curved overlapping husk panels enclose the cob; shortened front panels reveal kernels.
local hv,hf={},{}
local rows={{.015,.135,.76},{.18,.221,.78},{.48,.226,.72},{.74,.195,.48},{.96,.24,.025}}
for layer=0,1 do for _,r in rows do for j=-1,1 do
    local angle=j*r[3];local radius=r[2]-layer*.014
    table.insert(hv,V(math.sin(angle)*radius,r[1],math.cos(angle)*radius))
end end end
for k=0,3 do for j=1,2 do local a=k*3+j
    table.insert(hf,{a,a+3,a+1});table.insert(hf,{a+1,a+3,a+4})
    table.insert(hf,{a+15,a+16,a+18});table.insert(hf,{a+16,a+19,a+18})
end end
local he={1,2,3,6,9,12,15,14,13,10,7,4}
for i,a in he do local b=he[i%#he+1];table.insert(hf,{a,b,a+15});table.insert(hf,{b,b+15,a+15}) end
local cornHusk=mesh("WrappingCornHusk",hv,hf,C(103,145,49))
local gv={V(0,0,0),V(-.24,-.015,.06),V(-.47,-.035,.21),V(-.39,-.035,.34),V(-.57,-.06,.51),V(-.32,-.045,.61),V(-.27,-.075,.80),V(-.12,-.085,.77),V(0,-.13,.99),V(.14,-.08,.78),V(.29,-.06,.80),V(.33,-.03,.61),V(.56,-.04,.50),V(.40,-.02,.33),V(.46,-.015,.20),V(.24,0,.06),V(0,.12,.43),V(0,.085,.43)}
local gf={} for j=1,16 do local k=j%16+1;table.insert(gf,{17,k,j});table.insert(gf,{18,j,k}) end
local grapeLeaf=mesh("BroadGrapeLeaf",gv,gf,C(79,123,43))
local function folder(name,parent) local f=Instance.new("Folder"); f.Name=name; f.Parent=parent; return f end
local function model(name,parent) local m=Instance.new("Model"); m.Name=name; m.WorldPivot=CFrame.identity; m.Parent=parent; return m end
local function place(t,parent,cf,scale,color,name)
    scale=scale or V(1,1,1); local p=t:Clone(); p.Size=t.Size*scale
    p.CFrame=cf*(CFrame.new(t.Position*scale)*t.CFrame.Rotation)
    if color then p.Color=color end; if name then p.Name=name end; p.Parent=parent; return p
end
local function branch(parent,a,b,width,color,name)
    local y=(b-a).Unit; local ref=math.abs(y.Z)>.98 and V(1,0,0) or V(0,0,1)
    local x=y:Cross(ref).Unit; local z=x:Cross(y)
    return place(stem,parent,CFrame.fromMatrix(a,x,y,z),V(width,(b-a).Magnitude+.018,width),color,name)
end
local function foliage(t,parent,o,yaw,length,width,pitch,roll,color)
    return place(t,parent,CFrame.new(o)*CFrame.Angles(0,math.rad(yaw),0)*CFrame.Angles(math.rad(-pitch),0,math.rad(roll or 0)),V(width,length,length),color)
end
local function wood(parent,name,size,pos)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=CFrame.new(pos);p.Color=C(143,111,68);p.Material=Enum.Material.Wood
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent; return p
end
local green=C(77,119,43);local lightGreen=C(108,148,54);local gold=C(211,167,69)
local function grapeBunch(parent,origin,scale,ripe)
    local m=model("GrapeBunch",parent)
    local specs={{-.18,-.13,.03},{.18,-.12,.03},{0,-.13,-.20},{-.25,-.40,.05},{.04,-.38,.21},{.27,-.39,.01},{-.08,-.38,-.21},{-.15,-.65,.07},{.15,-.64,.06},{0,-.62,-.16},{.035,-.87,.02}}
    for i,v in specs do
        local col=ripe and C(91,57,125):Lerp(C(146,90,169),(i%3)*.18) or C(132,164,67)
        place(grape,m,CFrame.new(origin+V(v[1],v[2],v[3])*scale)*CFrame.Angles(0,i*.4,.1*i),V(scale,scale,scale),col)
    end
    branch(m,origin+V(0,.22,0)*scale,origin+V(0,-.10,0)*scale,.055*scale,green,"BunchStem")
    return m
end
local function cornEar(parent,cf,scale,ripe)
    local m=model("CornEar",parent); local s=V(scale,scale,scale)
    place(cob,m,cf,s,ripe and C(220,162,35) or lightGreen)
    if ripe then
        for row=0,9 do for j=0,9 do
            local a=j*math.pi/5
            local radius=row>=8 and (.16-(row-8)*.033) or .173
            local p=V(math.sin(a)*radius,.14+row*.073,math.cos(a)*radius)
            place(kernel,m,cf*CFrame.new(p*scale)*CFrame.Angles(0,a,0),V(row>=8 and .35 or .44,.23,.21)*scale,C(240,190+row%2*6,61))
        end end
    end
    for i=0,4 do
        local yaw=math.rad(i*72)
        local height=ripe and ((i==0 and .60) or ((i==1 or i==4) and .80 or 1.02)) or 1.04
        place(cornHusk,m,cf*CFrame.Angles(0,yaw,0),V(1,height,1)*scale,C(88,130,43):Lerp(C(134,163,62),(i%3)*.17))
    end
    return m
end
local function wheatHead(parent,base,scale,ripe,yaw)
    local m=model("WheatHead",parent)
    local cf=CFrame.new(base)*CFrame.Angles(0,yaw or 0,math.rad(-9))
    local color=ripe and C(224,182,82) or C(143,158,66)
    branch(m,cf.Position,cf:PointToWorldSpace(V(0,.76,0)*scale),.032*scale,color,"Rachis")
    for row=0,4 do for _,side in {-1,1} do
        place(kernel,m,cf*CFrame.new(V(side*(.067-row*.004),.13+row*.113,0)*scale)*CFrame.Angles(0,0,math.rad(-side*24)),V(.60-row*.055,.82-row*.04,.53)*scale,color:Lerp(C(244,208,115),(row%2)*.18))
    end end
    for _,side in {-1,0,1} do branch(m,cf:PointToWorldSpace(V(side*.09,.55,0)*scale),cf:PointToWorldSpace(V(side*.14,.91,0)*scale),.009*scale,color,"Awn") end
    return m
end
local function lettuceHead(parent,stage)
    local m=model("LettuceHead",parent)
    local ringsSpec=stage==1 and {{4,.32,.31,0}} or stage==2 and {{5,.65,.58,0},{4,.43,.44,.08}} or stage==3 and {{7,.93,.87,0},{6,.70,.69,.09},{4,.48,.48,.18}} or {{8,1.02,1.0,0},{7,.82,.86,.12},{6,.60,.68,.24},{4,.38,.47,.35}}
    for r,v in ringsSpec do for i=1,v[1] do
        local a=i*360/v[1]+r*29
        foliage(lettuceLeaf,m,V(0,v[4],0),a,v[2],v[3],r==1 and -5 or 7,(i%2==0) and 4 or -4,C(74,126,47):Lerp(C(170,194,84),(r-1)*.22+(i%3)*.035))
    end end
    return m
end
local function carrotTop(parent,scale,offset)
    offset=offset or V(0,0,0)
    for i=1,5 do
        local a=math.rad(i*72);local tip=V(math.sin(a)*.43, .83+(i%2)*.16,math.cos(a)*.43)*scale+offset
        local base=offset+V(0,.04,0);branch(parent,base,tip,.030*scale,green,"CarrotPetiole")
        for j=1,3 do
            local at=base:Lerp(tip,.28+j*.18)
            for _,side in {-1,1} do foliage(leaf,parent,at,i*72+side*70,(.34-j*.035)*scale,.13*scale,18,side*22,(i%2==0) and green or lightGreen) end
        end
        foliage(leaf,parent,tip,i*72,.25*scale,.12*scale,58,0,lightGreen)
    end
end
local function potatoFruit(parent,pos,scale,yaw)
    local m=model("Potato",parent)
    local cf=CFrame.new(pos)*CFrame.Angles(.12,yaw or 0,.25)
    place(potato,m,cf,V(1.15,.88,.85)*scale,C(175,130,74))
    for _,v in {{-.14,.295,.09},{.10,.29,-.07}} do
        place(kernel,m,cf*CFrame.new(V(v[1],v[2],v[3])*scale)*CFrame.Angles(math.pi/2,0,0),V(.25,.11,.13)*scale,C(127,94,58),"PotatoEye")
    end
    return m
end
local cropNames={"Grape","Corn","Wheat","Lettuce","Potato","Carrot"}
local captionsSource=workspace.WorkshopLabels.Pepper:FindFirstChildWhichIsA("BasePart")
local function buildPlant(crop,stage,parent)
    local m=model(({"Planted","Developing","Mature","Ready"})[stage],parent)
    m:SetAttribute("CropType",crop);m:SetAttribute("VisualStage",m.Name);m:SetAttribute("AssetVersion",1)
    local leaves=model("Foliage",m);local stems=model("Stems",m);local produce=model("Produce",m)
    if crop=="Grape" then
        local support=model("Trellis",m)
        for _,x in {-1.12,1.12} do wood(support,"TimberPost",V(.105,2.75,.105),V(x,1.375,-.16)) end
        for _,y in {1.06,2.08} do wood(support,"CrossRail",V(2.4,.075,.075),V(0,y,-.16)) end
        local height=({.44,1.29,2.28,2.28})[stage]
        branch(stems,V(0,0,0),V(.03,height,0),.10,C(102,112,52),"MainVine")
        local specs={{.35,-.30,80,.59},{.65,.28,-70,.62},{1.04,-.63,-95,.72},{1.16,.66,70,.76},{1.68,-.75,-105,.81},{1.84,.61,65,.8},{2.25,-.25,-30,.72},{2.18,.45,105,.71},{2.02,-.94,-80,.72},{2.20,.91,72,.68},{1.47,-.32,165,.79},{1.40,.42,-170,.74},{.89,-.91,-95,.60},{.93,.88,85,.62}}
        for i,v in specs do if i<=({1,5,12,14})[stage] then
            local y,x,a,l=table.unpack(v);local pt=V(x,y,.04)
            branch(stems,V(.02,y-.20,0),pt,.052,green,"VineArm")
            foliage(grapeLeaf,leaves,pt,a,l,l*.95,12,(i%2==0) and 24 or -27,green:Lerp(lightGreen,(i%3)*.15))
        end end
        if stage>=3 then
            for i,p in {V(-.74,1.65,.36),V(.69,1.83,.42),V(.04,1.13,.48)} do
                branch(stems,V(.02,p.Y+.17,0),p+V(0,.13,0),.04,green,"FruitBranch")
                grapeBunch(produce,p,stage==4 and (.73+(i%2)*.08) or .46,stage==4)
            end
        end
    elseif crop=="Corn" then
        local h=({.30,1.05,2.55,3.10})[stage]
        branch(stems,V(0,0,0),V(.05,h,0),stage==1 and .07 or .13,green,"CornStalk")
        -- Uneven nodes and depth variation break the flat ladder silhouette.
        -- Lower leaves fall away; the smaller upper crown rises toward the tassel.
        local bladeSpecs={{.14,-110,.88,.67,-17,-16},{.24,83,1.02,.78,-9,14},{.35,-25,.92,.68,5,-22},{.43,158,.96,.77,12,18},{.53,-92,.88,.70,23,-16},{.62,67,.84,.66,30,11},{.72,-158,.73,.60,43,-9},{.82,-58,.64,.51,56,-13},{.90,36,.52,.43,66,9}}
        for i,v in bladeSpecs do if i<=({2,5,8,9})[stage] then
            local y,a,length,width,pitch,roll=table.unpack(v)
            local youth=stage==1 and .32 or stage==2 and .58 or 1
            local node=stage<=2 and (.15+i*.13) or y
            foliage(cornBlade,leaves,V(.02,h*node,0),a,length*youth,width*youth,pitch,roll,green:Lerp(lightGreen,(i%3)*.13))
        end
        end
        if stage>=3 then
            for i,v in {{-.12,1.00,.07,18},{.12,1.57,.06,-20},{-.10,2.12,.08,22}} do
                cornEar(produce,CFrame.new(V(v[1],v[2],v[3])*(stage==3 and .80 or 1))*CFrame.Angles(0,i==2 and -.3 or .2,math.rad(v[4])),(stage==4 and .79 or .57)*(i==3 and .85 or 1),stage==4)
            end
            for i=-2,2 do
                local a=V(.05,h-.03,0);local b=V(i*.12,h+.40-math.abs(i)*.07,i%2*.08)
                branch(stems,a,b,.018,stage==4 and gold or lightGreen,"TasselBranch")
                for j=1,4 do place(kernel,produce,CFrame.new(a:Lerp(b,j/4)),V(.15,.24,.15),stage==4 and gold or lightGreen,"Tassel") end
            end
        end
    elseif crop=="Wheat" then
        local count=({3,6,10,11})[stage]
        for i=1,count do
            local a=i*2.4;local spread=stage<=2 and .26 or .39
            local base=V(math.sin(a)*spread,0,math.cos(a)*spread)
            local h=({.30,.86,1.48,1.64})[stage]+math.sin(i*1.7)*.19+(i%3)*.085
            local top=base+V(math.sin(a)*.18,h,math.cos(a)*.17)
            local col=stage==4 and gold or green
            branch(stems,base,top,.031,col,"WheatStem")
            for j=1,(stage>=3 and 3 or 2) do foliage(cornBlade,leaves,base:Lerp(top,.12+j*.15),math.deg(a)+j*130,stage==1 and .20 or .42,stage==1 and .18 or .29,19-j*3,(i%2==0) and 14 or -12,stage==4 and C(177,151,66) or lightGreen) end
            if stage>=3 then wheatHead(produce,top,stage==4 and .76 or .61,stage==4,a) end
        end
    elseif crop=="Lettuce" then
        lettuceHead(leaves,stage)
    elseif crop=="Potato" then
        local count=({1,3,4,5})[stage]
        for i=1,count do
            local a=i*2.4;local h=({.28,.68,1.09,1.18})[stage]+(i%2)*.10
            local top=V(math.sin(a)*.35,h,math.cos(a)*.34)
            branch(stems,V(0,0,0),top,.047,green,"PotatoStem")
            for j=1,({1,2,3,3})[stage] do
                local at=top*(.27+j*.20)
                for _,side in {-1,1} do foliage(leaf,leaves,at,math.deg(a)+side*70,stage==1 and .27 or .44,stage==1 and .18 or .34,12,side*15,green:Lerp(lightGreen,(i%3)*.10)) end
            end
            foliage(leaf,leaves,top,math.deg(a),.37,.28,45,0,lightGreen)
            if stage==3 and i%2==0 then
                for j=1,5 do local ang=j*math.pi*.4;place(kernel,produce,CFrame.new(top+V(math.cos(ang)*.075,.025,math.sin(ang)*.075))*CFrame.Angles(math.pi/2,ang,0),V(.55,.5,.22),C(204,182,212),"PotatoBlossom") end
                place(kernel,produce,CFrame.new(top+V(0,.06,0)),V(.25,.2,.25),gold,"FlowerCenter")
            end
        end
        if stage>=3 then
            for i,p in {V(-.30,-.34,.14),V(.31,-.32,.1),V(.03,-.40,-.30)} do
                potatoFruit(produce,p+(stage==4 and V(0,.22,0) or V(0,0,0)),stage==4 and .66 or .32,i*.8)
            end
        end
    elseif crop=="Carrot" then
        if stage==1 then
            branch(stems,V(0,0,0),V(0,.21,0),.035,green)
            for _,a in {-85,95} do foliage(leaf,leaves,V(0,.20,0),a,.26,.13,22,0,lightGreen) end
        else
            carrotTop(leaves,({0,.48,.77,1})[stage])
            local s=({0,.22,.6,1})[stage]
            place(carrot,produce,CFrame.identity,V(s,s,s),nil,"CarrotRoot")
        end
    end
    return m
end
local function harvest(crop,parent)
    local m=model(crop.."Harvest",parent);m:SetAttribute("CropType",crop)
    if crop=="Grape" then grapeBunch(m,V(0,1.06,0),1,true)
    elseif crop=="Corn" then cornEar(m,CFrame.new(0,.10,0)*CFrame.Angles(0,.25,-.32),1.25,true)
    elseif crop=="Wheat" then
        for i=1,5 do local o=V((i-3)*.115,0,(i%2)*.10);local tip=o+V((i-3)*.06,1.2+(i%2)*.11,0);branch(m,o,tip,.035,gold);wheatHead(m,tip,.78,true,i*.7) end
        wood(m,"TwineTie",V(.60,.07,.22),V(0,.60,.05)).Color=C(148,123,76)
    elseif crop=="Lettuce" then lettuceHead(m,4)
    elseif crop=="Potato" then
        for i,p in {V(-.47,.25,.07),V(.28,.26,.13),V(-.05,.35,-.37)} do potatoFruit(m,p,i==2 and .78 or .94,i*.9) end
    elseif crop=="Carrot" then
        local root=model("WholeCarrot",m);place(carrot,root,CFrame.new(0,1.13,0),V(1,1,1));carrotTop(root,.58,V(0,1.32,0))
        root:PivotTo(CFrame.new(0,.03,0)*CFrame.Angles(0,.2,-.30))
    end
    return m
end
local function label(parent,name,pos,title,subtitle)
    local b=captionsSource:Clone();b.Name=name;b.CFrame=CFrame.new(pos)*CFrame.Angles(math.rad(-20),0,0)
    local texts=b:FindFirstChildWhichIsA("SurfaceGui"):GetChildren();table.sort(texts,function(a,b) return a.Position.Y.Scale<b.Position.Y.Scale end)
    texts[1].Text=title;texts[2].Text=subtitle;b.Parent=parent
end
for row,crop in cropNames do
    local stages=folder(crop.."GrowthStages",nil);local display=folder(crop.."Workshop",nil);local captions=folder(crop,nil)
    local z=-11-row*9
    for stage=1,4 do
        local template=buildPlant(crop,stage,stages);local x=(stage-2.5)*5.3
        local study=model("Study_"..template.Name,display)
        place(soil,study,CFrame.new(x,0,z),V(1.62,1,1.32))
        local plant=template:Clone();plant.Parent=study;plant:PivotTo(CFrame.new(x,.18,z))
        label(captions,template.Name.."_Caption",V(x,.30,z+2.1),string.upper(crop).."  /  "..({"01 PLANTED","02 DEVELOPING","03 MATURING","04 READY"})[stage],({"first growth","building structure","developing crop","harvest-ready study"})[stage])
        task.wait()
    end
    local harvestTemplate=harvest(crop,nil)
    local study=harvestTemplate:Clone();study.Parent=display;study:PivotTo(CFrame.new(12,.05,z))
    label(captions,"Harvest_Caption",V(12,.30,z+2.1),string.upper(crop).."  /  HARVEST","produce study / actual asset scale")
    for _,spec in {{library,crop.."GrowthStages",stages},{library,crop.."Harvest",harvestTemplate},{workspace,crop.."Workshop",display},{workspace.WorkshopLabels,crop,captions}} do
        local old=spec[1]:FindFirstChild(spec[2]);if old then old:Destroy() end;spec[3].Parent=spec[1];task.wait()
    end
end
local old=library:FindFirstChild("CropMeshTemplates");if old then old:Destroy() end;templates.Parent=library
return "Built six crop rows: Grapes, Corn, Wheat, Lettuce, Potatoes, Carrots; 24 stages plus six harvest studies; labels separate."
