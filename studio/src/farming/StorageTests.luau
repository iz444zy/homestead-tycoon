-- Focused contracts, deterministic profiles and injected persistence. No real saves.
local D=require(script.Parent.Domain) local Store=require(script.Parent.ProfileStore)
local I=require(game.ReplicatedStorage.Farming.Inventory) local C=require(game.ReplicatedStorage.Farming.Catalog)
local T={}
function T.run()
    local passed=0 local cases={}
    local function check(x,msg) assert(x,msg) passed+=1 end
    local function eq(a,b,msg) check(a==b,(msg or "Mismatch")..": "..tostring(a).." ~= "..tostring(b)) end
    local function same(a,b)
        if type(a)~=type(b) then return false end if type(a)~="table" then return a==b end
        for k,x in pairs(a) do if not same(x,b[k]) then return false end end
        for k in pairs(b) do if a[k]==nil then return false end end return true
    end
    local function fixture()
        local p=D.new(248) p.Claimed=true p.WateringCan=true p.Fertilizer=12
        for id in pairs(C.Crops) do p.Seeds[id]=12 for _,q in ipairs(C.Qualities) do p.Produce[id][q]=7 end end return p
    end
    local serial=0
    local function action(p,kind,id,q,n)
        serial+=1 return {Kind=kind,Item=id,Quality=q,Quantity=n,Revision=p.Revision,RequestId="test-transfer-"..serial}
    end
    -- Every crop, quality and equipment moves a whole and partial stack, with conservation.
    for _,entry in ipairs(I.entries(fixture())) do
        local p=fixture() local id,q=entry.Item,entry.Quality local original=I.quantity(p,id,q)
        check(D.transfer(p,action(p,"Deposit",id,q,original),1000000),"Whole deposit")
        eq(I.quantity(p,id,q),0) eq(I.quantity(p,id,q,true),original)
        check(D.transfer(p,action(p,"Withdraw",id,q,1),1000000),"Partial withdrawal")
        eq(I.quantity(p,id,q)+I.quantity(p,id,q,true),original,"Conservation")
        if original>1 then check(D.transfer(p,action(p,"Withdraw",id,q,original-1),1000000),"Remaining withdrawal") end
        eq(I.quantity(p,id,q),original) eq(I.quantity(p,id,q,true),0)
        check(D.valid(p),"Valid after transfers")
    end
    table.insert(cases,"all seeds, four qualities, fertilizer and equipment conserved")
    -- Invalid amounts, unknown item and irrelevant quality leave both inventories byte-equivalent.
    for _,n in ipairs({0,-1,.5,13,1000001,math.huge,0/0,"2"}) do
        local p=fixture() local before=D.copy(p)
        check(not D.transfer(p,action(p,"Deposit","pepper_seeds",nil,n),1000000),"Invalid quantity rejected") check(same(p,before),"No mutation on failure")
    end
    for _,spec in ipairs({{"missing",nil},{"pepper_seeds","Gold"},{"pepper_harvest","Purple"},{"watering_can","Gold"}}) do
        local p=fixture() local before=D.copy(p) check(not D.transfer(p,action(p,"Deposit",spec[1],spec[2],1),1000000),"Invalid item") check(same(p,before),"Invalid item unchanged")
    end
    local p=fixture() p.Chest.pepper_seeds=1000000 local before=D.copy(p)
    check(not D.transfer(p,action(p,"Deposit","pepper_seeds",nil,1),1000000),"Capacity rejection") check(same(p,before),"Capacity unchanged")
    p=fixture() check(not D.transfer(p,action(p,"Withdraw","pepper_seeds",nil,1),1000000),"Empty chest")
    check(D.transfer(p,action(p,"Deposit","pepper_harvest","Blue",3),1000000),"Blue deposit") eq(p.Produce.pepper.Gold,7) eq(p.Chest['pepper_harvest:Gold'],nil)
    table.insert(cases,"empty, malformed, excessive, capacity and quality isolation")
    -- Migration copies all legacy data, including crops/care/timestamps, before adding empty storage.
    local legacy=fixture() legacy.Version=1 legacy.Chest=nil legacy.TransferReceipts=nil legacy.TransferOrder=nil
    legacy.Plants['Area01/Slot1']={Crop="pepper",Cycle="a:1",Seed=91,StartedAt=100,Duration=180,Interval=60,Watered={['1']=true},Fertilized={['2']=true}}
    legacy.CareReceipts['88']={Serial=3,Success=true} legacy.LastHarvest={Cycle="a:0",Count=2}
    local migrated=D.migrate(legacy) check(migrated~=nil,"Migration") eq(migrated.Version,2)
    for k,value in pairs(legacy) do if k~="Version" then check(same(migrated[k],value),"Legacy preserved: "..k) end end
    eq(next(migrated.Chest),nil) eq(legacy.Version,1)
    local broken=D.copy(legacy) broken.Seeds.pepper=-1 check(D.migrate(broken)==nil,"Invalid legacy fails closed")
    broken=fixture() broken.Chest.watering_can=2 check(not D.valid(broken),"Duplicate tool rejected")
    table.insert(cases,"non-destructive legacy migration and invalid-profile fence")
    -- Adapter simulates failure before write, lost acknowledgement, lease contention and reload.
    local data={} local failBefore=false local loseAck=false
    local backend={UpdateAsync=function(_,key,fn)
        if failBefore then error("TEST failure before write") end
        local n=fn(D.copy(data[key])) if n then data[key]=D.copy(n) end
        if loseAck then loseAck=false error("TEST ambiguous acknowledgement") end return D.copy(data[key])
    end}
    data['player:700']=fixture() local store=Store.new(backend) check(store:load(700)~=nil,"Load")
    p=store.Sessions[700].Profile local a=action(p,"Deposit","pepper_harvest","Gold",4) local candidate=D.copy(p)
    check(D.transfer(candidate,a,1000000),"Candidate transfer")
    failBefore=true check(not store:commit(700,candidate,"operation-one"),"Failure surfaced")
    check(same(store.Sessions[700].Profile,p),"Failed save not rendered") eq(data['player:700'].Produce.pepper.Gold,7)
    failBefore=false loseAck=true check(not store:retry(700),"Lost ack remains pending")
    eq(data['player:700'].Produce.pepper.Gold,3) eq(data['player:700'].Chest['pepper_harvest:Gold'],4)
    check(store:retry(700),"Ambiguous retry resolves") eq(store.Sessions[700].Profile.Revision,1)
    p=store.Sessions[700].Profile before=D.copy(p) check(D.transfer(p,a,1000000),"Duplicate receipt success") check(same(p,before),"Duplicate no transfer")
    local changed=D.copy(a) changed.Quantity=1 check(not D.transfer(p,changed,1000000),"Reused id with changed payload rejected")
    local racing=action(p,"Deposit","pepper_harvest","Gold",2) racing.Revision=0 check(not D.transfer(p,racing,1000000),"Racing revision rejected")
    local competing=Store.new(backend) check(competing:load(700)==nil,"Competing session rejected")
    store:release(700) local resumed=Store.new(backend) local reloaded=resumed:load(700)
    eq(reloaded.Produce.pepper.Gold,3) eq(reloaded.Chest['pepper_harvest:Gold'],4) check(D.transfer(reloaded,a,1000000),"Duplicate after reconnect")
    resumed:release(700)
    data['player:701']=D.copy(legacy) local migratedStore=Store.new(backend) check(migratedStore:load(701)~=nil,"Atomic migration load") eq(data['player:701'].Version,2)
    data['player:702']=broken before=D.copy(broken) check(Store.new(backend):load(702)==nil,"Corrupt load rejected") check(same(data['player:702'],before),"No defaults written")
    table.insert(cases,"failed and ambiguous saves, duplicate/racing revisions, lease, reconnect")
    return {Passed=passed,Cases=cases,Backend="Injected memory; no production writes"}
end
return T
