local C=require(game.ReplicatedStorage.Farming.Catalog)
local I=require(game.ReplicatedStorage.Farming.Inventory)
local R={}
local items=game.ReplicatedStorage.FarmingAssets.InventoryItems
function R.quantity(p,id,quality)
    return I.quantity(p,id,quality)
end
function R.clear(player)
    for _,parent in pairs({player:FindFirstChildOfClass("Backpack"),player.Character}) do
        if parent then for _,tool in ipairs(parent:GetChildren()) do if tool:IsA("Tool") and tool:GetAttribute("InventoryRepresentation") then tool:Destroy() end end end
    end
end
function R.reconcile(player,p)
    for _,parent in pairs({player:FindFirstChildOfClass("Backpack"),player.Character}) do
        if parent then for _,tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("InventoryRepresentation") then
                if R.quantity(p,tool:GetAttribute("ItemId"),tool:GetAttribute("Quality"))<1 then tool:Destroy() end
            end
        end end
    end
end
function R.equip(player,p,id,quality,onActivate)
    local item=C.Items[id]
    if not item or R.quantity(p,id,quality)<1 then return false,"That inventory stack is empty." end
    local character=player.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    local backpack=player:FindFirstChildOfClass("Backpack")
    if not humanoid or humanoid.Health<=0 or not backpack then return false,"Respawn before equipping an item." end
    local source=items:FindFirstChild(item.Tool)
    if not source and id~="shovel" then return false,"Item asset unavailable." end
    humanoid:UnequipTools() R.clear(player)
    local tool
    if source then tool=source:Clone() else
        tool=Instance.new("Tool") tool.Name="Shovel"
        local h=Instance.new("Part") h.Name="Handle" h.Size=Vector3.new(.22,3.2,.22) h.Color=Color3.fromRGB(139,108,75) h.Parent=tool
        local b=Instance.new("Part") b.Name="Blade" b.Size=Vector3.new(.95,1,.2) b.Color=Color3.fromRGB(103,110,102) b.CFrame=h.CFrame*CFrame.new(0,-1.85,0) b.Parent=tool
        local weld=Instance.new("WeldConstraint") weld.Part0=h weld.Part1=b weld.Parent=h
    end
    tool:SetAttribute("ItemId",id)
    tool.CanBeDropped=false tool:SetAttribute("InventoryRepresentation",true) tool:SetAttribute("Quality",quality)
    for _,part in ipairs(tool:GetDescendants()) do if part:IsA("BasePart") then part.Anchored=false part.Massless=true part.CanCollide=false part.CanTouch=false part.CanQuery=false end end
    if onActivate then tool.Activated:Connect(onActivate) end
    tool.Parent=backpack humanoid:EquipTool(tool)
    return true,"Holding "..item.Label..(quality and " · "..quality or "").."."
end
return R
