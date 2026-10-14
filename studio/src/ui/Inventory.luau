-- Shared inventory references. A hotbar entry never owns a second quantity.
local C=require(script.Parent.Catalog)
local I={}
function I.key(id,q) return id..(q and (":"..q) or "") end
function I.validItem(id,q)
    local item=C.Items[id]
    return item and ((item.Kind=="Produce" and C.QualityMultipliers[q]~=nil) or (item.Kind~="Produce" and q==nil))
end
function I.quantity(p,id,q,stored)
    if not I.validItem(id,q) then return 0 end
    local chest=p.Chest or {}
    if stored then return chest[I.key(id,q)] or 0 end
    local item=C.Items[id]
    if item.Kind=="Seed" then return p.Seeds[item.Crop]
    elseif item.Kind=="Produce" then return p.Produce[item.Crop][q]
    elseif item.Kind=="Water" then return p.WateringCan and 1-(chest[id] or 0) or 0
    elseif item.Kind=="Dig" then return p.Claimed and 1-(chest[id] or 0) or 0
    elseif item.Kind=="Fertilize" then return p.Fertilizer end
    return 0
end
function I.entries(p,category,stored)
    local out={}
    local function add(id,q)
        local n=I.quantity(p,id,q,stored)
        if n>0 then table.insert(out,{Item=id,Quality=q,Count=n,Key=I.key(id,q)}) end
    end
    for _,id in ipairs(C.Order) do
        local c=C.Crops[id]
        if category==nil or category=="Seeds" then add(c.SeedId) end
        if category==nil or category=="Produce" then for _,q in ipairs(C.Qualities) do add(c.HarvestId,q) end end
    end
    if category==nil or category=="Tools" then for _,id in ipairs({"shovel","watering_can","fertilizer_bag"}) do add(id) end end
    return out
end
return I
