local addonName, CFCT = ...
_G[addonName] = CFCT
local IsClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local IsBCC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
local IsRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local tinsert, tremove, tsort, format, strlen, strsub, gsub, floor, sin, cos, asin, acos, random, select, pairs, ipairs, unpack, bitband = table.insert, table.remove, table.sort, string.format, string.len, string.sub, string.gsub, math.floor, math.sin, math.cos, math.asin, math.acos, math.random, select, pairs, ipairs, unpack, bit.band
local InCombatLockdown = InCombatLockdown
local AbbreviateNumbers = AbbreviateNumbers
local GetTime = GetTime
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata

-- Secret Values API helpers (WoW Midnight 12.0+)
-- Amounts and booleans from CLEU may become opaque "secret values" during
-- restricted encounters. Never do arithmetic on them directly; always guard
-- with pcall or the helpers below.
CFCT.restricted = false
local function IsSecretValue(value)
    if issecretvalue then return issecretvalue(value) end
    return false
end
local function CanAccessValue(value)
    if canaccessvalue then return canaccessvalue(value) end
    return true
end

local GetSpellInfo_old = GetSpellInfo
local GetSpellInfo = (type(GetSpellInfo_old) == 'function') and function(id)
    local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo_old(id)
    return {
        name = name,
        rank = rank,
        iconID = icon,
        originalIconID = originalIcon,
        castTime = castTime,
        minRange = minRange,
        maxRange = maxRange,
        spellID = spellID
    }
end or C_Spell.GetSpellInfo

CFCT.frame = CreateFrame("Frame", "ClassicFCT.frame", UIParent)
CFCT.Animating = {}
CFCT.fontStringCache = {}
CFCT.Debug = false

-- Midnight 12.0+: suppress the "action blocked" popup for this addon.
-- SetCVar for FCT CVars is now a protected action; we handle it with pcall
-- below, so the popup is just noise.
do
    local _origShow = StaticPopup_Show
    StaticPopup_Show = function(which, text_arg1, ...)
        if which == "ADDON_ACTION_FORBIDDEN"
        and type(text_arg1) == "string"
        and text_arg1:find("ClassicFCT", 1, true) then
            return nil
        end
        return _origShow(which, text_arg1, ...)
    end
end

local now = GetTime()
local f = CFCT.frame
f:SetSize(1,1)
f:SetPoint("CENTER", 0, 0)

local anim = CFCT.Animating
local fsc = CFCT.fontStringCache

local function round(n, d)
    local p = 10^d
    return math.floor(n * p) / p
end

local damageRollingAverage = 0
function CFCT:DamageRollingAverage()
    return damageRollingAverage
end

local ROLLING_AVERAGE_LENGTH = 10
local rollingAverageTimer = 0
local damageCache = {}
local function AddToAverage(value)
    if CFCT._testMode and not InCombatLockdown() then return end
    if IsSecretValue(value) then return end  -- skip opaque secret values
    tinsert(damageCache, {
        value = value,
        time = now
    })
end
local ROLLINGAVERAGE_UPDATE_INTERVAL = 0.5
local function CalculateRollingAverage()
    local cacheSize = #damageCache
    local damage, count = 0, 0
    for k,v in ipairs(damageCache) do
        if (cacheSize > 200) and ((now - v.time) > ROLLING_AVERAGE_LENGTH) then
            tremove(damageCache, k)
        else
            damage = damage + v.value
            count = count + 1
        end
    end
    damageRollingAverage = count > 0 and damage / count or 0
end


local function FormatThousandSeparator(v)
    local s = format("%d", floor(v))
    local pos = strlen(s) % 3
    if pos == 0 then pos = 3 end
    return strsub(s, 1, pos)..gsub(strsub(s, pos+1), "(...)", ",%1")
end

local function InitFont(self, state)
    local fontOptions = state.fontOptions
    self:SetFont(fontOptions.fontPath, fontOptions.fontSize, fontOptions.fontStyle)
    self:SetShadowOffset(fontOptions.fontSize/14, fontOptions.fontSize/14)
    self:SetDrawLayer("OVERLAY")
    self:SetJustifyH("CENTER")
    self:SetJustifyV("MIDDLE")
    -- self:SetPoint("BOTTOM", 0, 0)
    self:SetText(state.text)
    self:SetTextColor(unpack(fontOptions.fontColor))
    self:SetAlpha(fontOptions.fontAlpha)
    self:SetShadowColor(0,0,0,fontOptions.fontAlpha/2)
    state.initialTime = now
    state.strHeight = self:GetStringHeight()
    state.strWidth = self:GetStringWidth()
    state.posX = 0
    state.posY = 0
    state.direction = 0
    self.state = state
    self:Hide()
    return self
end

local function ReleaseFont(self)
    self.state = nil
    self:Hide()
    tinsert(fsc, self)
end

local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    local overlapX = x1 < x2 and w1 - (x2 - x1) or w2 -( x1 - x2)
    local overlapY = y1 < y2 and h1 - (y2 - y1) or h2 - (y1 - y2)
    if (overlapX > 0 and overlapY > 0) then
        return overlapX, overlapY
    end
end

local GRID = {
    false,
    {y={o=1, p=1}},
    {x={o=1, p=1}},
    {y={o=-1, p=1}},
    {x={o=-1, p=1}},
    {x={o=1, p=2}, y={o=1, p=3}},
    {x={o=1, p=4}, y={o=-1, p=3}},
    {x={o=-1, p=2}, y={o=1, p=5}},
    {x={o=-1, p=4}, y={o=-1, p=5}},
    {y={o=1, p=2}},
    {x={o=1, p=3}},
    {y={o=-1, p=4}},
    {x={o=-1, p=5}},
    {x={o=1, p=6}, y={o=1, p=11}},
    {x={o=1, p=7}, y={o=-1, p=11}},
    {x={o=-1, p=8}, y={o=1, p=13}},
    {x={o=-1, p=9}, y={o=-1, p=13}},
    {x={o=1, p=10}, y={o=1, p=6}},
    {x={o=1, p=12}, y={o=-1, p=7}},
    {x={o=-1, p=10}, y={o=1, p=8}},
    {x={o=-1, p=12}, y={o=-1, p=9}},
    {y={o=1, p=10}},
    {x={o=1, p=11}},
    {y={o=-1, p=12}},
    {x={o=-1, p=13}},
    {x={o=1, p=18}, y={o=1, p=14}},
    {x={o=1, p=19}, y={o=-1, p=15}},
    {x={o=-1, p=20}, y={o=1, p=16}},
    {x={o=-1, p=21}, y={o=-1, p=17}},
    {x={o=1, p=22}, y={o=1, p=18}},
    {x={o=1, p=14}, y={o=1, p=23}},
    {x={o=1, p=15}, y={o=-1, p=23}},
    {x={o=1, p=24}, y={o=-1, p=19}},
    {x={o=-1, p=24}, y={o=-1, p=21}},
    {x={o=-1, p=16}, y={o=1, p=25}},
    {x={o=-1, p=17}, y={o=-1, p=25}},
    {x={o=-1, p=22}, y={o=1, p=20}},
    {y={o=1, p=22}},
    {x={o=1, p=23}},
    {y={o=-1, p=24}},
    {x={o=-1, p=25}},
    {x={o=1, p=30}, y={o=1, p=26}},
    {x={o=1, p=33}, y={o=-1, p=27}},
    {x={o=-1, p=34}, y={o=-1, p=29}},
    {x={o=-1, p=37}, y={o=1, p=28}},
    {x={o=1, p=26}, y={o=1, p=31}},
    {x={o=1, p=27}, y={o=-1, p=32}},
    {x={o=-1, p=28}, y={o=1, p=35}},
    {x={o=-1, p=29}, y={o=-1, p=36}},
    {x={o=1, p=38}, y={o=1, p=30}},
    {x={o=1, p=31}, y={o=1, p=39}},
    {x={o=1, p=32}, y={o=-1, p=39}},
    {x={o=1, p=40}, y={o=-1, p=33}},
    {x={o=-1, p=40}, y={o=-1, p=34}},
    {x={o=-1, p=35}, y={o=1, p=41}},
    {x={o=-1, p=36}, y={o=-1, p=41}},
    {x={o=-1, p=38}, y={o=1, p=37}},
    {y={o=1, p=38}},
    {x={o=1, p=39}},
    {y={o=-1, p=40}},
    {x={o=-1, p=41}},
    {x={o=1, p=50}, y={o=1, p=42}},
    {x={o=1, p=53}, y={o=-1, p=43}},
    {x={o=-1, p=57}, y={o=1, p=45}},
    {x={o=-1, p=54}, y={o=-1, p=44}},
    {x={o=1, p=42}, y={o=1, p=46}},
    {x={o=1, p=43}, y={o=-1, p=47}},
    {x={o=-1, p=45}, y={o=1, p=48}},
    {x={o=-1, p=44}, y={o=-1, p=49}},
    {x={o=1, p=46}, y={o=1, p=51}},
    {x={o=1, p=47}, y={o=-1, p=52}},
    {x={o=-1, p=48}, y={o=1, p=55}},
    {x={o=-1, p=49}, y={o=-1, p=56}},
    {x={o=1, p=58}, y={o=1, p=50}},
    {x={o=1, p=51}, y={o=1, p=59}},
    {x={o=1, p=52}, y={o=-1, p=59}},
    {x={o=1, p=60}, y={o=-1, p=53}},
    {x={o=-1, p=60}, y={o=-1, p=54}},
    {x={o=-1, p=55}, y={o=1, p=61}},
    {x={o=-1, p=56}, y={o=-1, p=61}},
    {x={o=-1, p=58}, y={o=1, p=57}},
    {y={o=1, p=58}},
    {x={o=1, p=59}},
    {y={o=-1, p=60}},
    {x={o=-1, p=61}},
    {x={o=1, p=62}, y={o=1, p=66}},
    {x={o=1, p=63}, y={o=-1, p=67}},
    {x={o=-1, p=65}, y={o=-1, p=69}},
    {x={o=-1, p=64}, y={o=1, p=68}},
    {x={o=1, p=66}, y={o=1, p=70}},
    {x={o=1, p=67}, y={o=-1, p=71}},
    {x={o=-1, p=68}, y={o=1, p=72}},
    {x={o=-1, p=69}, y={o=-1, p=73}},
    {x={o=1, p=74}, y={o=1, p=62}},
    {x={o=1, p=77}, y={o=-1, p=63}},
    {x={o=-1, p=81}, y={o=1, p=64}},
    {x={o=-1, p=78}, y={o=-1, p=65}},
    {x={o=1, p=70}, y={o=1, p=75}},
    {x={o=1, p=71}, y={o=-1, p=76}},
    {x={o=-1, p=72}, y={o=1, p=79}},
    {x={o=-1, p=73}, y={o=-1, p=80}},
    {x={o=1, p=82}, y={o=1, p=74}},
    {x={o=1, p=84}, y={o=-1, p=77}},
    {x={o=-1, p=84}, y={o=-1, p=78}},
    {x={o=-1, p=82}, y={o=1, p=81}},
    {x={o=1, p=75}, y={o=1, p=83}},
    {x={o=1, p=76}, y={o=-1, p=83}},
    {x={o=-1, p=79}, y={o=1, p=85}},
    {x={o=-1, p=80}, y={o=-1, p=85}},
    {y={o=1, p=82}},
    {x={o=1, p=83}},
    {y={o=-1, p=84}},
    {x={o=-1, p=85}},
    {x={o=1, p=86}, y={o=1, p=90}},
    {x={o=1, p=87}, y={o=-1, p=91}},
    {x={o=-1, p=89}, y={o=1, p=92}},
    {x={o=-1, p=88}, y={o=-1, p=93}},
    {x={o=1, p=94}, y={o=1, p=86}},
    {x={o=1, p=95}, y={o=-1, p=87}},
    {x={o=-1, p=96}, y={o=1, p=89}},
    {x={o=-1, p=97}, y={o=-1, p=88}},
    {x={o=1, p=102}, y={o=1, p=94}},
    {x={o=1, p=103}, y={o=-1, p=95}},
    {x={o=-1, p=105}, y={o=1, p=96}},
    {x={o=-1, p=104}, y={o=-1, p=97}},
    {x={o=1, p=90}, y={o=1, p=98}},
    {x={o=1, p=91}, y={o=-1, p=99}},
    {x={o=-1, p=92}, y={o=1, p=100}},
    {x={o=-1, p=93}, y={o=-1, p=101}},
    {x={o=1, p=110}, y={o=1, p=102}},
    {x={o=1, p=112}, y={o=-1, p=103}},
    {x={o=-1, p=110}, y={o=1, p=105}},
    {x={o=-1, p=112}, y={o=-1, p=104}},
    {x={o=1, p=98}, y={o=1, p=106}},
    {x={o=1, p=99}, y={o=-1, p=107}},
    {x={o=-1, p=100}, y={o=1, p=108}},
    {x={o=-1, p=101}, y={o=-1, p=109}},
    {x={o=1, p=106}, y={o=1, p=111}},
    {x={o=1, p=107}, y={o=-1, p=111}},
    {x={o=-1, p=108}, y={o=1, p=113}},
    {x={o=-1, p=109}, y={o=-1, p=113}},
    {x={o=1, p=118}, y={o=1, p=114}},
    {x={o=1, p=119}, y={o=-1, p=115}},
    {x={o=-1, p=120}, y={o=1, p=116}},
    {x={o=-1, p=121}, y={o=-1, p=117}},
    {x={o=1, p=122}, y={o=1, p=118}},
    {x={o=1, p=123}, y={o=-1, p=119}},
    {x={o=-1, p=124}, y={o=1, p=120}},
    {x={o=-1, p=125}, y={o=-1, p=121}},
    {x={o=1, p=114}, y={o=1, p=126}},
    {x={o=1, p=115}, y={o=-1, p=127}},
    {x={o=-1, p=116}, y={o=1, p=128}},
    {x={o=-1, p=117}, y={o=-1, p=129}},
    {x={o=1, p=126}, y={o=1, p=134}},
    {x={o=1, p=127}, y={o=-1, p=135}},
    {x={o=-1, p=128}, y={o=1, p=136}},
    {x={o=-1, p=129}, y={o=-1, p=137}},
    {x={o=1, p=130}, y={o=1, p=122}},
    {x={o=1, p=131}, y={o=-1, p=123}},
    {x={o=-1, p=132}, y={o=1, p=124}},
    {x={o=-1, p=133}, y={o=-1, p=125}},
    {x={o=1, p=134}, y={o=1, p=138}},
    {x={o=1, p=135}, y={o=-1, p=139}},
    {x={o=-1, p=136}, y={o=1, p=140}},
    {x={o=-1, p=137}, y={o=-1, p=141}},
    {x={o=1, p=142}, y={o=1, p=150}},
    {x={o=1, p=143}, y={o=-1, p=151}},
    {x={o=-1, p=144}, y={o=1, p=152}},
    {x={o=-1, p=145}, y={o=-1, p=153}},
    {x={o=1, p=146}, y={o=1, p=142}},
    {x={o=1, p=147}, y={o=-1, p=143}},
    {x={o=-1, p=148}, y={o=1, p=144}},
    {x={o=-1, p=149}, y={o=-1, p=145}},
    {x={o=1, p=150}, y={o=1, p=154}},
    {x={o=1, p=151}, y={o=-1, p=155}},
    {x={o=-1, p=152}, y={o=1, p=156}},
    {x={o=-1, p=153}, y={o=-1, p=157}},
    {x={o=1, p=158}, y={o=1, p=146}},
    {x={o=1, p=159}, y={o=-1, p=147}},
    {x={o=-1, p=160}, y={o=1, p=148}},
    {x={o=-1, p=161}, y={o=-1, p=149}},
    {x={o=1, p=154}, y={o=1, p=162}},
    {x={o=1, p=155}, y={o=-1, p=163}},
    {x={o=-1, p=156}, y={o=1, p=164}},
    {x={o=-1, p=157}, y={o=-1, p=165}},
    {x={o=1, p=170}, y={o=1, p=166}},
    {x={o=1, p=171}, y={o=-1, p=167}},
    {x={o=-1, p=172}, y={o=1, p=168}},
    {x={o=-1, p=173}, y={o=-1, p=169}},
    {x={o=1, p=178}, y={o=1, p=170}},
    {x={o=1, p=179}, y={o=-1, p=171}},
    {x={o=-1, p=180}, y={o=1, p=172}},
    {x={o=-1, p=181}, y={o=-1, p=173}},
    {x={o=1, p=166}, y={o=1, p=174}},
    {x={o=1, p=167}, y={o=-1, p=175}},
    {x={o=-1, p=168}, y={o=1, p=176}},
    {x={o=-1, p=169}, y={o=-1, p=177}},
    {x={o=1, p=174}, y={o=1, p=182}},
    {x={o=1, p=175}, y={o=-1, p=183}},
    {x={o=-1, p=176}, y={o=1, p=184}},
    {x={o=-1, p=177}, y={o=-1, p=185}},
    {x={o=1, p=186}, y={o=1, p=194}},
    {x={o=-1, p=188}, y={o=1, p=196}},
    {x={o=1, p=187}, y={o=-1, p=195}},
    {x={o=1, p=190}, y={o=1, p=186}},
    {x={o=1, p=191}, y={o=-1, p=187}},
    {x={o=-1, p=192}, y={o=1, p=188}},
    {x={o=-1, p=193}, y={o=-1, p=189}},
    {x={o=1, p=194}, y={o=1, p=198}},
    {x={o=1, p=195}, y={o=-1, p=199}},
    {x={o=-1, p=196}, y={o=1, p=200}},
    {x={o=-1, p=197}, y={o=-1, p=201}},
    {x={o=1, p=205}, y={o=1, p=202}},
    {x={o=1, p=206}, y={o=-1, p=204}},
    {x={o=-1, p=207}, y={o=1, p=203}},
    {x={o=-1, p=208}, y={o=-1, p=204}},
    {x={o=1, p=202}, y={o=1, p=209}},
    {x={o=1, p=204}, y={o=-1, p=210}},
    {x={o=-1, p=203}, y={o=1, p=211}},
    {x={o=-1, p=204}, y={o=-1, p=212}},
    {x={o=1, p=213}, y={o=1, p=217}},
    {x={o=1, p=214}, y={o=-1, p=218}},
    {x={o=-1, p=215}, y={o=1, p=219}},
    {x={o=-1, p=216}, y={o=-1, p=220}},
}


-- local gapX = 30
-- local gapY = 50
local function GridLayout(unsortedFrames)
    local fctConfig = CFCT.Config
    local frames = {}
    if fctConfig.sortByDamage then
        local missPrio = fctConfig.sortMissPrio
        local tinsert = tinsert
        local count = 0
        for k,v in ipairs(unsortedFrames) do
            if (k == 1) then
                tinsert(frames, v)
                count = count + 1
            else
                local s1 = v.state
                for i,e in ipairs(frames) do
                    local s2 = e.state
                    if (not s2.miss and not s1.miss) and (s2.amount < s1.amount) then
                        tinsert(frames, i, v)
                        count = count + 1
                        break
                    elseif (s1.miss ~= s2.miss) and ((s1.miss and missPrio) or not s1.miss) then
                        tinsert(frames, i, v)
                        count = count + 1
                        break
                    elseif (i == count) then
                        tinsert(frames, i + 1, v)
                        count = count + 1
                        break
                    end
                end
            end
        end
    else
        frames = unsortedFrames
    end
    -- if CFCT.Debug then
    --     for k,v in pairs(frames) do
    --         v:SetText(k .. v.state.text)
    --     end
    -- end
    local gapX = fctConfig.preventOverlapSpacingX
    local gapY = fctConfig.preventOverlapSpacingY
    for k, e in ipairs(frames) do
        -- frame mode
        -- local gapX, gapY = gapX * e.state.baseScale, gapY * e.state.baseScale
        local gridCell = GRID[k]
        local gridX = gridCell and (gridCell.x and frames[gridCell.x.p].state.gridX + gridCell.x.o * (gapX + frames[gridCell.x.p].state.width + 0.5*(e.state.width - frames[gridCell.x.p].state.width))) or 0
        local gridY = gridCell and (gridCell.y and frames[gridCell.y.p].state.gridY + gridCell.y.o * (gapY + (gridCell.y.o < 0 and e.state.height or frames[gridCell.y.p].state.height))) or 0
        if gridCell or k == 1 then
            if (e.state.gridIdx and (e.state.gridIdx ~= k)) then
                e.state.scrollReset = true
            end
            e.state.gridIdx = k
            -- e:SetText(format("%03d",e.state.gridIdx))
            e.state.posX = e.state.posX + gridX - (e.state.gridX or 0)
            e.state.posY = e.state.posY + gridY - (e.state.gridY or 0)
            e.state.gridX = gridX
            e.state.gridY = gridY
        else
            e.state.posX = e.state.posX + gridX - (e.state.gridX or 0)
            e.state.posY = e.state.posY + gridY - (e.state.gridY or 0)
            e.state.gridX = 9999
            e.state.gridY = 9999
        end
    end
    return frames
end

local function AnimateLinearAbsolute(startTime, duration, minval, maxval)
    local prog = min(max((now - startTime) / duration, 0), 1)
    return (maxval - minval) * prog + minval
end

local function AnimateLinearRelative(startTime, duration, minval, maxval, curval)
    local prog = min(max((now - startTime) / duration, 0), 1)
    return ((maxval - minval) * prog + minval) - curval
end

local ANIMATIONS = {
    Pow = function(self, catConfig, animConfig)
        local duration = animConfig.duration * CFCT.Config.animDuration
        local midTime = self.state.initialTime + (duration * animConfig.inOutRatio)
        if (now < midTime) then
            self.state.powScale = AnimateLinearAbsolute(self.state.initialTime, midTime - self.state.initialTime, animConfig.initScale, animConfig.midScale)
            -- self:SetTextHeight(catConfig.fontSize * AnimateLinearAbsolute(self.state.initialTime, midTime - self.state.initialTime, animConfig.initScale, animConfig.midScale))
        else
            self.state.powScale = AnimateLinearAbsolute(midTime, duration * (1 - animConfig.inOutRatio), animConfig.midScale, animConfig.endScale)
            -- self:SetTextHeight(catConfig.fontSize * AnimateLinearAbsolute(midTime, duration * (1 - animConfig.inOutRatio), animConfig.midScale, animConfig.endScale))
        end
    end,
    FadeIn = function(self, catConfig, animConfig)
        local curAlpha = self:GetAlpha()
        local duration = animConfig.duration * CFCT.Config.animDuration
        local endTime = self.state.initialTime + duration
        if (now <= endTime) then
            local fadeInAlpha = AnimateLinearAbsolute(self.state.initialTime, duration, 0, self.state.fontOptions.fontAlpha)
            self.state.fadeAlpha = (fadeInAlpha + (self.state.fadeOutAlpha or fadeInAlpha)) * 0.5
            self.state.fadeInAlpha = fadeInAlpha
        else
            self.state.fadeInAlpha = nil
        end
    end,
    FadeOut = function(self, catConfig, animConfig)
        local curAlpha = self:GetAlpha()
        local duration = animConfig.duration
        local startTime = self.state.initialTime + CFCT.Config.animDuration - duration
        if (now >= startTime) then
            local fadeOutAlpha = AnimateLinearAbsolute(startTime, duration, self.state.fontOptions.fontAlpha, 0)
            self.state.fadeAlpha = (fadeOutAlpha + (self.state.fadeInAlpha or fadeOutAlpha)) * 0.5
            self.state.fadeOutAlpha = fadeOutAlpha
        else
            self.state.fadeOutAlpha = nil
        end
    end,
    Scroll = function(self, catConfig, animConfig)
        local duration = CFCT.Config.animDuration
        local state, dir, dist, scrollX, scrollY = self.state, animConfig.direction, animConfig.distance, 0, 0

        if dir:find("RANDOM") then
            if (state.randomX == nil) and (state.randomY == nil) then
                local a = random(1,628) / 100
                local rx, ry = cos(a), sin(a)
                state.randomX, state.randomY =  rx * dist, ry * dist
            end
            scrollX = AnimateLinearAbsolute(state.initialTime, duration, 0, state.randomX)
            scrollY = AnimateLinearAbsolute(state.initialTime, duration, 0, state.randomY)
        elseif dir:find("RIGHT") then
            scrollX = AnimateLinearAbsolute(state.initialTime, duration, 0, dist)
        elseif dir:find("LEFT") then
            scrollX = AnimateLinearAbsolute(state.initialTime, duration, 0, -dist)
        end
        if dir:find("UP") then
            scrollY = AnimateLinearAbsolute(state.initialTime, duration, 0, dist)
        elseif dir:find("DOWN") then
            scrollY = AnimateLinearAbsolute(state.initialTime, duration, 0, -dist)
        end
        if state.scrollOriginX == nil then
            state.scrollOriginX = 0
            state.scrollOriginY = 0
        elseif state.scrollReset then
            state.scrollOriginX = -scrollX
            state.scrollOriginY = -scrollY
            state.scrollReset = nil
        end
        scrollX = scrollX + state.scrollOriginX
        scrollY = scrollY + state.scrollOriginY
        -- substract old scroll pos and add new scroll pos
        state.posX = state.posX + scrollX - (state.scrollX or 0)
        state.posY = state.posY + scrollY - (state.scrollY or 0)
        -- save current scroll pos for next call
        state.scrollX = scrollX
        state.scrollY = scrollY
    end,
    -- Map


}

local UIParent = UIParent
local WorldFrame = WorldFrame
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local function UpdateFontParent(self)
    local fctConfig = CFCT.Config
    local nameplate = UnitExists(self.state.unit) and GetNamePlateForUnit(self.state.unit) or false
    local attach
    local isNameplateMode = (fctConfig.attachMode == "tn") or (fctConfig.attachMode == "en")
    if isNameplateMode and nameplate then
        attach = nameplate
    elseif isNameplateMode or (fctConfig.attachMode == "sc") or fctConfig.attachModeFallback then
        -- Nameplate-based modes always fall back to screen-center when the nameplate is
        -- gone (target died the same frame the hit landed, or moved out of nameplate range),
        -- so in-flight animations complete rather than silently disappearing.
        attach = f
    else
        attach = false
    end
    local inheritNameplates = fctConfig.inheritNameplates
    if fctConfig.dontOverlapNameplates then
        self:SetParent(WorldFrame)
        self.state.baseScale = inheritNameplates and (attach and attach == nameplate) and attach:GetEffectiveScale() * UIParent:GetScale() or UIParent:GetScale()
    else
        self:SetParent(UIParent)
        self.state.baseScale = inheritNameplates and (attach and attach == nameplate) and attach:GetEffectiveScale() or 1
    end
    self.state.attach = attach
end

local function CalculateStringSize(self)
    -- frame mode
    -- self.state.height = self.state.strHeight * self.state.baseScale * self.state.powScale
    -- self.state.width = self.state.strWidth * self.state.baseScale * self.state.powScale
    self.state.height = self.state.strHeight * self.state.powScale
    self.state.width = self.state.strWidth * self.state.powScale
end

local function ValidateFont(self)
    local fctConfig = CFCT.Config
    if ((now - self.state.initialTime) > fctConfig.animDuration) then
        return false
    end
    local catConfig = fctConfig[self.state.cat]
    if not (catConfig and catConfig.enabled) then
        return false
    end
    self.state.catConfig = catConfig
    return true
end

local function UpdateFontAnimations(self)
    local catConfig = self.state.catConfig
    CalculateStringSize(self)
    for animName, animFunc in pairs(ANIMATIONS) do
        local animConfig = catConfig[animName]
        if (animConfig and (type(animConfig) == 'table')) and animConfig.enabled then
            animFunc(self, catConfig, animConfig)
        end
    end
    CalculateStringSize(self)
    -- self:SetText(format("%04d",self.state.width))
    -- print(self:GetParent():GetName(), round(self.state.strWidth,2), round(self.state.baseScale,2), round(self.state.width,2))
end


local function UpdateFontPos(self)
    local fctConfig = CFCT.Config
    local attach = self.state.attach
    if attach then
        local isNamePlate = attach.namePlateUnitToken ~= nil
        local areaX = isNamePlate and fctConfig.areaNX or fctConfig.areaX
        local areaY = isNamePlate and fctConfig.areaNY or fctConfig.areaY
        if fctConfig.perspectiveScale then
            self:SetPoint("CENTER", attach, "CENTER", areaX + self.state.posX, areaY + self.state.posY)
        else
            -- local scaleFactor = 1 / (self.state.baseScale * self.state.powScale)
            local scaleFactor = 1 / self.state.powScale
            self:SetPoint("CENTER", attach, "CENTER", (areaX + self.state.posX) * scaleFactor, (areaY + self.state.posY) * scaleFactor)
        end
        -- self:SetFrameStrata(fctConfig.textStrata or "MEDIUM")
        self:Show()
    else
        self:Hide()
    end
end

local function ApplyFontUpdate(self)
    local alpha = self.state.baseAlpha * self.state.fadeAlpha
    local scale = self.state.baseScale * self.state.powScale
    -- local scale = self.state.powScale
    self:SetAlpha(alpha)
    self:SetShadowColor(0, 0, 0, alpha / 2)
    -- if CFCT.Config.perspectiveScale then
        self:SetScale(scale)
    -- else
        -- self.font:SetScale(scale)
    -- end
end






local function GrabFontString()
    if (#fsc > 0) then return tremove(fsc) end
    local frame = f:CreateFontString()

    frame.Init = InitFont
    frame.UpdateParent = UpdateFontParent
    frame.UpdateAnimation = UpdateFontAnimations
    frame.UpdatePosition = UpdateFontPos
    frame.Validate = ValidateFont
    frame.Release = ReleaseFont
    frame.ApplyUpdate = ApplyFontUpdate

    return frame
end

local iconCache = {}
local function SpellIconText(spell) -- spellid or spellname
    local fctConfig = CFCT.Config
    local tx = iconCache[spell] or GetSpellInfo(spell).iconID
    if tx then
        iconCache[spell] = tx
        local aspectRatio = fctConfig.spellIconAspectRatio
        local zoom = fctConfig.spellIconZoom
        local offsetX, offsetY = fctConfig.spellIconOffsetX, fctConfig.spellIconOffsetY
        local height, width = 12 / aspectRatio, 12
        local txSize = zoom * 100
        local txMinX = (zoom - 1) * 100 / 2
        local txMaxX = (zoom + 1) * 100 / 2
        local txMinY = (zoom - (1 / aspectRatio)) * 100 / 2
        local txMaxY = (zoom + (1 / aspectRatio)) * 100 / 2
        return format("|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t",
            tx, height, width, offsetX, offsetY, txSize, txSize, txMinX, txMaxX, txMinY, txMaxY)
    end
    return false
end


local function GetDamageTypeColor(school)
    return CFCT.Config.colorTable[school]
end
local function GetDotTypeColor(school)
    return CFCT.Config.colorTableDot[school]
end


local function DispatchText(guid, event, text, amount, spellid, spellicon, periodic, crit, miss, pet, school, count)
    -- Guard: crit/periodic/miss may be secret values if they slipped past the CLEU normalizer
    local critSafe, periodicSafe, missSafe = false, false, false
    pcall(function() critSafe = crit == true end)
    pcall(function() periodicSafe = periodic and true or false end)
    pcall(function() missSafe = miss == true end)
    local cat = (pet and "pet" or "")..event..(periodicSafe and "tick" or "")..(critSafe and "crit" or missSafe and "miss" or "")
    local fctConfig = CFCT.Config
    local catConfig = fctConfig[cat]
    -- If catConfig is nil the category is unknown (shouldn't happen with a full preset, but guard it)
    if not catConfig then return end
    if CFCT.Debug then
        -- Only print for the first few events to avoid chat spam
        if not CFCT._debugCount then CFCT._debugCount = 0 end
        CFCT._debugCount = CFCT._debugCount + 1
        if CFCT._debugCount <= 20 then
            print(string.format("|cFF44CCFFCFCT|r #%d DispatchText: event=%s cat=%s crit=%s critSafe=%s catConfig=%s",
                CFCT._debugCount, tostring(event), tostring(cat),
                tostring(crit), tostring(critSafe),
                catConfig and "OK" or "|cFFFF4444NIL|r"))
        end
    end
    text = text or tostring(amount)
    -- TODO put fctConfig and catConfig into state

    count = count or 1
    if (not miss) then
        -- Guard: crit flag may be a secret value; pcall the boolean check
        local critOk, critVal = pcall(function() return not crit end)
        if critOk and critVal then
            -- Guard: amount may be a secret value; guard arithmetic
            local avgOk = pcall(AddToAverage, amount / count)
            -- avgOk failure is silently ignored; rolling average just misses this sample
            _ = avgOk
        end

        -- Guard filter comparisons against secret value arithmetic failures
        local filterPassed = false
        pcall(function()
            filterPassed = (fctConfig.filterAbsoluteEnabled and (fctConfig.filterAbsoluteThreshold > amount))
                or (fctConfig.filterRelativeEnabled and ((fctConfig.filterRelativeThreshold * 0.01 * CFCT:UnitHealthMax('player')) > amount))
                or (fctConfig.filterAverageEnabled and ((fctConfig.filterAverageThreshold * 0.01 * CFCT:DamageRollingAverage()) > amount))
        end)
        if filterPassed then return false end

        -- Guard number formatting: secret values cannot be passed to format()
        -- If the value is inaccessible, pass it raw to SetText (WoW renders it correctly)
        if not IsSecretValue(amount) then
            if (fctConfig.abbreviateNumbers) then
                local fmtOk, fmtResult = pcall(AbbreviateNumbers, amount)
                if fmtOk then text = fmtResult end
            elseif (fctConfig.kiloSeparator) then
                local fmtOk, fmtResult = pcall(FormatThousandSeparator, amount)
                if fmtOk then text = fmtResult end
            end
        else
            -- Secret value: let WoW render it natively via its __tostring metamethod
            text = amount
        end
    end
    
    if (count > 1) and fctConfig.mergeEventsCounter then
        text = text.." x"..tostring(count)
    end

    if (spellicon and catConfig.showIcons) then text = spellicon..text end

    
    local fontColor, fontAlpha
    local typeColor = periodic and fctConfig.colorTableDotEnabled and GetDotTypeColor(school) or GetDamageTypeColor(school)
    if (catConfig.colorByType == true) and typeColor then
        local r, g, b, a = CFCT.Color2RGBA((strlen(typeColor) == 6) and "FF"..typeColor or typeColor)
        local a = min(a, select(4, CFCT.Color2RGBA(catConfig.fontColor)))
        fontColor = {r, g, b, a}
        fontAlpha = a
    else
        local r, g, b, a = CFCT.Color2RGBA(catConfig.fontColor)
        fontColor = {r, g, b, a}
        fontAlpha = a
    end

    tinsert(anim, 1, GrabFontString():Init({
        cat = cat,
        guid = guid,
        icon = spellicon,
        text = text,
        amount = amount,
        miss = miss,
        baseAlpha = 1,
        baseScale = 1,
        fadeAlpha = 1,
        powScale = 1,
        fontOptions = {
            fontPath = catConfig.fontPath,
            fontSize = catConfig.fontSize,
            fontStyle = catConfig.fontStyle,
            fontColor = fontColor,
            fontAlpha = fontAlpha
        },
    }))
end

local spellIdCache = {}
CFCT.spellIdCache = spellIdCache
local eventCache = {}
CFCT.eventCache = eventCache
local function CacheEvent(guid, event, amount, text, spellid, spellicon, periodic, crit, miss, pet, school)
    if (spellid and not spellIdCache[spellid]) then
        spellIdCache[spellid] = true
        if CFCT.ConfigPanel:IsVisible() then
            CFCT.ConfigPanel:refresh()
        end
    end

    local fctConfig = CFCT.Config
    if fctConfig.filterSpellBlacklist[spellid] == true
    or (fctConfig.filterMissesEnabled and miss) then
        return
    end

    local mergeConfig = {
        {fctConfig.mergeEventsByGuid, guid},
        {fctConfig.mergeEventsBySpellID, spellid},
        {fctConfig.mergeEventsBySpellIcon, spellicon},
        {fctConfig.mergeEventsBySchool, school}
    }
    local id = tostring(pet)
    for _, e in ipairs(mergeConfig) do
        if e[1] == true then id = id .. tostring(e[2]) end
    end
    -- print(id)
    local mergeTime = fctConfig.mergeEventsIntervalOverrides[spellid] or fctConfig.mergeEventsInterval
    local now = GetTime()
    local record = eventCache[id] or {
        events = {},
        expiry = nil
    }
    tinsert(record.events, {
        time = now,
        guid = guid,
        event = event,
        amount = amount,
        text = text,
        spellid = spellid,
        spellicon = spellicon,
        periodic = periodic,
        crit = crit,
        miss = miss,
        pet = pet,
        school = school,
        count = 1
    })
    if fctConfig.mergeEventsIntervalMode == "first" then
        record.expiry = record.expiry or (now + mergeTime)
    elseif fctConfig.mergeEventsIntervalMode == "last" then
        record.expiry = now + mergeTime
    end
    eventCache[id] = record
end

local function ProcessCachedEvents()
    local mergingEnabled = CFCT.Config.mergeEvents
    local separateMisses = CFCT.Config.mergeEventsMisses

    for id,record in pairs(eventCache) do
        if mergingEnabled then
            if (now > record.expiry) then
                local merge
                for _,e in ipairs(record.events) do
                    if e.miss and separateMisses then
                        DispatchText(e.guid, e.event, e.text, e.amount, e.spellid, e.spellicon, e.periodic, e.crit, e.miss, e.pet, e.school)
                    elseif not merge then
                        merge = e
                    else
                        merge.amount = merge.amount + e.amount
                        merge.text = merge.text or e.text
                        merge.count = merge.count + 1
                        merge.miss = merge.miss == false and false or e.miss
                        merge.crit = merge.crit or e.crit
                        merge.periodic = merge.periodic and e.periodic
                    end
                end
                if merge then
                    local text = (merge.amount ~= 0) and merge.amount or merge.text
                    DispatchText(merge.guid, merge.event, text, merge.amount, merge.spellid, merge.spellicon, merge.periodic, merge.crit, merge.miss, merge.pet, merge.school, merge.count)
                end
                eventCache[id] = nil
            end
        else
            for _,e in ipairs(record.events) do
                -- Note: `text` was computed here but never used (DispatchText takes e.text
                -- directly). The dead computation was removed because it crashed on secret
                -- amounts: (e.amount ~= 0) throws when e.amount is a secret value.
                DispatchText(e.guid, e.event, e.text, e.amount, e.spellid, e.spellicon, e.periodic, e.crit, e.miss, e.pet, e.school)
            end
            eventCache[id] = nil
        end
    end
end


-- CFCT.TestFrames = {}
CFCT._testMode = false
local testModeTimer = 0
function CFCT:Test(n)
    local cats = {
        "auto",
        "spell",
        "heal"
    }
    local nameplates = C_NamePlate.GetNamePlates()
    local numplates = #nameplates
    local it = (numplates > 0) and (n*numplates) or n
    for i = 1, it do
        local spellinfo
        repeat
            spellinfo = GetSpellInfo(random(1,32767))
        until (spellinfo and spellinfo.iconID)

        local school = random(1,128)
        local pet = (random(1,3) == 1)
        local crit = (random(1,3) == 1)
        local miss = not crit and (random(1,2) == 1)
        local event = cats[random(1,#cats)]
        local text = miss and "Miss" or nil
        local periodic = (random(1,3) == 1) and event == "spell"
        local amount = crit and 2674 or miss and 0 or 1337
        if crit and miss then
            print(amount, crit, miss)
        end
        local guid = (numplates > 0) and UnitGUID(nameplates[random(1,numplates)].UnitFrame.unit) or UnitGUID("target")
        local spellicon = spellid and SpellIconText(spellid) or ""
        DispatchText(guid, event, text, amount, spellid, spellicon, periodic, crit, miss, pet, school)
    end
end



local CVAR_CHECK_INTERVAL = 5
local cvarTimer = 0
local function checkCvars()
    if (GetCVarDefault("floatingCombatTextCombatDamage")) then
        local varHideDamage = CFCT.hideBlizz and "0" or "1"
        local cvarHideDamage = GetCVar("floatingCombatTextCombatDamage")
        if not (cvarHideDamage == varHideDamage) then
            if CFCT.forceCVars then
                pcall(SetCVar, "floatingCombatTextCombatDamage", varHideDamage)
            else
                CFCT.hideBlizz = (cvarHideDamage == "0")
            end
        end
    end
    if (GetCVarDefault("floatingCombatTextCombatHealing")) then
        local varHideHealing = CFCT.hideBlizzHeals and "0" or "1"
        local cvarHideHealing = GetCVar("floatingCombatTextCombatHealing")
        if not (cvarHideHealing == varHideHealing) then
            if CFCT.forceCVars then
                pcall(SetCVar, "floatingCombatTextCombatHealing", varHideHealing)
            else
                CFCT.hideBlizzHeals = (cvarHideHealing == "0")
            end
        end
    end
end



local events = {
    COMBAT_LOG_EVENT_UNFILTERED = true,
    UNIT_MAXHEALTH = true,
    ADDON_LOADED = true,
    PLAYER_LOGOUT = true,
    PLAYER_ENTERING_WORLD = true,
    NAME_PLATE_UNIT_ADDED = true,
    NAME_PLATE_UNIT_REMOVED = true,
    ADDON_RESTRICTION_STATE_CHANGED = true  -- Midnight 12.0+: fires when Secret Values restrictions change
}
for e,_ in pairs(events) do f:RegisterEvent(e) end
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local function SortByUnit(allFrames)
    local fctConfig = CFCT.Config
    local animAreas = {target={}}
    -- In "en" mode, refresh the persistent nameplate-GUID cache from all currently-
    -- visible nameplates before resolving any frame.  This closes the race window
    -- where a CLEU hit fires in the same event-queue pass as NAME_PLATE_UNIT_ADDED,
    -- so the persistent cache hasn't been populated yet when the first SortByUnit
    -- call runs.  One O(40) scan per frame is negligible.
    if fctConfig.attachMode == "en" then
        CFCT:RefreshNameplateCache()
    end
    for k, frame in ipairs(allFrames) do
        local state = frame.state
        if (fctConfig.attachMode == "en") then
            state.unit = CFCT:GetNamePlateUnitByGUID(state.guid) or ""
        elseif (fctConfig.attachMode == "tn") then
            -- Resolve the actual hit target's nameplate unit so that AoE/DoT/multi-target
            -- hits each appear above the correct enemy rather than all piling onto the
            -- currently-selected target's nameplate.  Fall back to "target" when the
            -- nameplate is not visible (e.g. out of range or already dead).
            state.unit = CFCT:GetNamePlateUnitByGUID(state.guid) or "target"
        else
            state.unit = "target"
        end
        animAreas[state.unit] = animAreas[state.unit] or {}
        tinsert(animAreas[state.unit], frame)
    end
    return animAreas
end

local function PrepareAnimatingFonts()
    local c = #anim
    local i = 1
    while (i <= c) do
        local frame = anim[i]
        if (frame:Validate() == false) then
            frame:Release()
            tremove(anim, i)
            c = c - 1
        else
            i = i + 1
        end
    end
end

local function UpdateAnimatingFonts()
    local animAreas = SortByUnit(anim)
    for k, animArea in pairs(animAreas) do
        for k, frame in ipairs(animArea) do
            frame:UpdateParent(animArea)
            frame:UpdateAnimation()
        end
        if CFCT.Config.preventOverlap then
            GridLayout(animArea)
        end
        for _, e in pairs(animArea) do
            e:UpdatePosition()
            e:ApplyUpdate()
        end
        if (now > cvarTimer) then
            checkCvars()
            cvarTimer = now + CVAR_CHECK_INTERVAL
        end
    end
end

f:SetScript("OnUpdate", function(self, elapsed)
    now = GetTime()
    if CFCT._testMode and (now > testModeTimer) and not InCombatLockdown() then
        CFCT:Test(2)
        testModeTimer = now + CFCT.Config.animDuration / 2
    end
    if (now > rollingAverageTimer) then
        CalculateRollingAverage()
        rollingAverageTimer = now + ROLLINGAVERAGE_UPDATE_INTERVAL
    end
    ProcessCachedEvents()
    PrepareAnimatingFonts()
    UpdateAnimatingFonts()
end)
f:Show()

function f:ADDON_LOADED(name)
    if (name == addonName) then
        CFCT.Config:OnLoad()
        local version = GetAddOnMetadata(addonName, "Version")
        if (version ~= CFCT.lastVersion) then
            C_Timer.After(5,function()
                CFCT:Log(GetAddOnMetadata(addonName, "Version")..[[

Recent changes:
    0.87u   Aug 16, 2024
        - Fixed miss filter, ColorPicker and Config panels for The War Within]])
            end)
        end
        CFCT.lastVersion = version
    end
end

function f:PLAYER_LOGOUT()
    CFCT.Config:OnSave()
end

local playerGUID = UnitGUID("player")  -- init immediately; refreshed on zone change below

-- Non-crit categories must never use Pow animation (Pow is only for crits).
-- Saved vars from older sessions may have Pow.enabled=true; sanitize on every load.
local NON_CRIT_CATS = {
    "auto","automiss",
    "spell","spellmiss","spelltick","spelltickmiss",
    "heal","healmiss","healtick","healtickmiss",
    "petauto","petautomiss",
    "petspell","petspellmiss","petspelltick","petspelltickmiss",
    "petheal","pethealmiss","pethealtick","pethealtickmiss",
}

function f:PLAYER_ENTERING_WORLD()
    playerGUID = UnitGUID("player")
    -- Refresh restriction state on every zone transition so the UNIT_COMBAT fallback
    -- is only active when CLEU is actually blocked by the Secret Values system.
    if C_RestrictedActions and C_RestrictedActions.IsAddOnRestrictionActive then
        local ok, result = pcall(C_RestrictedActions.IsAddOnRestrictionActive, 0)
        CFCT.restricted = ok and result or false
    end
    if CFCT.Config then
        -- Sanitize: ensure non-crit categories never run Pow animation.
        -- Saved vars from older sessions may have Pow.enabled=true; force it off.
        for _, cat in ipairs(NON_CRIT_CATS) do
            local cc = CFCT.Config[cat]
            if cc and cc.Pow then
                cc.Pow.enabled = false
            end
        end
        -- Migrate: several categories used to be FFFFFFFF (white) in older saves;
        -- update them to yellow so they are visible. Only migrate the old white value.
        local WHITE = "FFFFFFFF"
        local YELLOW = "FFFFE800"
        for _, cat in ipairs({
            "auto","automiss","autocrit",
            -- spell (direct-damage) categories — crits from multihit spells land here
            "spell","spellmiss","spellcrit",
            "spelltick","spelltickmiss","spelltickcrit",
            -- pet spell categories
            "petspell","petspellmiss","petspellcrit",
            "petspelltick","petspelltickmiss","petspelltickcrit",
            -- heal tick categories (direct heals stay green; only stale-white ticks need fixing)
            "healtick","healtickmiss",
            "pethealtick","pethealtickmiss",
        }) do
            local cc = CFCT.Config[cat]
            if cc and cc.fontColor == WHITE then
                cc.fontColor = YELLOW
            end
        end
    end
end

local nameplates = {}
function f:NAME_PLATE_UNIT_ADDED(unit)
    local guid = UnitGUID(unit)
    if guid and not IsSecretValue(guid) then
        nameplates[unit] = guid
        nameplates[guid] = unit
    end
end
function f:NAME_PLATE_UNIT_REMOVED(unit)
    local guid = nameplates[unit]
    nameplates[unit] = nil
    if guid then nameplates[guid] = nil end
end
function CFCT:GetNamePlateUnitByGUID(guid)
    if not guid or IsSecretValue(guid) then return nil end
    return nameplates[guid]
end
-- Scan all currently-visible nameplates and fill any missing GUID entries.
-- Called once per SortByUnit pass when in "en" mode so that per-enemy routing
-- works even when NAME_PLATE_UNIT_ADDED fires in the same frame as the CLEU hit
-- (a common race condition where the event queue runs CLEU before the nameplate
-- add notification reaches us).
function CFCT:RefreshNameplateCache()
    for i = 1, 40 do
        local np = "nameplate" .. i
        if UnitExists(np) then
            local g = UnitGUID(np)
            if g and not IsSecretValue(g) and not nameplates[g] then
                nameplates[np] = g
                nameplates[g] = np
            end
        end
    end
end

local unitHealthMax = {}
function f:UNIT_MAXHEALTH(unit)
    if (unit == 'player') then
        unitHealthMax[unit] = UnitHealthMax(unit)
    end
end
function CFCT:UnitHealthMax(unit)
    return unitHealthMax[unit] or UnitHealthMax(unit)
end

-- Midnight 12.0+: track addon restriction state so other code can react
function f:ADDON_RESTRICTION_STATE_CHANGED()
    if C_RestrictedActions and C_RestrictedActions.IsAddOnRestrictionActive then
        local ok, result = pcall(C_RestrictedActions.IsAddOnRestrictionActive, 0)
        CFCT.restricted = ok and result or false
    end
end








local CLEU_SWING_EVENT = {
    SWING_DAMAGE = true,
    SWING_HEAL = true,
    SWING_LEECH = true,
    SWING_MISSED = true
}
local CLEU_SPELL_EVENT = {
    DAMAGE_SHIELD = true,
    DAMAGE_SPLIT = true,
    RANGE_DAMAGE = true,
    SPELL_DAMAGE = true,
    SPELL_BUILDING_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
    RANGE_MISSED = true,
    SPELL_MISSED = true,
    SPELL_PERIODIC_MISSED = true,
    SPELL_BUILDING_MISSED = true
}
local CLEU_MISS_EVENT = {
    SWING_MISSED = true,
    RANGE_MISSED = true,
    SPELL_MISSED = true,
    SPELL_PERIODIC_MISSED = true,
    SPELL_BUILDING_MISSED = true,
}
local CLEU_DAMAGE_EVENT = {
    SWING_DAMAGE = true,
    DAMAGE_SHIELD = true,
    DAMAGE_SPLIT = true,
    RANGE_DAMAGE = true,
    SPELL_DAMAGE = true,
    SPELL_BUILDING_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true
}
local CLEU_HEALING_EVENT = {
    SWING_HEAL = true,
    RANGE_HEAL = true,
    SPELL_HEAL = true,
    SPELL_BUILDING_HEAL = true,
    SPELL_PERIODIC_HEAL = true,
}


-- local MISS_EVENT_STRINGS = {
--     ["ABSORB"] = "Absorbed",
--     ["BLOCK"] = "Blocked",
--     ["DEFLECT"] = "Deflected",
--     ["DODGE"] = "Dodged",
--     ["EVADE"] = "Evaded",
--     ["IMMUNE"] = "Immune",
--     ["MISS"] = "Missed",
--     ["PARRY"] = "Parried",
--     ["REFLECT"] = "Reflected",
--     ["RESIST"] = "Resisted",
-- }

-- Dedup table: CLEU marks events so the UNIT_COMBAT fallback can skip them
local cleuDedup = {}
local CLEU_DEDUP_WINDOW = 0.15
-- Track the last time CLEU successfully identified a player/pet event.
-- UNIT_COMBAT is suppressed while CLEU is working; it takes over automatically
-- when CLEU fails (e.g. Midnight secret-value restrictions outside formal encounters).
local lastCLEUPlayerEventTime = 0
local CLEU_PLAYER_EVENT_WINDOW = 3  -- seconds
local function MarkCLEU(amount, tag)
    cleuDedup[tostring(amount) .. tag] = GetTime()
end
local function IsCLEUDuplicate(amount, tag)
    local key = tostring(amount) .. tag
    local t = cleuDedup[key]
    if t and (GetTime() - t) <= CLEU_DEDUP_WINDOW then
        cleuDedup[key] = nil
        return true
    end
    return false
end

function f:COMBAT_LOG_EVENT_UNFILTERED()
    if CFCT.enabled == false then return end
    -- Wrap the entire handler: in Midnight (12.0+) CombatLogGetCurrentEventInfo()
    -- may fail under addon restrictions, and returned amounts/booleans may be
    -- opaque "secret values" that throw on arithmetic. pcall keeps us safe.
    local ok, err = pcall(function()
        local timestamp, cleuEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25 = CombatLogGetCurrentEventInfo()

        -- Guard: sourceGUID/sourceFlags may be secret values; wrap in nested pcall
        -- so a failure here doesn't abort event dispatch for valid events.
        local playerEvent, petEvent = false, false
        local sourceOk = pcall(function()
            playerEvent = (playerGUID == sourceGUID)
            if not playerEvent then
                petEvent = (bitband(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0
                    or bitband(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0)
                    and (bitband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0)
            end
        end)
        if CFCT.Debug and not CFCT._cleuGUIDShown then
            CFCT._cleuGUIDShown = true
            print(string.format("|cFF44FFFFCFCT|r CLEU GUID: playerGUID=%s sourceGUID=%s playerEvent=%s",
                tostring(playerGUID), tostring(sourceGUID), tostring(playerEvent)))
        end
        if not sourceOk then
            if CFCT.Debug then
                if not CFCT._cleuSrcErrCount then CFCT._cleuSrcErrCount = 0 end
                CFCT._cleuSrcErrCount = CFCT._cleuSrcErrCount + 1
                if CFCT._cleuSrcErrCount <= 3 then
                    print("|cFFFF4444CFCT|r CLEU source-detection threw; skipping event")
                end
            end
            return  -- cannot determine ownership; skip safely
        end
        if not (playerEvent or petEvent) then return end
        -- Record that CLEU is successfully resolving player ownership right now;
        -- UNIT_COMBAT will stand down for the next CLEU_PLAYER_EVENT_WINDOW seconds.
        lastCLEUPlayerEventTime = GetTime()
        -- Skip if WE are the target, EXCEPT for healing events (self-heals/self-absorbs are valid)
        if (destGUID == playerGUID) and not CLEU_HEALING_EVENT[cleuEvent] then return end
        -- local unit = nameplates[destGUID]
        local guid = destGUID
        -- Helper: normalize a CLEU boolean (may be a secret value) to plain Lua bool
        local function safeBool(v)
            local ok, result = pcall(function() return v == true end)
            return ok and result or false
        end

        if CLEU_DAMAGE_EVENT[cleuEvent] then
            if CLEU_SWING_EVENT[cleuEvent] then
                local amount,overkill,school,resist,block,absorb,crit,glancing,crushing,offhand = arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21
                if CFCT.Debug then
                    if not CFCT._cleuDispatchCount then CFCT._cleuDispatchCount = 0 end
                    CFCT._cleuDispatchCount = CFCT._cleuDispatchCount + 1
                    if CFCT._cleuDispatchCount <= 10 then
                        print(string.format("|cFF44FF44CFCT|r CLEU dispatch SWING: cleuEvent=%s crit=%s", tostring(cleuEvent), tostring(crit)))
                    end
                end
                -- Dispatch FIRST so a MarkCLEU failure cannot abort event processing
                f:DamageEvent(guid, nil, amount, nil, safeBool(crit), petEvent, school)
                pcall(MarkCLEU, amount, "dmg")
            else --its a SPELL event
                local periodic = cleuEvent:find("SPELL_PERIODIC", 1, true)
                local spellid,spellname,school1,amount,overkill,school2,resist,block,absorb,crit,glancing,crushing,offhand = arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24
                if (spellid == 0 and IsClassic) then spellid = spellname end
                -- Guard: spellid and school may be secret values in restricted encounters.
                -- SpellIconText(secretID) throws inside DamageEvent and silently drops the event.
                if IsSecretValue(spellid) then spellid = nil end
                if IsSecretValue(school1) then school1 = nil end
                if CFCT.Debug then
                    if not CFCT._cleuDispatchCount then CFCT._cleuDispatchCount = 0 end
                    CFCT._cleuDispatchCount = CFCT._cleuDispatchCount + 1
                    if CFCT._cleuDispatchCount <= 10 then
                        print(string.format("|cFF44FF44CFCT|r CLEU dispatch SPELL: cleuEvent=%s spellid=%s crit=%s", tostring(cleuEvent), tostring(spellid), tostring(crit)))
                    end
                end
                f:DamageEvent(guid, spellid, amount, periodic, safeBool(crit), petEvent, school1)
                pcall(MarkCLEU, amount, "dmg")
            end
        elseif CLEU_MISS_EVENT[cleuEvent] then
            if CLEU_SWING_EVENT[cleuEvent] then
                local misstype,_,amount = arg12,arg13,arg14
                f:MissEvent(guid, nil, amount, nil, misstype, petEvent, SCHOOL_MASK_PHYSICAL)
                pcall(MarkCLEU, 0, misstype)
            else --its a SPELL event
                local periodic = cleuEvent:find("SPELL_PERIODIC", 1, true)
                local spellid,spellname,school1,misstype,_,amount = arg12,arg13,arg14,arg15,arg16,arg17
                if (spellid == 0 and IsClassic) then spellid = spellname end
                if IsSecretValue(spellid) then spellid = nil end
                if IsSecretValue(school1) then school1 = nil end
                f:MissEvent(guid, spellid, amount, periodic, misstype, petEvent, school1)
                pcall(MarkCLEU, 0, misstype)
            end
        elseif CLEU_HEALING_EVENT[cleuEvent] then
            if CLEU_SWING_EVENT[cleuEvent] then
                local amount,overheal,absorb,crit = arg12,arg13,arg14,arg15
                f:HealingEvent(guid, nil, amount, nil, safeBool(crit), petEvent, nil)
                pcall(MarkCLEU, amount, "heal")
            else --its a SPELL event
                local periodic = cleuEvent:find("SPELL_PERIODIC", 1, true)
                local spellid,spellname,school1,amount,overheal,absorb,crit = arg12,arg13,arg14,arg15,arg16,arg17,arg18
                if (spellid == 0 and IsClassic) then spellid = spellname end
                if IsSecretValue(spellid) then spellid = nil end
                if IsSecretValue(school1) then school1 = nil end
                f:HealingEvent(guid, spellid, amount, periodic, safeBool(crit), petEvent, school1)
                pcall(MarkCLEU, amount, "heal")
            end
        end
    end)
    -- Only log CLEU failures (successes are confirmed by "CLEU dispatch" messages above)
    if CFCT.Debug and not ok then
        if not CFCT._cleuErrCount then CFCT._cleuErrCount = 0 end
        CFCT._cleuErrCount = CFCT._cleuErrCount + 1
        if CFCT._cleuErrCount <= 3 then
            print("|cFFFF4444CFCT|r CLEU pcall FAILED: " .. tostring(err))
        end
    end
end




function f:DamageEvent(guid, spellid, amount, periodic, crit, pet, school, dot)
    -- Guard: spellid may be a secret value if it came from UNIT_SPELLCAST_SUCCEEDED
    -- during a restricted encounter; treat it as a plain auto-attack in that case.
    if IsSecretValue(spellid) then spellid = nil end
    spellid = spellid or 6603 -- 6603 = Auto Attack
    local event = ((spellid == 75) or (spellid == 6603)) and "auto" or "spell" -- 75 = autoshot
    local spellicon = spellid and SpellIconText(spellid) or ""
    CacheEvent(guid, event, amount, nil, spellid, spellicon, periodic, crit, false, pet, school)
end
function f:MissEvent(guid, spellid, amount, periodic, misstype, pet, school)
    -- Guard: same secret spellid protection as DamageEvent
    if IsSecretValue(spellid) then spellid = nil end
    spellid = spellid or 6603 -- 6603 = Auto Attack
    local event = ((spellid == 75) or (spellid == 6603)) and "auto" or "spell" -- 75 = autoshot
    local spellicon = spellid and SpellIconText(spellid) or ""
    CacheEvent(guid, event, 0, strlower(misstype):gsub("^%l", strupper), spellid or 6603, spellicon, periodic, false, true, pet, school)
end
function f:HealingEvent(guid, spellid, amount, periodic, crit, pet, school)
    local event = "heal"
    local spellicon = spellid and SpellIconText(spellid) or ""
    CacheEvent(guid, event, amount, nil, spellid, spellicon, periodic, crit, false, pet, school)
end


-------------------------------------------------------------------------------
-- UNIT_COMBAT fallback (WoW Midnight 12.0+)
--
-- When CLEU is restricted and the pcall above fails silently, UNIT_COMBAT
-- still fires and provides basic damage/heal info for the target.
-- We use the dedup table to skip events already handled by CLEU.
--
-- UNIT_COMBAT args: unitTarget, action, flagText, amount, schoolMask
--   action:   "WOUND" (damage), "HEAL", "BLOCK", "DODGE", "PARRY", "MISS", etc.
--   flagText: "CRITICAL", "CRUSHING", "GLANCING", or ""
-------------------------------------------------------------------------------

local UC_MISS_ACTIONS = {
    BLOCK = true, DODGE = true, PARRY = true, MISS = true,
    IMMUNE = true, DEFLECT = true, REFLECT = true,
    RESIST = true, ABSORB = true, EVADE = true,
}

local ucFrame = CreateFrame("Frame")
local hasUnitCombat = false

-- Attempt to register for unit-specific UNIT_COMBAT events (preferred)
local ucRegOk = pcall(function()
    ucFrame:RegisterUnitEvent("UNIT_COMBAT", "player", "target")
end)
if ucRegOk then
    hasUnitCombat = true
else
    -- Fallback to global UNIT_COMBAT (fires for all units)
    local ucRegOk2 = pcall(function() ucFrame:RegisterEvent("UNIT_COMBAT") end)
    if ucRegOk2 then hasUnitCombat = true end
end

if hasUnitCombat then
    -- Re-register when target changes so we always track the current target
    local ucTargetFrame = CreateFrame("Frame")
    ucTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    ucTargetFrame:SetScript("OnEvent", function()
        pcall(function()
            ucFrame:RegisterUnitEvent("UNIT_COMBAT", "player", "target")
        end)
    end)

    ucFrame:SetScript("OnEvent", function(self, event, unit, action, flagText, amount, schoolMask)
        if CFCT.enabled == false then return end
        if unit ~= "target" then return end
        -- UNIT_COMBAT has no source information: it fires for every source that hits the
        -- current target (player, party members, pets, everyone).  Suppress it while CLEU
        -- is successfully resolving player/pet ownership — if CLEU has fired a confirmed
        -- player event in the last CLEU_PLAYER_EVENT_WINDOW seconds, we don't need this
        -- fallback and showing it would duplicate or misattribute other players' hits
        -- (bugs 3 & 4).  When CLEU fails (Midnight secret-value restrictions, phasing,
        -- etc.) the window expires naturally and UNIT_COMBAT takes over automatically.
        if (GetTime() - lastCLEUPlayerEventTime) < CLEU_PLAYER_EVENT_WINDOW then return end

        local guid = UnitGUID("target")
        if not guid then return end  -- no target at all
        -- In instances, delves, and grouped content, UnitGUID("target") returns a secret
        -- value and we cannot compare it to playerGUID. Proceed anyway — "target" is the
        -- player's selected enemy, not themselves. Only skip when guid is a plain value
        -- that matches the player (prevents showing self-inflicted damage).
        if not IsSecretValue(guid) and guid == playerGUID then return end

        -- guard: isCrit comparison on flagText (plain string, always safe)
        local isCrit = (flagText == "CRITICAL")

        if CFCT.Debug then
            if not CFCT._ucDebugCount then CFCT._ucDebugCount = 0 end
            CFCT._ucDebugCount = CFCT._ucDebugCount + 1
            if CFCT._ucDebugCount <= 10 then
                print(string.format("|cFFFFCC44CFCT|r UNIT_COMBAT: unit=%s action=%s flagText=%s isCrit=%s amount=%s",
                    tostring(unit), tostring(action), tostring(flagText), tostring(isCrit), tostring(amount)))
            end
        end

        if action == "WOUND" then
            -- Skip if CLEU already handled this damage event.
            -- No spell-ID attribution here: UNIT_COMBAT is a restricted-mode fallback
            -- only; guessing spellIDs from UNIT_SPELLCAST_SUCCEEDED caused misattribution
            -- for DoTs (tick long after cast) and multi-hit abilities.
            if not IsCLEUDuplicate(amount, "dmg") then
                f:DamageEvent(guid, nil, amount, nil, isCrit, false, schoolMask)
            end
        elseif action == "HEAL" then
            if not IsCLEUDuplicate(amount, "heal") then
                f:HealingEvent(guid, nil, amount, nil, isCrit, false, schoolMask)
            end
        elseif UC_MISS_ACTIONS[action] then
            if not IsCLEUDuplicate(0, action) then
                f:MissEvent(guid, nil, 0, nil, action, false, schoolMask or SCHOOL_MASK_PHYSICAL)
            end
        end
    end)
end
























