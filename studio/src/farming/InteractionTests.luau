-- Run from a temporary server Script in Studio memory mode. Never touches production data.
local T={}
function T.run(player)
    local settings=require(script.Parent.Settings)
    assert(game:GetService("RunService"):IsStudio() and settings.StudioTest.Enabled and settings.StudioTest.UseMemoryStore,"Memory tests only")
    local a=assert(require(script.Parent.TestHooks).Access) local D=require(script.Parent.Domain)
    local I=require(game.ReplicatedStorage.Farming.Inventory) local rules=require(game.ReplicatedStorage.Farming.Interaction)
    local chest=workspace.LunaLandingFirstPlot.HouseChest local passed=0
    local function check(x,m) assert(x,m) passed+=1 end
    local function request(v,immediate) if not immediate then task.wait(.22) end v.Revision=v.Revision or a.Snapshot(player).Revision return a.Dispatch(player,v) end
    local original=D.copy(a.Store.Sessions[player.UserId].Profile) local position=player.Character:GetPivot()
    local fixture=D.copy(original) fixture.Seeds.lettuce=12 fixture.Produce.lettuce.Gold=5 fixture.Produce.lettuce.Blue=7 fixture.Chest={} fixture.WateringCan=true
    assert(a.Store:commit(player.UserId,fixture,'interaction-fixture'))
    player.Character:PivotTo(CFrame.new(-65,6,-54)) task.wait(.3)
    check(request({Kind="Focus",Mode="Chest",Chest=chest}).Ok,"Open actual chest")
    check(not request({Kind="Deposit",Chest=workspace,Item="lettuce_seeds",Quantity=1,RequestId="wrong-chest"}).Ok,"Reject forged chest")
    local rev=a.Snapshot(player).Revision
    local deposit={Kind="Deposit",Chest=chest,Item="lettuce_harvest",Quality="Gold",Quantity=5,RequestId="runtime-full-stack",Revision=rev}
    check(request(deposit).Ok,"Full deposit")
    check(request(deposit).Ok,"Idempotent retry")
    local p=a.Store.Sessions[player.UserId].Profile
    check(p.Produce.lettuce.Gold==0 and p.Chest["lettuce_harvest:Gold"]==5 and p.Produce.lettuce.Blue==7,"Quality conservation")
    check(request({Kind="Withdraw",Chest=chest,Item="lettuce_harvest",Quality="Gold",Quantity=3,RequestId="runtime-partial"}).Ok,"Partial take")
    p=a.Store.Sessions[player.UserId].Profile check(p.Produce.lettuce.Gold==3 and p.Chest["lettuce_harvest:Gold"]==2,"Partial conserved")
    for _,n in ipairs({0,-1,1.5,1000001}) do check(not request({Kind="Withdraw",Chest=chest,Item="lettuce_harvest",Quality="Gold",Quantity=n,RequestId="invalid-"..n}).Ok,"Reject quantity") end
    check(request({Kind="Deposit",Chest=chest,Item="watering_can",Quantity=1,RequestId="runtime-store-tool"}).Ok,"Store tool")
    check(not request({Kind="Equip",Item="watering_can"}).Ok,"Stored tool unavailable")
    check(request({Kind="Withdraw",Chest=chest,Item="watering_can",Quantity=1,RequestId="runtime-take-tool"}).Ok,"Retrieve tool")
    check(request({Kind="Equip",Item="watering_can"}).Ok,"Retrieved tool usable")
    check(request({Kind="Close"},true).Ok,"Close immediately after equip despite cooldown")
    check(request({Kind="Focus",Mode="Seeds"},true).Ok,"Focus immediately after close")
    check(request({Kind="Equip",Item="lettuce_seeds"}).Ok,"Select seed")
    check(request({Kind="Close"},true).Ok,"Picker closes after seed commit")
    player.Character:PivotTo(CFrame.new(-50,5,48)) task.wait(.3)
    check(not request({Kind="Focus",Mode="Chest",Chest=chest}).Ok,"Out of range open rejected")
    check(not request({Kind="Withdraw",Chest=chest,Item="lettuce_harvest",Quality="Gold",Quantity=1,RequestId="remote-take"}).Ok,"Out of range transfer rejected")
    local slots=workspace.LunaLandingFirstPlot.GrowingAreas.Area01.Slots
    local slot=slots.Slot1
    local before=a.Snapshot(player).Seeds.lettuce
    if not a.Store.Sessions[player.UserId].Profile.Plants['Area01/Slot1'] then
        check(request({Kind="Plant",Slot="Area01/Slot1",Crop="lettuce"}).Ok,"Plant after picker close")
        check(a.Snapshot(player).Seeds.lettuce==before-1,"Exactly one seed")
    end
    player.Character:PivotTo(CFrame.new(-70,5,80)) task.wait(.3)
    local dirt=workspace.LunaLandingFirstPlot.Digging.Dirt
    check(rules.visible(player.Character,dirt,12),"Dig decoration does not occlude its own target")
    local block=Instance.new('Part') block.Name='TemporaryLOSTest' block.Anchored=true block.Size=Vector3.new(8,.8,8) block.Position=player.Character.Head.Position:Lerp(dirt.Position,.5) block.Parent=workspace
    check(not rules.visible(player.Character,dirt,12),"Unrelated blocker still rejects LOS") block:Destroy()
    original.Revision=a.Snapshot(player).Revision
    assert(a.Store:commit(player.UserId,original,'restore-interaction-fixture'))
    player.Character:PivotTo(position) a.Render()
    game.ReplicatedStorage.Farming:WaitForChild('Changed'):FireClient(player,{State=a.Snapshot(player),Close=true})
    return {Passed=passed,Backend="Studio memory",PhysicalDevices=false}
end
return T
