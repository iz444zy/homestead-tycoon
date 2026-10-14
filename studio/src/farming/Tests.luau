-- Run in Studio: require(game.ServerStorage.Farming.Tests).run()
-- Uses pure profiles and an injected durable-store simulator; no player saves.
local C=require(game.ReplicatedStorage.Farming.Catalog)
local D=require(script.Parent.Domain)
local Settings=require(script.Parent.Settings)
local ProfileStore=require(script.Parent.ProfileStore)
local Tests={}
function Tests.run()
    local passed=0 local reports={}
    local function check(ok,msg) assert(ok,msg) passed+=1 end
    local function eq(a,b,msg) check(a==b,(msg or "Mismatch").." expected "..tostring(b)..", got "..tostring(a)) end
    local function ctx(now,seed) return {Now=now or 1000,UserId="101",Seed=seed or 123,TimeScale=1,MaxStack=1000000,MaxBalance=1000000000,UnlockedSlots=Settings.UnlockedSlots} end
    local slot="Area01/Slot1"
    local expected={lettuce={16,32,60,0,30,14},carrot={24,48,90,0,45,24},wheat={32,64,120,0,60,20},pepper={32,64,180,120,60,8},potato={48,96,180,0,90,22},corn={64,128,300,0,120,36},grape={96,192,480,240,120,24},pumpkin={96,192,600,0,180,84}}
    for _,id in ipairs(C.Order) do
        local c=C.Crops[id] local e=expected[id]
        for i,value in ipairs({c.Packs[4],c.Packs[9],c.Growth,c.Regrowth or 0,c.CareInterval,c.Sale}) do eq(value,e[i],id.." config") end
        local p=D.new(10000)
        check(D.apply(p,{Kind="Claim"},ctx()),"Claim") check(p.WateringCan,"Can granted")
        check(D.apply(p,{Kind="Buy",Crop=id,Quantity=4},ctx()),"Four pack") eq(p.Seeds[id],4)
        check(D.apply(p,{Kind="Buy",Crop=id,Quantity=9},ctx()),"Nine pack") eq(p.Seeds[id],13)
        eq(p.Sterne,10000-e[1]-e[2])
        local balance=p.Sterne check(not D.apply(p,{Kind="Buy",Crop=id,Quantity=5},ctx()),"Invalid pack") eq(p.Sterne,balance)
        check(not D.apply(p,{Kind="Plant",Crop=id,Slot="Area02/Slot1"},ctx()),"Locked area") eq(p.Seeds[id],13)
        check(D.apply(p,{Kind="Plant",Crop=id,Slot=slot},ctx()),"Plant") eq(p.Seeds[id],12)
        check(not D.apply(p,{Kind="Plant",Crop=id,Slot=slot},ctx()),"Occupied") eq(p.Seeds[id],12)
        local plant=p.Plants[slot]
        eq(D.stage(plant,1000),"Planted") eq(D.stage(plant,1000+c.Growth*.15),"Developing")
        eq(D.stage(plant,1000+c.Growth*.5),"Mature") eq(D.stage(plant,1000+c.Growth),"Ready")
        eq(D.stage(plant,1000+c.Growth+86400),"Ready","Offline completion")
        check(not D.apply(p,{Kind="Harvest",Slot=slot,Cycle=plant.Cycle},ctx()),"Early harvest rejected")
        check(D.apply(p,{Kind="Water",Slot=slot,Cycle=plant.Cycle},ctx()),"First interval open")
        check(not D.apply(p,{Kind="Water",Slot=slot,Cycle=plant.Cycle},ctx()),"Duplicate water")
        check(D.apply(p,{Kind="Fertilize",Slot=slot,Cycle=plant.Cycle},ctx()),"Neighbor interval")
        check(not D.apply(p,{Kind="Fertilize",Slot=slot,Cycle=plant.Cycle},ctx()),"Second visitor same interval")
        local total=math.ceil(c.Growth/c.CareInterval)
        local w,f,n=D.coverage(plant) eq(n,total) eq(w,1/total) eq(f,1/total)
        for i=2,total do
            check(D.apply(p,{Kind="Water",Slot=slot,Cycle=plant.Cycle},ctx(1000+(i-1)*c.CareInterval)),"Next water interval")
            check(D.apply(p,{Kind="Fertilize",Slot=slot,Cycle=plant.Cycle},ctx(1000+(i-1)*c.CareInterval)),"Next fertilizer interval")
        end
        w,f=D.coverage(plant) eq(w,1) eq(f,1)
        check(not D.apply(p,{Kind="Water",Slot=slot,Cycle=plant.Cycle},ctx(1000+c.Growth)),"Ready care frozen")
        local count,awards=D.harvestRoll(plant) local count2,awards2=D.harvestRoll(plant) eq(count,count2,"Stable yield")
        local cap=D.copy(p) for _,q in ipairs(C.Qualities) do cap.Produce[id][q]=1000000 eq(awards[q],awards2[q],"Stable qualities") end
        check(not D.apply(cap,{Kind="Harvest",Slot=slot,Cycle=plant.Cycle},ctx(1000+c.Growth)),"Capacity rejection") eq(cap.Plants[slot].Cycle,plant.Cycle)
        check(D.apply(p,{Kind="Harvest",Slot=slot,Cycle=plant.Cycle},ctx(1000+c.Growth,456)),"Harvest")
        local sum=0 for _,q in ipairs(C.Qualities) do sum+=p.Produce[id][q] end eq(sum,count)
        check(not D.apply(p,{Kind="Harvest",Slot=slot,Cycle=plant.Cycle},ctx(1000+c.Growth)),"Replay rejected")
        if c.Regrowth then
            local reg=p.Plants[slot] eq(D.stage(reg,reg.StartedAt),"Regrowing") eq(reg.Duration,c.Regrowth)
            w,f=D.coverage(reg) eq(w,0) eq(f,0)
            eq(D.stage(reg,reg.StartedAt+c.Regrowth),"Ready")
        else check(p.Plants[slot]==nil,"Replant crop cleared") end
        local frequencies={} local mixed=0
        for seed=1,10000 do
            plant.Seed=seed local amount,quality=D.harvestRoll(plant)
            frequencies[amount]=(frequencies[amount] or 0)+1
            local types=0 local items=0 for _,q in ipairs(C.Qualities) do items+=quality[q] if quality[q]>0 then types+=1 end end
            eq(items,amount,"Individual quality sum") if types>1 then mixed+=1 end
        end
        local boundary=0
        for _,v in ipairs(c.Yield) do
            eq(D.weighted(c.Yield,boundary),v[1],"Weighted boundary")
            check(math.abs((frequencies[v[1]] or 0)/100-v[2])<2,id.." measured yield weight") boundary+=v[2]
        end
        eq(boundary,100) check(mixed>0,id.." mixed quality possible")
        reports[id]={Yields=frequencies,MixedQualityHarvests=mixed,Trials=10000}
    end
    for _,case in ipairs({{0,0,80,15,4,1},{1,0,60,25,12,3},{1,1,50,30,15,5},{0,1,70,20,7,3},{.5,.25,67.5,21.25,8.75,2.5}}) do
        local odds=D.odds(case[1],case[2]) local sum=0 for i,v in ipairs(odds) do eq(v,case[i+2],"Quality odds") sum+=v end eq(sum,100)
    end
    local p=D.new(0)
    p.Produce.potato.Blue=1 p.Produce.lettuce.Blue=1 p.Produce.carrot.Gold=2
    local lines={{Crop="potato",Quality="Blue",Quantity=1},{Crop="lettuce",Quality="Blue",Quantity=1},{Crop="carrot",Quality="Gold",Quantity=2}}
    local quote=D.quote(p,lines) eq(quote.Total,141,"Floor once: 27.5+17.5+96")
    check(D.apply(p,{Kind="Sell",Lines=lines},ctx()),"Mixed sale") eq(p.Sterne,141) eq(p.Produce.potato.Blue,0)
    check(not D.apply(p,{Kind="Sell",Lines=lines},ctx()),"Duplicate sale")
    check(not D.quote(p,{{Crop="pepper",Quality="Gold",Quantity=0/0}}),"NaN rejected")
    p.Sterne=12 check(D.apply(p,{Kind="Buy",Item="fertilizer_bag"},ctx()),"Buy fertilizer") eq(p.Fertilizer,12) eq(p.Sterne,0)
    check(not D.apply(p,{Kind="Buy",Crop="grape",Quantity=9},ctx()),"Insufficient funds") eq(p.Seeds.grape,0)
    -- Deterministic DataStore fault injection, leases, reconnect and care races.
    local data={} local failBefore=false local failAfter=false
    local backend={UpdateAsync=function(_,key,fn)
        if failBefore then error("TEST: unavailable before write") end
        local result=fn(D.copy(data[key]))
        if not result then return nil end
        data[key]=D.copy(result)
        if failAfter then error("TEST: lost acknowledgement after write") end
        return D.copy(result)
    end}
    local store=ProfileStore.new(backend) local second=ProfileStore.new(backend)
    failBefore=true check(store:load(10)==nil,"Load failure") eq(data['player:10'],nil,"No defaults written on failure") failBefore=false
    check(store:load(10)~=nil,"Load new") check(second:load(10)==nil,"Concurrent session rejected")
    local initial=D.copy(store.Sessions[10].Profile) initial.Sterne=50
    failAfter=true check(not store:commit(10,initial,"purchase-1"),"Lost ack") check(store.Sessions[10].Pending~=nil,"Pending retained") failAfter=false
    check(store:retry(10),"Ambiguous save recovery") eq(store.Sessions[10].Profile.Sterne,50) eq(store.Sessions[10].Profile.Revision,1)
    check(store:commit(10,initial,"purchase-1"),"Same operation deduplicated") eq(store.Sessions[10].Profile.Revision,1)
    check(not store:commit(10,initial,"purchase-2"),"Stale revision rejected") eq(store.Sessions[10].Profile.Sterne,50)
    store:release(10) check(second:load(10)~=nil,"Rejoin after release") eq(second.Sessions[10].Profile.Sterne,50)
    check(store:load(11)~=nil,"Helper profile")
    local target=D.copy(second.Sessions[10].Profile)
    eq(store:resolveHelp(10,11,1),false,"Cancel unresolved care")
    target.CareReceipts['11']={Serial=1,Success=true}
    check(not second:commit(10,target,"late-care"),"Canceled help fences late application")
    target=D.copy(second.Sessions[10].Profile) target.CareReceipts['11']={Serial=2,Success=true}
    check(second:commit(10,target,"care-success"),"Care committed")
    eq(store:resolveHelp(10,11,2),true,"Care success recovered") eq(store:resolveHelp(10,11,2),true,"Care recovery idempotent")
    local corrupt={Version=999,Sterne=900} data['player:12']=D.copy(corrupt)
    check(store:load(12)==nil,"Unsupported schema blocked") eq(data['player:12'].Sterne,900,"Corrupt save preserved")
    local restored=game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):JSONEncode(second.Sessions[10].Profile)) check(D.valid(restored),"JSON round trip")
    return {Passed=passed,Crops=reports,Persistence="Fault-injected adapter; production API requires a published test place"}
end
return Tests
