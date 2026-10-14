-- Durable optimistic transactions with session fencing and ambiguous-write recovery.
local DSS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local D=require(script.Parent.Domain)
local Settings=require(script.Parent.Settings)
local Store={}
Store.__index=Store
local memory={}
function Store.new(adapter)
    local test=Run:IsStudio() and Settings.StudioTest.Enabled
    local self=setmetatable({Sessions={}, Token=game.JobId..":"..Http:GenerateGUID(false)},Store)
    self.Mode=(adapter or (test and Settings.StudioTest.UseMemoryStore)) and "STUDIO MEMORY — NOT SAVED" or "Saved"
    local persistent
    if not adapter and self.Mode=="Saved" then
        local ok,result=pcall(function() return DSS:GetDataStore(Settings.StoreName) end)
        if not ok then self.InitializationError="Saving requires a published place with API access. For local testing, enable StudioTest.Enabled and UseMemoryStore in ServerStorage.Farming.Settings." end
        persistent=ok and result or {UpdateAsync=function() error("Publish a test place and enable API access, or explicitly enable StudioTest.UseMemoryStore. "..tostring(result)) end}
    end
    self.Backend=adapter or persistent or {
        UpdateAsync=function(_,key,fn) local nextValue=fn(D.copy(memory[key])) if nextValue~=nil then memory[key]=D.copy(nextValue) end return D.copy(memory[key]) end,
    }
    return self
end
function Store:update(id,fn)
    if self.InitializationError then return nil,self.InitializationError end
    local ok,value=pcall(function() return self.Backend:UpdateAsync("player:"..id,fn) end)
    if not ok then warn("Farming persistence unavailable: "..tostring(value)) return nil,"Saving unavailable. Progress is paused; retry shortly." end
    if not value or not D.valid(value) then return nil,"Saved data unavailable or unsupported. It has not been overwritten." end
    return value
end
function Store:load(id)
    local rejection
    local p,err=self:update(id,function(old)
        local now=os.time()
        if old and not D.valid(old) then rejection="Saved data invalid; no defaults were written." return nil end
        if old and old.Lease and old.Lease.Token~=self.Token and old.Lease.Expires>now then rejection="Your previous session is still saving. Rejoin shortly." return nil end
        local test=Run:IsStudio() and Settings.StudioTest.Enabled
        local nextValue=old and D.migrate(old) or D.new(test and Settings.StudioTest.StartingSterne or 0)
        nextValue.Lease={Token=self.Token,Expires=now+Settings.LeaseSeconds}
        return nextValue
    end)
    if rejection then return nil,rejection end
    if not p then return nil,err end
    self.Sessions[id]={Profile=p, Pending=nil, Blocked=false}
    return p
end
function Store:commit(id,candidate,operation)
    local s=self.Sessions[id]
    if not s then return false,"Profile not loaded." end
    if s.Pending and s.Pending.Operation~=operation then return false,"Previous save is unresolved. Please wait." end
    s.Pending={Candidate=D.copy(candidate),Operation=operation}
    local conflict
    local p,err=self:update(id,function(old)
        if not old or not D.valid(old) then return nil end
        if not old.Lease or old.Lease.Token~=self.Token then conflict="Session lock lost. Rejoin to continue." return nil end
        if old.LastOperation==operation then return old end -- Retry after an ambiguous successful write.
        if old.Revision~=candidate.Revision then conflict="Inventory changed. Please review and try again." return old end
        local nextValue=D.copy(candidate)
        nextValue.Revision=old.Revision+1 nextValue.LastOperation=operation
        nextValue.Lease={Token=self.Token,Expires=os.time()+Settings.LeaseSeconds}
        return nextValue
    end)
    if not p then s.Blocked=true return false,err end
    if conflict then
        s.Pending=nil s.Profile=p
        s.Blocked=not p.Lease or p.Lease.Token~=self.Token
        return false,conflict
    end
    s.Profile=p s.Pending=nil s.Blocked=false
    return true,p
end
function Store:retry(id)
    local s=self.Sessions[id] if not s then return false end
    if s.Pending then return self:commit(id,s.Pending.Candidate,s.Pending.Operation) end
    local p,err=self:update(id,function(old)
        if not old or not D.valid(old) or not old.Lease or old.Lease.Token~=self.Token then return nil end
        old.Lease.Expires=os.time()+Settings.LeaseSeconds return old
    end)
    if not p or not p.Lease or p.Lease.Token~=self.Token then s.Blocked=true return false,err end
    s.Profile=p s.Blocked=false return true,p
end
-- Resolve helper intents even if their owner is offline. A terminal cancellation
-- fences an in-flight owner save via Revision, so a late success cannot be free.
function Store:resolveHelp(ownerId,helperId,serial)
    local key=tostring(helperId)
    local p,err=self:update(ownerId,function(old)
        if not old or not D.valid(old) then return nil end
        local receipt=old.CareReceipts[key]
        if receipt and receipt.Serial>=serial then return old end
        old.CareReceipts[key]={Serial=serial,Success=false}
        old.Revision+=1
        return old
    end)
    if not p then return nil,err end
    local live=self.Sessions[ownerId]
    if live and not live.Pending then live.Profile=p end
    local receipt=p.CareReceipts[key]
    if not receipt or receipt.Serial~=serial then return nil,"Care receipt mismatch; progress paused." end
    return receipt.Success
end
function Store:release(id)
    local s=self.Sessions[id] if not s then return end
    if s.Pending then self:retry(id) end
    if s.Pending then return end -- Keep the fencing lease; next load recovers saved state.
    self:update(id,function(old)
        if old and D.valid(old) and old.Lease and old.Lease.Token==self.Token then old.Lease=nil return old end
        return nil
    end)
    self.Sessions[id]=nil
end
return Store
