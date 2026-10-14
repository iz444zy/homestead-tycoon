-- Shared target/tool rules; client cues and server authorization use this module.
local I=require(script.Parent.Inventory)
local Rules={}
function Rules.action(kind,slot,owned,held,p)
    if kind=="Chest" then return owned and "Chest" or "Not Yours","chest_closed" end
    if kind=="Claim" then return "Claim","hand" end
    if kind=="Market" then return "Market","bag" end
    if kind=="Dig" then return held=="shovel" and I.quantity(p,held)>0 and "Dig" or "Need Shovel","shovel" end
    if not owned then
        if kind=="Slot" and slot.Crop and slot.Stage~="Ready" then
            if slot.Fertilized then return "Helped","fertilizer_bag" end
            if held~="fertilizer_bag" then return "Need Fertilizer","fertilizer_bag" end
            return I.quantity(p,held)>0 and "Help" or "Empty","fertilizer_bag"
        end
        return "Not Yours","hand"
    end
    if not slot.Crop then
        if held and held:match("_seeds$") then return I.quantity(p,held)>0 and "Plant" or "Empty",held end
        return "Seeds","hand"
    end
    if slot.Stage=="Ready" then return "Harvest","hand" end
    if slot.Watered then return "Watered","watering_can" end
    if held~="watering_can" then return "Need Can","watering_can" end
    return I.quantity(p,held)>0 and "Water" or "Stored","watering_can"
end
-- Decorative pieces belong to the same interaction, not separate occluders.
function Rules.surface(point,hit)
    if hit==point or hit:IsDescendantOf(point) then return true end
    local parent=point.Parent
    if not parent then return false end
    if parent.Name=="HouseChest" or (point.Name=="Dirt" and parent.Name=="Digging") or (point.Name=="BoxLid" and parent.Name=="SellBox") then
        return hit:IsDescendantOf(parent)
    end
    return false
end
function Rules.visible(character,point,maxDistance)
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local human=character and character:FindFirstChildOfClass("Humanoid")
    if not root or not human or human.Health<=0 or not point or not point:IsA("BasePart") then return false end
    local localPoint=point.CFrame:PointToObjectSpace(root.Position)
    local half=point.Size/2
    local nearest=point.CFrame:PointToWorldSpace(Vector3.new(math.clamp(localPoint.X,-half.X,half.X),math.clamp(localPoint.Y,-half.Y,half.Y),math.clamp(localPoint.Z,-half.Z,half.Z)))
    if (root.Position-nearest).Magnitude>maxDistance then return false end
    local origin=character:FindFirstChild("Head") or root
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={character}
    local hit=workspace:Raycast(origin.Position,point.Position-origin.Position,params)
    if not hit then return true end
    return Rules.surface(point,hit.Instance)
end
return Rules
