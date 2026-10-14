-- FIRST-PLAYTEST DEFAULTS. This is the only crop/economy/asset catalog.
local C = {}
C.Order = {"lettuce", "carrot", "wheat", "pepper", "potato", "corn", "grape", "pumpkin"}
C.Qualities = {"Common", "Blue", "Silver", "Gold"}
C.QualityMultipliers = {Common=1, Blue=1.25, Silver=1.5, Gold=2}
C.AreaTierQualityBonuses = {[1]=0, [2]=0, [3]=0} -- Reserved, deliberately no tier bonus in this pass.
C.MarketMultiplier = 1 -- NPC prices only; never applies to player listings.
C.Equipment = {
    shovel={Tool="Shovel", Kind="Dig", Label="Shovel"},
    watering_can={Tool="Watering Can", Kind="Water", Label="Watering Can"},
    fertilizer_bag={Tool="Fertilizer Bag", Kind="Fertilize", Label="Fertilizer Bag", Price=12, Charges=12},
}
C.Crops = {
    lettuce={CropType="Lettuce", Label="Lettuce", Unit="head", Units="heads", SeedId="lettuce_seeds", PacketTool="Lettuce Seeds", HarvestId="lettuce_harvest", HarvestTool="Lettuce", Models={Planted="LettuceGrowthStages/Planted", Developing="LettuceGrowthStages/Developing", Mature="LettuceGrowthStages/Mature", Ready="LettuceGrowthStages/Ready"}, Growth=60, CareInterval=30, Packs={[4]=16,[9]=32}, Sale=14, Yield={{1,80},{2,20}}},
    carrot={CropType="Carrot", Label="Carrot", Unit="carrot", Units="carrots", SeedId="carrot_seeds", PacketTool="Carrot Seeds", HarvestId="carrot_harvest", HarvestTool="Carrot", Models={Planted="CarrotGrowthStages/Planted", Developing="CarrotGrowthStages/Developing", Mature="CarrotGrowthStages/Mature", Ready="CarrotGrowthStages/Ready"}, Growth=90, CareInterval=45, Packs={[4]=24,[9]=48}, Sale=24, Yield={{1,25},{2,50},{3,25}}},
    wheat={CropType="Wheat", Label="Wheat", Unit="bundle", Units="bundles", SeedId="wheat_seeds", PacketTool="Wheat Seeds", HarvestId="wheat_harvest", HarvestTool="Wheat", Models={Planted="WheatGrowthStages/Planted", Developing="WheatGrowthStages/Developing", Mature="WheatGrowthStages/Mature", Ready="WheatGrowthStages/Ready"}, Growth=120, CareInterval=60, Packs={[4]=32,[9]=64}, Sale=20, Yield={{1,25},{2,50},{3,25}}},
    pepper={CropType="Pepper", Label="Pepper", Unit="pepper", Units="peppers", SeedId="pepper_seeds", PacketTool="Pepper Seeds", HarvestId="pepper_harvest", HarvestTool="Pepper", Models={Planted="PepperGrowthStages/Planted", Developing="PepperGrowthStages/Developing", Mature="PepperGrowthStages/Mature", Ready="PepperGrowthStages/Ready", Regrowing="PepperGrowthStages/Regrowing"}, Growth=180, Regrowth=120, CareInterval=60, Packs={[4]=32,[9]=64}, Sale=8, Yield={{2,20},{3,35},{4,30},{5,15}}},
    potato={CropType="Potato", Label="Potato", Unit="potato", Units="potatoes", SeedId="potato_seeds", PacketTool="Potato Seeds", HarvestId="potato_harvest", HarvestTool="Potato", Models={Planted="PotatoGrowthStages/Planted", Developing="PotatoGrowthStages/Developing", Mature="PotatoGrowthStages/Mature", Ready="PotatoGrowthStages/Ready"}, Growth=180, CareInterval=90, Packs={[4]=48,[9]=96}, Sale=22, Yield={{2,20},{3,35},{4,30},{5,15}}},
    corn={CropType="Corn", Label="Corn", Unit="ear", Units="ears", SeedId="corn_seeds", PacketTool="Corn Seeds", HarvestId="corn_harvest", HarvestTool="Corn", Models={Planted="CornGrowthStages/Planted", Developing="CornGrowthStages/Developing", Mature="CornGrowthStages/Mature", Ready="CornGrowthStages/Ready"}, Growth=300, CareInterval=120, Packs={[4]=64,[9]=128}, Sale=36, Yield={{2,25},{3,50},{4,25}}},
    grape={CropType="Grape", Label="Grape", Unit="bunch", Units="bunches", SeedId="grape_seeds", PacketTool="Grape Seeds", HarvestId="grape_harvest", HarvestTool="Grape", Models={Planted="GrapeGrowthStages/Planted", Developing="GrapeGrowthStages/Developing", Mature="GrapeGrowthStages/Mature", Ready="GrapeGrowthStages/Ready", Regrowing="GrapeGrowthStages/Regrowing"}, Growth=480, Regrowth=240, CareInterval=120, Packs={[4]=96,[9]=192}, Sale=24, Yield={{2,25},{3,50},{4,25}}},
    pumpkin={CropType="Pumpkin", Label="Pumpkin", Unit="pumpkin", Units="pumpkins", SeedId="pumpkin_seeds", PacketTool="Pumpkin Seeds", HarvestId="pumpkin_harvest", HarvestTool="Pumpkin", Models={Planted="PumpkinGrowthStages/Planted", Developing="PumpkinGrowthStages/Developing", Mature="PumpkinGrowthStages/Mature", Ready="PumpkinGrowthStages/Ready"}, Growth=600, CareInterval=180, Packs={[4]=96,[9]=192}, Sale=84, Yield={{1,25},{2,50},{3,25}}},
}
C.Items = {}
for id,crop in pairs(C.Crops) do
    crop.Id=id
    C.Items[crop.SeedId]={Crop=id, Kind="Seed", Tool=crop.PacketTool, Label=crop.Label.." seeds"}
    C.Items[crop.HarvestId]={Crop=id, Kind="Produce", Tool=crop.HarvestTool, Label=crop.Label}
end
for id,item in pairs(C.Equipment) do C.Items[id]=item end
return C
