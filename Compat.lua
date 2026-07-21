-- Migrates saved data from TyrantAvoidance and early TRDR builds.

local function Normalize(database)
    if type(database) ~= "table" then return end

    if database.auto == nil and database.autoCompare ~= nil then
        database.auto = database.autoCompare and true or false
    end

    local baseline = database.baseline
    if type(baseline) ~= "table" then return end

    baseline.time = baseline.time or baseline.timestamp
    baseline.hp = baseline.hp or baseline.maxHealth or 0
    baseline.defRating = baseline.defRating or baseline.defenseRating or 0
    baseline.defBase = baseline.defBase or baseline.defenseBase or 0
    baseline.defBonus = baseline.defBonus or baseline.defenseBonus or 0
    baseline.total = baseline.total or baseline.totalAvoidance
end

Normalize(TRDRDB)
Normalize(TyrantAvoidanceDB)
