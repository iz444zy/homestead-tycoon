from pathlib import Path
p=Path(__file__).parent/'src/farming/Runtime.server.luau'
s=p.read_text(encoding='utf-8')
s=s.replace('local targets={}','local focus={}\nlocal I=require(Shared.Inventory)\nlocal Rules=require(Shared.Interaction)\nlocal chest=require(Modules.HouseChest).ensure(plot)\nlocal chestAnchor=chest.InteractionAnchor')
start=s.index('    return root and h and h.Health>0')
end=s.index('\nend',start)
s=s[:start]+'    return Rules.visible(ch,part,Settings.InteractionDistance)'+s[end:]
s=s.replace('local function snapshot(player)', '''local function equipped(player)
    local t=player.Character and player.Character:FindFirstChildOfClass("Tool")
    return t and {Item=t:GetAttribute("ItemId"),Quality=t:GetAttribute("Quality")} or nil
end
local function snapshot(player)''')
s=s.replace('return {Loaded=true, Revision=p.Revision,','return {Loaded=true, Chest=D.copy(p.Chest), Claimed=p.Claimed, Equipped=equipped(player), LastHarvest=D.copy(p.LastHarvest), Revision=p.Revision,')
s=s.replace('Selected=selection[player]','Selected=selection[player] or p.SelectedSeed')
start=s.index('    if a.Revision~=p.Revision')
end=s.index('    if a.Kind=="Quote"',start)
s=s[:start]+'''    if a.Kind=="Close" then focus[player]=nil chest:SetAttribute("Open",false) return true end
    if a.Kind=="Focus" then
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
    if a.Revision~=p.Revision then return false,"Updated. Try again." end
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
'''+s[end:]
s=s.replace('    if a.Kind=="Fertilize" then return fertilize(player,a) end','''    if a.Kind=="Plant" or a.Kind=="Water" or a.Kind=="Harvest" or a.Kind=="Fertilize" or a.Kind=="Dig" then
        local plant=owner and profile(owner) and profile(owner).Plants[a.Slot]
        local slotInfo={Crop=plant and plant.Crop,Stage=D.stage(plant,workspace:GetServerTimeNow())}
        if plant then local interval=D.interval(plant,workspace:GetServerTimeNow()) slotInfo.Watered=interval and plant.Watered[interval] slotInfo.Fertilized=interval and plant.Fertilized[interval] end
        local e=equipped(player)
        local action=Rules.action(a.Kind=="Dig" and "Dig" or "Slot",slotInfo,owner==player,e and e.Item,p)
        local expected=a.Kind=="Fertilize" and "Help" or a.Kind
        if action~=expected then return false,action end
        if a.Kind=="Plant" and (not e or not C.Items[e.Item] or C.Items[e.Item].Crop~=a.Crop) then return false,"Select seeds." end
    end
    if a.Kind=="Fertilize" then return fertilize(player,a) end''')
start=s.index('local function giveShovel(player)')
end=s.index('local function setup(player)',start)
s=s[:start]+'''-- Native UI owns all action input. No Tool.Activated or remembered prompt target.
for _,v in ipairs(plot:GetDescendants()) do if v:IsA("ProximityPrompt") then v.Enabled=false end end
'''+s[end:]
s=s.replace('R.clear(player) if owner==player then giveShovel(player) end refresh(player)','R.clear(player) focus[player]=nil chest:SetAttribute("Open",false) refresh(player)')
s=s.replace('quotes[player]=nil targets[player]=nil','quotes[player]=nil focus[player]=nil')
s=s.replace('refresh(player,"Claim at the welcome sign. Shop and sell at the produce box.")','refresh(player)')
s=s.replace('task.spawn(function() while true do render() task.wait(.5) end end)', '''task.spawn(function() while true do
    for player,mode in pairs(focus) do
        if mode=="Chest" and (owner~=player or not nearby(player,chestAnchor)) then
            focus[player]=nil chest:SetAttribute("Open",false) push:FireClient(player,{Close=true,State=snapshot(player)})
        end
    end
    render() task.wait(.5)
end end)''')
p.write_text(s,encoding='utf-8')
w=p.parent/'World.luau';s=w.read_text();s=s.replace('prompt.Enabled=p~=nil','prompt.Enabled=false');w.write_text(s)
