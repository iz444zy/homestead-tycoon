-- Explicit Studio fixture; never run automatically and never enabled in production.
local T={}
function T.run()
    assert(game:GetService("RunService"):IsStudio())
    local access=require(game.ServerStorage.Farming.TestHooks).Access
    assert(access,"Enable StudioTest before running runtime tests")
    local modules=game.ServerStorage.Farming
    local D=require(modules.Domain) local C=require(game.ReplicatedStorage.Farming.Catalog)
    require(modules.Settings).StudioTest.TimeScale=1
    local player=game.Players:GetPlayers()[1]
    local plot=workspace.LunaLandingFirstPlot local slot="Area01/Slot1"
    local passed=0 local results={}
    local function check(v,msg) assert(v,msg) passed+=1 end
    local function p() return access.Store.Sessions[player.UserId].Profile end
    local function move(part) player.Character:PivotTo(part.CFrame*CFrame.new(0,3,3)) end
    local function command(a)
        task.wait(.21) a.Revision=p().Revision return access.Dispatch(player,a)
    end
    local function fixture(fn)
        local state=D.copy(p()) fn(state)
        local ok,err=access.Store:commit(player.UserId,state,game:GetService("HttpService"):GenerateGUID(false)) assert(ok,err) access.Render()
    end
    move(plot.Arrival.ClaimSign)
    check(command({Kind="Claim"}).Ok,"Claim") check(p().WateringCan,"Can granted")
    move(plot.Commerce.SellBox.BoxLid)
    for _,id in ipairs(C.Order) do
        local before=p().Seeds[id]
        check(command({Kind="Buy",Crop=id,Quantity=4}).Ok,id.." buy four") check(p().Seeds[id]==before+4,"Four seeds")
        check(command({Kind="Buy",Crop=id,Quantity=9}).Ok,id.." buy nine") check(p().Seeds[id]==before+13,"Nine seeds")
    end
    check(command({Kind="Buy",Item="fertilizer_bag"}).Ok,"Buy fertilizer") check(p().Fertilizer==12,"Twelve charges")
    for _,id in ipairs(C.Order) do
        local c=C.Crops[id] local part=access.World.Slots[slot]
        move(part) local before=p().Seeds[id]
        check(command({Kind="Equip",Item=c.SeedId}).Ok,"Equip "..c.SeedId)
        check(command({Kind="Store"}).Ok,"Store packet") check(p().Seeds[id]==before,"Equip no seeds")
        check(command({Kind="Plant",Crop=id,Slot=slot}).Ok,"Plant "..id) check(p().Seeds[id]==before-1,"One seed consumed")
        check(not command({Kind="Plant",Crop=id,Slot=slot}).Ok,"Occupied rejected")
        local cycle=p().Plants[slot].Cycle
        check(not command({Kind="Harvest",Slot=slot,Cycle=cycle}).Ok,"Not ready rejected")
        check(command({Kind="Equip",Item="watering_can"}).Ok,"Equip can")
        check(command({Kind="Water",Slot=slot,Cycle=cycle}).Ok,"Water")
        check(not command({Kind="Water",Slot=slot,Cycle=cycle}).Ok,"Duplicate water")
        check(command({Kind="Equip",Item="fertilizer_bag"}).Ok,"Equip fertilizer")
        check(not command({Kind="Fertilize",Slot=slot,Cycle=cycle}).Ok,"Cannot fertilize own crop") check(p().Fertilizer==12,"Rejected care no charge")
        for _,stage in ipairs({{0,"Planted"},{.16,"Developing"},{.51,"Mature"},{1.01,"Ready"}}) do
            fixture(function(state) local plant=state.Plants[slot] plant.StartedAt=workspace:GetServerTimeNow()-plant.Duration*stage[1] end)
            check(part:GetAttribute("GrowthState")==stage[2],id.." visual "..stage[2])
            local model=part.CropPlant
            check((model:GetPivot().Position-(part.Position+Vector3.new(0,part.Size.Y/2,0))).Magnitude<.001,"Consistent root pivot")
            if id=="pepper" and stage[2]=="Ready" then local stake=model:FindFirstChild("TimberStake",true) check(stake.Position.Y>part.Position.Y+1.4,"Pepper stake stays above soil") check(stake.CFrame.UpVector:Dot(part.CFrame.UpVector)>.99,"Pepper stake upright") end
            if id=="grape" then local post=model:FindFirstChild("TimberPost",true) check(post.Position.Y>part.Position.Y+1.3,"Trellis above soil") check(post.CFrame.UpVector:Dot(part.CFrame.UpVector)>.99,"Trellis upright") end
            for _,v in ipairs(model:GetDescendants()) do if v:IsA("BasePart") then check(v.Anchored and not v.CanCollide and not v.CanQuery and not v.CanTouch,"Static crop physics") end end
        end
        check(not command({Kind="Water",Slot=slot,Cycle=cycle}).Ok,"Ready care freeze")
        local oldRevision=p().Revision
        local harvested=command({Kind="Harvest",Slot=slot,Cycle=cycle}) check(harvested.Ok,"Harvest "..id)
        local repeated=access.Dispatch(player,{Kind="Harvest",Slot=slot,Cycle=cycle,Revision=oldRevision}) check(not repeated.Ok,"Rapid repeat rejected")
        local total=0
        for _,quality in ipairs(C.Qualities) do
            local n=p().Produce[id][quality] total+=n
            if n>0 then
                check(command({Kind="Equip",Item=c.HarvestId,Quality=quality}).Ok,"Equip produce")
                local tool=player.Character:FindFirstChildOfClass("Tool") check(tool and tool:GetAttribute("ItemId")==c.HarvestId,"Correct held tool")
                for _,v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then check(not v.Anchored and v.Massless and not v.CanCollide,"Held physics") elseif v:IsA("WeldConstraint") then check(v.Part0~=nil and v.Part1~=nil,"Resolved weld") end end
                check(command({Kind="Store"}).Ok,"Store produce") check(p().Produce[id][quality]==n,"Holding no quantity change")
            end
        end
        if c.Regrowth then
            check(p().Plants[slot].Regrowing,"Persistent plant")
            check(part:GetAttribute("GrowthState")=="Regrowing","Regrowing visual")
            if id=="grape" then check(part.CropPlant:FindFirstChild("Produce")==nil,"Fruit-free grape") check(part.CropPlant:FindFirstChild("Trellis")~=nil,"Trellis preserved") end
            local regCycle=p().Plants[slot].Cycle
            fixture(function(state) state.Plants[slot].StartedAt=workspace:GetServerTimeNow()-c.Regrowth-1 end)
            check(command({Kind="Harvest",Slot=slot,Cycle=regCycle}).Ok,"Second persistent harvest")
            fixture(function(state) state.Plants[slot]=nil end)
        else check(p().Plants[slot]==nil and not part:FindFirstChild("CropPlant"),"Slot clears") end
        results[id]={Harvest=harvested.Message,InitialYield=total}
    end
    -- Sale quote comes from the server and removes an equipped empty stack.
    fixture(function(state) state.Produce.potato.Blue=1 state.Produce.lettuce.Blue=1 state.Produce.carrot.Gold=2 end)
    move(plot.Commerce.SellBox.BoxLid)
    check(command({Kind="Equip",Item="potato_harvest",Quality="Blue"}).Ok,"Equip sale stack")
    local quote=command({Kind="Quote",Lines={{Crop="potato",Quality="Blue",Quantity=1},{Crop="lettuce",Quality="Blue",Quantity=1},{Crop="carrot",Quality="Gold",Quantity=2}}})
    check(quote.Ok and quote.Quote.Total==141,"Server mixed sale quote") local money=p().Sterne
    check(command({Kind="Sell",QuoteId=quote.Quote.Id}).Ok,"Confirm sale") check(p().Sterne==money+141,"Sale proceeds")
    check(player.Character:FindFirstChildOfClass("Tool")==nil,"Empty equipped stack removed")
    check(not command({Kind="Sell",QuoteId=quote.Quote.Id}).Ok,"Duplicate sale blocked")
    local count=p().Seeds.pepper
    player.Character:PivotTo(CFrame.new(0,5,0))
    check(not command({Kind="Buy",Crop="pepper",Quantity=4}).Ok,"Out of range buy")
    check(not command({Kind="Plant",Crop="pepper",Slot=slot}).Ok,"Out of range plant") check(p().Seeds.pepper==count,"Failures preserve seeds")
    move(plot.Commerce.SellBox.BoxLid)
    check(command({Kind="Equip",Item="pepper_seeds"}).Ok,"Equip before death")
    local beforeJson=game:GetService("HttpService"):JSONEncode(p().Seeds)
    player:LoadCharacterAsync() task.wait(1)
    check(game:GetService("HttpService"):JSONEncode(p().Seeds)==beforeJson,"Respawn inventory retained")
    local representations=0 for _,parent in pairs({player.Character,player:FindFirstChildOfClass("Backpack")}) do for _,t in ipairs(parent:GetChildren()) do if t:GetAttribute("InventoryRepresentation") then representations+=1 end end end
    check(representations==0,"No respawn representation duplication")
    -- Leave a measured four-slot fixture, without unlocking any area.
    fixture(function(state)
        for i,id in ipairs({"pepper","grape","corn","wheat"}) do
            local cx={UserId=tostring(player.UserId),Seed=500+i,TimeScale=1}
            state.Plants['Area01/Slot'..i]=D.cycle(state,id,workspace:GetServerTimeNow()-1000,false,cx)
        end
    end)
    move(plot.GrowingAreas.Area01.Slots.Slot4)
    return {Passed=passed,Crops=results,Mode="Studio memory, explicit fixture timestamp advances",Fixture="Four ready crops: pepper, grape, corn, wheat"}
end
return T
