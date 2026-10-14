-- Server-only operational settings. Never trust a client to enable test mode.
return {
    StoreName="LunaLandingFarming_v1",
    LeaseSeconds=180, HeartbeatSeconds=45,
    InteractionDistance=18, RequestCooldown=.18, DigCooldown=.7, SeedChance=.4,
    MaxStack=1000000, MaxBalance=1000000000,
    UnlockedSlots={ ["Area01/Slot1"]=true, ["Area01/Slot2"]=true, ["Area01/Slot3"]=true, ["Area01/Slot4"]=true },
    -- Explicit opt-in, ignored outside Studio. Normal times/prices live in Catalog.
    StudioTest={Enabled=false, UseMemoryStore=false, TimeScale=1, StartingSterne=0},
}
