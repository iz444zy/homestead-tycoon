-- Run only in AssetWorkshop Edit mode. Replaces this builder's own containers.
local V, C = Vector3.new, Color3.fromRGB
local library = game.ReplicatedStorage:WaitForChild("AssetLibrary")
assert(workspace:FindFirstChild("WorkshopLabels"), "AssetWorkshop only")
local items = Instance.new("Folder"); items.Name = "InventoryItems"
local display = Instance.new("Folder"); display.Name = "InventoryWorkshop"
local cream, ink, green = C(235,218,177), C(56,67,43), C(86,117,68)
local function part(parent,name,size,cf,color)
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color
    p.Material=Enum.Material.SmoothPlastic; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=parent
    return p
end
local function text(p,title,subtitle)
    local gui=Instance.new("SurfaceGui");gui.Name="Packaging";gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(400,520);gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.MaxDistance=150;gui.Parent=p
    for i,s in {title,subtitle} do
        local t=Instance.new("TextLabel");t.Name=i==1 and "Title" or "Subtitle";t.BackgroundTransparency=1;t.Text=s;t.TextColor3=ink;t.Font=Enum.Font.GothamBold;t.TextScaled=true
        t.Size=UDim2.fromScale(.9,i==1 and .15 or .10);t.Position=UDim2.fromScale(.05,i==1 and .12 or .78);t.Parent=gui
    end
end
local function cloneGeometry(source)
    local m=source:Clone()
    -- Preserve a source path for lossless local XML serialization of native CSG.
    local function mark(a,b)
        if a:IsA("UnionOperation") then b:SetAttribute("MeshSource",a:GetFullName()) end
        local aa,bb=a:GetChildren(),b:GetChildren()
        for i,x in aa do mark(x,bb[i]) end
    end
    mark(source,m)
    m:PivotTo(CFrame.identity)
    return m
end
local function center(m,height)
    local cf,s=m:GetBoundingBox();m:ScaleTo(m:GetScale()*height/s.Y)
    cf=m:GetBoundingBox();m:PivotTo(CFrame.new(-cf.Position)*m:GetPivot())
end
local function tool(id,label,kind,crop,visual,grip)
    local t=Instance.new("Tool");t.Name=label;t.ToolTip=label;t.RequiresHandle=true;t.CanBeDropped=false;t.Grip=grip or CFrame.new(0,-.1,0)
    t:SetAttribute("ItemId",id);t:SetAttribute("ItemKind",kind);if crop then t:SetAttribute("CropType",crop) end
    local h=part(t,"Handle",V(.18,.18,.18),CFrame.identity,cream);h.Transparency=1
    visual.Name="Visual";visual.Parent=t
    for _,p in t:GetDescendants() do if p:IsA("BasePart") then
        p.Anchored=false;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
        if p~=h then local w=Instance.new("WeldConstraint");w.Name="HandleWeld";w.Part0=h;w.Part1=p;w.Parent=p end
    end end
    t.Parent=items;return t
end
local function stand(t,pos)
    local m=Instance.new("Model");m.Name=t:GetAttribute("ItemId");m.Parent=display
    local v=t.Visual:Clone();v.Parent=m
    for _,p in v:GetDescendants() do if p:IsA("WeldConstraint") then p:Destroy() elseif p:IsA("BasePart") then p.Anchored=true end end
    local cf,s=v:GetBoundingBox();v:PivotTo(CFrame.new(pos+V(0,.3+s.Y/2,0)-cf.Position)*v:GetPivot())
    local base=part(m,"Plinth",V(3,.25,3),CFrame.new(pos),C(142,113,77));base.CanQuery=true
    local sign=part(m,"Caption",V(2.8,.55,.10),CFrame.new(pos+V(0,.32,-1.46)),cream)
    text(sign,t.Name,"");sign.Packaging.CanvasSize=Vector2.new(600,100);sign.Packaging.Title.Size=UDim2.fromScale(.94,.85);sign.Packaging.Title.Position=UDim2.fromScale(.03,.075)
    local prompt=Instance.new("ProximityPrompt");prompt.Name="TryItem";prompt.ActionText="Add to backpack";prompt.ObjectText=t.Name;prompt.HoldDuration=.2;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt:SetAttribute("ItemId",t:GetAttribute("ItemId"));prompt.Parent=base
end
local crops={"Pepper","Pumpkin","Grape","Corn","Wheat","Lettuce","Potato","Carrot"}
local colors={C(185,63,41),C(212,125,40),C(116,76,137),C(217,177,57),C(185,153,83),C(109,145,65),C(163,122,79),C(216,119,49)}
for i,crop in crops do
    local source=library:FindFirstChild(crop.."Harvest") or library:FindFirstChild(crop.."FruitTemplate")
    assert(source,"Missing harvest "..crop)
    local produce=cloneGeometry(source)
    -- One potato is one inventory item; the original three-tuber study is unchanged.
    if crop=="Potato" then local children=produce:GetChildren();for j=2,#children do children[j]:Destroy() end end
    center(produce,crop=="Pumpkin" and 1.25 or crop=="Wheat" and 1.65 or 1.05)
    local packet=Instance.new("Model");packet.Name="Packet"
    local body=part(packet,"PaperEnvelope",V(.94,1.32,.13),CFrame.identity,cream)
    part(packet,"TopCrimp",V(.96,.09,.16),CFrame.new(0,.615,0),colors[i])
    part(packet,"BottomCrimp",V(.96,.07,.16),CFrame.new(0,-.625,0),colors[i])
    part(packet,"RearFold",V(.78,.035,.025),CFrame.new(0,.44,.08),C(202,186,148))
    text(body,string.upper(crop),"SEEDS")
    local emblem=produce:Clone();center(emblem,.48);emblem:PivotTo(CFrame.new(0,-.03,-.15)*emblem:GetPivot());emblem.Name="CropEmblem";emblem.Parent=packet
    local seed=tool(string.lower(crop).."_seeds",crop.." Seeds","Seed",crop,packet,CFrame.new(0,-.25,0))
    local harvest=tool(string.lower(crop).."_harvest",crop,"Harvest",crop,produce)
    stand(seed,V(23,0,5-(i-1)*4));stand(harvest,V(27,0,5-(i-1)*4))
    task.wait()
end
local function rod(parent,name,a,b,width,color)
    return part(parent,name,V(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
end
local can=Instance.new("Model")
local body=part(can,"Reservoir",V(1.1,.95,.85),CFrame.new(0,-.3,0),C(84,132,129));body.Shape=Enum.PartType.Cylinder;body.Size=V(.95,1.05,1.05);body.CFrame=CFrame.new(0,-.3,0)*CFrame.Angles(0,0,math.pi/2)
local rim=part(can,"FillRim",V(.08,.70,.70),CFrame.new(0,.19,0)*CFrame.Angles(0,0,math.pi/2),C(64,102,98));rim.Shape=Enum.PartType.Cylinder
local hole=part(can,"DarkFillOpening",V(.015,.52,.52),CFrame.new(0,.235,0)*CFrame.Angles(0,0,math.pi/2),C(38,65,61));hole.Shape=Enum.PartType.Cylinder
rod(can,"HandleLeft",V(-.36,.1,0),V(-.36,.65,0),.13,green);rod(can,"CarryGrip",V(-.36,.65,0),V(.36,.65,0),.15,green);rod(can,"HandleRight",V(.36,.65,0),V(.36,.1,0),.13,green)
rod(can,"Spout",V(.40,-.47,0),V(1.12,.14,0),.19,C(84,132,129))
local rose=part(can,"SprinklerRose",V(.12,.39,.39),CFrame.new(1.14,.18,0)*CFrame.Angles(0,0,.65),C(178,171,128));rose.Shape=Enum.PartType.Cylinder
for j=-1,1 do for k=-1,1 do local dot=part(can,"SprinklerHole",V(.015,.038,.038),rose.CFrame*CFrame.new(.068,j*.09,k*.09),ink);dot.Shape=Enum.PartType.Cylinder end end
local watering=tool("watering_can","Watering Can","Care",nil,can,CFrame.new(0,.65,0));stand(watering,V(23,0,-30))
local bag=Instance.new("Model")
part(bag,"SackBody",V(1.02,1.05,.57),CFrame.new(0,-.10,0),C(187,157,108))
part(bag,"FoldedTop",V(.88,.16,.46),CFrame.new(0,.49,0)*CFrame.Angles(0,0,.04),C(154,127,87))
part(bag,"BottomSeam",V(1.06,.10,.60),CFrame.new(0,-.64,0),C(154,127,87))
local label=part(bag,"PaperLabel",V(.84,.77,.02),CFrame.new(0,-.08,-.30),cream);text(label,"PLANT FOOD","FERTILIZER")
rod(bag,"SproutStem",V(0,-.20,-.325),V(0,.08,-.325),.035,green)
for _,sign in {-1,1} do local p=part(bag,"SproutLeaf",V(.22,.11,.025),CFrame.new(sign*.09,0,-.33)*CFrame.Angles(0,0,sign*.5),green) end
local fertilizer=tool("fertilizer_bag","Fertilizer Bag","Care",nil,bag,CFrame.new(0,-.18,0));stand(fertilizer,V(27,0,-30))
for _,spec in {{library,"InventoryItems",items},{workspace,"InventoryWorkshop",display}} do
    local old=spec[1]:FindFirstChild(spec[2]);if old then old:Destroy() end;spec[3].Parent=spec[1]
end
return "18 inventory Tools built: 8 seed packets, 8 harvests, watering can, fertilizer bag."
