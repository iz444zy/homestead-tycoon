-- Session-only first-plot prototype. Tuning below is provisional, not final balance.
local Players = game:GetService("Players")
local plot = workspace:WaitForChild("LunaLandingFirstPlot")
local TUNING = { DigCooldown = 0.7, SeedChance = 0.4, GrowthSeconds = 25, RegrowthSeconds = 20, PepperValue = 1, DefaultProduceValue = 1 }
local owner: Player? = nil
local inventory = {}
local plants = {}
local lastDig = {}
local notice = {}
local diary = {}
local noticeId = {}
local bed = plot.GrowingAreas.Area01
local claim = plot.Arrival.ClaimSign.Claim
local dig = plot.Digging.Dirt.Dig
local sellBox = plot.Commerce.SellBox
local statusDisplay = bed.GardenStatusDisplay.StatusDisplay
local sell = sellBox.BoxLid.Sell
-- A previous live-place sync left this foreground board in place. Remove it so
-- the crop bed stays open from the approach while the status panel moves to the box.
local oldBedSign=bed:FindFirstChild("BedSign")
if oldBedSign then oldBedSign:Destroy() end
local oldBedSignPost=bed:FindFirstChild("BedSignPost")
if oldBedSignPost then oldBedSignPost:Destroy() end
-- Keep the prerequisite visible at the pit instead of hiding its interaction.
local function updateDigPrompt()
    dig.Enabled = true
    dig.ActionText = owner and "Dig" or "Claim at the gate first"
    dig.ObjectText = owner and "Dirt pit · +1 Sterne + possible seed" or "Welcome sign by the entrance"
end
updateDigPrompt()

local function message(player, text)
    notice[player] = text
    noticeId[player] = (noticeId[player] or 0) + 1
    player:SetAttribute("FarmNotice",text)
    player:SetAttribute("FarmNoticeId",noticeId[player])
end

local function record(player, text)
    local history=diary[player]
    if not history then return end
    table.insert(history,1,text)
    if #history>40 then table.remove(history) end
    player:SetAttribute("FarmDiary",table.concat(history,"\n\n"))
end

local function nearby(player, part, radius)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return root and humanoid and humanoid.Health > 0 and (root.Position - part.Position).Magnitude <= radius
end

local function makePart(parent, name, size, cf, color, className)
    local p = Instance.new(className or "Part")
    p.Name, p.Size, p.CFrame = name, size, cf
    p.Color, p.Material = color, Enum.Material.SmoothPlastic
    p.Anchored, p.CanCollide, p.CanTouch = true, false, false
    p.CanQuery = false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

-- Thin triangular faces keep the foliage broad and pointed at gameplay distance.
local function triangle(parent, name, a, b, c, color)
    local ab, ac, bc = b-a, c-a, c-b
    local ab2, ac2, bc2 = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
    if ab2 > ac2 and ab2 > bc2 then c,a = a,c
    elseif ac2 > ab2 and ac2 > bc2 then a,b = b,a end
    ab, ac, bc = b-a, c-a, c-b
    local right = ac:Cross(ab).Unit
    local back = bc.Unit
    local up = bc:Cross(right).Unit
    local height = math.abs(ab:Dot(up))
    makePart(parent,name,Vector3.new(.035,height,math.abs(ab:Dot(back))),CFrame.fromMatrix((a+b)/2,right,up,back),color,"WedgePart")
    makePart(parent,name,Vector3.new(.035,height,math.abs(ac:Dot(back))),CFrame.fromMatrix((a+c)/2,-right,up,-back),color,"WedgePart")
end

local function stemBetween(parent, name, a, b, thickness, color)
    makePart(parent,name,Vector3.new(thickness,thickness,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
end

local function leaf(parent, origin, angle, length, width, pitch, roll, shade)
    length, width = length*1.08, width*1.22
    local direction=Vector3.new(math.cos(angle),0,math.sin(angle))
    local frame=CFrame.lookAt(origin,origin+direction)*CFrame.Angles(pitch,0,roll)
    local function at(x,y,z) return frame:PointToWorldSpace(Vector3.new(x,y,z)) end
    local base=at(0,0,0)
    local left=at(-width/2,-.04,-length*.43)
    local right=at(width/2,-.04,-length*.43)
    local ridge=at(0,.13,-length*.43)
    local tip=at(0,-.22,-length)
    local light=Color3.fromRGB(99+shade,128+shade,68+shade)
    local dark=Color3.fromRGB(86+shade,116+shade,59+shade)
    triangle(parent,"LeafFacet",base,left,ridge,dark)
    triangle(parent,"LeafFacet",base,ridge,right,light)
    triangle(parent,"LeafFacet",ridge,left,tip,dark)
    triangle(parent,"LeafFacet",ridge,tip,right,light)
end

local function pepper(parent, center, yaw, scale, color)
    -- A rounded body and three soft lower lobes keep the pepper plump and readable.
    local frame=CFrame.new(center)*CFrame.Angles(0,yaw,.08)
    local function roundedBodyPart(name, size, offset)
        local part=makePart(parent,name,size*scale,frame*CFrame.new(offset*scale),color)
        part.Shape=Enum.PartType.Ball
        return part
    end
    roundedBodyPart("PepperBody",Vector3.new(.82,.91,.76),Vector3.new(0,.04,0))
    roundedBodyPart("PepperShoulder",Vector3.new(.67,.46,.65),Vector3.new(0,.27,0))
    for i=0,2 do
        local angle=i*math.pi*2/3+.25
        local offset=Vector3.new(math.cos(angle)*.16,-.34,math.sin(angle)*.16)
        roundedBodyPart("PepperBaseLobe",Vector3.new(.35,.43,.34),offset)
    end
    makePart(parent,"PepperCalyx",Vector3.new(.25,.09,.25)*scale,frame*CFrame.new(0,.48*scale,0),Color3.fromRGB(73,103,48))
    stemBetween(parent,"FruitStem",frame:PointToWorldSpace(Vector3.new(0,.51*scale,0)),frame:PointToWorldSpace(Vector3.new(-.1,.72*scale,0)),.075*scale,Color3.fromRGB(76,107,49))
end

local function drawPepperPlant(slot, stage)
    local model=Instance.new("Model")
    model.Name="CropPlant"
    model:SetAttribute("VisualStage",stage)
    local pos=slot.Position+Vector3.new(0,.16,0)
    local stemColor=Color3.fromRGB(78,105,52)
    if stage=="Planted" then
        makePart(model,"SeedMound",Vector3.new(1.2,.23,.9),CFrame.new(pos+Vector3.new(0,.04,0))*CFrame.Angles(0,.3,0),Color3.fromRGB(115,82,56),"WedgePart")
        stemBetween(model,"NewShoot",pos,pos+Vector3.new(.02,.62,0),.12,stemColor)
        leaf(model,pos+Vector3.new(0,.4,0),.2,.62,.42,.3,.08,7)
        leaf(model,pos+Vector3.new(0,.5,0),3.1,.54,.4,.5,-.12,4)
    elseif stage=="Developing" then
        stemBetween(model,"YoungStem",pos,pos+Vector3.new(-.07,1.9,.04),.15,stemColor)
        for _,spec in {{.65,.1,1.0,.62,.18,.1},{1,2.8,1.1,.7,.1,-.13},{1.45,4.5,.9,.6,.32,.2},{1.8,1.7,.7,.47,.65,-.1}} do
            local y,a,l,w,pitch,roll=table.unpack(spec)
            leaf(model,pos+Vector3.new(0,y,0),a,l,w,pitch,roll,3)
        end
    else
        local root=pos+Vector3.new(.06,1.05,0)
        local fork=pos+Vector3.new(-.09,2.1,.05)
        local crown=pos+Vector3.new(.1,3.55,-.06)
        stemBetween(model,"MainStem",pos,root,.2,stemColor)
        stemBetween(model,"MainStem",root,fork,.18,stemColor)
        stemBetween(model,"CrownStem",fork,crown,.15,stemColor)
        for i,spec in {{1.25,4.3,1.75,1.06,-.08,.18},{2.35,2.6,1.6,1.02,.3,-.18},{2.05,4.4,1.7,1.1,.2,.12},{2.35,1.15,1.55,1.0,.26,-.22},{2.8,3.35,1.35,.88,.3,.18},{3.0,5.7,1.22,.78,.35,-.16},{3.15,.5,1.18,.88,.4,-.13},{3.4,1.9,.88,.64,.66,.2}} do
            local y,a,l,w,pitch,roll=table.unpack(spec)
            local attach=pos+Vector3.new(0,y-.2,0)
            local origin=pos+Vector3.new(math.cos(a)*.38,y,math.sin(a)*.38)
            stemBetween(model,"LeafBranch",attach,origin,.1,stemColor)
            leaf(model,origin,a,l,w,pitch,roll,(i%3)*3)
        end
        if stage=="Ready" or stage=="Mature" then
            local ripe=stage=="Ready"
            local fruitSites={{-1.15,1.35,.85,.3},{1.1,1.65,.7,2.3},{.4,1.25,-1.15,4.4}}
            for i,spec in fruitSites do
                if ripe or i<3 then
                    local x,y,z,yaw=table.unpack(spec)
                    local center=pos+Vector3.new(x,y,z)
                    stemBetween(model,"FruitBranch",fork,center+Vector3.new(-.1,ripe and .9 or .5,0),.12,stemColor)
                    local color=ripe and (i==2 and Color3.fromRGB(205,153,47) or Color3.fromRGB(184,62,39)) or Color3.fromRGB(100,135,57)
                    pepper(model,center,yaw,ripe and 1 or .48,color)
                end
            end
        end
    end
    model.Parent=slot
end

local CROP_ICON_ASSETS = { Pepper = "rbxassetid://94516029859579" }
local CROP_PLANT_BUILDERS = { Pepper = drawPepperPlant }
local function drawPlant(slot, stage, cropType)
    local old=slot:FindFirstChild("CropPlant")
    if old then old:Destroy() end
    if stage=="Empty" or not cropType then return end
    local builder=CROP_PLANT_BUILDERS[cropType]
    if builder then
        builder(slot,stage)
        local model=slot:FindFirstChild("CropPlant")
        if model then model:SetAttribute("CropType",cropType) end
    end
end

local statusIndicators = {}
local statusHeading

local function buildBedStatusUI(capacity)
    local columns=capacity==4 and 2 or 3
    local rows=math.ceil(capacity/columns)
    local canvasWidth,canvasHeight=1200,450
    if capacity==4 then canvasWidth,canvasHeight=760,700 end
    local diameter=capacity==4 and 168 or (rows==1 and 166 or 132)
    statusDisplay.CanQuery=false
    local gui=statusDisplay.Lettering
    gui:ClearAllChildren()
    gui.CanvasSize=Vector2.new(canvasWidth,canvasHeight)
    gui.AlwaysOnTop=true
    gui.LightInfluence=0
    local function label(parent,name,value,pos,size,fontSize)
        local t=Instance.new("TextLabel")
        t.Name,t.Text,t.Position,t.Size=name,value,pos,size
        t.BackgroundTransparency=1
        t.Font,t.TextSize,t.TextColor3=Enum.Font.GothamBold,fontSize,Color3.fromRGB(228,250,246)
        t.TextScaled=true
        t.TextWrapped=true
        t.Parent=parent
        return t
    end
    statusHeading=label(gui,"Heading","PLANTER",UDim2.fromOffset(0,16),UDim2.fromOffset(canvasWidth,62),42)
    statusIndicators={}
    local slots=bed.Slots:GetChildren()
    table.sort(slots,function(a,b) return a.Name<b.Name end)
    for i,slot in ipairs(slots) do
        local col=(i-1)%columns
        local row=math.floor((i-1)/columns)
        local x,y
        if capacity==4 then
            x=canvasWidth*(col==0 and .36 or .64)-diameter/2
            y=128+row*302
        else
            local cellWidth=1120/columns
            local rowHeight=(canvasHeight-95)/rows
            x=40+cellWidth*(col+.5)-diameter/2
            y=72+row*rowHeight
        end
        local circle=Instance.new("Frame")
        circle.Name="Slot"..i
        circle.Size=UDim2.fromOffset(diameter,diameter)
        circle.Position=UDim2.fromOffset(x,y)
        circle.BackgroundColor3=Color3.fromRGB(48,52,53)
        circle.BackgroundTransparency=.12
        circle.BorderSizePixel=0
        circle.ClipsDescendants=true
        circle.Parent=gui
        local round=Instance.new("UICorner")
        round.CornerRadius,round.Parent=UDim.new(1,0),circle
        local outline=Instance.new("UIStroke")
        outline.Color,outline.Thickness,outline.Parent=Color3.fromRGB(215,222,215),3,circle
        local ringSegments={}
        local ringCount=48
        local ringRadius=diameter/2-5
        for segment=1,ringCount do
            local angle=math.rad((segment-1)*360/ringCount-90)
            local tick=Instance.new("Frame")
            tick.Name="Progress"..segment
            tick.AnchorPoint=Vector2.new(.5,.5)
            tick.Size=UDim2.fromOffset(4,10)
            tick.Position=UDim2.fromOffset(diameter/2+math.cos(angle)*ringRadius,diameter/2+math.sin(angle)*ringRadius)
            tick.Rotation=(segment-1)*360/ringCount
            tick.BackgroundColor3=Color3.fromRGB(102,108,107)
            tick.BorderSizePixel=0
            tick.Parent=circle
            local tickRound=Instance.new("UICorner")
            tickRound.CornerRadius,tickRound.Parent=UDim.new(.5,0),tick
            ringSegments[segment]=tick
        end
        local icon=Instance.new("ImageLabel")
        icon.Name="CropIcon"
        icon.Image=""
        icon.Visible=false
        icon.ScaleType=Enum.ScaleType.Fit
        icon.Size=UDim2.fromScale(.68,.68)
        icon.Position=UDim2.fromScale(.16,.16)
        icon.BackgroundTransparency=1
        icon.ZIndex=2
        icon.Parent=circle
        statusIndicators[i]={Slot=slot,Circle=circle,Outline=outline,RingSegments=ringSegments,Icon=icon}
    end
end

local function updateBedStatusDisplay()
    local occupied=0
    local now=os.clock()
    for _,indicator in ipairs(statusIndicators) do
        local slot=indicator.Slot
        local state=plants[slot]
        local stage=state and state.Stage or "Empty"
        local cropType=state and state.CropType
        local cropIcon=cropType and CROP_ICON_ASSETS[cropType]
        indicator.Icon.Image=cropIcon or ""
        indicator.Icon.Visible=cropIcon~=nil and stage~="Empty"
        if stage~="Empty" then occupied+=1 end
        local progress=0
        if stage=="Ready" then
            progress=1
        elseif stage~="Empty" and state then
            local duration=math.max(tonumber(state.Duration) or 0,1)
            progress=math.clamp(1-(state.ReadyAt-now)/duration,0,1)
        end
        local activeSegments=math.floor(progress*#indicator.RingSegments+.5)
        for index,tick in ipairs(indicator.RingSegments) do
            if index<=activeSegments then
                tick.BackgroundColor3=stage=="Ready" and Color3.fromRGB(112,205,111) or Color3.fromRGB(245,246,235)
            else
                tick.BackgroundColor3=Color3.fromRGB(102,108,107)
            end
        end
        if stage=="Empty" then
            indicator.Circle.BackgroundColor3=Color3.fromRGB(48,52,53)
            indicator.Circle.BackgroundTransparency=.12
            indicator.Outline.Color=Color3.fromRGB(190,197,190)
        elseif stage=="Ready" then
            indicator.Circle.BackgroundTransparency=.03
            indicator.Circle.BackgroundColor3=Color3.fromRGB(49,76,49)
            indicator.Outline.Color=Color3.fromRGB(112,205,111)
        else
            indicator.Circle.BackgroundTransparency=.08
            indicator.Circle.BackgroundColor3=Color3.fromRGB(48,52,53)
            indicator.Outline.Color=Color3.fromRGB(220,225,216)
        end
    end
    statusHeading.Text="PLANTER"
    bed:SetAttribute("PlantedSlots",occupied)
end
buildBedStatusUI(#bed.Slots:GetChildren())

local giveShovel
local function animateDig(player)
    local character=player.Character
    local tool=giveShovel(player)
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if not tool or not humanoid then return end
    if tool.Parent~=character then humanoid:EquipTool(tool) end
    if tool:GetAttribute("Digging") then return end
    tool:SetAttribute("Digging",true)
    local grip=tool.Grip
    local tweens=game:GetService("TweenService")
    local down=tweens:Create(tool,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Grip=grip*CFrame.new(0,-.65,-.3)*CFrame.Angles(math.rad(-65),0,0)})
    down:Play()
    task.delay(.2,function()
        if not tool.Parent then return end
        if tool.Parent~=character then tool.Grip=grip tool:SetAttribute("Digging",false) return end
        tweens:Create(tool,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Grip=grip}):Play()
        local root=character:FindFirstChild("HumanoidRootPart")
        if root then
            local center=root.Position+root.CFrame.LookVector*2
            for i=1,3 do
                local soil=makePart(plot.Digging,"DigFeedback",Vector3.new(.5,.25,.4),CFrame.new(center.X+(i-2)*.5,.35,center.Z),Color3.fromRGB(124,91,61),"WedgePart")
                tweens:Create(soil,TweenInfo.new(.3),{Position=soil.Position+Vector3.new((i-2)*.35,.65,0),Transparency=1}):Play()
                game:GetService("Debris"):AddItem(soil,.35)
            end
        end
    end)
    task.delay(.6,function() if tool.Parent then tool.Grip=grip tool:SetAttribute("Digging",false) end end)
end

local function shovel(player)
    if owner ~= player then
        message(player, owner and "This homestead belongs to another player." or "Claim your homestead at the welcome sign by the gate, then return here to dig.")
        return
    end
    if not nearby(player, plot.Digging.Dirt, 15) then
        message(player, "Move onto the dirt pit, then hold E or click with your shovel equipped.")
        return
    end
    local now = os.clock()
    if now - (lastDig[player] or -math.huge) < TUNING.DigCooldown then return end
    lastDig[player] = now
    local bag = inventory[player]
    bag.Sterne += 1 -- Confirmed base digging reward.
    animateDig(player)
    if math.random() < TUNING.SeedChance then
        bag.Seeds += 1
        message(player, "+1 Sterne · found a pepper seed")
        record(player,"Dug soil · +1 Sterne, +1 pepper seed")
    else
        message(player, "+1 Sterne · keep digging to discover pepper seeds")
        record(player,"Dug soil · +1 Sterne")
    end
end

giveShovel = function(player)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local existing=backpack:FindFirstChild("Shovel") or (player.Character and player.Character:FindFirstChild("Shovel"))
    if existing then return existing end
    local tool = Instance.new("Tool")
    tool.Name, tool.CanBeDropped, tool.ToolTip = "Shovel", false, "Stand on the dirt pit and click to dig. Or hold E without equipping."
    local handle = Instance.new("Part")
    handle.Name, handle.Size = "Handle", Vector3.new(0.22,3.2,0.22)
    handle.Color, handle.Material = Color3.fromRGB(139,108,75), Enum.Material.SmoothPlastic
    handle.CanCollide, handle.Massless = false, true
    handle.Parent = tool
    local blade = Instance.new("Part")
    blade.Name, blade.Size = "Blade", Vector3.new(0.95,1.0,0.2)
    blade.Color, blade.Material = Color3.fromRGB(103,110,102), Enum.Material.SmoothPlastic
    blade.CanCollide, blade.Massless = false, true
    blade.CFrame = handle.CFrame * CFrame.new(0,-1.85,0)
    blade.Parent = tool
    local weld = Instance.new("WeldConstraint")
    weld.Part0, weld.Part1, weld.Parent = handle, blade, handle
    tool.Activated:Connect(function() shovel(player) end)
    tool.Parent = backpack
    return tool
end

claim.Triggered:Connect(function(player)
    if owner or not nearby(player, claim.Parent, 12) then return end
    owner = player
    plot:SetAttribute("OwnerUserId", player.UserId)
    claim.Enabled = false
    updateDigPrompt()
    for _,slot in bed.Slots:GetChildren() do slot.Plant.Enabled = true end
    message(player,"Claimed! At the dirt pit: hold E to dig, or equip Shovel and click.")
    giveShovel(player)
    record(player,"Claimed your homestead")
end)
dig.Triggered:Connect(shovel)

for _,slot in bed.Slots:GetChildren() do
    plants[slot] = { Stage = "Empty", ReadyAt = 0, Duration = 0, CropType = nil }
    slot.Plant.ActionText = "Plant"
    slot.Plant.ObjectText = slot.Name
    slot.Plant.Triggered:Connect(function(player)
        if owner ~= player or not nearby(player,slot,12) then return end
        local state, bag = plants[slot], inventory[player]
        if state.Stage == "Empty" then
            if bag.Seeds < 1 then message(player,"Dig beside the gate to find pepper seeds."); return end
            bag.Seeds -= 1
            state.Stage, state.ReadyAt, state.Duration, state.CropType = "Planted", os.clock() + TUNING.GrowthSeconds, TUNING.GrowthSeconds, "Pepper"
            slot:SetAttribute("CropType","Pepper")
            slot:SetAttribute("GrowthState", "Planted")
            slot.Plant.ActionText = "Growing"
            drawPlant(slot,"Planted",state.CropType)
            updateBedStatusDisplay()
            message(player,"Pepper planted · watch its circle for the harvest timer")
            record(player,"Planted pepper in "..slot.Name)
        elseif state.Stage == "Ready" then
            local cropType=state.CropType
            if not cropType then return end
            bag.Produce[cropType]=(bag.Produce[cropType] or 0)+1
            if cropType=="Pepper" then bag.Peppers=bag.Produce.Pepper end
            state.Stage, state.ReadyAt, state.Duration = "Regrowing", os.clock() + TUNING.RegrowthSeconds, TUNING.RegrowthSeconds
            slot:SetAttribute("GrowthState", "Regrowing")
            slot.Plant.ActionText = "Regrowing"
            drawPlant(slot,"Regrowing",state.CropType)
            updateBedStatusDisplay()
            local cropName=string.lower(cropType)
            message(player,cropName.." harvested · the plant stays and grows more")
            record(player,"Harvested "..cropName.." from "..slot.Name.." · regrowing")
        else
            message(player,"Growing · " .. math.max(1,math.ceil(state.ReadyAt-os.clock())) .. " seconds left")
        end
    end)
end

sell.ActionText="Sell produce"
sell.ObjectText="Shared box · all harvested crops"
sell.Triggered:Connect(function(player)
    if owner ~= player then
        message(player, owner and "This homestead belongs to another player." or "Claim your homestead at the welcome sign before selling.")
        return
    end
    if not nearby(player,sell.Parent,12) then
        message(player,"Stand beside the shared produce box to sell your harvest.")
        return
    end
    local bag=inventory[player]
    if not bag or not bag.Produce then
        message(player,"Harvest a ripe crop before using the produce box.")
        return
    end
    local amount,proceeds=0,0
    local sold={}
    for cropType,count in bag.Produce do
        if count>0 then
            local unitValue=cropType=="Pepper" and TUNING.PepperValue or TUNING.DefaultProduceValue
            amount+=count
            proceeds+=count*unitValue
            bag.Produce[cropType]=0
            local singular=cropType=="Pepper" and "pepper" or string.lower(cropType)
            local plural=cropType=="Pepper" and "peppers" or (singular.."s")
            table.insert(sold,string.format("%d %s",count,count==1 and singular or plural))
        end
    end
    if amount<1 then
        message(player,"No harvested produce to sell · harvest a ripe crop first.")
        return
    end
    bag.Peppers=bag.Produce.Pepper or 0
    bag.Sterne+=proceeds
    local receipt=string.format("Sold %s · +%d Sterne",table.concat(sold,", "),proceeds)
    message(player,receipt)
    record(player,receipt)
end)

updateBedStatusDisplay()

local function setupPlayer(player)
    inventory[player] = {Sterne=0, Seeds=0, Peppers=0, Produce={Pepper=0}}
    diary[player] = {}
    message(player,"Welcome! Claim your homestead at the sign by the gate.")
    player.CharacterAdded:Connect(function() if owner == player then task.defer(giveShovel,player) end end)
end
Players.PlayerAdded:Connect(setupPlayer)
for _,player in Players:GetPlayers() do task.spawn(setupPlayer,player) end
Players.PlayerRemoving:Connect(function(player)
    inventory[player], notice[player], lastDig[player] = nil,nil,nil
    diary[player],noticeId[player]=nil,nil
    if owner ~= player then return end
    owner = nil
    plot:SetAttribute("OwnerUserId",nil)
    claim.Enabled = true
    updateDigPrompt()
    for slot,state in plants do
        state.Stage, state.ReadyAt, state.Duration, state.CropType = "Empty",0,0,nil
        slot:SetAttribute("CropType",nil)
        slot:SetAttribute("GrowthState","Empty")
        slot.Plant.ActionText, slot.Plant.Enabled = "Plant",false
        drawPlant(slot,"Empty")
    end
    updateBedStatusDisplay()
end)

task.spawn(function()
    while true do
        local now = os.clock()
        for slot,state in plants do
            if state.Stage ~= "Empty" and state.Stage ~= "Ready" then
                if now >= state.ReadyAt then
                    state.Stage = "Ready"
                    slot:SetAttribute("GrowthState","Ready")
                    slot.Plant.ActionText = "Harvest"
                    drawPlant(slot,"Ready",state.CropType)
                elseif state.Stage == "Planted" and state.ReadyAt-now < TUNING.GrowthSeconds*0.65 then
                    state.Stage = "Developing"
                    slot:SetAttribute("GrowthState","Developing")
                    drawPlant(slot,"Developing",state.CropType)
                elseif state.Stage == "Developing" and state.ReadyAt-now < TUNING.GrowthSeconds*0.3 then
                    state.Stage = "Mature"
                    slot:SetAttribute("GrowthState","Mature")
                    drawPlant(slot,"Mature",state.CropType)
                end
            end
        end
        updateBedStatusDisplay()
        for player,bag in inventory do
            player:SetAttribute("Sterne",bag.Sterne)
            player:SetAttribute("PepperSeeds",bag.Seeds)
            bag.Peppers=bag.Produce.Pepper or 0
            player:SetAttribute("Peppers",bag.Peppers)
            for cropType,count in bag.Produce do
                player:SetAttribute("Harvested"..cropType,count)
            end
        end
        task.wait(0.25)
    end
end)
