-- TRDR: Felsworn Tyrant diminishing returns and gear comparison
-- WoW 3.3.5a / Interface 30300

local A = CreateFrame("Frame")
local P, pending, skinned
local rows = {}

local C = {
    rating = 13.8,
    def = 0.04,
    dodgeK = 0.972,
    dodgeCap = 116.890707,
    agi = 20.246477,
    parryK = 0.972,
    parryCap = 47.003525,
    strStep = 5,
    strRating = 0.75,
    baseAgi = 100,
    baseDodge = 23.603130340576,
    fixedParry = 9.183999459357,
}

local function copy(t)
    if type(t) ~= "table" then return t end
    local n = {}
    for k, v in pairs(t) do
        if type(v) ~= "function" then n[k] = copy(v) end
    end
    return n
end

local function curve(x, cap, k)
    if not x or x <= 0 then return 0 end
    return 1 / ((1 / cap) + (k / x))
end

local function efficiency(x, cap, k)
    local d = x + k * cap
    return 100 * k * cap * cap / (d * d)
end

local function db()
    if not TRDRDB and TyrantAvoidanceDB then TRDRDB = copy(TyrantAvoidanceDB) end
    TRDRDB = TRDRDB or {}
    if TyrantAvoidanceDB and TyrantAvoidanceDB ~= TRDRDB then
        TRDRDB.baseline = TRDRDB.baseline or copy(TyrantAvoidanceDB.baseline)
        TRDRDB.calibration = TRDRDB.calibration or copy(TyrantAvoidanceDB.calibration)
    end
    TyrantAvoidanceDB = nil
    if TRDRDB.auto == nil then TRDRDB.auto = true end
    TRDRDB.calibration = TRDRDB.calibration or {
        baseAgi = C.baseAgi,
        baseDodge = C.baseDodge,
        fixedParry = C.fixedParry,
    }
    local c = TRDRDB.calibration
    c.baseAgi = c.baseAgi or C.baseAgi
    c.baseDodge = c.baseDodge or C.baseDodge
    c.fixedParry = c.fixedParry or C.fixedParry
end

local function enrich(s)
    db()
    local cal = TRDRDB.calibration
    s.total = s.dodge + s.parry
    s.dodgeRaw = math.max(0,
        (s.agi - cal.baseAgi) / C.agi +
        s.dodgeRating / C.rating +
        s.defBonus * C.def)
    s.dodgeModel = cal.baseDodge + curve(s.dodgeRaw, C.dodgeCap, C.dodgeK)
    s.dodgeEff = efficiency(s.dodgeRaw, C.dodgeCap, C.dodgeK)
    s.dodge10 = curve(s.dodgeRaw + 10 / C.rating, C.dodgeCap, C.dodgeK)
        - curve(s.dodgeRaw, C.dodgeCap, C.dodgeK)
    s.agi10 = curve(s.dodgeRaw + 10 / C.agi, C.dodgeCap, C.dodgeK)
        - curve(s.dodgeRaw, C.dodgeCap, C.dodgeK)

    local steps = math.floor(s.str / C.strStep)
    s.strRaw = steps * C.strRating / C.rating
    s.parryRaw = s.parryRating / C.rating + s.defBonus * C.def
    s.parryModel = cal.fixedParry
        + curve(s.strRaw, C.parryCap, C.parryK)
        + curve(s.parryRaw, C.parryCap, C.parryK)
    s.parryEff = efficiency(s.parryRaw, C.parryCap, C.parryK)
    s.parry10 = curve(s.parryRaw + 10 / C.rating, C.parryCap, C.parryK)
        - curve(s.parryRaw, C.parryCap, C.parryK)

    local rem = s.str % C.strStep
    s.strNeeded = C.strStep - rem
    local nextRaw = s.strRaw + C.strRating / C.rating
    s.strGain = curve(nextRaw, C.parryCap, C.parryK)
        - curve(s.strRaw, C.parryCap, C.parryK)
    s.dodgeError = s.dodge - s.dodgeModel
    s.parryError = s.parry - s.parryModel
    return s
end

local function snap()
    local _, str = UnitStat("player", 1)
    local _, agi = UnitStat("player", 2)
    local _, sta = UnitStat("player", 3)
    local defBase, defBonus = UnitDefense("player")
    return enrich({
        time = time(),
        level = UnitLevel("player"),
        str = str or 0,
        agi = agi or 0,
        sta = sta or 0,
        hp = UnitHealthMax("player") or 0,
        defRating = GetCombatRating(2) or 0,
        dodgeRating = GetCombatRating(3) or 0,
        parryRating = GetCombatRating(4) or 0,
        defBase = defBase or 0,
        defBonus = defBonus or 0,
        dodge = GetDodgeChance() or 0,
        parry = GetParryChance() or 0,
    })
end

local function val(v, dec, suffix)
    if v == nil then return "-" end
    return string.format("%." .. (dec or 0) .. "f%s", v, suffix or "")
end

local function signed(v, dec, suffix)
    if math.abs(v or 0) < 0.0000005 then v = 0 end
    return string.format("%+." .. (dec or 0) .. "f%s", v or 0, suffix or "")
end

local function message(text, r, g, b)
    if not P then return end
    P.message:SetText(text or "")
    P.message:SetTextColor(r or 1, g or 0.82, b or 0)
end

local metrics = {
    {"str", "Strength", 0},
    {"agi", "Agility", 0},
    {"sta", "Stamina", 0},
    {"hp", "Maximum health", 0},
    {"defRating", "Defense rating", 0},
    {"defBonus", "Bonus defense skill", 0},
    {"dodgeRating", "Dodge rating", 0},
    {"parryRating", "Parry rating", 0},
    {"dodge", "Dodge after DR", 6, "%"},
    {"parry", "Parry after DR", 6, "%"},
    {"total", "Dodge + parry", 6, "%"},
    {"dodgeRaw", "Raw dodge pool", 4, "%"},
    {"dodgeEff", "Next dodge efficiency", 2, "%"},
    {"parryEff", "Next parry efficiency", 2, "%"},
}

local function drName(e)
    if e >= 80 then return "light" end
    if e >= 70 then return "moderate" end
    if e >= 60 then return "heavy" end
    return "very heavy"
end

local function verdict(now, base)
    if not base then
        P.verdict:SetText("Save the current setup as a baseline, then equip or remove an item.")
        P.verdict:SetTextColor(1, 0.82, 0)
        return
    end
    local av = now.total - base.total
    local sta = now.sta - base.sta
    local hp = now.hp - base.hp
    local text, r, g, b
    if av > 0.00005 and sta >= 0 then
        text, r, g, b = "Avoidance upgrade", 0.2, 1, 0.2
    elseif av > 0.00005 then
        text, r, g, b = "Trade-off: more avoidance, less stamina", 1, 0.82, 0
    elseif av < -0.00005 and sta > 0 then
        text, r, g, b = "Trade-off: less avoidance, more stamina", 1, 0.82, 0
    elseif av < -0.00005 then
        text, r, g, b = "Avoidance downgrade", 1, 0.35, 0.25
    elseif sta > 0 then
        text, r, g, b = "Avoidance unchanged; more stamina", 0.2, 1, 0.2
    elseif sta < 0 then
        text, r, g, b = "Avoidance unchanged; less stamina", 1, 0.35, 0.25
    else
        text, r, g, b = "No meaningful tank-stat change", 0.8, 0.8, 0.8
    end
    P.verdict:SetText(string.format("%s - avoidance %s, STA %s, health %s.",
        text, signed(av, 6, "%"), signed(sta), signed(hp)))
    P.verdict:SetTextColor(r, g, b)
end

local function update()
    if not P then return end
    db()
    local now = snap()
    TRDRDB.last = copy(now)
    local base = TRDRDB.baseline and enrich(copy(TRDRDB.baseline)) or nil

    for i, m in ipairs(metrics) do
        local row, key, dec, suffix = rows[i], m[1], m[3], m[4]
        row.base:SetText(val(base and base[key], dec, suffix))
        row.now:SetText(val(now[key], dec, suffix))
        if base then
            local d = now[key] - base[key]
            row.diff:SetText(signed(d, dec, suffix))
            if d > 0.0000005 then row.diff:SetTextColor(0.2, 1, 0.2)
            elseif d < -0.0000005 then row.diff:SetTextColor(1, 0.35, 0.25)
            else row.diff:SetTextColor(0.8, 0.8, 0.8) end
        else
            row.diff:SetText("-")
            row.diff:SetTextColor(0.8, 0.8, 0.8)
        end
    end

    P.baseInfo:SetText(base and ("Baseline: " .. date("%Y-%m-%d %H:%M", base.time)) or "No baseline saved")
    P.auto:SetChecked(TRDRDB.auto)
    verdict(now, base)
    P.marginal:SetText(string.format(
        "+10 dodge rating: %.4f%% dodge | +10 parry rating: %.4f%% parry | +10 agility: %.4f%% dodge",
        now.dodge10, now.parry10, now.agi10))

    local compare = ""
    if now.dodge10 > 0 and now.parry10 > now.dodge10 * 1.05 then
        compare = string.format(" Equal parry rating gives about %.0f%% more avoidance.",
            (now.parry10 / now.dodge10 - 1) * 100)
    elseif now.parry10 > 0 and now.dodge10 > now.parry10 * 1.05 then
        compare = string.format(" Equal dodge rating gives about %.0f%% more avoidance.",
            (now.dodge10 / now.parry10 - 1) * 100)
    end
    P.dr:SetText(string.format(
        "Dodge DR: %s (%.2f%% efficiency). Parry-rating DR: %s (%.2f%%).%s",
        drName(now.dodgeEff), now.dodgeEff, drName(now.parryEff), now.parryEff, compare))
    P.strength:SetText(string.format(
        "Next Strength parry breakpoint: +%d STR for about %.4f%% parry.",
        now.strNeeded, now.strGain))

    if now.level ~= 60 then
        P.model:SetText("Warning: fitted formulas are calibrated for level 60.")
        P.model:SetTextColor(1, 0.35, 0.25)
    elseif math.abs(now.dodgeError) <= 0.01 and math.abs(now.parryError) <= 0.01 then
        P.model:SetText(string.format("Model check: dodge error %.6f%%; parry error %.6f%%.",
            now.dodgeError, now.parryError))
        P.model:SetTextColor(0.65, 0.8, 1)
    else
        P.model:SetText(string.format("Model mismatch: dodge %.4f%%; parry %.4f%%. Check form, buffs, talents, or calibration.",
            now.dodgeError, now.parryError))
        P.model:SetTextColor(1, 0.35, 0.25)
    end
end

local function saveBaseline()
    db()
    TRDRDB.baseline = copy(snap())
    update()
    message("Current setup saved as baseline.", 0.2, 1, 0.2)
end

local function clearBaseline()
    db()
    TRDRDB.baseline = nil
    update()
    message("Baseline cleared.")
end

local function calibrate()
    db()
    local s = snap()
    if s.dodgeRating ~= 0 or s.parryRating ~= 0 or s.defRating ~= 0 or s.defBonus ~= 0 then
        message("Calibration refused: remove all defense, dodge, and parry gear first.", 1, 0.35, 0.25)
        return
    end
    local strRaw = math.floor(s.str / C.strStep) * C.strRating / C.rating
    TRDRDB.calibration = {
        baseAgi = s.agi,
        baseDodge = s.dodge,
        fixedParry = s.parry - curve(strRaw, C.parryCap, C.parryK),
    }
    update()
    message("Naked calibration saved.", 0.2, 1, 0.2)
end

local function button(parent, text, width, x, y, fn)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 24)
    b:SetPoint("TOPLEFT", x, y)
    b:SetText(text)
    b:SetScript("OnClick", fn)
    return b
end

local function skin()
    if skinned or not P or not IsAddOnLoaded("ElvUI") or not ElvUI then return end
    local ok, E = pcall(function() return unpack(ElvUI) end)
    if not ok or not E or not E.GetModule then return end
    local S = E:GetModule("Skins", true)
    if not S then return end
    if S.HandleButton then
        for _, b in ipairs({P.save, P.refresh, P.calibrate, P.clear}) do
            pcall(S.HandleButton, S, b)
        end
    end
    if S.HandleCheckBox then pcall(S.HandleCheckBox, S, P.auto) end
    skinned = true
end

local function font(parent, template, x, y, width, justify)
    local f = parent:CreateFontString(nil, "ARTWORK", template)
    f:SetPoint("TOPLEFT", x, y)
    if width then f:SetWidth(width) end
    if justify then f:SetJustifyH(justify) end
    return f
end

local function createPanel()
    P = CreateFrame("Frame", "TRDROptionsPanel")
    P.name = "TRDR"

    local title = font(P, "GameFontNormalLarge", 16, -16)
    title:SetText("TRDR")
    local sub = font(P, "GameFontHighlightSmall", 16, -42, 590, "LEFT")
    sub:SetText("Felsworn Tyrant diminishing returns and persistent gear comparison. Character-sheet avoidance is already after DR.")
    P.baseInfo = font(P, "GameFontNormalSmall", 390, -20, 200, "RIGHT")

    local heads = {{"Metric",18,180,"LEFT"},{"Baseline",203,105,"RIGHT"},{"Current",317,105,"RIGHT"},{"Difference",431,115,"RIGHT"}}
    for _, h in ipairs(heads) do
        local f = font(P, "GameFontNormal", h[2], -68, h[3], h[4])
        f:SetText(h[1])
    end
    for i, m in ipairs(metrics) do
        local y = -90 - (i - 1) * 18
        local r = {}
        r.label = font(P, "GameFontHighlightSmall", 18, y, 180, "LEFT"); r.label:SetText(m[2])
        r.base = font(P, "GameFontHighlightSmall", 203, y, 105, "RIGHT")
        r.now = font(P, "GameFontHighlightSmall", 317, y, 105, "RIGHT")
        r.diff = font(P, "GameFontHighlightSmall", 431, y, 115, "RIGHT")
        rows[i] = r
    end

    P.verdict = font(P, "GameFontNormal", 18, -345, 570, "LEFT")
    P.marginal = font(P, "GameFontHighlightSmall", 18, -373, 570, "LEFT")
    P.dr = font(P, "GameFontHighlightSmall", 18, -397, 570, "LEFT")
    P.strength = font(P, "GameFontHighlightSmall", 18, -421, 570, "LEFT")
    P.model = font(P, "GameFontHighlightSmall", 18, -445, 570, "LEFT")

    P.auto = CreateFrame("CheckButton", "TRDRAutoCompareCheckButton", P, "InterfaceOptionsCheckButtonTemplate")
    P.auto:SetPoint("TOPLEFT", 14, -470)
    _G[P.auto:GetName() .. "Text"]:SetText("Automatically refresh after equipment changes")
    P.auto:SetScript("OnClick", function(self)
        db(); TRDRDB.auto = self:GetChecked() and true or false
        message(TRDRDB.auto and "Automatic comparison enabled." or "Automatic comparison disabled.", 0.65, 0.8, 1)
        if TRDRDB.auto then update() end
    end)

    P.save = button(P, "Save Baseline", 112, 18, -504, saveBaseline)
    P.refresh = button(P, "Refresh", 86, 136, -504, function() update(); message("Comparison refreshed.", 0.65, 0.8, 1) end)
    P.calibrate = button(P, "Calibrate Naked", 120, 228, -504, calibrate)
    P.clear = button(P, "Clear Baseline", 112, 354, -504, clearBaseline)
    P.message = font(P, "GameFontHighlightSmall", 18, -538, 570, "LEFT")
    P:SetScript("OnShow", function() update(); skin() end)

    InterfaceOptions_AddCategory(P)
    skin()
end

A:RegisterEvent("PLAYER_LOGIN")
A:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
A:RegisterEvent("PLAYER_ENTERING_WORLD")
A:RegisterEvent("ADDON_LOADED")
A:SetScript("OnEvent", function(_, event, arg)
    if event == "PLAYER_LOGIN" then
        db(); createPanel(); TRDRDB.last = copy(snap())
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        db(); if TRDRDB.auto then pending = GetTime() + 0.8 end
    elseif event == "PLAYER_ENTERING_WORLD" then
        pending = GetTime() + 1
    elseif event == "ADDON_LOADED" and arg == "ElvUI" then
        skin()
    end
end)
A:SetScript("OnUpdate", function()
    if pending and GetTime() >= pending then
        pending = nil
        db(); TRDRDB.last = copy(snap())
        if P and P:IsShown() then update() end
    end
end)
