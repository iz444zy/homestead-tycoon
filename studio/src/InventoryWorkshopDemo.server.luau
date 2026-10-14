-- Workshop-only pickup preview. Inventory is the standard Roblox Backpack.
local items=game.ReplicatedStorage.AssetLibrary.InventoryItems
local byId={}
for _,t in items:GetChildren() do byId[t:GetAttribute("ItemId")]=t end
for _,p in workspace.InventoryWorkshop:GetDescendants() do
    if p:IsA("ProximityPrompt") then p.Triggered:Connect(function(player)
        local template=byId[p:GetAttribute("ItemId")]
        local character=player.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local backpack=player:FindFirstChildOfClass("Backpack")
        if not root or not backpack or (root.Position-p.Parent.Position).Magnitude>12 then return end
        for _,container in {backpack,character} do for _,t in container:GetChildren() do
            if t:IsA("Tool") and t:GetAttribute("ItemId")==template:GetAttribute("ItemId") then return end
        end end
        template:Clone().Parent=backpack
    end) end
end
