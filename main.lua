local addonName, CFCT = ...
_G[addonName] = CFCT

local tinsert, tremove, tsort, format, strlen, strsub, gsub, floor, sin, cos, asin, acos, random, select, pairs, ipairs, unpack, bitband = tinsert, tremove, table.sort, format, strlen, strsub, gsub, floor, sin, cos, asin, acos, random, select, pairs, ipairs, unpack, bit.band
local InCombatLockdown = InCombatLockdown
local AbbreviateNumbers = AbbreviateNumbers
local GetTime = GetTime

CFCT.enabled = true
CFCT.frame = CreateFrame("Frame", "CFCT.frame", UIParent)
CFCT.animating = {target={}}
CFCT.fontStringCache = {}
-- CFCT.Debug = true

local now = GetTime()
local f = CFCT.frame
f:SetSize(1,1)
f:SetPoint("CENTER", 0, 0)

local animAreas = CFCT.animating
local fsc = CFCT.fontStringCache


local damageRollingAverage = 0
function CFCT:DamageRollingAverage()
    return damageRollingAverage
end

local ROLLING_AVERAGE_LENGTH = 10
local rollingAverageTimer = 0
local damageCache = {}
local function AddToAverage(value)
    if CFCT._testMode and not InCombatLockdown() then return end
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

local function InitFontString(self, state)
    local fontOptions = state.fontOptions
    self:SetFont(fontOptions.fontPath, fontOptions.fontSize, fontOptions.fontStyle)
    self:SetShadowOffset(fontOptions.fontSize/14, fontOptions.fontSize/14)
    self:SetDrawLayer("OVERLAY")
    self:SetPoint("BOTTOM", 0, 0)
    self:SetText(state.text)
    self:SetTextColor(unpack(fontOptions.fontColor))
    self:SetAlpha(fontOptions.fontAlpha)
    self:SetShadowColor(0,0,0,fontOptions.fontAlpha/2)
    self.initialTime = now
    self.state = state
    self.state.height = self:GetStringHeight()
    self.state.width = self:GetStringWidth()
    self.state.posX = 0
    self.state.posY = 0
    self.state.direction = 0
    self:Hide()
    return self
end

local function ReleaseFontString(self)
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

local function PushFrames(self, frames)
    self.state.checkOverlap = false
    for k, e in ipairs(frames) do
        if (e ~= self) and e.state.checkOverlap then
            local overlapX, overlapY = CheckCollision(self.state.posX, self.state.posY, self.state.width, self.state.height, e.state.posX, e.state.posY, e.state.width, e.state.height)
            if overlapX and overlapY then 
                if (overlapX and e.state.direction > 1) then
                    -- e.state.posX = (e.state.posX + (e.state.width / 2)) < (self.state.posX + (self.state.width / 2)) and e.state.posX - overlapX - (0.3 * e.state.height) or e.state.posX + overlapX + (0.3 * e.state.height)
                    e.state.posX = (e.state.posX + (e.state.width / 2)) < (self.state.posX + (self.state.width / 2)) and e.state.posX - overlapX - e.state.height * 0.5 or e.state.posX + overlapX + e.state.height * 0.5
                    PushFrames(e, frames)
                    e.state.direction = 0
                else
                    -- e.state.posY = (e.state.posY + (e.state.height / 2)) < (self.state.posY + (self.state.height / 2)) and e.state.posY - overlapY or e.state.posY + overlapY
                    e.state.posY = (e.state.posY + (e.state.height / 2)) < (self.state.posY + (self.state.height / 2)) and e.state.posY - e.state.height * 0.5 or e.state.posY + e.state.height * 0.5
                    PushFrames(e, frames)
                    e.state.direction = e.state.direction + 1
                end
            end
        end
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


local gapX = 30
local gapY = 50
local function SortFrames(unsortedFrames)
    local frames = {}
    if CFCT.Config.sortByDamage then
        local missPrio = CFCT.Config.sortMissPrio
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
                    if (s2.isNumber and s1.isNumber) and (s2.value < s1.value) then
                        tinsert(frames, i, v)
                        count = count + 1
                        break
                    elseif (s1.isString ~= s2.isString) and (missPrio or s1.isNumber) then
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
    for k, e in ipairs(frames) do
        local gridX = GRID[k] and (GRID[k].x and frames[GRID[k].x.p].state.gridX + GRID[k].x.o * (gapX + frames[GRID[k].x.p].state.width + 0.5*(e.state.width - frames[GRID[k].x.p].state.width))) or 0
        local gridY = GRID[k] and (GRID[k].y and frames[GRID[k].y.p].state.gridY + GRID[k].y.o * (gapY + (GRID[k].y.o < 0 and e.state.height or frames[GRID[k].y.p].state.height))) or 0
        if GRID[k] or k == 1 then
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
        local midTime = self.initialTime + (duration * animConfig.inOutRatio)
        if (now < midTime) then
            self:SetTextHeight(catConfig.fontSize * AnimateLinearAbsolute(self.initialTime, midTime - self.initialTime, animConfig.initScale, animConfig.midScale))
        else
            self:SetTextHeight(catConfig.fontSize * AnimateLinearAbsolute(midTime, duration * (1 - animConfig.inOutRatio), animConfig.midScale, animConfig.endScale))
        end
    end,
    FadeIn = function(self, catConfig, animConfig)
        local curAlpha = self:GetAlpha()
        local duration = animConfig.duration * CFCT.Config.animDuration
        local endTime = self.initialTime + duration
        if (now <= endTime) then
            local fadeInAlpha = AnimateLinearAbsolute(self.initialTime, duration, 0, self.state.fontOptions.fontAlpha)
            local avgFadeInOutAlpha = (fadeInAlpha + (self.state.fadeOutAlpha or fadeInAlpha)) * 0.5
            -- print("FadeIn", avgFadeInOutAlpha)
            self:SetAlpha(avgFadeInOutAlpha)
            self:SetShadowColor(0,0,0,avgFadeInOutAlpha/2)
            self.state.fadeInAlpha = fadeInAlpha
        else
            self.state.fadeInAlpha = nil
        end
    end,
    FadeOut = function(self, catConfig, animConfig)
        local curAlpha = self:GetAlpha()
        local duration = animConfig.duration
        local startTime = self.initialTime + CFCT.Config.animDuration - duration
        if (now >= startTime) then
            local fadeOutAlpha = AnimateLinearAbsolute(startTime, duration, self.state.fontOptions.fontAlpha, 0)
            local avgFadeInOutAlpha = (fadeOutAlpha + (self.state.fadeInAlpha or fadeOutAlpha)) * 0.5
            -- print("FadeOut", avgFadeInOutAlpha)
            self:SetAlpha(avgFadeInOutAlpha)
            self:SetShadowColor(0,0,0,avgFadeInOutAlpha/2)
            self.state.fadeOutAlpha = fadeOutAlpha
        else
            self.state.fadeOutAlpha = nil
        end
    end,
    Scroll = function(self, catConfig, animConfig)
        local duration = CFCT.Config.animDuration
        local dir, dist, scrollX, scrollY = animConfig.direction, animConfig.distance, 0, 0

        if dir:find("RANDOM") then
            if (self.state.randomX == nil) and (self.state.randomY == nil) then
                local a = random(1,628) / 100
                local rx, ry = cos(a), sin(a)
                self.state.randomX, self.state.randomY =  rx * dist, ry * dist
            end
            scrollX = AnimateLinearAbsolute(self.initialTime, duration, 0, self.state.randomX)
            scrollY = AnimateLinearAbsolute(self.initialTime, duration, 0, self.state.randomY)
        elseif dir:find("RIGHT") then
            scrollX = AnimateLinearAbsolute(self.initialTime, duration, 0, dist)
        elseif dir:find("LEFT") then
            scrollX = AnimateLinearAbsolute(self.initialTime, duration, 0, -dist)
        end
        if dir:find("UP") then
            scrollY = AnimateLinearAbsolute(self.initialTime, duration, 0, dist)
        elseif dir:find("DOWN") then
            scrollY = AnimateLinearAbsolute(self.initialTime, duration, 0, -dist)
        end
        -- substract old scroll pos and add new scroll pos
        self.state.posX = self.state.posX + scrollX - (self.state.scrollX or 0)
        self.state.posY = self.state.posY + scrollY - (self.state.scrollY or 0)
        -- save current scroll pos for next call
        self.state.scrollX = scrollX
        self.state.scrollY = scrollY
    end,
    -- Map


}

local function UpdateFontString(self, elapsed)
    local fctConfig = CFCT.Config
    if ((now - self.initialTime) > fctConfig.animDuration) then
        return true
    end
    local catConfig = fctConfig[self.state.cat]
    if not (catConfig and catConfig.enabled) then
        return true
    end
    self.state.height = self:GetStringHeight()
    self.state.width = self:GetStringWidth()
    for animName, animFunc in pairs(ANIMATIONS) do
        local animConfig = catConfig[animName]
        if (animConfig and (type(animConfig) == 'table')) and animConfig.enabled then
            if animFunc(self, catConfig, animConfig) then
                return true
            end
        end
    end
    self.state.height = self:GetStringHeight()
    self.state.width = self:GetStringWidth()
end

local function UpdateFontPos(self)
    local fctConfig = CFCT.Config
    local nameplate = UnitExists(self.state.unit) and C_NamePlate.GetNamePlateForUnit(self.state.unit)
    if ((fctConfig.attachMode == "tn") or (fctConfig.attachMode == "en")) and nameplate then
        self:SetPoint("BOTTOM", nameplate.UnitFrame, "CENTER", fctConfig.areaNX + self.state.posX, fctConfig.areaNY + self.state.posY)
        self:Show()
    elseif (fctConfig.attachMode == "sc") or (fctConfig.attachModeFallback == true) then
        self:SetPoint("BOTTOM", f, "CENTER", fctConfig.areaX + self.state.posX, fctConfig.areaY + self.state.posY)
        self:Show()
    else
        self:Hide()
    end
end

local function GrabFontString()
    if (#fsc > 0) then return tremove(fsc) end
    local fontString = f:CreateFontString()

    fontString.Init = InitFontString
    fontString.UpdateAnimation = UpdateFontString
    fontString.UpdatePosition = UpdateFontPos
    fontString.Release = ReleaseFontString

    return fontString
end


local function SpellIconText(spellid)
    return "|T"..select(3,GetSpellInfo(spellid))..":0|t"
end


local function GetTypeColor(school)
    return CFCT.Config.colorTable[school]
end


local function DispatchText(unit, event, value, spellid, crit, miss, pet, school, count)
    local cat = (pet and "pet" or "")..event..(crit and "crit" or miss and "miss" or "")
    local fctConfig = CFCT.Config
    local catConfig = fctConfig[cat]
    local text = value

    local unit = (fctConfig.attachMode == "en") and unit or "target"

    count = count or 1
    if (not miss) then
        if (not crit) then
            AddToAverage(text / count)
        end
        if (fctConfig.filterAbsoluteEnabled and (fctConfig.filterAbsoluteThreshold > text))
        or (fctConfig.filterRelativeEnabled and ((fctConfig.filterRelativeThreshold * 0.01 * CFCT:UnitHealthMax('player')) > text))
        or (fctConfig.filterAverageEnabled and ((fctConfig.filterAverageThreshold * 0.01 * CFCT:DamageRollingAverage()) > text)) then
            return false
        end

        if (fctConfig.abbreviateNumbers) then
            text = AbbreviateNumbers(text)
        elseif (fctConfig.kiloSeparator) then
            text = FormatThousandSeparator(text)
        end
    end
    
    if (count > 1) and fctConfig.mergeEventsCounter then
        text = text.." x"..tostring(count)
    end

    local icon = spellid and SpellIconText(spellid) or ""
    if (icon and catConfig.showIcons) then text = icon..text end

    
    local fontColor, fontAlpha
    local typeColor = GetTypeColor(school)
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

    tinsert(animAreas[unit], 1, GrabFontString():Init({
        cat = cat,
        unit = unit,
        icon = icon,
        text = text,
        value = value,
        fontOptions = {
            fontPath = catConfig.fontPath,
            fontSize = catConfig.fontSize,
            fontStyle = catConfig.fontStyle,
            fontColor = fontColor,
            fontAlpha = fontAlpha
        },
        isNumber = not miss,
        -- isCrit = crit,
        isString = miss
    }))
end


local eventCache = {}
CFCT.eventCache = eventCache
local function CacheEvent(unit, event, text, spellid, crit, miss, pet, school)
    local id = tostring(pet)..tostring(spellid)..tostring(school)
    local mergeTime = CFCT.Config.mergeEventsInterval
    local now = GetTime()
    local record = eventCache[id] or {
        events = {},
        expiry = nil
    }
    tinsert(record.events, {
        time = now,
        unit = unit,
        event = event,
        text = text,
        spellid = spellid,
        crit = crit,
        miss = miss,
        pet = pet,
        school = school,
        count = 1
    })
    record.expiry = now + mergeTime
    eventCache[id] = record
end

local function ProcessCachedEvents()
    local mergingEnabled = CFCT.Config.mergeEvents
    for id,record in pairs(eventCache) do
        if mergingEnabled then
            if (now > record.expiry) then
                local merge
                for _,e in ipairs(record.events) do
                    if e.miss then
                        DispatchText(e.unit, e.event, e.text, e.spellid, e.crit, e.miss, e.pet, e.school)
                    elseif not merge then
                        merge = e
                    else
                        merge.text = merge.text + e.text
                        merge.count = merge.count + 1
                        merge.crit = merge.crit or e.crit
                    end
                end
                if merge then
                    DispatchText(merge.unit, merge.event, merge.text, merge.spellid, merge.crit, merge.miss, merge.pet, merge.school, merge.count)
                end
                eventCache[id] = nil
            end
        else
            for _,e in ipairs(record.events) do
                DispatchText(e.unit, e.event, e.text, e.spellid, e.crit, e.miss, e.pet, e.school)
            end
            eventCache[id] = nil
        end
    end
end


-- CFCT.TestFrames = {}
CFCT._testMode = false
local testModeTimer = 0
function CFCT:Test(n)
    -- for i = 1, n do
    --     local fontString = GrabFontString()
    --     fontString:Init("|T"..select(3,GetSpellInfo(1))..":0|t"..i.."1234", "white")
    --     fontString.state.cat = "white"
    --     fontString.dragFrame = CreateFrame("frame", "CFCT.TestFrames["..#CFCT.TestFrames+i.."]", f)
    --     fontString.dragFrame:SetFrameStrata("DIALOG")
    --     fontString.dragFrame:SetSize(fontString.state.width, fontString.state.height)
    --     fontString.dragFrame:SetPoint("CENTER", f, "CENTER", 0, 0)
    --     fontString.dragFrame:SetBackdrop({bgFile="Interface/CharacterFrame/UI-Party-Background", tile=true, tileSize=32, insets={left=0, right=0, top=0, bottom=0}})
    --     fontString.dragFrame:SetAlpha(0.3)
    --     fontString.dragFrame:SetMovable(true)
    --     fontString.dragFrame:SetScript("OnMouseDown", function(self, btn)
    --         self:StartMoving()
    --         self:SetScript("OnUpdate", function(self, elapsed)
    --             local x, y = self:GetCenter()
    --             local fx, fy = f:GetCenter()
    --             fontString.state.posX = x - fx
    --             fontString.state.posY = y - fy
    --             fontString:SetPoint("CENTER", f, "CENTER", fontString.state.posX, fontString.state.posY)
    --             PushFrames(fontString, CFCT.TestFrames)
    --             for _, e in pairs(CFCT.TestFrames) do
    --                 if (e ~= fontString) then
    --                     e:SetPoint("CENTER", f, "CENTER", e.state.posX, e.state.posY)
    --                     e.dragFrame:SetPoint("CENTER", f, "CENTER", e.state.posX, e.state.posY)
    --                 end
    --             end
    --         end)
    --     end)
    --     fontString.dragFrame:SetScript("OnMouseUp", function(self, btn)
    --         self:StopMovingOrSizing()
    --         self:SetScript("OnUpdate", nil)
    --     end)
    --     fontString.dragFrame:EnableMouse(true)
    --     tinsert(CFCT.TestFrames, fontString)
    -- end
    -- local cats = {
    --     "auto",
    --     "automiss",
    --     "autocrit",
    --     "petauto",
    --     "petautomiss",
    --     "petautocrit",
    --     "spell",
    --     "spellmiss",
    --     "spellcrit",
    --     "petspell",
    --     "petspellmiss",
    --     "petspellcrit",
    --     "heal",
    --     "healmiss",
    --     "healcrit",
    --     "petheal",
    --     "pethealmiss",
    --     "pethealcrit"
    -- }
    local cats = {
        "auto",
        "spell",
        "heal"
    }
    local nameplates = C_NamePlate.GetNamePlates()
    local numplates = #nameplates
    local it = (numplates > 0) and (n*numplates) or n
    for i = 1, it do
        local spellid
        repeat
            spellid = random(1,32767)
        until select(3,GetSpellInfo(spellid))

        local school = random(1,128)
        local pet = (random(1,3) == 1)
        local crit = (random(1,3) == 1)
        local miss = not crit and (random(1,2) == 1)
        local event = cats[random(1,#cats)]
        local amount = crit and 2674 or miss and "Missed" or 1337
        if crit and miss then
            print(amount, crit, miss)
        end
        local unit = (numplates > 0) and nameplates[random(1,numplates)].UnitFrame.unit or "target"
        DispatchText(unit, event, amount, spellid, crit, miss, pet, school)
    end
end



local CVAR_CHECK_INTERVAL = 5
local cvarTimer = 0
local function checkCvars()
    local val = CFCT.hideBlizz and "1" or "0"
    local cvar = GetCVar("floatingCombatTextCombatDamage")
    CFCT.hideBlizz = (cvar == "1")
end











local events = {
    COMBAT_LOG_EVENT_UNFILTERED = true,
    UNIT_MAXHEALTH = true,
    ADDON_LOADED = true,
    PLAYER_LOGOUT = true,
    PLAYER_ENTERING_WORLD = true,
    NAME_PLATE_UNIT_ADDED = true,
    NAME_PLATE_UNIT_REMOVED = true
}
for e,_ in pairs(events) do f:RegisterEvent(e) end
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)


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
    for k, animArea in pairs(animAreas) do
        for k, fontString in ipairs(animArea) do
            if fontString:UpdateAnimation(k, elapsed) then
                fontString:Release()
                tremove(animArea, k)
            else
                fontString.state.checkOverlap = true
            end
        end
        if CFCT.Config.preventOverlap then
            local frames = SortFrames(animArea)
            -- if CFCT.Debug and (k == "target") then
            --     print("---frames---")
            --     for k,v in ipairs(frames) do
            --         print(v:GetText(),v.state.width,v.state.height,v.state.gridX,v.state.gridY)
            --     end
            --     print("---------------")
            -- end
        end
        for _, e in pairs(animArea) do
            e:UpdatePosition()
        end
        if (now > cvarTimer) then
            self:SetFrameStrata(CFCT.Config.textStrata or "MEDIUM")
            checkCvars()
            cvarTimer = now + CVAR_CHECK_INTERVAL
        end
    end
end)
f:Show()


function f:ADDON_LOADED(name)
    if (name == addonName) then
        CFCT.Config:OnLoad()
    end
end

function f:PLAYER_LOGOUT()
    CFCT.Config:OnSave()
end

local playerGUID
function f:PLAYER_ENTERING_WORLD()
    playerGUID = UnitGUID("player")
    C_Timer.After(5,function()
        CFCT:Log(GetAddOnMetadata(addonName, "Version").."\nNew in this version:\n    - Damage/Healing numbers filtering, sorting, merging")
    end)
end

local nameplates = {}
function f:NAME_PLATE_UNIT_ADDED(unit)
    local guid = UnitGUID(unit)
    animAreas[unit] = animAreas[unit] or {}
    nameplates[unit] = guid
    nameplates[guid] = unit 
end
function f:NAME_PLATE_UNIT_REMOVED(unit)
    local guid = nameplates[unit]
    nameplates[unit] = nil
    nameplates[guid] = nil
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


local MISS_EVENT_STRINGS = {
    ["ABSORB"] = "Absorbed",
    ["BLOCK"] = "Blocked",
    ["DEFLECT"] = "Deflected",
    ["DODGE"] = "Dodged",
    ["EVADE"] = "Evaded",
    ["IMMUNE"] = "Immune",
    ["MISS"] = "Missed",
    ["PARRY"] = "Parried",
    ["REFLECT"] = "Reflected",
    ["RESIST"] = "Resisted",
}

function f:COMBAT_LOG_EVENT_UNFILTERED()
    if CFCT.enabled == false then return end
    local timestamp, cleuEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25 = CombatLogGetCurrentEventInfo()
    local playerEvent, petEvent = (playerGUID == sourceGUID), false
    if not playerEvent then petEvent = (bitband(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or bitband(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0) and (bitband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0) end
    if not (playerEvent or petEvent) then return end
    if (destGUID == playerGUID) then return end
    local unit = nameplates[destGUID]

    if CLEU_DAMAGE_EVENT[cleuEvent] then
        if CLEU_SWING_EVENT[cleuEvent] then
            local amount,overkill,school,resist,block,absorb,crit = arg12,arg13,arg14,arg15,arg16,arg17,arg18
            self:DamageEvent(unit, nil, amount, crit, petEvent, school)
        else --its a SPELL event
            local spellid,spellname,school1,amount,overkill,school2,resist,block,absorb,crit = arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21
            self:DamageEvent(unit, spellid, amount, crit, petEvent, school1)
        end
    elseif CLEU_MISS_EVENT[cleuEvent] then
        if CLEU_SWING_EVENT[cleuEvent] then
            local misstype,_,amount = arg12,arg13,arg14
            self:MissEvent(unit, nil, amount, misstype, petEvent, SCHOOL_MASK_PHYSICAL)
        else --its a SPELL event
            local spellid,spellname,school1,misstype,_,amount = arg12,arg13,arg14,arg15,arg16,arg17
            self:MissEvent(unit, spellid, amount, misstype, petEvent, school1)
        end
    elseif CLEU_HEALING_EVENT[cleuEvent] then
        if CLEU_SWING_EVENT[cleuEvent] then
            local amount,overheal,absorb,crit = arg12,arg13,arg14,arg15
            self:HealingEvent(unit, nil, amount, crit, petEvent, nil)
        else --its a SPELL event
            local spellid,spellname,school1,amount,overheal,absorb,crit = arg12,arg13,arg14,arg15,arg16,arg17,arg18
            self:HealingEvent(unit, spellid, amount, crit, petEvent, school1)
        end
    end
end




function f:DamageEvent(unit, spellid, amount, crit, pet, school)
    if (spellid == 75) then spellid = nil end -- 75 = autoshot
    local event = spellid and "spell" or "auto"
    CacheEvent(unit, event, amount, spellid, crit, false, pet, school)
end
function f:MissEvent(unit, spellid, amount, misstype, pet, school)
    if (spellid == 75) then spellid = nil end -- 75 = autoshot
    local event = spellid and "spell" or "auto"
    CacheEvent(unit, event, strlower(misstype):gsub("^%l", strupper), spellid, false, true, pet, school)
end
function f:HealingEvent(unit, spellid, amount, crit, pet, school)
    local event = "heal"
    CacheEvent(unit, event, amount, spellid, crit, false, pet, school)
end
























