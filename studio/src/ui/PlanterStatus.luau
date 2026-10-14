-- Client display reads replicated growth timestamps; it never changes crop state.
local A=require(script.Parent.UIAssets)
local C=require(script.Parent.Catalog)
local P={}
function P.mount(area)
    local board=area:WaitForChild("GardenStatusDisplay"):WaitForChild("StatusDisplay")
    local gui=board:WaitForChild("Lettering")
    gui:ClearAllChildren()
    gui.Enabled=true gui.Face=Enum.NormalId.Back
    gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
    gui.CanvasSize=Vector2.new(760,805) gui.LightInfluence=0 gui.AlwaysOnTop=false
    local function label(name,text,pos,size)
        local t=Instance.new("TextLabel") t.Name=name t.Text=text t.Position=pos t.Size=size
        t.BackgroundTransparency=1 t.TextColor3=A.Colors.cream t.Font=Enum.Font.GothamBold
        t.TextSize=34 t.Parent=gui return t
    end
    local heading=label("Heading","PLANTER 1",UDim2.fromOffset(0,24),UDim2.fromOffset(760,100))
    heading.TextSize=64
    local slots=area.Slots:GetChildren()
    table.sort(slots,function(a,b) return a.Name<b.Name end)
    local indicators={}
    for i,slot in ipairs(slots) do
        local x=760*((i-1)%2==0 and .30 or .70)
        local y=270+math.floor((i-1)/2)*310
        local circle=Instance.new("Frame") circle.Name="Slot"..i circle.Size=UDim2.fromOffset(201.6,201.6)
        circle.Position=UDim2.fromOffset(x-100.8,y-100.8) circle.BackgroundColor3=Color3.fromRGB(48,52,53)
        circle.BackgroundTransparency=.32 circle.BorderSizePixel=0 circle.Parent=gui
        local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(1,0) corner.Parent=circle
        local ticks={}
        for j=1,48 do
            local angle=math.rad((j-1)*360/48-90)
            local tick=Instance.new("Frame") tick.Name="Progress"..j tick.AnchorPoint=Vector2.new(.5,.5)
            tick.Size=UDim2.fromOffset(6,14.4) tick.Position=UDim2.fromOffset(100.8+math.cos(angle)*92.4,100.8+math.sin(angle)*92.4)
            tick.Rotation=(j-1)*360/48 tick.BorderSizePixel=0 tick.Parent=circle ticks[j]=tick
        end
        local icon=Instance.new("ImageLabel") icon.Name="CropIcon" icon.BackgroundTransparency=1
        icon.Position=UDim2.fromOffset(34.8,34.8) icon.Size=UDim2.fromOffset(132,132) icon.Parent=circle
        local text=label("Growth"..i,"",UDim2.fromOffset(x-125,y+108),UDim2.fromOffset(250,48))
        indicators[i]={Slot=slot,Icon=icon,Ticks=ticks,Text=text}
    end
    local function update()
        local now=workspace:GetServerTimeNow()
        for _,v in ipairs(indicators) do
            local crop=C.Crops[v.Slot:GetAttribute("CropId")]
            local started=v.Slot:GetAttribute("StartedAt") local ready=v.Slot:GetAttribute("ReadyAt")
            local progress=0
            if crop and started and ready then progress=math.clamp((now-started)/math.max(ready-started,.001),0,1) end
            local isReady=crop and (v.Slot:GetAttribute("GrowthState")=="Ready" or progress>=1)
            if isReady then progress=1 end
            v.Icon.Visible=crop~=nil
            if crop then A.apply(v.Icon,crop.HarvestId) end
            v.Text.Text=not crop and "" or isReady and "Ready" or tostring(math.floor(progress*100)).."%"
            for j,tick in ipairs(v.Ticks) do
                tick.BackgroundColor3=j<=math.floor(progress*48) and (isReady and Color3.fromRGB(112,205,111) or A.Colors.cream) or Color3.fromRGB(102,108,107)
            end
        end
    end
    update()
    task.spawn(function() while gui.Parent do task.wait(.25) update() end end)
end
return P
