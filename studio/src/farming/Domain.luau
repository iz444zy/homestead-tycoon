-- Pure server domain: callers clone the profile, validate world context, then commit.
local C=require(game.ReplicatedStorage.Farming.Catalog)
local I=require(game.ReplicatedStorage.Farming.Inventory)
local D={}
function D.copy(x)
    if type(x)~="table" then return x end
    local y={} for k,v in pairs(x) do y[k]=D.copy(v) end return y
end
function D.new(balance)
    local p={Version=2, Chest={}, TransferReceipts={}, TransferOrder={}, Revision=0, Sterne=balance or 0, Seeds={}, Produce={}, WateringCan=false, Fertilizer=0, Claimed=false, Plants={}, CycleSerial=0, HelpSerial=0, CareReceipts={}, LastHarvest={}}
    for id in pairs(C.Crops) do p.Seeds[id]=0 p.Produce[id]={Common=0,Blue=0,Silver=0,Gold=0} end
    return p
end
local function integer(x) return type(x)=="number" and x==x and x>=0 and x<math.huge and x%1==0 end
function D.valid(p)
    if type(p)~="table" or (p.Version~=1 and p.Version~=2) or not integer(p.Revision) or not integer(p.Sterne) or not integer(p.Fertilizer) or type(p.Plants)~="table" or type(p.CareReceipts)~="table" or not integer(p.CycleSerial) or not integer(p.HelpSerial) or type(p.WateringCan)~="boolean" or type(p.Claimed)~="boolean" then return false end
    if type(p.Seeds)~="table" or type(p.Produce)~="table" then return false end
    for id in pairs(C.Crops) do
        if not integer(p.Seeds[id]) or type(p.Produce[id])~="table" then return false end
        for _,q in ipairs(C.Qualities) do if not integer(p.Produce[id][q]) then return false end end
    end
    for key,v in pairs(p.Plants) do
        if type(key)~="string" or type(v)~="table" or not C.Crops[v.Crop] or type(v.Cycle)~="string" or not integer(v.Seed) or type(v.StartedAt)~="number" or v.StartedAt~=v.StartedAt or type(v.Duration)~="number" or v.Duration<=0 or v.Duration==math.huge or type(v.Interval)~="number" or v.Interval<=0 or type(v.Watered)~="table" or type(v.Fertilized)~="table" then return false end
    end
    if p.Version==2 then
        if type(p.Chest)~="table" or type(p.TransferReceipts)~="table" or type(p.TransferOrder)~="table" or #p.TransferOrder>32 then return false end
        for key,n in pairs(p.Chest) do
            if type(key)~="string" or not integer(n) or n>1000000 then return false end
            local id,q=key:match("^([^:]+):(.+)$") id=id or key
            if not I.validItem(id,q) then return false end
            if id=="watering_can" and (n>1 or (n>0 and not p.WateringCan)) then return false end
            if id=="shovel" and (n>1 or (n>0 and not p.Claimed)) then return false end
        end
        for id,receipt in pairs(p.TransferReceipts) do if type(id)~="string" or type(receipt)~="string" then return false end end
        for _,id in ipairs(p.TransferOrder) do if type(id)~="string" or not p.TransferReceipts[id] then return false end end
    end
    return true
end
function D.migrate(p)
    if not D.valid(p) then return nil end
    p=D.copy(p)
    if p.Version==1 then p.Version=2 p.Chest={} p.TransferReceipts={} p.TransferOrder={} end
    return p
end
function D.transferSignature(a)
    return table.concat({a.Kind,tostring(a.Item),tostring(a.Quality),tostring(a.Quantity),tostring(a.Revision)},"|")
end
function D.transfer(p,a,maxStack)
    if a.Kind~="Deposit" and a.Kind~="Withdraw" then return false,"Invalid transfer." end
    if not I.validItem(a.Item,a.Quality) or not integer(a.Quantity) or a.Quantity<1 or a.Quantity>maxStack then return false,"Invalid amount." end
    if type(a.RequestId)~="string" or #a.RequestId<8 or #a.RequestId>80 then return false,"Invalid request." end
    local signature=D.transferSignature(a)
    local receipt=p.TransferReceipts[a.RequestId]
    if receipt then return receipt==signature,receipt==signature and "Done" or "Request changed." end
    if a.Revision~=p.Revision then return false,"Updated. Try again." end
    local taking=a.Kind=="Withdraw" local item=C.Items[a.Item] local key=I.key(a.Item,a.Quality)
    local available=I.quantity(p,a.Item,a.Quality,taking)
    local destination=I.quantity(p,a.Item,a.Quality,not taking)
    local equipment=item.Kind=="Water" or item.Kind=="Dig"
    if a.Quantity>available then return false,"Stock changed." end
    if destination+a.Quantity>(equipment and 1 or maxStack) then return false,"Storage full." end
    local delta=taking and a.Quantity or -a.Quantity
    -- All validation precedes either mutation. The caller commits this entire candidate.
    if item.Kind=="Seed" then p.Seeds[item.Crop]+=delta
    elseif item.Kind=="Produce" then p.Produce[item.Crop][a.Quality]+=delta
    elseif item.Kind=="Fertilize" then p.Fertilizer+=delta end
    p.Chest[key]=(p.Chest[key] or 0)-delta
    if p.Chest[key]==0 then p.Chest[key]=nil end
    p.TransferReceipts[a.RequestId]=signature table.insert(p.TransferOrder,a.RequestId)
    if #p.TransferOrder>32 then p.TransferReceipts[table.remove(p.TransferOrder,1)]=nil end
    return true,"Done"
end
function D.stage(plant,now)
    if not plant then return "Empty" end
    local progress=(now-plant.StartedAt)/plant.Duration
    if progress>=1 then return "Ready" end
    if plant.Regrowing then return "Regrowing" end
    if progress<.15 then return "Planted" elseif progress<.5 then return "Developing" else return "Mature" end
end
function D.interval(plant,now)
    if now<plant.StartedAt or D.stage(plant,now)=="Ready" then return nil end
    return tostring(math.floor((now-plant.StartedAt)/plant.Interval)+1)
end
function D.coverage(plant)
    local total=math.ceil(plant.Duration/plant.Interval)
    local function count(t) local n=0 for k,v in pairs(t) do local i=tonumber(k) if v and i and i>=1 and i<=total then n+=1 end end return math.clamp(n/total,0,1) end
    return count(plant.Watered),count(plant.Fertilized),total
end
function D.odds(w,f)
    w=math.clamp(w,0,1) f=math.clamp(f,0,1)
    return {80-20*w-10*f,15+10*w+5*f,4+8*w+3*f,1+2*w+2*f}
end
function D.weighted(outcomes,roll)
    local cumulative=0
    for _,entry in ipairs(outcomes) do cumulative+=entry[2] if roll<cumulative then return entry[1] end end
    return outcomes[#outcomes][1]
end
function D.harvestRoll(plant)
    -- Cycle seed is saved at planting/regrowth. Save retries or reconnects cannot reroll.
    local rng=Random.new(plant.Seed)
    local crop=C.Crops[plant.Crop]
    local count=D.weighted(crop.Yield,rng:NextNumber(0,100))
    local w,f=D.coverage(plant)
    local odds=D.odds(w,f)
    local choices={} for i,q in ipairs(C.Qualities) do choices[i]={q,odds[i]} end
    local awards={Common=0,Blue=0,Silver=0,Gold=0}
    for _=1,count do local q=D.weighted(choices,rng:NextNumber(0,100)) awards[q]+=1 end
    return count,awards
end
function D.cycle(p,cropId,now,regrowing,ctx)
    p.CycleSerial+=1
    local c=C.Crops[cropId]
    return {Crop=cropId, Cycle=ctx.UserId..":"..p.CycleSerial, Seed=ctx.Seed, StartedAt=now, Duration=(regrowing and c.Regrowth or c.Growth)/ctx.TimeScale, Interval=c.CareInterval/ctx.TimeScale, Regrowing=regrowing or false, Watered={}, Fertilized={}}
end
function D.quote(p,lines)
    if type(lines)~="table" or #lines<1 or #lines>32 then return nil,"Select produce to sell." end
    local seen,total,items={},0,{}
    for _,line in ipairs(lines) do
        if type(line)~="table" then return nil,"Invalid sale selection." end
        local c=C.Crops[line.Crop] local q=line.Quality local n=line.Quantity
        if not c or not C.QualityMultipliers[q] or not integer(n) or n<1 then return nil,"Invalid sale selection." end
        local key=line.Crop..":"..q
        if seen[key] or p.Produce[line.Crop][q]<n then return nil,"Stock changed. Review your selection." end
        seen[key]=true
        local unit=c.Sale*C.QualityMultipliers[q]*C.MarketMultiplier
        total+=unit*n
        table.insert(items,{Crop=line.Crop, Quality=q, Quantity=n, Unit=unit})
    end
    return {Lines=items, Total=math.floor(total)}
end
function D.apply(p,a,ctx)
    local kind=a.Kind local now=ctx.Now local crop=C.Crops[a.Crop]
    if kind=="Claim" then p.Claimed=true p.WateringCan=true return true,"Homestead claimed. Watering can available in inventory."
    elseif kind=="Buy" then
        local price,quantity
        if a.Item=="fertilizer_bag" then price=C.Equipment.fertilizer_bag.Price quantity=C.Equipment.fertilizer_bag.Charges
        elseif crop then price=crop.Packs[a.Quantity] quantity=a.Quantity end
        if not price then return false,"Choose a listed pack." end
        if p.Sterne<price then return false,"Not enough Sterne." end
        if a.Item=="fertilizer_bag" then
            if p.Fertilizer+quantity>ctx.MaxStack then return false,"Fertilizer storage full." end
            p.Fertilizer+=quantity
        else
            if p.Seeds[a.Crop]+quantity>ctx.MaxStack then return false,"Seed storage full." end
            p.Seeds[a.Crop]+=quantity
        end
        p.Sterne-=price
        return true,a.Item=="fertilizer_bag" and "Bought 12 fertilizer applications." or string.format("Bought %d %s seeds.",quantity,crop.Label)
    elseif kind=="Sell" then
        local quote,err=D.quote(p,a.Lines) if not quote then return false,err end
        if p.Sterne+quote.Total>ctx.MaxBalance then return false,"Sterne balance full." end
        for _,line in ipairs(quote.Lines) do p.Produce[line.Crop][line.Quality]-=line.Quantity end
        p.Sterne+=quote.Total return true,"Sold produce for "..quote.Total.." Sterne."
    elseif kind=="Dig" then
        if not p.Claimed then return false,"Claim your homestead first." end
        if p.Sterne>=ctx.MaxBalance then return false,"Sterne balance full." end
        p.Sterne+=1
        if ctx.Discovery and p.Seeds[ctx.Discovery]<ctx.MaxStack then p.Seeds[ctx.Discovery]+=1 return true,"+1 Sterne; discovered 1 "..C.Crops[ctx.Discovery].Label.." seed." end
        return true,"+1 Sterne."
    end
    if not ctx.UnlockedSlots[a.Slot] then return false,"That planting slot is locked." end
    local plant=p.Plants[a.Slot]
    if kind=="Plant" then
        if not p.Claimed then return false,"Claim your homestead first." end
        if plant then return false,"That slot is occupied." end
        if not crop or p.Seeds[a.Crop]<1 then return false,"No seeds available for that crop." end
        p.Plants[a.Slot]=D.cycle(p,a.Crop,now,false,ctx) p.Seeds[a.Crop]-=1
        return true,crop.Label.." planted; one seed used."
    end
    if not plant then return false,"There is no crop here." end
    if a.Cycle~=plant.Cycle then return false,"Crop cycle changed. Target it again." end
    if kind=="Harvest" then
        if D.stage(plant,now)~="Ready" then return false,"This crop is still growing." end
        local count,awards=D.harvestRoll(plant)
        for q,n in pairs(awards) do if p.Produce[plant.Crop][q]+n>ctx.MaxStack then return false,"Produce storage full. Sell some before harvesting." end end
        local summary={} for _,q in ipairs(C.Qualities) do local n=awards[q] if n>0 then table.insert(summary,n.." "..q) end p.Produce[plant.Crop][q]+=n end
        local c=C.Crops[plant.Crop]
        p.LastHarvest={Cycle=plant.Cycle, Crop=plant.Crop, Awards=awards, Count=count}
        p.Plants[a.Slot]=c.Regrowth and D.cycle(p,plant.Crop,now,true,ctx) or nil
        return true,count.." "..(count==1 and c.Unit or c.Units)..": "..table.concat(summary,", ").."."
    elseif kind=="Water" or kind=="Fertilize" then
        local interval=D.interval(plant,now)
        if not interval then return false,"Already Ready; care is frozen until the next cycle." end
        if kind=="Water" and I.quantity(p,"watering_can")<1 then return false,"Take your can from the chest." end
        local records=kind=="Water" and plant.Watered or plant.Fertilized
        if records[interval] then return false,"Already cared for in this interval." end
        records[interval]=true
        return true,kind=="Water" and "Watered this interval." or "Fertilized this interval."
    end
    return false,"Unknown action."
end
return D
