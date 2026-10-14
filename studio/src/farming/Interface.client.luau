local Players=game:GetService("Players") local UIS=game:GetService("UserInputService") local CAS=game:GetService("ContextActionService") local GS=game:GetService("GuiService")
local player=Players.LocalPlayer local shared=game.ReplicatedStorage:WaitForChild("Farming")
local C=require(shared.Catalog) local I=require(shared.Inventory) local Rules=require(shared.Interaction)
local A=require(shared.UIAssets) local S=require(shared.UIStyle)
pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) end)
local gui=Instance.new("ScreenGui") gui.Name="LunaFarming" gui.ResetOnSpawn=false gui.DisplayOrder=10 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets gui.Parent=player:WaitForChild("PlayerGui")
local root=Instance.new("Frame") root.Name="SafeArea" root.Size=UDim2.fromScale(1,1) root.BackgroundTransparency=1 root.Parent=gui
local coin=S.panel(root,"Balance") coin.AnchorPoint=Vector2.new(1,0) coin.Size=UDim2.fromOffset(182,64) coin.Position=UDim2.new(1,-16,0,12)
S.icon(coin,"sterne",UDim2.fromOffset(56,56),UDim2.fromOffset(4,4))
local balance=S.text(coin,"…",34) balance.Position=UDim2.fromOffset(64,0) balance.Size=UDim2.new(1,-70,1,0)
local bar=Instance.new("Frame") bar.Name="Toolbar" bar.BackgroundTransparency=1 bar.AnchorPoint=Vector2.new(.5,1) bar.Position=UDim2.new(.5,0,1,-12) bar.Parent=root
local panel=S.panel(root,"Panel") panel.AnchorPoint=Vector2.new(1,0) panel.Visible=false
local prompt=S.button(root,"WorldAction","",function() end) prompt.AnchorPoint=Vector2.new(.5,1) prompt.Visible=false
local promptIcon=S.icon(prompt,"hand",UDim2.fromOffset(46,46),UDim2.fromOffset(8,7))
local promptText=S.text(prompt,"",26) promptText.Position=UDim2.fromOffset(60,0) promptText.Size=UDim2.new(1,-68,1,0)
local feedback=S.panel(root,"Feedback") feedback.AnchorPoint=Vector2.new(.5,0) feedback.Position=UDim2.new(.5,0,0,12) feedback.Size=UDim2.fromOffset(330,56) feedback.Visible=false
local feedbackText=S.text(feedback,"",24)
local details=S.button(root,"Details","Details",function() end) details.Size=UDim2.fromOffset(116,48) details.Position=UDim2.new(0,16,0,48) details.Visible=false
local memory=S.text(root,"",22) memory.Size=UDim2.fromOffset(310,32) memory.Position=UDim2.fromOffset(16,8) memory.TextXAlignment=Enum.TextXAlignment.Left
local receipts=require(shared.RewardFeedback).mount(root,coin)
local V={State={},Mode=nil,Category="Seeds",Page=1,Panel=panel,Root=root,Selected=nil,Amount=nil,Sales={},Pending=false}
local heldRef,remembered,target=nil,nil,nil local dismissUntil=0 local serial=0 local toolButtons={}
local renderHUD,resize,open,close,send,act,equip
local plot=workspace:WaitForChild("LunaLandingFirstPlot") local chest=plot:WaitForChild("HouseChest") V.Chest=chest
local points={{Part=plot.Arrival.ClaimSign,Kind="Claim"},{Part=plot.Digging.Dirt,Kind="Dig"},{Part=plot.Commerce.SellBox.BoxLid,Kind="Market"},{Part=chest:WaitForChild("InteractionAnchor"),Kind="Chest"}}
for _,area in ipairs(plot.GrowingAreas:GetChildren()) do local slots=area:FindFirstChild("Slots") if slots then for _,slot in ipairs(slots:GetChildren()) do table.insert(points,{Part=slot,Kind="Slot",Slot=area.Name.."/"..slot.Name}) end end end
local highlight=Instance.new("Highlight") highlight.Name="FarmTarget" highlight.FillTransparency=1 highlight.OutlineColor=A.Colors.creamRaised highlight.DepthMode=Enum.HighlightDepthMode.Occluded highlight.Parent=gui
local function show(text,sticky)
    serial+=1 local version=serial feedbackText.Text=text feedback.Visible=true
    if not sticky then task.delay(2.2,function() if serial==version then feedback.Visible=false end end) end
end
local function fail(message) V.Failure=message details.Visible=true show("Please retry",true) end
local function apply(s)
    if not s then return end V.State=s
    if s.Loaded then remembered=s.Selected or remembered heldRef=s.Equipped or heldRef if heldRef and I.quantity(s,heldRef.Item,heldRef.Quality)==0 then heldRef=nil end end
    V.Held=heldRef renderHUD()
end
send=function(action,after)
    if V.Pending then return end V.Pending=true action.Revision=action.Revision or V.State.Revision show("…",true)
    task.spawn(function()
        local ok,r=pcall(function() return shared.Request:InvokeServer(action) end) V.Pending=false
        if not ok then if action.Kind=="Deposit" or action.Kind=="Withdraw" then V.FailedTransfer=action end fail("Connection interrupted. Review inventory before retrying.") return end
        apply(r.State)
        if r.Ok==false then
            if V.State.Blocked then V.FailedTransfer=(action.Kind=="Deposit" or action.Kind=="Withdraw") and action or V.FailedTransfer fail(r.Message)
            else show(r.Message or "Try again") end
        else
            feedback.Visible=false
            if action.Kind=="Deposit" or action.Kind=="Withdraw" then V.FailedTransfer=nil show("Done")
            elseif action.Kind=="Water" or action.Kind=="Fertilize" then show(action.Kind=="Water" and "Watered ✓" or "Helped ✓") end
        end
        if after then after(r) end if V.Mode then V:rebuild() end
    end)
end
close=function()
    if V.Pending then return end V.Mode=nil panel.Visible=false V.AmountOpen=false GS.SelectedObject=nil dismissUntil=os.clock()+.3 target=nil highlight.Adornee=nil prompt.Visible=false send({Kind="Close"})
end
open=function(mode)
    if V.Pending then return end
    send({Kind="Focus",Mode=mode,Chest=mode=="Chest" and chest or nil},function(r)
        if r.Ok then V.Mode=mode V.Page=1 V.Selected=nil V.Amount=nil V.AmountOpen=false panel.Visible=true V:rebuild() end
    end)
end
equip=function(entry)
    send({Kind="Equip",Item=entry.Item,Quality=entry.Quality},function(r)
        if r.Ok then
            heldRef={Item=entry.Item,Quality=entry.Quality} V.Held=heldRef
            if C.Items[entry.Item].Kind=="Seed" then remembered=C.Items[entry.Item].Crop end
            if V.Mode=="Chest" then V.Selected=nil V.Amount=nil V.AmountOpen=false
            elseif V.ReturnChest then V.ReturnChest=nil V.Mode="Chest" send({Kind="Focus",Mode="Chest",Chest=chest})
            else close() end renderHUD()
        end
    end)
end
local function tool(id)
    if V.Pending or not V.State.Loaded then return end
    if id=="bag" then V.ReturnChest=V.Mode=="Chest" open("Bag") return end
    if id=="selected" then
        if heldRef and (C.Items[heldRef.Item].Kind=="Seed" or C.Items[heldRef.Item].Kind=="Produce") then
            if V.Mode=="Chest" then V.Selected=nil V.Amount=nil V:rebuild() else open("Seeds") end
        elseif remembered and V.State.Seeds[remembered]>0 then equip({Item=C.Crops[remembered].SeedId}) else open("Seeds") end return
    end
    if V.State.Equipped and V.State.Equipped.Item==id and V.Mode~="Chest" then send({Kind="PutAway"},function(r) if r.Ok then heldRef=nil V.Held=nil renderHUD() end end)
    elseif I.quantity(V.State,id)>0 then equip({Item=id}) else show("In Chest") end
end
local toolOrder={"shovel","watering_can","selected","fertilizer_bag","bag"}
for index,id in ipairs(toolOrder) do
    local b=S.button(bar,id,"",function() tool(id) end) b.LayoutOrder=index
    S.icon(b,id=="selected" and "hand" or id,UDim2.new(1,-12,1,-12),UDim2.fromOffset(6,6))
    local n=S.text(b,"",28) n.Name="Count" n.AnchorPoint=Vector2.new(1,1) n.Position=UDim2.new(1,-1,1,-1) n.Size=UDim2.fromOffset(48,32) n.BackgroundTransparency=0 n.BackgroundColor3=A.Colors.green n.TextColor3=A.Colors.creamRaised S.round(n,14) toolButtons[id]=b
end
renderHUD=function()
    local state=V.State balance.Text=state.Loaded and tostring(state.Sterne) or "…" memory.Text=state.Mode and state.Mode~="Saved" and "Studio · Not Saved" or ""
    local selected=heldRef and heldRef.Item
    if not selected or (C.Items[selected].Kind~="Seed" and C.Items[selected].Kind~="Produce") then selected=remembered and C.Crops[remembered].SeedId end
    for id,b in pairs(toolButtons) do
        local icon=id=="selected" and (selected or "hand") or id A.apply(b.Icon,icon)
        local q=id=="selected" and heldRef and heldRef.Item==selected and heldRef.Quality or nil
        local old=b:FindFirstChild("Quality") if old then old:Destroy() end S.badge(b,q)
        local n=state.Loaded and I.quantity(state,icon,q) or 0 b.Count.Visible=id=="fertilizer_bag" or (id=="selected" and selected~=nil) b.Count.Text=tostring(n)
        local active=state.Equipped and state.Equipped.Item==icon or false
        local changed=b:GetAttribute("Selected")~=active
        S.selected(b,active)
        if changed then
            local position=UDim2.fromOffset(b.Position.X.Offset,active and -4 or 0)
            if S.reduced() then b.Position=position else game:GetService("TweenService"):Create(b,TweenInfo.new(.12),{Position=position}):Play() end
        end
        b.Icon.ImageTransparency=state.Loaded and C.Items[icon] and n==0 and .55 or 0
    end
    if state.Blocked or (state.Loaded==false and state.Message) then fail(state.Message or "Saving is paused. Inventory changes appear only after the save is resolved.") end
end
resize=function()
    local size=root.AbsoluteSize V.Small=size.Y<600 or size.X<760 local n=V.Small and 64 or 80 bar.Size=UDim2.fromOffset(n*5+48,n)
    for _,b in pairs(toolButtons) do b.Size=UDim2.fromOffset(n,n) b.Position=UDim2.fromOffset((b.LayoutOrder-1)*(n+12),b:GetAttribute("Selected") and -4 or 0) end
    prompt.Size=UDim2.fromOffset(280,72) coin.Visible=not(V.Small and panel.Visible)
end
V.Send=send V.Close=close V.Open=open V.Equip=equip V.Show=show
require(shared.UIViews).attach(V)
details.Activated:Connect(function() if not V.Pending then open("Details") end end)
local function overUI(pos)
    pos+=GS:GetInsetArea(Enum.ScreenInsets.None).Min
    for _,v in ipairs(player.PlayerGui:GetGuiObjectsAtPosition(pos.X,pos.Y)) do
        if v:IsDescendantOf(gui) and v.Visible and (v:IsDescendantOf(bar) or v==panel or v:IsDescendantOf(panel) or v==coin or v:IsDescendantOf(coin) or v==details) then return true end
    end return false
end
local function onPrompt(pos)
    if not prompt.Visible then return false end
    pos+=GS:GetInsetArea(Enum.ScreenInsets.None).Min
    for _,object in ipairs(player.PlayerGui:GetGuiObjectsAtPosition(pos.X,pos.Y)) do
        if object==prompt or object:IsDescendantOf(prompt) then return true end
    end
    return false
end
local function pick(pos)
    local camera=workspace.CurrentCamera local best,score=nil,math.huge
    local ray=camera:ViewportPointToRay(pos.X,pos.Y)
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={player.Character}
    local hit=workspace:Raycast(ray.Origin,ray.Direction*300,params)
    for _,entry in ipairs(points) do
        if (entry.Kind~="Claim" or V.State.OwnerId==nil) and Rules.visible(player.Character,entry.Part,18) then
            if hit and Rules.surface(entry.Part,hit.Instance) then return entry end
            local v,visible=camera:WorldToViewportPoint(entry.Part.Position) local d=(Vector2.new(v.X,v.Y)-pos).Magnitude
            if visible and d<(entry.Kind=="Dig" and 150 or 100) and d<score then best=entry score=d end
        end
    end return best
end
local function aimTarget()
    if UIS:GetLastInputType().Name:match("Gamepad") then return pick(workspace.CurrentCamera.ViewportSize/2) end
    local pos=UIS:GetMouseLocation()
    if onPrompt(pos) then return target end
    if UIS.TouchEnabled and not UIS:GetLastInputType().Name:match("Gamepad") then return target end
    if overUI(pos) then return nil end
    return pick(pos)
end
local function cue(entry)
    local p=entry.Part local state=V.State local e=state.Equipped
    return Rules.action(entry.Kind,{Crop=p:GetAttribute("CropId"),Stage=p:GetAttribute("GrowthState"),Watered=p:GetAttribute("WateredNow"),Fertilized=p:GetAttribute("FertilizedNow")},state.OwnerId==player.UserId,e and e.Item,state)
end
act=function()
    if V.Pending or V.Mode or not target or not V.State.Loaded or os.clock()<dismissUntil then return end
    if not Rules.visible(player.Character,target.Part,18) then target=nil return end
    local action=cue(target)
    if action=="Chest" or action=="Market" or action=="Seeds" then open(action) return elseif action=="Empty" then show("Empty") return end
    if action=="Dig" or action=="Plant" or action=="Water" or action=="Help" or action=="Harvest" or action=="Claim" then
        local e=V.State.Equipped local crop=e and C.Items[e.Item] and C.Items[e.Item].Crop
        send({Kind=action=="Help" and "Fertilize" or action,Slot=target.Slot,Crop=crop,Cycle=target.Part:GetAttribute("Cycle")})
    end
end
prompt.Activated:Connect(act)
CAS:BindActionAtPriority("FarmAction",function(_,phase) if phase==Enum.UserInputState.Begin and not UIS:GetFocusedTextBox() then target=aimTarget() act() end return Enum.ContextActionResult.Sink end,false,3000,Enum.KeyCode.E,Enum.KeyCode.ButtonX)
CAS:BindActionAtPriority("FarmBag",function(_,phase) if phase==Enum.UserInputState.Begin then if V.Mode then close() else open("Bag") end end return Enum.ContextActionResult.Sink end,false,3000,Enum.KeyCode.I,Enum.KeyCode.DPadUp)
CAS:BindActionAtPriority("FarmClose",function(_,phase) if V.Mode then if phase==Enum.UserInputState.Begin then close() end return Enum.ContextActionResult.Sink end return Enum.ContextActionResult.Pass end,false,3000,Enum.KeyCode.Escape,Enum.KeyCode.ButtonB)
local controllerTool=1
CAS:BindAction("FarmTools",function(_,phase,input) if phase==Enum.UserInputState.Begin then controllerTool=(controllerTool-1+(input.KeyCode==Enum.KeyCode.ButtonR1 and 1 or -1))%5+1 GS.SelectedObject=toolButtons[toolOrder[controllerTool]] end return Enum.ContextActionResult.Sink end,false,Enum.KeyCode.ButtonL1,Enum.KeyCode.ButtonR1)
local keys={[Enum.KeyCode.One]="shovel",[Enum.KeyCode.Two]="watering_can",[Enum.KeyCode.Three]="selected",[Enum.KeyCode.Four]="fertilizer_bag",[Enum.KeyCode.Five]="bag"}
UIS.InputBegan:Connect(function(input,processed) if not processed and keys[input.KeyCode] then tool(keys[input.KeyCode]) end end)
UIS.InputEnded:Connect(function(input,processed)
    if input.UserInputType~=Enum.UserInputType.MouseButton1 or processed then return end
    local pos=UIS:GetMouseLocation() if overUI(pos) or onPrompt(pos) then return end
    if V.Mode then close() return end
    target=pick(pos) act()
end)
UIS.TouchTapInWorld:Connect(function(pos,processed)
    if processed or overUI(pos) then return end if V.Mode then close() return end
    target=pick(pos) act()
end)
local timer=0
game:GetService("RunService").RenderStepped:Connect(function(dt)
    timer+=dt if timer<.08 then return end timer=0
    if V.Mode or not V.State.Loaded then highlight.Adornee=nil prompt.Visible=false return end
    if not UIS.TouchEnabled or UIS:GetLastInputType().Name:match("Gamepad") then target=aimTarget() end
    if target and not Rules.visible(player.Character,target.Part,18) then target=nil end
    highlight.Adornee=target and target.Part or nil prompt.Visible=target~=nil
    for _,button in pairs(toolButtons) do button.Outline.Enabled=button:GetAttribute("Selected")==true or GS.SelectedObject==button end
    if target then
        local text,icon=cue(target) A.apply(promptIcon,icon)
        local controller=UIS:GetLastInputType().Name:match("Gamepad")
        local actionable=not text:match("^Need") and text~="Not Yours" and text~="Watered" and text~="Helped" and text~="Stored" and text~="Empty"
        promptText.Text=(actionable and (controller and "X  " or UIS.TouchEnabled and "" or "E  ") or "")..text
        local v,visible=workspace.CurrentCamera:WorldToViewportPoint(target.Part.Position+Vector3.new(0,1.4,0))
        local origin=root.AbsolutePosition-GS:GetInsetArea(Enum.ScreenInsets.None).Min local size=root.AbsoluteSize
        prompt.Position=UDim2.fromOffset(math.clamp(v.X-origin.X,134,size.X-134),math.clamp(v.Y-origin.Y-12,72,size.Y-bar.AbsoluteSize.Y-24))
        prompt.Visible=visible
        if text:match("^Need") then local button=toolButtons[icon] if button then button.Outline.Enabled=true end end
    end
end)
shared:WaitForChild("Changed").OnClientEvent:Connect(function(event) receipts:receive(event) apply(event.State) if event.Close then V.Mode=nil panel.Visible=false dismissUntil=os.clock()+.3 end if V.Mode and not V.Pending then V:rebuild() end end)
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() resize() if V.Mode then V:rebuild() end end) panel:GetPropertyChangedSignal("Visible"):Connect(resize)
player.CharacterAdded:Connect(function() heldRef=nil target=nil V.Mode=nil panel.Visible=false task.defer(function() send({Kind="Snapshot"}) end) end)
local lid=chest:WaitForChild("Lid") local closed=lid:GetPivot() local tween local angle=Instance.new("NumberValue")
angle.Changed:Connect(function(v) lid:PivotTo(closed*CFrame.Angles(math.rad(-v),0,0)) end)
local function lidState() if tween then tween:Cancel() end local value=chest:GetAttribute("Open") and 100 or 0 if S.reduced() then angle.Value=value else tween=game:GetService("TweenService"):Create(angle,TweenInfo.new(.18),{Value=value}) tween:Play() end end
chest:GetAttributeChangedSignal("Open"):Connect(lidState) lidState()
require(shared.PlanterStatus).mount(plot.GrowingAreas.Area01)
task.spawn(function() local ok=pcall(function() game:GetService("ContentProvider"):PreloadAsync({A.Image}) end) if not ok then fail("Item images could not load. Check connection and asset permissions.") end end)
resize() renderHUD() send({Kind="Snapshot"})

