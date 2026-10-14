local T={}
function T.run()
    assert(game:GetService("RunService"):IsStudio())
    local Players=game:GetService("Players") local Http=game:GetService("HttpService")
    local access=require(game.ServerStorage.Farming.TestHooks).Access
    local D=require(game.ServerStorage.Farming.Domain)
    require(game.ServerStorage.Farming.Settings).StudioTest.TimeScale=1
    local roster=Players:GetPlayers() table.sort(roster,function(a,b) return a.UserId<b.UserId end)
    assert(#roster>=3,"Three clients required")
    for _,p in ipairs(roster) do
        local deadline=os.clock()+30
        while (not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not access.Store.Sessions[p.UserId]) and os.clock()<deadline do task.wait(.1) end
        assert(p.Character and access.Store.Sessions[p.UserId],"Player failed to load")
    end
    local passed=0 local function check(v,msg) assert(v,msg) passed+=1 end
    local function profile(p) return access.Store.Sessions[p.UserId].Profile end
    local function move(p,part) p.Character:PivotTo(part.CFrame*CFrame.new(0,3,3)) end
    local function cmd(p,a) task.wait(.22) a.Revision=profile(p).Revision return access.Dispatch(p,a) end
    local function fixture(p,fn) local n=D.copy(profile(p)) fn(n) assert(access.Store:commit(p.UserId,n,Http:GenerateGUID(false))) access.Render() end
    -- Make commits yield to exercise actual interleaving in the running server.
    local original=access.Store.Backend.UpdateAsync
    access.Store.Backend.UpdateAsync=function(self,key,fn) task.wait(.08) return original(self,key,fn) end
    local plot=workspace.LunaLandingFirstPlot
    local a,b,c=roster[1],roster[2],roster[3]
    move(a,plot.Arrival.ClaimSign) move(b,plot.Arrival.ClaimSign)
    local replies={} local complete=0
    for _,p in ipairs({a,b}) do task.spawn(function() replies[p]=cmd(p,{Kind="Claim"}) complete+=1 end) end
    while complete<2 do task.wait(.05) end
    check((replies[a].Ok and 1 or 0)+(replies[b].Ok and 1 or 0)==1,"Simultaneous claim grants one owner")
    local owner=replies[a].Ok and a or b local helper=owner==a and b or a local helper2=c
    check(plot:GetAttribute("OwnerUserId")==owner.UserId,"Correct owner")
    for _,p in ipairs({owner,helper,helper2}) do move(p,plot.Commerce.SellBox.BoxLid) end
    check(cmd(owner,{Kind="Buy",Crop="grape",Quantity=4}).Ok,"Owner seeds")
    check(cmd(helper,{Kind="Buy",Item="fertilizer_bag"}).Ok,"Neighbor bag")
    check(cmd(helper2,{Kind="Buy",Item="fertilizer_bag"}).Ok,"Other neighbor bag")
    local slot="Area01/Slot1" local part=access.World.Slots[slot]
    for _,p in ipairs({owner,helper,helper2}) do move(p,part) end
    check(cmd(owner,{Kind="Plant",Crop="grape",Slot=slot}).Ok,"Owner planting")
    local cycle=profile(owner).Plants[slot].Cycle
    for _,kind in ipairs({"Plant","Water","Harvest","Dig"}) do
        check(not cmd(helper,{Kind=kind,Crop="grape",Slot=slot,Cycle=cycle}).Ok,"Neighbor cannot "..kind)
    end
    check(cmd(helper,{Kind="Equip",Item="fertilizer_bag"}).Ok,"Hold bag")
    check(cmd(helper2,{Kind="Equip",Item="fertilizer_bag"}).Ok,"Hold second bag")
    complete=0 replies={}
    for _,p in ipairs({helper,helper2}) do task.spawn(function() replies[p]=cmd(p,{Kind="Fertilize",Slot=slot,Cycle=cycle}) complete+=1 end) end
    while complete<2 do task.wait(.05) end
    check((replies[helper].Ok and 1 or 0)+(replies[helper2].Ok and 1 or 0)==1,"Two visitors: one application")
    check(profile(helper).Fertilizer+profile(helper2).Fertilizer==23,"Exactly one charge consumed")
    check(not cmd(helper,{Kind="Fertilize",Slot=slot,Cycle=cycle}).Ok,"Repeated fertilizer rejected")
    check(profile(helper).Fertilizer+profile(helper2).Fertilizer==23,"No charge on rejection")
    check(cmd(owner,{Kind="Equip",Item="watering_can"}).Ok,"Owner can")
    check(cmd(owner,{Kind="Water",Slot=slot,Cycle=cycle}).Ok,"Water independent of fertilizer")
    fixture(owner,function(p) p.Plants[slot].StartedAt=workspace:GetServerTimeNow()-121 end)
    check(cmd(helper,{Kind="Fertilize",Slot=slot,Cycle=cycle}).Ok,"New care interval opens")
    check(profile(helper).Fertilizer+profile(helper2).Fertilizer==22,"New interval charge")
    -- Persist an unresolved helper intent + successful owner receipt, then reload.
    local before=profile(helper).Fertilizer
    fixture(helper,function(p) p.HelpSerial+=1 p.PendingHelp={OwnerId=owner.UserId,Serial=p.HelpSerial} end)
    fixture(owner,function(p) p.CareReceipts[tostring(helper.UserId)]={Serial=profile(helper).HelpSerial,Success=true} end)
    access.Store:release(helper.UserId) check(access.Store:load(helper.UserId)~=nil,"Helper profile rejoin")
    cmd(helper,{Kind="Store"}) -- pending-help recovery is required before all actions
    check(profile(helper).PendingHelp==nil and profile(helper).Fertilizer==before-1,"Rejoin settles exactly one charge")
    cmd(helper,{Kind="Store"}) check(profile(helper).Fertilizer==before-1,"Recovery cannot consume twice")
    fixture(owner,function(p) p.Plants[slot].StartedAt=workspace:GetServerTimeNow()-1000 end)
    check(not cmd(helper,{Kind="Fertilize",Slot=slot,Cycle=cycle}).Ok,"Ready care frozen")
    check(not cmd(helper,{Kind="Harvest",Slot=slot,Cycle=cycle}).Ok,"Harvest ownership enforced")
    complete=0 local harvests={}
    for i=1,2 do task.spawn(function() harvests[i]=cmd(owner,{Kind="Harvest",Slot=slot,Cycle=cycle}) complete+=1 end) end
    while complete<2 do task.wait(.05) end
    check((harvests[1].Ok and 1 or 0)+(harvests[2].Ok and 1 or 0)==1,"One award under repeated concurrent harvest")
    check(profile(owner).Plants[slot].Regrowing,"Regrowing after concurrent harvest")
    -- Saved crop reload / offline completion. No auto harvest, payout, or restart.
    fixture(owner,function(p) p.Plants[slot].StartedAt=workspace:GetServerTimeNow()-86400 end)
    local saved=D.copy(profile(owner))
    access.Store:release(owner.UserId) check(access.Store:load(owner.UserId)~=nil,"Owner profile reload")
    access.Render() task.wait(1)
    check(part:GetAttribute("GrowthState")=="Ready","Offline growth completes")
    check(profile(owner).CycleSerial==saved.CycleSerial and profile(owner).Sterne==saved.Sterne,"No offline repeated cycles or payouts")
    for q,n in pairs(saved.Produce.grape) do check(profile(owner).Produce.grape[q]==n,"Offline inventory unchanged") end
    access.Store.Backend.UpdateAsync=original
    return {Passed=passed,Players=#roster,ClaimRace="one owner",VisitorRace="one charge, one application",ConcurrentHarvest="one award",Reload="Saved profiles reloaded via store adapter, with offline completion and pending-care recovery"}
end
return T
