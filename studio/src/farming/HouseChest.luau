-- Reusable, modest timber chest. No UI or crop geometry is embedded in the model.
local Chest={}
function Chest.ensure(plot)
    local existing=plot:FindFirstChild("HouseChest") if existing then return existing end
    local m=Instance.new("Model") m.Name="HouseChest" m:SetAttribute("ChestId","CottageChest")
    local origin=CFrame.new(-82,0,-38) -- In front of cottage, beside the stairs.
    local function part(parent,name,size,cf,metal)
        local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=origin*cf p.Anchored=true
        p.Material=metal and Enum.Material.Metal or Enum.Material.Wood
        p.Color=metal and Color3.fromRGB(53,54,48) or Color3.fromRGB(130,85,48)
        p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
    end
    local body=Instance.new("Model") body.Name="Body" body.Parent=m
    part(body,"Bottom",Vector3.new(4.4,.25,2.4),CFrame.new(0,.15,0))
    for _,z in ipairs({-1.08,1.08}) do part(body,"Timber",Vector3.new(4.4,1.75,.24),CFrame.new(0,1,z)) end
    for _,x in ipairs({-2.08,2.08}) do part(body,"Side",Vector3.new(.24,1.75,2.2),CFrame.new(x,1,0)) end
    for _,x in ipairs({-1.55,1.55}) do for _,z in ipairs({-1.23,1.23}) do part(body,"Band",Vector3.new(.22,1.85,.08),CFrame.new(x,1,z),true) end end
    part(body,"Latch",Vector3.new(.38,.55,.16),CFrame.new(0,1.6,1.25),true)
    local lid=Instance.new("Model") lid.Name="Lid" lid.Parent=m
    part(lid,"TimberLid",Vector3.new(4.55,.3,2.55),CFrame.new(0,2,0))
    for _,x in ipairs({-1.55,1.55}) do part(lid,"LidBand",Vector3.new(.23,.34,2.6),CFrame.new(x,2,0),true) end
    lid.WorldPivot=origin*CFrame.new(0,1.85,-1.15)
    local anchor=part(m,"InteractionAnchor",Vector3.new(4.7,2.2,2.7),CFrame.new(0,1.15,0))
    anchor.Transparency=1 anchor.CanCollide=false m.PrimaryPart=anchor
    m:SetAttribute("Open",false) m.Parent=plot return m
end
return Chest
