local C=require(game.ReplicatedStorage.Farming.Catalog)
local D=require(script.Parent.Domain)
local W={}
function W.new(plot)
    plot.Arrival.ClaimGuidance.Lettering.Face=Enum.NormalId.Back
    local display=plot.GrowingAreas.Area01.GardenStatusDisplay.StatusDisplay
    display.Transparency=.32
    display.Lettering.Face=Enum.NormalId.Back
    local self={Plot=plot,Slots={},Rendered={}}
    for _,area in ipairs(plot.GrowingAreas:GetChildren()) do
        local slots=area:FindFirstChild("Slots")
        if slots then for _,slot in ipairs(slots:GetChildren()) do self.Slots[area.Name.."/"..slot.Name]=slot end end
    end
    function self:render(p,now)
        local occupied=0
        for key,slot in pairs(self.Slots) do
            local plant=p and p.Plants[key] local stage=D.stage(plant,now)
            local signature=plant and plant.Cycle..":"..stage or "Empty"
            if self.Rendered[key]~=signature then
                self.Rendered[key]=signature
                local old=slot:FindFirstChild("CropPlant") if old then old:Destroy() end
                if plant then
                    local ref=C.Crops[plant.Crop].Models[stage]
                    local template=game.ServerStorage.FarmingCropAssets
                    for segment in ref:gmatch("[^/]+") do template=template:FindFirstChild(segment) assert(template,"Missing crop asset "..ref) end
                    local model=template:Clone() model.Name="CropPlant"
                    -- Workshop geometry is authored about the soil origin. Older XML
                    -- snapshots omit WorldPivotData; Roblox then invents a rotated
                    -- bounding-box pivot. Reset the pivot without moving geometry.
                    model.WorldPivot=CFrame.identity
                    model:ScaleTo(model:GetScale()*1.3)
                    for _,part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") then part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false end end
                    model:PivotTo(slot.CFrame*CFrame.new(0,slot.Size.Y/2,0)) model.Parent=slot
                end
            end
            slot:SetAttribute("SlotId",key) slot:SetAttribute("CropId",plant and plant.Crop or nil)
            slot:SetAttribute("Cycle",plant and plant.Cycle or nil) slot:SetAttribute("GrowthState",stage)
            slot:SetAttribute("ReadyAt",plant and plant.StartedAt+plant.Duration or nil)
            slot:SetAttribute("StartedAt",plant and plant.StartedAt or nil)
            local prompt=slot:FindFirstChild("Plant")
            prompt.Enabled=false prompt.ActionText=stage=="Empty" and "Choose crop" or stage=="Ready" and "Harvest / inspect" or "Care / inspect"
            prompt.ObjectText=plant and C.Crops[plant.Crop].Label.." · "..stage or "Empty planting slot"
            prompt.KeyboardKeyCode=Enum.KeyCode.E prompt.GamepadKeyCode=Enum.KeyCode.ButtonX prompt.RequiresLineOfSight=false
            if plant then
                occupied+=1
                local w,f,total=D.coverage(plant) local interval=D.interval(plant,now)
                slot:SetAttribute("WaterCoverage",w) slot:SetAttribute("FertilizerCoverage",f) slot:SetAttribute("CareIntervals",total)
                slot:SetAttribute("WateredNow",interval and plant.Watered[interval]==true or false)
                slot:SetAttribute("FertilizedNow",interval and plant.Fertilized[interval]==true or false)
            end
        end
        plot.GrowingAreas.Area01:SetAttribute("PlantedSlots",occupied)
    end
    return self
end
return W
