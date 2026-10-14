-- Read-only presentation of server-owned session state.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local COIN = "rbxassetid://79465188173312"
local SEED = "rbxassetid://70460576376188" -- Reversible bell-pepper seed art preview.
task.spawn(function() pcall(function() game:GetService("ContentProvider"):PreloadAsync({COIN,SEED}) end) end)
local cream, green, timber = Color3.fromRGB(247,236,211), Color3.fromRGB(49,72,56), Color3.fromRGB(127,98,67)
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "LunaInterface", false, Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local function round(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=o end
local function text(parent,name,value,pos,size,fontSize)
    local t=Instance.new("TextLabel") t.Name=name t.Text=value t.Position=pos t.Size=size
    t.BackgroundTransparency=1 t.TextColor3=cream t.Font=Enum.Font.GothamMedium t.TextSize=fontSize or 18 t.TextWrapped=true t.Parent=parent return t
end
local function button(parent,name,value,pos,size)
    local b=Instance.new("TextButton") b.Name=name b.Text=value b.Position=pos b.Size=size b.BackgroundColor3=timber b.TextColor3=cream b.Font=Enum.Font.GothamBold b.TextSize=17 b.Parent=parent round(b,10) return b
end
local function icon(parent,name,asset,pos,size)
    local i=Instance.new("ImageLabel") i.Name=name i.Image=asset i.BackgroundTransparency=1 i.ScaleType=Enum.ScaleType.Fit i.Position=pos i.Size=size i.Parent=parent return i
end
local top=Instance.new("Frame") top.Name="TopBar" top.AnchorPoint=Vector2.new(1,0) top.Position=UDim2.new(1,-12,0,12) top.Size=UDim2.new(.94,0,0,58) top.BackgroundColor3=green top.Parent=gui round(top)
local limit=Instance.new("UISizeConstraint") limit.MaxSize=Vector2.new(520,58) limit.Parent=top
icon(top,"SterneIcon",COIN,UDim2.fromOffset(8,6),UDim2.fromOffset(46,46))
local balance=text(top,"Balance","0",UDim2.new(0,57,0,3),UDim2.new(.37,-57,0,29),23) balance.TextXAlignment=Enum.TextXAlignment.Left
local name=text(top,"CurrencyName","Sterne",UDim2.new(0,57,0,32),UDim2.new(.37,-57,0,20),13) name.TextXAlignment=Enum.TextXAlignment.Left
local inventoryButton=button(top,"InventoryButton","Inventory",UDim2.new(.37,3,0,8),UDim2.new(.32,-9,0,42))
local diaryButton=button(top,"DiaryButton","Diary",UDim2.new(.69,0,0,8),UDim2.new(.31,-8,0,42))
local function panel(name,title)
    local f=Instance.new("Frame") f.Name=name f.AnchorPoint=Vector2.new(1,0) f.Position=UDim2.new(1,-12,0,80) f.Size=UDim2.new(.94,0,.78,-45) f.BackgroundColor3=green f.Visible=false f.Parent=gui round(f)
    local c=Instance.new("UISizeConstraint") c.MaxSize=Vector2.new(480,550) c.Parent=f
    local titleLabel=text(f,"Title",title,UDim2.fromOffset(20,12),UDim2.new(1,-90,0,35),24) titleLabel.TextXAlignment=Enum.TextXAlignment.Left
    local close=button(f,"Close","×",UDim2.new(1,-51,0,10),UDim2.fromOffset(40,40)) close.Activated:Connect(function() f.Visible=false end)
    return f
end
local inv=panel("Inventory","Your inventory")
local items=Instance.new("ScrollingFrame") items.Name="Items" items.Position=UDim2.fromOffset(20,65) items.Size=UDim2.new(1,-40,1,-85) items.BackgroundTransparency=1 items.BorderSizePixel=0 items.ScrollBarThickness=4 items.AutomaticCanvasSize=Enum.AutomaticSize.Y items.CanvasSize=UDim2.new() items.Parent=inv
icon(items,"PepperSeedIcon",SEED,UDim2.fromOffset(2,10),UDim2.fromOffset(74,74))
local seeds=text(items,"Seeds","Pepper seeds · 0",UDim2.fromOffset(90,17),UDim2.new(1,-100,0,60),22) seeds.TextXAlignment=Enum.TextXAlignment.Left
local peppers=text(items,"Peppers","Harvested peppers · 0",UDim2.fromOffset(2,104),UDim2.new(1,-14,0,60),22) peppers.TextXAlignment=Enum.TextXAlignment.Left
text(items,"Hint","Find seeds by digging. Plant and harvest crops, then sell all harvested produce at the shared box by the gate.",UDim2.fromOffset(2,182),UDim2.new(1,-14,0,92),17)
local diary=panel("Diary","Farming diary")
local help=text(diary,"Help","THIS VISIT\nClaim at the welcome sign. At the dirt pit, hold E or equip Shovel and click.\nProgress starts fresh next visit.",UDim2.fromOffset(20,60),UDim2.new(1,-40,0,105),15) help.TextXAlignment=Enum.TextXAlignment.Left
local scroll=Instance.new("ScrollingFrame") scroll.Name="Entries" scroll.Position=UDim2.fromOffset(20,179) scroll.Size=UDim2.new(1,-40,1,-195) scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0 scroll.ScrollBarThickness=4 scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y scroll.CanvasSize=UDim2.new() scroll.Parent=diary
local entries=text(scroll,"Text","Your story starts here.",UDim2.fromOffset(0,0),UDim2.new(1,-12,0,0),17) entries.AutomaticSize=Enum.AutomaticSize.Y entries.TextXAlignment=Enum.TextXAlignment.Left entries.TextYAlignment=Enum.TextYAlignment.Top
inventoryButton.Activated:Connect(function() inv.Visible=not inv.Visible diary.Visible=false end)
diaryButton.Activated:Connect(function() diary.Visible=not diary.Visible inv.Visible=false end)
local toast=Instance.new("Frame") toast.Name="Notice" toast.AnchorPoint=Vector2.new(.5,1) toast.Position=UDim2.new(.5,0,1,-86) toast.Size=UDim2.new(.9,0,0,64) toast.BackgroundColor3=green toast.Parent=gui round(toast)
local tc=Instance.new("UISizeConstraint") tc.MaxSize=Vector2.new(650,64) tc.Parent=toast
local notice=text(toast,"Text","",UDim2.fromOffset(12,6),UDim2.new(1,-24,1,-12),17)
local function refresh()
    balance.Text=tostring(player:GetAttribute("Sterne") or 0)
    seeds.Text="Pepper seeds · "..tostring(player:GetAttribute("PepperSeeds") or 0)
    peppers.Text="Harvested peppers · "..tostring(player:GetAttribute("Peppers") or 0)
    entries.Text=player:GetAttribute("FarmDiary") or "Your story starts here."
end
local noticeVersion=0
local function showNotice()
    noticeVersion+=1 local version=noticeVersion
    notice.Text=player:GetAttribute("FarmNotice") or "Claim your homestead at the welcome sign."
    toast.Visible=true
    task.delay(7,function() if version==noticeVersion then toast.Visible=false end end)
end
for _,a in {"Sterne","PepperSeeds","Peppers","FarmDiary"} do player:GetAttributeChangedSignal(a):Connect(refresh) end
player:GetAttributeChangedSignal("FarmNoticeId"):Connect(showNotice)
refresh() showNotice()

-- Refresh the world sign when replicated text changes; Studio can otherwise keep
-- an old SurfaceGui text raster while its circle colors have already updated.
task.spawn(function()
    local signGui=workspace:WaitForChild("LunaLandingFirstPlot"):WaitForChild("GrowingAreas"):WaitForChild("Area01"):WaitForChild("GardenStatusDisplay"):WaitForChild("StatusDisplay"):WaitForChild("Lettering")
    local queued=false
    local function redraw()
        if queued then return end
        queued=true
        task.defer(function()
            queued=false
            if signGui.Parent then signGui.Enabled=false signGui.Enabled=true end
        end)
    end
    local function observe(v)
        if v:IsA("TextLabel") then v:GetPropertyChangedSignal("Text"):Connect(redraw) end
    end
    signGui.DescendantAdded:Connect(function(v) observe(v) redraw() end)
    for _,v in signGui:GetDescendants() do observe(v) end
    redraw()
end)
