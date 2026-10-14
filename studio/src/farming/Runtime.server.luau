local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local Shared=game.ReplicatedStorage.Farming
local C=require(Shared.Catalog)
local Modules=game.ServerStorage.Farming
local Settings=require(Modules.Settings)
local D=require(Modules.Domain)
local Store=require(Modules.ProfileStore).new()
local R=require(Modules.Representations)
local plot=workspace:WaitForChild("LunaLandingFirstPlot")
local World=require(Modules.World).new(plot)
local request=Shared.Request local push=Shared:WaitForChild("Changed")
local owner=nil
local claimBusy=false
local busy,lastRequest,lastDig,selection,quotes={},{},{},{},{}
local focus={}
local digWaiting={}
local I=require(Shared.Inventory)
local Rules=require(Shared.Interaction)
local chest=require(Modules.HouseChest).ensure(plot)
local chestAnchor=chest.InteractionAnchor
local dispatch
local function digFeedback(player)
    local tool=player.Character and player.Character:FindFirstChild("Shovel")
    if not tool then return end
    local grip=tool.Grip local tween=game:GetService("TweenService")
    tween:Create(tool,TweenInfo.new(.18),{Grip=grip*CFrame.Angles(math.rad(-55),0,0)}):Play()
    task.delay(.2,function() if tool.Parent then tween:Create(tool,TweenInfo.new(.25),{Grip=grip}):Play() end end)
end
local claim=plot.Arrival.ClaimSign.Claim
local dig=plot.Digging.Dirt.Dig
local sell=plot.Commerce.SellBox.BoxLid.Sell
local shop=Instance.new("ProximityPrompt") shop.Name="TemporarySeedShop" shop.ActionText="Seed shop" shop.ObjectText="Playtest shop · seeds & fertilizer"
shop.KeyboardKeyCode=Enum.KeyCode.R shop.GamepadKeyCode=Enum.KeyCode.ButtonY shop.MaxActivationDistance=12 shop.RequiresLineOfSight=false shop.Parent=sell.Parent
sell.ActionText="Review sale" sell.ObjectText="Produce box · NPC prices"
local function profile(player) local s=Store.Sessions[player.UserId] return s and s.Profile end
local function nearby(player,part)
    local ch=player.Character local root=ch and ch:FindFirstChild("HumanoidRootPart") local h=ch and ch:FindFirstChildOfClass("Humanoid")
    return Rules.visible(ch,part,Settings.InteractionDistance)
end
local function held(player,id)
    local t=player.Character and player.Character:FindFirstChildOfClass("Tool")
    return t and t:GetAttribute("InventoryRepresentation") and t:GetAttribute("ItemId")==id
end
local function equipped(player)
    local t=player.Character and player.Character:FindFirstChildOfClass("Tool")
    return t and {Item=t:GetAttribute("ItemId"),Quality=t:GetAttribute("Quality")} or nil
end
local function snapshot(player)
    local p=profile(player)
    if not p then return {Loaded=false,Mode=Store.Mode,Message=player:GetAttribute("FarmLoadError") or "Loading inventory…"} end
    return {Loaded=true, Chest=D.copy(p.Chest), Claimed=p.Claimed, Equipped=equipped(player), LastHarvest=D.copy(p.LastHarvest), Revision=p.Revision, Sterne=p.Sterne, Seeds=D.copy(p.Seeds),Produce=D.copy(p.Produce),WateringCan=p.WateringCan,Fertilizer=p.Fertilizer,Mode=Store.Mode,Blocked=Store.Sessions[player.UserId].Blocked or p.PendingHelp~=nil,OwnerId=owner and owner.UserId, Selected=selection[player] or p.SelectedSeed}
end
local function refresh(player,message,open,slot)
    if player.Parent~=Players then return end
    local p=profile(player)
    if p then player:SetAttribute("Sterne",p.Sterne) R.reconcile(player,p) end
    push:FireClient(player,{State=snapshot(player),Message=message,Open=open,Slot=slot})
end
local function render() World:render(owner and profile(owner),workspace:GetServerTimeNow()) end
local function context(player)
    return {Now=workspace:GetServerTimeNow(),UserId=tostring(player.UserId),Seed=math.random(1,2147483646),TimeScale=Run:IsStudio() and Settings.StudioTest.Enabled and math.max(.01,Settings.StudioTest.TimeScale) or 1,MaxStack=Settings.MaxStack,MaxBalance=Settings.MaxBalance,UnlockedSlots=Settings.UnlockedSlots}
end
local function commit(player,candidate)
    local ok,result=Store:commit(player.UserId,candidate,Http:GenerateGUID(false))
    if not ok then return false,result end return true
end
local function recoverHelp(player)
    local p=profile(player) if not p or not p.PendingHelp then return true end
    local intent=p.PendingHelp
    local applied,err=Store:resolveHelp(intent.OwnerId,player.UserId,intent.Serial)
    if applied==nil then return false,err end
    local nextValue=D.copy(profile(player))
    if applied then nextValue.Fertilizer-=1 end
    nextValue.PendingHelp=nil
    return commit(player,nextValue)
end
local function fertilize(player,a)
    if owner==player then return false,"Neighbors fertilize; you cannot fertilize your own crops." end
    if not owner then return false,"This property has no owner." end
    if not held(player,"fertilizer_bag") then return false,"Equip your fertilizer bag first." end
    local p=profile(player) if p.Fertilizer<1 then return false,"No fertilizer remaining." end
    local recipient=owner local target=profile(recipient)
    if not target or Store.Sessions[recipient.UserId].Blocked or Store.Sessions[recipient.UserId].Pending then return false,"Owner's progress is saving; try again." end
    -- Preflight before reserving; rejection consumes no charge.
    local probe=D.copy(target)
    local valid,msg=D.apply(probe,{Kind="Fertilize",Slot=a.Slot,Cycle=a.Cycle},context(recipient))
    if not valid then return false,msg end
    local intent=D.copy(p) intent.HelpSerial+=1
    intent.PendingHelp={OwnerId=recipient.UserId,Serial=intent.HelpSerial}
    local ok,err=commit(player,intent) if not ok then return false,err end
    target=D.copy(profile(recipient))
    valid,msg=D.apply(target,{Kind="Fertilize",Slot=a.Slot,Cycle=a.Cycle},context(recipient))
    target.CareReceipts[tostring(player.UserId)]={Serial=intent.HelpSerial,Success=valid}
    ok,err=commit(recipient,target)
    -- If a write's outcome is unknown, retry it before deciding success/cancellation.
    if not ok and Store.Sessions[recipient.UserId].Pending then Store:retry(recipient.UserId) end
    local done,recoveryErr=recoverHelp(player)
    render() refresh(recipient)
    if not done then return false,recoveryErr end
    local receipt=profile(recipient).CareReceipts[tostring(player.UserId)]
    if receipt and receipt.Serial==intent.HelpSerial and receipt.Success then return true,"Fertilized your neighbor's crop; one application used." end
    return false,err or msg or "Care changed; no fertilizer was used."
end
local function handle(player,a)
    if type(a)~="table" or type(a.Kind)~="string" then return false,"Invalid request." end
    if a.Kind=="Close" then if focus[player]=="Chest" then chest:SetAttribute("Open",false) end focus[player]=nil return true end
    local p=profile(player) local s=Store.Sessions[player.UserId]
    if not p then return false,player:GetAttribute("FarmLoadError") or "Inventory is still loading." end
    if s.Blocked or s.Pending then return false,"Saving is paused. Please wait for recovery." end
    if p.PendingHelp then local ok,err=recoverHelp(player) if not ok then return false,err end p=profile(player) end
    if a.Kind=="Focus" then
        if not ({Chest=true,Bag=true,Seeds=true,Market=true,Details=true})[a.Mode] then return false,"Unknown panel." end
        if a.Mode=="Chest" then
            if a.Chest~=chest or owner~=player or not nearby(player,chestAnchor) then return false,"Move to your chest." end
            chest:SetAttribute("Open",true)
        end
        focus[player]=a.Mode return true
    end
    if a.Kind=="Deposit" or a.Kind=="Withdraw" then
        if a.Chest~=chest or owner~=player or focus[player]~="Chest" or not nearby(player,chestAnchor) then return false,"Move to your chest." end
        local receipt=type(a.RequestId)=="string" and p.TransferReceipts[a.RequestId]
        if receipt then return receipt==D.transferSignature(a),receipt==D.transferSignature(a) and "Done" or "Request changed." end
        local nextValue=D.copy(p)
        local ok,msg=D.transfer(nextValue,a,Settings.MaxStack) if not ok then return false,msg end
        local saved,err=commit(player,nextValue) if not saved then return false,err end
        R.reconcile(player,profile(player)) return true,"Done"
    end
    if a.Kind~="Dig" and a.Revision~=p.Revision then return false,"Updated. Try again." end
    if a.Kind=="Equip" then
        if not I.validItem(a.Item,a.Quality) or I.quantity(p,a.Item,a.Quality)<1 then return false,"Empty" end
        if C.Items[a.Item].Kind=="Seed" then
            local nextValue=D.copy(p) nextValue.SelectedSeed=C.Items[a.Item].Crop
            local ok,err=commit(player,nextValue) if not ok then return false,err end
            selection[player]=nextValue.SelectedSeed
        end
        return R.equip(player,profile(player),a.Item,a.Quality)
    elseif a.Kind=="PutAway" then R.clear(player) return true,"Put Away" end
    if focus[player] and a.Kind~="Quote" and a.Kind~="Buy" and a.Kind~="Sell" then return false,"Close the panel." end
    if a.Kind=="Quote" then
        if not nearby(player,sell.Parent) then return false,"Out of range. Move to the produce box." end
        local q,err=D.quote(p,a.Lines) if not q then return false,err end
        q.Id=Http:GenerateGUID(false) q.Revision=p.Revision q.Expires=os.clock()+60 quotes[player]=q
        return true,"Review the sale before confirming."
    end
    local point
    if a.Kind=="Claim" then
        if owner and owner~=player then return false,"This homestead belongs to another player." end
        point=claim.Parent
    elseif a.Kind=="Buy" or a.Kind=="Sell" then point=sell.Parent
    elseif a.Kind=="Dig" then point=dig.Parent
    else point=type(a.Slot)=="string" and World.Slots[a.Slot] end
    if not point then return false,"Unknown or locked planting slot." end
    if not nearby(player,point) then return false,"Out of range. Move closer to interact." end
    if a.Kind=="Plant" or a.Kind=="Water" or a.Kind=="Harvest" or a.Kind=="Fertilize" or a.Kind=="Dig" then
        local plant=owner and profile(owner) and profile(owner).Plants[a.Slot]
        local slotInfo={Crop=plant and plant.Crop,Stage=D.stage(plant,workspace:GetServerTimeNow())}
        if plant then local interval=D.interval(plant,workspace:GetServerTimeNow()) slotInfo.Watered=interval and plant.Watered[interval] slotInfo.Fertilized=interval and plant.Fertilized[interval] end
        local e=equipped(player)
        local action=Rules.action(a.Kind=="Dig" and "Dig" or "Slot",slotInfo,owner==player,e and e.Item,p)
        local expected=a.Kind=="Fertilize" and "Help" or a.Kind
        if action~=expected then return false,action end
        if a.Kind=="Plant" and (not e or not C.Items[e.Item] or C.Items[e.Item].Crop~=a.Crop) then return false,"Select seeds." end
    end
    if a.Kind=="Fertilize" then return fertilize(player,a) end
    if a.Kind~="Buy" and a.Kind~="Sell" and a.Kind~="Claim" and a.Kind~="Dig" and owner~=player then return false,"Only the owner can plant, water, harvest or dig here." end
    if a.Kind=="Water" and not held(player,"watering_can") then return false,"Equip your watering can first." end
    if a.Kind=="Sell" then
        local q=quotes[player]
        if not q or a.QuoteId~=q.Id or q.Expires<os.clock() or q.Revision~=p.Revision then return false,"Sale quote expired or stock changed. Review again." end
        local current=D.quote(p,q.Lines)
        if not current or current.Total~=q.Total then return false,"Market price changed. Review a new quote." end
        a={Kind="Sell",Lines=q.Lines}
    end
    if a.Kind=="Dig" then
        if not owner or not profile(owner) then return false,"Claim this homestead first." end
        local recipientSession=Store.Sessions[owner.UserId]
        if recipientSession.Blocked or recipientSession.Pending or profile(owner).PendingHelp then return false,"Owner progress is saving. Try again." end
        if os.clock()-(lastDig[player] or -math.huge)<Settings.DigCooldown then return false,"Wait for the next shovel stroke." end
        lastDig[player]=os.clock()
    end
    local recipient=a.Kind=="Dig" and owner or player
    local before=profile(recipient)
    local nextValue=D.copy(before) local ctx=context(recipient)
    if a.Kind=="Dig" and math.random()<Settings.SeedChance then ctx.Discovery=C.Order[math.random(1,#C.Order)] end
    local ok,msg=D.apply(nextValue,a,ctx) if not ok then return false,msg end
    local saved,err=commit(recipient,nextValue) if not saved then return false,err end
    local rewards={}
    for _,crop in ipairs(C.Order) do
        local n=nextValue.Seeds[crop]-before.Seeds[crop]
        if n>0 then table.insert(rewards,{Item=C.Crops[crop].SeedId,Count=n}) end
        for quality,count in pairs(nextValue.Produce[crop]) do
            local delta=count-(before.Produce[crop][quality] or 0)
            if delta>0 then table.insert(rewards,{Item=C.Crops[crop].HarvestId,Count=delta,Quality=quality}) end
        end
    end
    if nextValue.Fertilizer>before.Fertilizer then table.insert(rewards,{Item="fertilizer_bag",Count=nextValue.Fertilizer-before.Fertilizer}) end
    push:FireClient(recipient,{Rewards=rewards,Coins=math.max(0,nextValue.Sterne-before.Sterne),Claimed=a.Kind=="Claim"})
    if recipient~=player then refresh(recipient) end
    if a.Kind=="Claim" then owner=player plot:SetAttribute("OwnerUserId",player.UserId) claim.Enabled=false end
    if a.Kind=="Dig" then digFeedback(player) end
    render() return true,msg
end
dispatch=function(player,a)
    local isDig=type(a)=="table" and a.Kind=="Dig"
    if isDig then
        if digWaiting[player] or busy[player.UserId] then return {Ok=false,Message="Please wait for your shovel stroke.",State=snapshot(player)} end
        digWaiting[player]=true
        local recipient=owner local deadline=os.clock()+10
        while recipient and busy[recipient.UserId] and os.clock()<deadline do task.wait(.03) end
        digWaiting[player]=nil
        if owner~=recipient or player.Parent~=Players then return {Ok=false,Message="Plot owner changed.",State=snapshot(player)} end
    end
    local now=os.clock()
    local panelRequest=type(a)=="table" and (a.Kind=="Close" or a.Kind=="Focus")
    if busy[player.UserId] or (not panelRequest and now-(lastRequest[player] or -math.huge)<Settings.RequestCooldown) then return {Ok=false,Message="Please wait for the current action.",State=snapshot(player)} end
    local other=type(a)=="table" and (a.Kind=="Fertilize" or a.Kind=="Dig") and owner and owner.UserId
    local claiming=type(a)=="table" and a.Kind=="Claim"
    if claiming and claimBusy then return {Ok=false,Message="Someone is claiming this property.",State=snapshot(player)} end
    if other and busy[other] then return {Ok=false,Message="Your neighbor is busy saving. Try again.",State=snapshot(player)} end
    busy[player.UserId]=true if other then busy[other]=true end if claiming then claimBusy=true end if not panelRequest then lastRequest[player]=now end
    local success,ok,msg=pcall(handle,player,a)
    busy[player.UserId]=nil if other then busy[other]=nil end
    if claiming then claimBusy=false end
    if not success then warn("Farming request failed: "..tostring(ok)) ok=false msg="Action could not finish. Review your inventory before retrying." end
    render() refresh(player,msg)
    return {Ok=ok,Message=msg,State=snapshot(player),Quote=type(a)=="table" and a.Kind=="Quote" and ok and quotes[player] or nil}
end
request.OnServerInvoke=function(player,a)
    if type(a)=="table" and a.Kind=="Snapshot" then return {State=snapshot(player)} end
    return dispatch(player,a)
end
-- Native UI owns all action input. No Tool.Activated or remembered prompt target.
for _,v in ipairs(plot:GetDescendants()) do if v:IsA("ProximityPrompt") then v.Enabled=false end end
local function setup(player)
    local p,err=Store:load(player.UserId)
    if not p then player:SetAttribute("FarmLoadError",err) refresh(player,err) return end
    if p.PendingHelp then recoverHelp(player) end
    player.CharacterAdded:Connect(function()
        task.defer(function() R.clear(player) focus[player]=nil chest:SetAttribute("Open",false) refresh(player) end)
    end)
    refresh(player)
end
Players.PlayerAdded:Connect(setup)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(setup,p) end
Players.PlayerRemoving:Connect(function(player)
    while busy[player.UserId] do task.wait(.1) end
    busy[player.UserId]=true
    if profile(player) and profile(player).PendingHelp then recoverHelp(player) end
    Store:release(player.UserId)
    busy[player.UserId]=nil lastRequest[player]=nil lastDig[player]=nil selection[player]=nil quotes[player]=nil focus[player]=nil
    if owner==player then owner=nil plot:SetAttribute("OwnerUserId",nil) claim.Enabled=true render() end
end)
game:BindToClose(function()
    local remaining=0
    for _,player in ipairs(Players:GetPlayers()) do remaining+=1 task.spawn(function()
        while busy[player.UserId] do task.wait(.1) end
        busy[player.UserId]=true
        if profile(player) and profile(player).PendingHelp then recoverHelp(player) end
        Store:release(player.UserId) remaining-=1
    end) end
    local deadline=os.clock()+25 while remaining>0 and os.clock()<deadline do task.wait(.1) end
end)
task.spawn(function() while true do
    for player,mode in pairs(focus) do
        if mode=="Chest" and (owner~=player or not nearby(player,chestAnchor)) then
            focus[player]=nil chest:SetAttribute("Open",false) push:FireClient(player,{Close=true,State=snapshot(player)})
        end
    end
    render() task.wait(.5)
end end)
task.spawn(function()
    while true do
        task.wait(Settings.HeartbeatSeconds)
        for _,player in ipairs(Players:GetPlayers()) do
            if not busy[player.UserId] and Store.Sessions[player.UserId] then
                busy[player.UserId]=true
                local ok=Store:retry(player.UserId)
                if ok and profile(player).PendingHelp then recoverHelp(player) end
                busy[player.UserId]=nil refresh(player)
            end
        end
    end
end)
-- Test harness may access services only in an explicitly enabled Studio test.
if Run:IsStudio() and Settings.StudioTest.Enabled then
    require(Modules.TestHooks).Access={Store=Store,Dispatch=dispatch,World=World,Render=render,Snapshot=snapshot}
end
render()
