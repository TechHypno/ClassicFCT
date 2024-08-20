local addonName, CFCT = ...
local tinsert, tremove, tsort, format, strlen, strsub, gsub, floor, sin, cos, asin, acos, random, select, pairs, ipairs, unpack, bitband = table.insert, table.remove, table.sort, string.format, string.len, string.sub, string.gsub, math.floor, math.sin, math.cos, math.asin, math.acos, math.random, select, pairs, ipairs, unpack, bit.band

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

local IsRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local IsClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local IsBCC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
local UsesNewSettingsInterface = (Settings and (type(Settings.RegisterAddOnCategory) == 'function'))
local UsesNewColorPicker = OpacitySliderFrame == nil or ((type(OpacitySliderFrame.GetParent) == 'function') and OpacitySliderFrame:GetParent():GetName() ~= "ColorPickerFrame")
local DefaultPresets = CFCT:GetDefaultPresets()
local DefaultConfig = DefaultPresets["Mists of Pandaria"]
local DefaultVars = {
    enabled = true,
    hideBlizz = true,
    hideBlizzHeals = true,
    forceCVars = true,
    characterSpecificConfig = false,
    selectedPreset = "",
    lastVersion = ""
}
local DefaultCharVars = {
    enabled = true,
    hideBlizz = true,
    hideBlizzHeals = true,
    forceCVars = true,
    selectedPreset = "",
}
local DefaultTables = {
    mergeEventsIntervalOverrides = {},
    filterSpellBlacklist = {}
}
local ClassSpecificTables = {
    mergeEventsIntervalOverrides = true,
    filterSpellBlacklist = true
}
for i=1,GetNumClasses(),1 do
    local class = select(2, GetClassInfo(i))
    if (class) then
        for k,v in pairs(ClassSpecificTables) do
            DefaultTables[k][class] = {}
        end
    end
end

local DefaultCharTables = {
    mergeEventsIntervalOverrides = {},
    filterSpellBlacklist = {}
}

local AnimationDefaults = {
    Pow = {
        enabled = false,
        initScale = 0.25,
        midScale = 1.55,
        endScale = 1,
        duration = 0.3,
        inOutRatio = 0.7
    },
    FadeIn = {
        enabled = false,
        duration = 0.07
    },
    FadeOut = {
        enabled = false,
        duration = 0.3
    },
    Scroll = {
        enabled = false,
        direction = "UP",
        distance = 32
    }
}

local function SetValue(path, value)
    local chain = { strsplit(".", path) }
    local depth = #chain
    local temp = CFCT
    for d, k in ipairs(chain) do
        if (d == depth) then
            if (type(value) == 'table') then
                for key,val in pairs(value) do
                    temp[k][key] = val
                end
            end
            temp[k] = value
            return true
        end
        temp = temp[k]
    end
    return false
end

local function GetValue(path)
    local chain = { strsplit(".", path) }
    local depth = #chain
    local temp = CFCT
    for d, k in ipairs(chain) do
        if (d == depth) then
            return temp[k]
        end
        temp = temp[k]
    end
end




local function UpdateTable(dest, source, template, overwrite)
    assert((type(dest) == 'table'), "UpdateTable: dest is not a table")
    assert((type(source) == 'table'), "UpdateTable: source is not a table")
    assert((type(template) == 'table'), "UpdateTable: template is not a table")
    local verbose = (CFCT.debug == true)
    if verbose then CFCT:Log("UpdateTable("..type(dest)..", "..type(source)..", "..type(template)..", "..tostring(overwrite)) end
    for k, t in pairs(template) do
        if verbose then CFCT:Log("["..tostring(k).."] dest("..tostring(dest[k])..") source("..tostring(source[k])..")") end
        if (type(t) == 'table') then
            if verbose then CFCT:Log("table "..tostring(k)) end
            dest[k] = (type(dest[k]) == 'table') and dest[k] or {}
            UpdateTable(dest[k], source[k], t, overwrite)
        elseif ((type(t) ~= type(dest[k])) or (dest[k] == nil) or (overwrite and (dest[k] ~= source[k]))) then
            dest[k] = (source[k] == nil) and t or source[k]
            if verbose then CFCT:Log("write ("..tostring(source[k])..((source[k] == nil) and "  |> " or " <|  ")..tostring(t)..")") end
        end
    end
end
local function AttachTables(dest, source, template)
    local class = UnitClassBase('player')
    for k, t in pairs(template) do
        if (ClassSpecificTables[k] == true) then
            if source[k] == nil then source[k] = {} end
            if source[k][class] == nil then source[k][class] = {} end
            -- print("AttachTable", k, dest[k], class, source[k][class])
            dest[k] = source[k][class]
        else
            if source[k] == nil then source[k] = {} end
            -- print("AttachTable", k, dest[k], source[k])
            dest[k] = source[k]
        end
    end
end

CFCT._log = {}
function CFCT:Log(msg)
    local msg = "|cffffff00ClassicFCT: |r|cffffff80"..(msg or "").."|r"
    print(msg)
    table.insert(self._log, "|cffffff00ClassicFCT: |r|cffffff80"..(msg or "").."|r")
end
function CFCT:DumpLog(n)
    local c = #self._log
    if not ((c > 0) and (c > n)) then return "Invalid Log Range" end
    return table.concat(self._log, "\n", c - n, n)
end


--Input Popup Box
StaticPopupDialogs["CLASSICFCT_POPUPDIALOG"] = {
    text = "POPUPDIALOG_TITLE",
    button1 = "OK",
    button2 = "Cancel",
    OnShow = function() end,
    OnAccept = function() end,
    EditBoxOnEnterPressed = function() end,
    hasEditBox = true,
    timeout = 0,
    exclusive = true,
    hideOnEscape = true
}

function CFCT:ShowInputBox(title, default, OnAccept)
    local pd = StaticPopupDialogs["CLASSICFCT_POPUPDIALOG"]
    pd.hasEditBox = true
    pd.text = title
    pd.OnShow = function(self) self.editBox:SetText(default) end
    pd.OnAccept = function(self) OnAccept(self.editBox:GetText()) end
    pd.EditBoxOnEnterPressed = function(self) OnAccept(self:GetText()) self:GetParent():Hide() end
    StaticPopup_Show("CLASSICFCT_POPUPDIALOG")
end

function CFCT:ConfirmAction(title, OnAccept)
    local pd = StaticPopupDialogs["CLASSICFCT_POPUPDIALOG"]
    pd.hasEditBox = false
    pd.text = title
    pd.OnShow = function() end
    pd.OnAccept = function(self) OnAccept() end
    pd.EditBoxOnEnterPressed = function() end
    StaticPopup_Show("CLASSICFCT_POPUPDIALOG")
end

CFCT.ConfigPanels = {}
CFCT.Presets = {}
CFCT.Config = {
    OnLoad = function(self)
        ClassicFCTCustomPresets = ClassicFCTCustomPresets or {}
        UpdateTable(CFCT.Presets, ClassicFCTCustomPresets, ClassicFCTCustomPresets, true)
        UpdateTable(CFCT.Presets, DefaultPresets, DefaultPresets, true)

        ClassicFCTVars = ClassicFCTVars or {}
        UpdateTable(ClassicFCTVars, DefaultVars, DefaultVars)
        UpdateTable(CFCT, ClassicFCTVars, DefaultVars, true)

        if (not CFCT.characterSpecificConfig) then
            -- print("Loading Global")
            ClassicFCTConfig = ClassicFCTConfig or {}
            UpdateTable(ClassicFCTConfig, DefaultConfig, DefaultConfig)
            UpdateTable(self, ClassicFCTConfig, DefaultConfig, true)

            ClassicFCTTables = ClassicFCTTables or {}
            UpdateTable(ClassicFCTTables, DefaultTables, DefaultTables)
            AttachTables(self, ClassicFCTTables, DefaultTables)
        else
            -- print("Loading Character")
            ClassicFCTCharVars = ClassicFCTCharVars or {}
            UpdateTable(ClassicFCTCharVars, DefaultCharVars, DefaultCharVars)
            UpdateTable(CFCT, ClassicFCTCharVars, DefaultCharVars, true)

            ClassicFCTCharConfig = ClassicFCTCharConfig or {}
            UpdateTable(ClassicFCTCharConfig, DefaultConfig, DefaultConfig)
            UpdateTable(self, ClassicFCTCharConfig, DefaultConfig, true)

            ClassicFCTCharTables = ClassicFCTCharTables or {}
            UpdateTable(ClassicFCTCharTables, DefaultCharTables, DefaultCharTables)
            AttachTables(self, ClassicFCTCharTables, DefaultCharTables)
        end
    end,
    OnSave = function(self)
        ClassicFCTCustomPresets = {}
        UpdateTable(ClassicFCTCustomPresets, CFCT.Presets, CFCT.Presets, true)
        ClassicFCTVars.lastVersion = CFCT.lastVersion
        if (not CFCT.characterSpecificConfig) then
            -- print("Saving Global")
            UpdateTable(CFCT, ClassicFCTVars, DefaultVars)
            UpdateTable(ClassicFCTVars, CFCT, DefaultVars, true)

            UpdateTable(self, ClassicFCTConfig, DefaultConfig)
            UpdateTable(ClassicFCTConfig, self, DefaultConfig, true)
        else
            -- print("Saving Character")
            UpdateTable(CFCT, ClassicFCTCharVars, DefaultCharVars)
            UpdateTable(ClassicFCTCharVars, CFCT, DefaultCharVars, true)

            UpdateTable(self, ClassicFCTCharConfig, DefaultConfig)
            UpdateTable(ClassicFCTCharConfig, self, DefaultConfig, true)
        end
    end,
    LoadPreset = function(self, presetName)
        CFCT:ConfirmAction("This will overwrite your current configuration. Are you sure?", function()
            if (CFCT.Presets[presetName] ~= nil) then
                UpdateTable(self, CFCT.Presets[presetName], CFCT.Presets[presetName], true)
                CFCT:Log(presetName.." preset loaded.")
            elseif (DefaultPresets[presetName] ~= nil) then
                UpdateTable(self, DefaultPresets[presetName], DefaultPresets[presetName], true)
                CFCT:Log(presetName.." preset loaded.")
            end
            CFCT.ConfigPanel:refresh()
        end)
    end,
    SavePreset = function(self, presetName)
        CFCT:ConfirmAction("This will overwrite your the selected preset. Are you sure?", function()
            if (DefaultPresets[presetName] == nil) and (CFCT.Presets[presetName] ~= nil) then
                UpdateTable(CFCT.Presets[presetName], CFCT.Config, CFCT.Config, true)
                CFCT:Log("Config saved to "..presetName.." preset.")
            end
        end)
    end,
    NewPresetName = function(self, baseName)
        for i=0, 10000, 1 do
            local name = format("%s%s", baseName, (i > 0) and tostring(i) or "")
            if (CFCT.Presets[name] == nil) then
                return name
            end
        end
    end,
    CreatePreset = function(self)
        local defaultName = self:NewPresetName("New preset")
        CFCT:ShowInputBox("Preset Name", defaultName, function(value)
            local value = ((strlen(value) > 0) and value or defaultName)
            if (CFCT.Presets[value] == nil) then
                CFCT.Presets[value] = {}
                UpdateTable(CFCT.Presets[value], DefaultConfig, DefaultConfig)
                CFCT.selectedPreset = value
            else
                CFCT:Log("Preset "..value.." already exists")
            end
            CFCT.ConfigPanel:refresh()
        end)
    end,
    CreatePresetCopy = function(self, presetName)
        local defaultName = self:NewPresetName("Copy of "..presetName)
        CFCT:ShowInputBox("Preset Name", defaultName, function(value)
            local value = ((strlen(value) > 0) and value or defaultName)
            if (CFCT.Presets[value] == nil) then
                CFCT.Presets[value] = {}
                UpdateTable(CFCT.Presets[value], CFCT.Presets[presetName], CFCT.Presets[presetName])
                CFCT.selectedPreset = value
            else
                CFCT:Log("Preset "..value.." already exists")
            end
            CFCT.ConfigPanel:refresh()
        end)
    end,
    RenamePreset = function(self, presetName)
        CFCT:ShowInputBox("Preset Name", presetName, function(value)
            local value = ((strlen(value) > 0) and value or presetName)
            if (CFCT.Presets[value] == nil) then
                CFCT.Presets[value] = CFCT.Presets[presetName]
                CFCT.Presets[presetName] = nil
                CFCT.selectedPreset = value
            else
                CFCT:Log("Preset "..value.." already exists")
            end
            CFCT.ConfigPanel:refresh()
        end)
    end,
    DeletePreset = function(self, presetName)
        CFCT:ConfirmAction("This will delete the preset permanently. Are you sure?", function()
            CFCT.Presets[presetName] = nil
            CFCT.ConfigPanel:refresh()
        end)
    end,
    RestoreDefaults = function(self)
        UpdateTable(self, DefaultConfig, DefaultConfig, true)
        UpdateTable(CFCT, DefaultVars, DefaultVars, true)
        CFCT.ConfigPanel:refresh()
        CFCT:Log("Defaults restored.")
    end,
    Show = function(self)
        if (UsesNewSettingsInterface) then
            Settings.OpenToCategory(CFCT.ConfigPanels[1].CategoryID)
        else
            InterfaceOptionsFrame_OpenToCategory(CFCT.ConfigPanels[1])
        end
    end
}

SLASH_CLASSICFCT1 = '/cfct'
SlashCmdList['CLASSICFCT'] = function(msg)
    CFCT.Config:Show()
end
SLASH_CLASSICFCTFS1 = '/fs'
SlashCmdList['CLASSICFCTFS'] = function(msg)
    FrameStackTooltip_Toggle(0, 0, 0);
end

function CFCT.Color2RGBA(color)
    return tonumber("0x"..strsub(color, 3, 4))/255, tonumber("0x"..strsub(color, 5, 6))/255, tonumber("0x"..strsub(color, 7, 8))/255, tonumber("0x"..strsub(color, 1, 2))/255
end

function CFCT.RGBA2Color(r, g, b, a)
    return format("%02X%02X%02X%02X", floor(a*255+0.5), floor(r*255+0.5), floor(g*255+0.5), floor(b*255+0.5))
end


local function ValidateValue(rawVal, minVal, maxVal, step)
    local stepval = floor(rawVal / step) * step
    return min(max((((rawVal - stepval) >= (step / 2)) and stepval + step or stepval), minVal), maxVal)
end

local function WidgetConfigBridgeGet(self, default, ConfigPathOrFunc)
    if (type(ConfigPathOrFunc) == 'function') then
        return ConfigPathOrFunc(self, "Get", default)
    else
        local ret = GetValue(ConfigPathOrFunc)
        -- print("WidgetConfigBridgeGet", ConfigPathOrFunc, default, ret, (ret == nil) and default or ret)
        return (ret == nil) and default or ret -- value == default
    end
end

local function WidgetConfigBridgeSet(self, value, ConfigPathOrFunc)
    if (type(ConfigPathOrFunc) == 'function') then
        ConfigPathOrFunc(self, "Set", value)
    else
        SetValue(ConfigPathOrFunc, value)
    end
end

local AttachModesMenu = {
    {
        text = "Screen Center",
        value = "sc"
    },
    {
        text = "Target Nameplate",
        value = "tn"
    },
    {
        text = "Every Nameplate",
        value = "en"
    }
}
local MergeIntervalModeMenu = {
    {
        text = "First Event",
        value = "first"
    },
    {
        text = "Last Event",
        value = "last"
    }
}

local TextStrataMenu = {
    -- {
    --     text = "World",
    --     value = "WORLD"
    -- },
    {
        text = "Background",
        value = "BACKGROUND"
    },
    {
        text = "Low",
        value = "LOW"
    },
    {
        text = "Medium",
        value = "MEDIUM"
    },
    {
        text = "High",
        value = "HIGH"
    },
    {
        text = "Dialog",
        value = "DIALOG"
    },
    {
        text = "Fullscreen",
        value = "FULLSCREEN"
    },
    {
        text = "Fullscreen Dialog",
        value = "FULLSCREEN_DIALOG"
    },
    {
        text = "Tooltip",
        value = "TOOLTIP"
    }
}



local AnimationsMenu = {
    Func = function(self, dropdown)
        
    end,
    {
        text = "Pow",
        value = "Pow"
    },
    {
        text = "Fade In",
        value = "FadeIn"
    },
    {
        text = "Fade Out",
        value = "FadeOut"
    },
    {
        text = "Scroll",
        value = "Scroll"
    },
}


local FontStylesMenu = {
    Func = function(self, dropdown)
        local ConfigPath = dropdown.configPath
        if (ConfigPath) then
            SetValue(ConfigPath, self.value)
        end
    end,
    {
        text = "No Outline",
        value = ""
    },
    {
        text = "No Outline Monochrome",
        value = "MONOCHROME"
    },
    {
        text = "Outline",
        value = "OUTLINE"
    },
    {
        text = "Outline Monochrome",
        value = "OUTLINE,MONOCHROME"
    },
    {
        text = "Thick Outline",
        value = "THICKOUTLINE"
    },
    {
        text = "Thick Outline Monochrome",
        value = "THICKOUTLINE,MONOCHROME"
    }
}


local SCHOOL_NAMES = {
    -- Single Schools
    [Enum.Damageclass.MaskPhysical]	    = STRING_SCHOOL_PHYSICAL,
    [Enum.Damageclass.MaskHoly]		    = STRING_SCHOOL_HOLY,
    [Enum.Damageclass.MaskFire]		    = STRING_SCHOOL_FIRE,
    [Enum.Damageclass.MaskNature]	    = STRING_SCHOOL_NATURE,
    [Enum.Damageclass.MaskFrost]	    = STRING_SCHOOL_FROST,
    [Enum.Damageclass.MaskShadow]	    = STRING_SCHOOL_SHADOW,
    [Enum.Damageclass.MaskArcane]	    = STRING_SCHOOL_ARCANE,
    -- Physical and a Magical
    [Enum.Damageclass.MaskFlamestrike]	= STRING_SCHOOL_FLAMESTRIKE,
    [Enum.Damageclass.MaskFroststrike]	= STRING_SCHOOL_FROSTSTRIKE,
    [Enum.Damageclass.MaskSpellstrike]	= STRING_SCHOOL_SPELLSTRIKE,
    [Enum.Damageclass.MaskStormstrike]	= STRING_SCHOOL_STORMSTRIKE,
    [Enum.Damageclass.MaskShadowstrike]	= STRING_SCHOOL_SHADOWSTRIKE,
    [Enum.Damageclass.MaskHolystrike]	= STRING_SCHOOL_HOLYSTRIKE,
    -- Two Magical Schools
    [Enum.Damageclass.MaskFrostfire]	= STRING_SCHOOL_FROSTFIRE,
    [Enum.Damageclass.MaskSpellfire]	= STRING_SCHOOL_SPELLFIRE,
    [Enum.Damageclass.MaskFirestorm]	= STRING_SCHOOL_FIRESTORM,
    [Enum.Damageclass.MaskShadowflame]	= STRING_SCHOOL_SHADOWFLAME,
    [Enum.Damageclass.MaskHolyfire]		= STRING_SCHOOL_HOLYFIRE,
    [Enum.Damageclass.MaskSpellfrost]	= STRING_SCHOOL_SPELLFROST,
    [Enum.Damageclass.MaskFroststorm]	= STRING_SCHOOL_FROSTSTORM,
    [Enum.Damageclass.MaskShadowfrost]	= STRING_SCHOOL_SHADOWFROST,
    [Enum.Damageclass.MaskHolyfrost]	= STRING_SCHOOL_HOLYFROST,
    [Enum.Damageclass.MaskSpellstorm]	= STRING_SCHOOL_SPELLSTORM,
    [Enum.Damageclass.MaskSpellshadow]	= STRING_SCHOOL_SPELLSHADOW,
    [Enum.Damageclass.MaskDivine]		= STRING_SCHOOL_DIVINE,
    [Enum.Damageclass.MaskShadowstorm]	= STRING_SCHOOL_SHADOWSTORM,
    [Enum.Damageclass.MaskHolystorm]	= STRING_SCHOOL_HOLYSTORM,
    [Enum.Damageclass.MaskTwilight]	    = STRING_SCHOOL_SHADOWLIGHT,
    -- Three or more schools
    [Enum.Damageclass.MaskElemental]	= STRING_SCHOOL_ELEMENTAL,
    [Enum.Damageclass.MaskChromatic]    = STRING_SCHOOL_CHROMATIC,
    [Enum.Damageclass.MaskMagical]      = STRING_SCHOOL_MAGIC,
    [Enum.Damageclass.MaskChaos]        = STRING_SCHOOL_CHAOS
}








function ShowColorPicker(_parentFrame, _r, _g, _b, _a, _changedCallback)
    --show color picker
    ColorPickerFrame:Hide()
    ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    
    if (_parentFrame) then
        ColorPickerFrame:SetFrameLevel(_parentFrame:GetFrameLevel() + 10)
    end
    local flip_alpha = not UsesNewColorPicker
    local function fix_alpha(src_alpha)
        return (flip_alpha and (1 - src_alpha)) or src_alpha
    end
    ColorPickerFrame:SetupColorPickerAndShow({
        hasOpacity = true,
        r = _r, g = _g, b = _b,
        opacity = fix_alpha(_a),
        extraInfo = nil,
        opacityFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = ColorPickerFrame:GetColorAlpha()
            _changedCallback(r, g, b, fix_alpha(a))
        end,
        swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = ColorPickerFrame:GetColorAlpha()
            _changedCallback(r, g, b, fix_alpha(a))
        end,
        cancelFunc = function()
            local r, g, b, a = ColorPickerFrame:GetPreviousValues()
            _changedCallback(r, g, b, fix_alpha(a))
        end,
    })
end

local function CreateHeader(self, text, headerType, parent, point1, point2, x, y)
    local header = self:CreateFontString(nil, "ARTWORK", headerType)
    self:AddFrame(header)
    header:SetText(text)
    header:SetPoint(point1, parent, point2, x, y)
    return header
end
local function CreateCheckbox(self, label, tooltip, parent, point1, point2, x, y, defVal, ConfigPathOrFunc)
    local checkbox = CreateFrame("CheckButton", self:NewFrameID(), self, "InterfaceOptionsCheckButtonTemplate")
    self:AddFrame(checkbox)
    checkbox:SetPoint(point1, parent, point2, x, y)
    checkbox:SetScript("OnShow", function(self)
        local val = WidgetConfigBridgeGet(self, defVal, ConfigPathOrFunc)
        self:SetChecked(val)
    end)
    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        WidgetConfigBridgeSet(self, checked, ConfigPathOrFunc)
    end)
    checkbox.label = getglobal(checkbox:GetName() .. 'Text')
    checkbox.label:SetText(label)
    checkbox.tooltipText = tooltip
    checkbox.tooltipRequirement = "Default: " .. (tostring(defVal) ~= "nil" and tostring(defVal) or "")
    return checkbox
end
local function CreateButton(self, label, tooltip, parent, point1, point2, x, y, Func)
    local btn = CreateFrame("button", self:NewFrameID(), self, "UIPanelButtonTemplate")
    self:AddFrame(btn)
    btn:SetWidth(70)
    btn:SetPoint(point1, parent, point2, x, y)
    btn:SetText(label)
    btn:SetScript("OnClick", function(self, btn, down) if (btn == "LeftButton") and (type(Func) == 'function') then Func(self) end end)
    btn:Show()
    return btn
end
local function CreateSlider(self, label, tooltip, parent, point1, point2, x, y, minVal, maxVal, step, defVal, ConfigPathOrFunc)
    local slider = CreateFrame("Slider", self:NewFrameID(), self, "OptionsSliderTemplate")
    self:AddFrame(slider)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint(point1, parent, point2, x, y)
    slider:SetWidth(270)
    slider.tooltipText = tooltip
	slider.tooltipRequirement = "Default: " .. (defVal or "") 
    getglobal(slider:GetName() .. 'Low'):SetText(tostring(minVal))
    getglobal(slider:GetName() .. 'High'):SetText(tostring(maxVal))
    getglobal(slider:GetName() .. 'Text'):SetText(label)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    slider:SetScript("OnShow", function(self)
        self:SetValue(WidgetConfigBridgeGet(self, defVal, ConfigPathOrFunc))
    end)
    slider:HookScript("OnValueChanged", function(self, val, isUserInput)
        slider.valueBox:SetText(val)
        WidgetConfigBridgeSet(self, val, ConfigPathOrFunc)
    end)

    local valueBox = CreateFrame('editbox', nil, slider, BackdropTemplateMixin and "BackdropTemplate")
	valueBox:SetPoint('TOP', slider, 'BOTTOM', 0, 0)
	valueBox:SetSize(60, 14)
	valueBox:SetFontObject(GameFontHighlightSmall)
	valueBox:SetAutoFocus(false)
	valueBox:SetJustifyH('CENTER')
	valueBox:SetScript('OnEscapePressed', function(self)
		self:SetText(slider:GetValue() or defVal)
		self:ClearFocus()
	end)
	valueBox:SetScript('OnEnterPressed', function(self)
        local value = ValidateValue(tonumber(self:GetText()) or slider:GetValue() or defVal, minVal, maxVal, step)
        slider:SetValue(value)
		self:SetText(value)
		self:ClearFocus()
	end)
	slider:HookScript('OnValueChanged', function(self, rawVal)
		local value = ValidateValue(rawVal, minVal, maxVal, step)
		valueBox:SetText(value)
	end)
	valueBox:SetScript('OnChar', function(self)
		self:SetText(self:GetText():gsub('[^%.0-9]+', ''):gsub('(%..*)%.', '%1'))
	end)
	valueBox:SetMaxLetters(5)

	valueBox:SetBackdrop({
		bgFile = 'Interface/ChatFrame/ChatFrameBackground',
		edgeFile = 'Interface/ChatFrame/ChatFrameBackground',
		tile = true, edgeSize = 1, tileSize = 5,
	})
	valueBox:SetBackdropColor(0, 0, 0, 0.5)
	valueBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

    slider.valueBox = valueBox
    return slider
end


local LSM = LibStub("LibSharedMedia-3.0")
local fontList = {[1]="Friz Quadrata TT"}
local fontPaths = {["Friz Quadrata TT"]="Fonts\\FRIZQT__.TTF"}
local fontObjects = {}
if LSM then
    local function updateFontList()
        for i, name in ipairs(LSM:List("font")) do
            local path = LSM:Fetch("font", name, true)
            if (path) then
                fontList[i] = name
                fontPaths[name] = path
                if (fontObjects[path] == nil) then
                    fontObjects[path] = CreateFont(name)
                    fontObjects[path]:SetFont(path, 14, "")
                end
            end
        end
    end
    updateFontList()
    function CFCT:UpdateUsedMedia(event, mediatype, key)
        if (mediatype == "font") then
            updateFontList()
        end
    end
    LSM.RegisterCallback(CFCT, "LibSharedMedia_Registered", "UpdateUsedMedia")
end



local function CreateFontDropdown(self, label, tooltip, parent, point1, point2, x, y, defVal, ConfigPath)
    local dropdown = CreateFrame('Frame', self:NewFrameID(), self, "UIDropDownMenuTemplate")
    self:AddFrame(dropdown)
    dropdown:SetPoint(point1, parent, point2, x, y)
    dropdown.left = getglobal(dropdown:GetName() .. "Left")
    dropdown.middle = getglobal(dropdown:GetName() .. "Middle")
    dropdown.middle:SetWidth(150)
    dropdown.right = getglobal(dropdown:GetName() .. "Right")
    local function itemOnClick(self)
        SetValue(ConfigPath, self.value)
        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
    end
    dropdown.initialize = function(dd)
        local curValue = GetValue(ConfigPath)
        local info = UIDropDownMenu_CreateInfo()
        for i,name in ipairs(fontList) do
            wipe(info)
            info.text = name
            info.value = fontPaths[name]
            info.fontObject = fontObjects[info.value]
            info.checked = (curValue == info.value)
            info.func = itemOnClick
            UIDropDownMenu_AddButton(info)
        end
        UIDropDownMenu_SetSelectedValue(dd, curValue or defVal)
    end
    dropdown:HookScript("OnShow", function(self)
        DropDownList1:SetClampedToScreen(true)
        local curValue = GetValue(ConfigPath)
        for name, path in pairs(fontPaths) do
            if (path == curValue) then
                getglobal(self:GetName().."Text"):SetText(name)
            end
        end
    end)
    return dropdown
end
local function CreateDropDownMenu(self, label, tooltip, parent, point1, point2, x, y, menuItems, ConfigPathOrFunc)
    local dropdown = CreateFrame('Frame', self:NewFrameID(), self, "UIDropDownMenuTemplate")
    self:AddFrame(dropdown)
    dropdown:SetPoint(point1, parent, point2, x, y)
    dropdown.left = getglobal(dropdown:GetName() .. "Left")
    dropdown.middle = getglobal(dropdown:GetName() .. "Middle")
    dropdown.middle:SetWidth(150)
    dropdown.right = getglobal(dropdown:GetName() .. "Right")
    dropdown.curValue = menuItems[1].value

    -- if (ConfigPathOrFunc and (type(ConfigPathOrFunc) == 'function')) then
    --     dropdown.menuFunc = ConfigPathOrFunc
    -- else
    --     dropdown.configPath = ConfigPathOrFunc
    -- end

    -- UIDropDownMenu_SetAnchor(dropdown, 300, 0, "CENTER", UIParent, "LEFT")
    local function itemOnClick(self)
        for i, item in ipairs(menuItems) do
            if (item.value == self.value) then
                dropdown.curValue = item.value
                break
            end
        end
        WidgetConfigBridgeSet(dropdown, self.value, ConfigPathOrFunc)
        -- if (dropdown.menuFunc and (type(dropdown.menuFunc) == 'function')) then
        --     dropdown.menuFunc(self, dropdown)
        -- elseif (dropdown.configPath and (type(dropdown.configPath) == 'string')) then
        --     SetValue(dropdown.configPath, dropdown.curValue)
        -- end
        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
    end
    dropdown.initialize = function(dd)
        local info = UIDropDownMenu_CreateInfo()
        for i,item in ipairs(menuItems) do
            wipe(info)
            info.text = item.text
            info.value = item.value
            info.checked = (info.value == dropdown.curValue)
            info.func = itemOnClick
            UIDropDownMenu_AddButton(info)
        end
        UIDropDownMenu_SetSelectedValue(dd, dd.curValue)
    end
    dropdown:HookScript("OnShow", function(self)
        self.curValue = WidgetConfigBridgeGet(self, self.curValue, ConfigPathOrFunc)
        for _,item in ipairs(menuItems) do
            if (item.value == self.curValue) then
                getglobal(self:GetName().."Text"):SetText(item.text)
            end
        end
    end)
    return dropdown
end

local function CreateColorOption(self, label, tooltip, parent, point1, point2, x, y, defVal, ConfigPathOrFunc)
    local btn = CreateFrame("Button", self:NewFrameID(), self)
    self:AddFrame(btn)

    btn:SetPoint(point1, parent, point2, x, y)
    btn:SetSize(110, 24)
    -- btn:Hide()
    btn:EnableMouse(true)

    if (ConfigPathOrFunc and (type(ConfigPathOrFunc) == 'function')) then
        btn.configFunc = ConfigPathOrFunc
    else
        btn.configPath = ConfigPathOrFunc
    end

    btn.SetColor = function(self, r, g, b, a)
        self.value = {a=a, r=r, g=g, b=b}
        self.preview:SetVertexColor(r, g, b, a)
    end
    btn:SetScript("OnEnter", function(self)
        --show tooltip
        self.preview.bg:SetColorTexture(1, 1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        --hide tooltip
        self.preview.bg:SetColorTexture(0.5, 0.5, 0.5)
    end)
    btn:SetScript("OnClick", function(self)
        --show color picker
        ShowColorPicker(self, self.value.r, self.value.g, self.value.b, self.value.a, function(r, g, b, a)
            WidgetConfigBridgeSet(self, CFCT.RGBA2Color(r, g, b, a), ConfigPathOrFunc)
            self:SetColor(r, g, b, a)
        end)
    end)
    btn:SetScript("OnShow", function(self)
        local r, g, b, a = CFCT.Color2RGBA(WidgetConfigBridgeGet(self, defVal, ConfigPathOrFunc))
        self:SetColor(r, g, b, a)
    end)

    local preview = btn:CreateTexture(nil, "OVERLAY")
    btn.preview = preview
    preview:SetSize(22, 22)
    preview:SetTexture(130939)
    preview:SetPoint("LEFT")

    local tex = btn:CreateTexture(nil, "BACKGROUND")
    preview.bg = tex
    tex:SetSize(18, 18)
    tex:SetColorTexture(0.5, 0.5, 0.5)
    tex:SetPoint("CENTER", preview)
    tex:Show()

    -- checkerboard alpha background
    local ch = btn:CreateTexture(nil, "BACKGROUND")
	preview.ch = ch
	ch:SetWidth(16)
	ch:SetHeight(16)
	ch:SetTexture(188523)
	ch:SetTexCoord(.25, 0, 0.5, .25)
	ch:SetDesaturated(true)
	ch:SetVertexColor(1, 1, 1, 0.75)
	ch:SetPoint("CENTER", preview)
    ch:Show()

    local lbl = btn:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    btn.label = lbl
	lbl:SetHeight(24)
	lbl:SetJustifyH("LEFT")
	lbl:SetTextColor(1, 1, 1)
	lbl:SetPoint("LEFT", preview, "RIGHT", 2, 0)
    lbl:SetPoint("RIGHT")
    lbl:SetText(label)

    btn._Disable = btn.Disable
    btn.Disable = function(self)
        self:_Disable()
        lbl:SetTextColor(0.5, 0.5, 0.5)
    end
    btn._Enable = btn.Enable
    btn.Enable = function(self)
        self:_Enable()
        lbl:SetTextColor(1, 1, 1)
    end

    return btn
end


local HEADER_TEXT = {
    auto = "Auto Hits",
    automiss = "Auto Misses",
    autocrit = "Auto Crits",
    petauto = "Pet Auto Hits",
    petautomiss = "Pet Auto Misses",
    petautocrit = "Pet Auto Crits",

    spell = "Spell Hits",
    spellmiss = "Spell Misses",
    spellcrit = "Spell Crits",
    spelltick = "DoT Ticks",
    spelltickmiss = "DoT Miss Ticks",
    spelltickcrit = "DoT Crit Ticks",

    petspell = "Pet Spell Hits",
    petspellmiss = "Pet Spell Misses",
    petspellcrit = "Pet Spell Crits",
    petspelltick = "Pet DoT Ticks",
    petspelltickmiss = "Pet DoT Miss Ticks",
    petspelltickcrit = "Pet DoT Crit Ticks",

    heal = "Heals",
    healmiss = "Heal Misses",
    healcrit = "Heal Crits",
    healtick = "HoT Ticks",
    healtickmiss = "HoT Miss Ticks",
    healtickcrit = "HoT Crit Ticks",

    petheal = "Pet Heals",
    pethealmiss = "Pet Heal Misses",
    pethealcrit = "Pet Heal Crits",
    pethealtick = "Pet HoT Ticks",
    pethealtickmiss = "Pet HoT Miss Ticks",
    pethealtickcrit = "Pet HoT Crit Ticks",
}
local function CreatePowAnimationPanel(self, cat, anchor, point1, point2, x, y)
    local f = self:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    f:Hide()
    DefaultConfig[cat].Pow = DefaultConfig[cat].Pow or {}
    UpdateTable(DefaultConfig[cat].Pow, AnimationDefaults.Pow, AnimationDefaults.Pow)
    local enabledCheckbox = f:CreateCheckbox("Enable Pow", "Enables/Disables this animation type", f, "TOPLEFT", "TOPLEFT", 170, -2, DefaultConfig[cat].Pow.enabled, "Config."..cat..".Pow.enabled")
    local c = f:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    
    local duration = c:CreateSlider("Duration", "Animation duration relative to global duration", f, "TOPLEFT", "TOPLEFT", 310, -12, 0.01, 1, 0.01, DefaultConfig[cat].Pow.duration, "Config."..cat..".Pow.duration")
    duration:SetFrameLevel(enabledCheckbox:GetFrameLevel()+1)
    local inOutRatio = c:CreateSlider("Duration Ratio", "Duration ratio between time spent in Start to Mid phase and time spent in Mid to End phase.", f, "TOPLEFT", "TOPLEFT", 460, -12, 0.01, 1, 0.01, DefaultConfig[cat].Pow.inOutRatio, "Config."..cat..".Pow.inOutRatio")
    
    local initScale = c:CreateSlider("Start Scale", "Initial text scale", f, "TOPLEFT", "TOPLEFT", 160, -58, 0.1, 5, 0.01, DefaultConfig[cat].Pow.initScale, "Config."..cat..".Pow.initScale")
    local midScale = c:CreateSlider("Mid Scale", "Mid point text scale", f, "TOPLEFT", "TOPLEFT", 310, -58, 0.1, 5, 0.01, DefaultConfig[cat].Pow.midScale, "Config."..cat..".Pow.midScale")
    local endScale = c:CreateSlider("End Scale", "Final text scale", f, "TOPLEFT", "TOPLEFT", 460, -58, 0.1, 5, 0.01, DefaultConfig[cat].Pow.endScale, "Config."..cat..".Pow.endScale")
    duration:SetWidth(140)
    inOutRatio:SetWidth(140)
    initScale:SetWidth(140)
    midScale:SetWidth(140)
    endScale:SetWidth(140)
    enabledCheckbox:HookScript("OnShow", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    enabledCheckbox:HookScript("OnClick", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    f.enabledCheckbox = enabledCheckbox
    return f
end    

local function CreateFadeInAnimationPanel(self, cat, anchor, point1, point2, x, y)
    local f = self:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    f:Hide()
    DefaultConfig[cat].FadeIn = DefaultConfig[cat].FadeIn or {}
    UpdateTable(DefaultConfig[cat].FadeIn, AnimationDefaults.FadeIn, AnimationDefaults.FadeIn)
    local enabledCheckbox = f:CreateCheckbox("Enable Fade In", "Enables/Disables this animation type", f, "TOPLEFT", "TOPLEFT", 170, -2, DefaultConfig[cat].FadeIn.enabled, "Config."..cat..".FadeIn.enabled")
    local c = f:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    
    local duration = c:CreateSlider("Duration", "Animation duration relative to global duration", f, "TOPLEFT", "TOPLEFT", 320, -12, 0.01, 1, 0.01, DefaultConfig[cat].FadeIn.duration, "Config."..cat..".FadeIn.duration")
    duration:SetFrameLevel(enabledCheckbox:GetFrameLevel()+1)
    duration:SetWidth(140)
    enabledCheckbox:HookScript("OnShow", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    enabledCheckbox:HookScript("OnClick", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    f.enabledCheckbox = enabledCheckbox
    return f
end   
local function CreateFadeOutAnimationPanel(self, cat, anchor, point1, point2, x, y)
    local f = self:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    f:Hide()
    DefaultConfig[cat].FadeOut = DefaultConfig[cat].FadeOut or {}
    UpdateTable(DefaultConfig[cat].FadeOut, AnimationDefaults.FadeOut, AnimationDefaults.FadeOut)
    local enabledCheckbox = f:CreateCheckbox("Enable Fade Out", "Enables/Disables this animation type", f, "TOPLEFT", "TOPLEFT", 170, -2, DefaultConfig[cat].FadeOut.enabled, "Config."..cat..".FadeOut.enabled")
    local c = f:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    
    local duration = c:CreateSlider("Duration", "Animation duration relative to global duration", f, "TOPLEFT", "TOPLEFT", 320, -12, 0.01, 1, 0.01, DefaultConfig[cat].FadeOut.duration, "Config."..cat..".FadeOut.duration")
    duration:SetFrameLevel(enabledCheckbox:GetFrameLevel()+1)
    duration:SetWidth(140)
    enabledCheckbox:HookScript("OnShow", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    enabledCheckbox:HookScript("OnClick", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    f.enabledCheckbox = enabledCheckbox
    return f
end
local ScrollDirectionsMenu = {
    {
        text = "Scroll Up",
        value = "UP"
    },
    {
        text = "Scroll Down",
        value = "DOWN"
    },
    {
        text = "Scroll Left",
        value = "LEFT"
    },
    {
        text = "Scroll Right",
        value = "RIGHT"
    },
    {
        text = "Scroll Up & Left",
        value = "UPLEFT"
    },
    {
        text = "Scroll Up & Right",
        value = "UPRIGHT"
    },
    {
        text = "Scroll Down & Left",
        value = "DOWNLEFT"
    },
    {
        text = "Scroll Down & Right",
        value = "DOWNRIGHT"
    },
    {
        text = "Random Direction",
        value = "RANDOM"
    },
}
local function CreateScrollAnimationPanel(self, cat, anchor, point1, point2, x, y)
    local f = self:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    f:Hide()
    DefaultConfig[cat].Scroll = DefaultConfig[cat].Scroll or {}
    UpdateTable(DefaultConfig[cat].Scroll, AnimationDefaults.Scroll, AnimationDefaults.Scroll)
    local enabledCheckbox = f:CreateCheckbox("Enable Scroll", "Enables/Disables this animation type", f, "TOPLEFT", "TOPLEFT", 170, -2, DefaultConfig[cat].Scroll.enabled, "Config."..cat..".Scroll.enabled")
    local c = f:CreateChildFrame(point1, point2, anchor, x, y, 612, 90)
    
    local dirDropDown = c:CreateDropDownMenu("Direction", "Scroll direction", f, "TOPLEFT", "TOPLEFT", 320-16, 0, ScrollDirectionsMenu, "Config."..cat..".Scroll.direction")
    dirDropDown.middle:SetWidth(120)
    local distance = c:CreateSlider("Distance", "Scroll distance", f, "TOPLEFT", "TOPLEFT", 320, -40, 1, floor(WorldFrame:GetWidth()), 1, DefaultConfig[cat].Scroll.distance, "Config."..cat..".Scroll.distance")
    distance:SetFrameLevel(enabledCheckbox:GetFrameLevel()+1)
    distance:SetWidth(140)
    enabledCheckbox:HookScript("OnShow", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    enabledCheckbox:HookScript("OnClick", function(self)
        if self:GetChecked() then c:Show() else c:Hide() end
    end)
    f.enabledCheckbox = enabledCheckbox
    return f
end    


local function CreateCategoryPanel(self, cat, anchor, point1, point2, x, y)
    local f = self:CreateChildFrame(point1, point2, anchor, x, y, 612, 180)
    f:Show()
    
    local header = self:CreateHeader(HEADER_TEXT[cat], "GameFontNormalLarge", f, "TOPLEFT", "TOPLEFT", 4, -2)
    local enabledCheckbox = self:CreateCheckbox("Enabled", "Enables/Disables this event type", f, "TOPLEFT", "TOPLEFT", 143, 0, DefaultConfig[cat].enabled, "Config."..cat..".enabled")
    enabledCheckbox.label:SetWidth(80)
    enabledCheckbox:HookScript("OnShow", function(self)
        if (self:GetChecked()) then f:Show() else f:Hide() end
    end)
    enabledCheckbox:HookScript("OnClick", function(self)
        if (self:GetChecked()) then f:Show() else f:Hide() end
    end)
    local showIconsCheckbox = f:CreateCheckbox("Show Spell Icons", "Enables/Disables showing spell icons next to damage text", f, "TOPLEFT", "TOPLEFT", 250, 0, DefaultConfig[cat].showIcons, "Config."..cat..".showIcons")
    showIconsCheckbox:SetFrameLevel(enabledCheckbox:GetFrameLevel() + 1)

    local fontFaceDropDown = f:CreateFontDropdown("Font Face", "Font face used", f, "TOPLEFT", "TOPLEFT", -16, -28, DefaultConfig[cat].fontPath, "Config."..cat..".fontPath")
    local fontStyleDropDown = f:CreateDropDownMenu("Font Style", "Font style used", f, "TOPLEFT", "TOPLEFT", 154, -28, FontStylesMenu, "Config."..cat..".fontStyle")
    local fontSizeSlider = f:CreateSlider("Font Size", "Font Size", f, "TOPLEFT", "TOPLEFT", 170+180, -28, 10, 128, 1, DefaultConfig[cat].fontSize, "Config."..cat..".fontSize")
    fontSizeSlider:SetWidth(150)
    local colorWidget = f:CreateColorOption("Text Color", "Custom text color for this event", f, "TOPLEFT", "TOPLEFT", 170+180+160, -30, DefaultConfig[cat].fontColor, "Config."..cat..".fontColor")
    if (cat:find("heal") == nil) then
        local clrDmgTypeCheckbox = f:CreateCheckbox("Color By Type", "Enables/Disables coloring damage text based on its type (alpha still taken from the text color below)", f, "TOPLEFT", "TOPLEFT", 480, 0, DefaultConfig[cat].colorByType, "Config."..cat..".colorByType")
    end
    local animPanel = {}
    animPanel.Pow = CreatePowAnimationPanel(f, cat, f, "TOPLEFT", "TOPLEFT", 0, -70)
    animPanel.FadeIn = CreateFadeInAnimationPanel(f, cat, f, "TOPLEFT", "TOPLEFT", 0, -70)
    animPanel.FadeOut = CreateFadeOutAnimationPanel(f, cat, f, "TOPLEFT", "TOPLEFT", 0, -70)
    animPanel.Scroll = CreateScrollAnimationPanel(f, cat, f, "TOPLEFT", "TOPLEFT", 0, -70)
    local animStatus = "init"
    local animStatusHeader = f:CreateHeader("Animation Status:"..animStatus, "GameFontHighlightSmall", f, "TOPLEFT", "TOPLEFT", 4, -100)
    animStatusHeader:SetJustifyH("LEFT")

    local function updateStatus()
        animStatus = ""
        for i,a in ipairs(AnimationsMenu) do
            local k = a.text
            animStatus = animStatus..(CFCT.Config[cat][a.value].enabled and "\n|cff00ff00"..k or "\n|cffff0000"..k).."|r"
        end
        animStatusHeader:SetText("Animation Status:"..animStatus)
    end

    for k,v in pairs(animPanel) do
        v.enabledCheckbox:HookScript("OnClick", function(self)
            updateStatus()
        end)
    end
    
    local function show(val)
        for k,v in pairs(animPanel) do
            if (k == val) then v:Show() else v:Hide() end
        end
    end

    local animHeader = f:CreateHeader("Animation Settings", "GameFontHighlightSmall", f, "TOPLEFT", "TOPLEFT", 4, -60)

    local animDropDown = f:CreateDropDownMenu("Animations", "Animations", f, "TOPLEFT", "TOPLEFT", -16, -70, AnimationsMenu, function(self, e, value)
        if (e == "Get") then
            return value
        elseif (e == "Set") then
            show(value)
        end
        updateStatus()
    end)
    animDropDown:HookScript("OnShow", function(self)
        show(self.curValue)
        updateStatus()
    end)

    return f
end

local function AddFrame(self, widget)
    n = self.widgetCount + 1
    self.widgets[n] = widget
    self.widgetCount = n
end

local function NewFrameID(self)
    return self:GetName().."_Frame" .. tostring(self.widgetCount + 1)
end

local function Refresh(self)
    if (self:IsShown()) then
        self:Hide()
        self:Show()
    end
end

local function EnableFrameTree(self)
    for _, e in ipairs(self.widgets) do
        if type(e.Enable) == 'function' then e:Enable() end
    end
end
local function DisableFrameTree(self)
    for _, e in ipairs(self.widgets) do
        if type(e.Disable) == 'function' then e:Disable() end
    end
end

local function CreateChildFrame(self, point1, point2, anchor, x, y, w, h)
    local f = CreateFrame("frame", self:NewFrameID(), self)
    self:AddFrame(f)
    f:SetPoint(point1, anchor, point2, x, y)
    f:SetSize(w,h)
    f:SetFrameLevel(1)
    f.widgets = {}
    f.widgetCount = 0
    f.CreateChildFrame = CreateChildFrame
    f.CreateHeader = CreateHeader
    f.CreateCheckbox = CreateCheckbox
    f.CreateButton = CreateButton
    f.CreateFontDropdown = CreateFontDropdown
    f.CreateDropDownMenu = CreateDropDownMenu
    f.CreateSlider = CreateSlider
    f.CreateColorOption = CreateColorOption
    f.AddFrame = AddFrame
    f.NewFrameID = NewFrameID
    f.Enable = EnableFrameTree
    f.Disable = DisableFrameTree
    f.Refresh = Refresh
    return f
end

local ScrollUpBtnOffsetX = UsesNewSettingsInterface and -15 or -6
local ScrollUpBtnOffsetY = UsesNewSettingsInterface and 8 or -2
local ScrollDnBtnOffsetX = UsesNewSettingsInterface and -15 or -6
local ScrollDnBtnOffsetY = UsesNewSettingsInterface and -1 or 2
local function CreateConfigPanel(name, parent, height)
    local Container = CreateFrame('frame', "ClassicFCTConfigPanel_"..gsub(name, " ", ""), UIParent)
    
    Container.name = name
    Container.parent = parent
    Container.CategoryID = name
    Container.refresh = Refresh
	Container.okay = function(self) end
	Container.cancel = function(self) end
    
    local sf = CreateFrame('ScrollFrame', Container:GetName().."_ScrollFrame", Container, "UIPanelScrollFrameTemplate")
    local sfname = sf:GetName()
    sf.scrollbar = getglobal(sfname.."ScrollBar")
    sf.scrollupbutton = getglobal(sfname.."ScrollBarScrollUpButton")
    sf.scrolldownbutton = getglobal(sfname.."ScrollBarScrollDownButton")

    sf.scrollupbutton:ClearAllPoints();
    sf.scrollupbutton:SetPoint("TOPLEFT", sf, "TOPRIGHT", ScrollUpBtnOffsetX, ScrollUpBtnOffsetY);
    
    sf.scrolldownbutton:ClearAllPoints();
    sf.scrolldownbutton:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", ScrollDnBtnOffsetX, ScrollDnBtnOffsetY);
    
    sf.scrollbar:ClearAllPoints();
    sf.scrollbar:SetPoint("TOP", sf.scrollupbutton, "BOTTOM", 0, -2);
    sf.scrollbar:SetPoint("BOTTOM", sf.scrolldownbutton, "TOP", 0, 2);
    
    if (UsesNewSettingsInterface) then
        Container.OnCommit = function(self)  end
        Container.OnDefault = function(self)  end
        Container.OnRefresh = function(self) Refresh(Container) end
        
        local Category, Layout
        if (parent == nil) then
            Category, Layout = Settings.RegisterCanvasLayoutCategory(Container, name)
            Settings.RegisterAddOnCategory(Category)
        else
            Category, Layout = Settings.RegisterCanvasLayoutSubcategory(Settings.GetCategory(parent), Container, name)
        end
        Container.CategoryID = Category:GetID()
    else
        InterfaceOptions_AddCategory(Container)
    end
    
        
    CFCT.ConfigPanels[#CFCT.ConfigPanels + 1] = Container
    -- Container:HookScript("OnShow")
    Container:SetAllPoints()
    Container:Hide()

    local p = CreateFrame("Frame", Container:GetName().."_ScrollChild")
    p.refresh = function(self) Container:refresh() end 
    p.widgets = {}
    p.widgetCount = 0
    p.CreateSubPanel = function(self, name, height)
        return CreateConfigPanel(name, Container.CategoryID, height)
    end
    p.CreateChildFrame = CreateChildFrame
    p.CreateCategoryPanel = CreateCategoryPanel
    p.CreateHeader = CreateHeader
    p.CreateCheckbox = CreateCheckbox
    p.CreateButton = CreateButton
    p.CreateFontDropdown = CreateFontDropdown
    p.CreateDropDownMenu = CreateDropDownMenu
    p.CreateSlider = CreateSlider
    p.CreateColorOption = CreateColorOption
    p.AddFrame = AddFrame
    p.NewFrameID = NewFrameID
    Container.panel = p
    p.Container = Container
    sf:SetScrollChild(p)
    sf:SetAllPoints()
    p:HookScript("OnShow", function(self) self:SetSize(sf:GetWidth(), height or sf:GetHeight()) end)
    return p
end



--ConfigPanel Layout

local ConfigPanel = CreateConfigPanel("ClassicFCT", nil, 800)
CFCT.ConfigPanel = ConfigPanel
local headerGlobal = ConfigPanel:CreateHeader("", "GameFontNormalLarge", ConfigPanel, "TOPLEFT", "TOPLEFT", 16, -16)
local charSpecificCheckbox = ConfigPanel:CreateCheckbox("Character Specific Config", "Settings are saved per character. Presets stay global.", headerGlobal, "LEFT", "LEFT", 0, -2, DefaultVars.characterSpecificConfig, function(self, e, value)
    if (e == "Get") then
        return CFCT.characterSpecificConfig == nil and value or CFCT.characterSpecificConfig
    elseif (e == "Set") then
        CFCT.Config:OnSave()
        CFCT.characterSpecificConfig = value
        ClassicFCTVars.characterSpecificConfig = value
        CFCT.Config:OnLoad()
        ConfigPanel:refresh()
    end
end)
local enabledCheckbox = ConfigPanel:CreateCheckbox("Enable ClassicFCT", "Enables/Disables the addon", charSpecificCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, -2, DefaultVars.enabled, "enabled")

local hideBlizzDamageCheckbox = ConfigPanel:CreateCheckbox("Hide Blizzard Damage", "Enables/Disables the default Blizzard Floating Damage Text", enabledCheckbox, "LEFT", "RIGHT", 150, 0, DefaultVars.hideBlizz, "hideBlizz")
hideBlizzDamageCheckbox:HookScript("OnClick", function(self)
    SetCVar("floatingCombatTextCombatDamage", self:GetChecked() and "0" or "1")
end)
if (GetCVarDefault("floatingCombatTextCombatDamage") == nil) then hideBlizzDamageCheckbox:Hide() end

local hideBlizzHealingCheckbox = ConfigPanel:CreateCheckbox("Hide Blizzard Healing", "Enables/Disables the default Blizzard Floating Healing Text", hideBlizzDamageCheckbox, "LEFT", "RIGHT", 150, 0, DefaultVars.hideBlizzHeals, "hideBlizzHeals")
hideBlizzHealingCheckbox:HookScript("OnClick", function(self)
    SetCVar("floatingCombatTextCombatHealing", self:GetChecked() and "0" or "1")
end)
if (GetCVarDefault("floatingCombatTextCombatHealing") == nil) then hideBlizzDamageCheckbox:Hide() end

local headerPresets = ConfigPanel:CreateHeader("Config Presets", "GameFontNormalLarge", headerGlobal, "TOPLEFT", "BOTTOMLEFT", 0, -46)
local newPresetBtn = ConfigPanel:CreateButton("New", "Creates a new preset", headerPresets, "TOPLEFT", "TOPRIGHT", 94, 0, function()
    CFCT.Config:CreatePreset()
end)
local copyPresetBtn = ConfigPanel:CreateButton("Copy", "Creates a copy of the selected preset", newPresetBtn, "TOPLEFT", "BOTTOMLEFT", 0, 0, function()
    CFCT.Config:CreatePresetCopy(CFCT.selectedPreset)
end)



local PresetMenu = {{}}
local presetDropDown = ConfigPanel:CreateDropDownMenu("Presets", "Configuration Presets", newPresetBtn, "LEFT", "RIGHT", -10, 0, PresetMenu, function(self, e, value)
    if (e == "Get") then
        return CFCT.selectedPreset == nil and value or CFCT.selectedPreset
    elseif (e == "Set") then
        CFCT.selectedPreset = value
    end
end)

local savePresetBtn = ConfigPanel:CreateButton("Save", "Saves current configuration into the selected preset", presetDropDown.middle, "BOTTOMRIGHT", "BOTTOM", 0, -2, function()
    CFCT.Config:SavePreset(CFCT.selectedPreset)
end)
savePresetBtn:SetWidth(84)
local loadPresetBtn = ConfigPanel:CreateButton("Load", "Loads the selected preset, overwriting current configuration", presetDropDown.middle, "BOTTOMLEFT", "BOTTOM", 0, -2, function()
    CFCT.Config:LoadPreset(CFCT.selectedPreset)
end)
loadPresetBtn:SetWidth(84)
local deletePresetBtn = ConfigPanel:CreateButton("Delete", "Deletes the selected preset permanently", presetDropDown, "LEFT", "RIGHT", presetDropDown.middle:GetWidth(), 0, function()
    CFCT.Config:DeletePreset(CFCT.selectedPreset)
end)
local renamePresetBtn = ConfigPanel:CreateButton("Rename", "Renames the selected preset", deletePresetBtn, "TOPLEFT", "BOTTOMLEFT", 0, 0, function()
    CFCT.Config:RenamePreset(CFCT.selectedPreset)
end)

presetDropDown:HookScript("OnShow", function(self)
    wipe(PresetMenu)
    for k,v in pairs(DefaultPresets) do
        table.insert(PresetMenu, {
            text = k.." |cff808080built-in|r",
            value = k
        })
    end
    for k,v in pairs(CFCT.Presets) do
        if (DefaultPresets[k] == nil) then
            table.insert(PresetMenu, {
                text = k,
                value = k
            })
        end
    end
    if (CFCT.Presets[CFCT.selectedPreset] == nil) then
        CFCT.selectedPreset = PresetMenu[1].value
    end
    self.curValue = CFCT.selectedPreset
    local dropDownText
    for k,v in pairs(PresetMenu) do if (v.value == self.curValue) then dropDownText = v.text end end
    getglobal(self:GetName().."Text"):SetText(dropDownText)
    if (DefaultPresets[self.curValue]) then
        savePresetBtn:Disable()
        deletePresetBtn:Disable()
        renamePresetBtn:Disable()
        savePresetBtn:Disable()
    else
        savePresetBtn:Enable()
        deletePresetBtn:Enable()
        renamePresetBtn:Enable()
        savePresetBtn:Enable()
    end
end)










local headerGeneralSettings = ConfigPanel:CreateHeader("General Settings", "GameFontNormalLarge", headerPresets, "TOPLEFT", "BOTTOMLEFT", 0, -32)

local animDurationSlider = ConfigPanel:CreateSlider("Animation Duration", "Animation length in seconds", headerGeneralSettings, "TOPLEFT", "BOTTOMLEFT", 20, -24, 0.1, 5.0, 0.1, DefaultConfig.animDuration, "Config.animDuration")
local textPosOptionsHeader = ConfigPanel:CreateHeader("Text Position Options", "GameFontNormalLarge", headerGeneralSettings, "TOPLEFT", "BOTTOMLEFT", 0, -64)

local attachModeHeader = ConfigPanel:CreateHeader("Attach Text To", "GameFontHighlightSmall", textPosOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -16)
local attachModeDropDown = ConfigPanel:CreateDropDownMenu("Attach Mode", "", attachModeHeader, "LEFT", "LEFT", 64, -3, AttachModesMenu, "Config.attachMode")
attachModeDropDown.middle:SetWidth(110)

local fallbackCheckbox = ConfigPanel:CreateCheckbox("Attachment Fallback", "When a nameplate isnt available, the text will temporarily attach to the screen center instead", attachModeDropDown.right, "LEFT", "RIGHT", -10, 0, DefaultConfig.attachModeFallback, "Config.attachModeFallback")
local overlapCheckbox = ConfigPanel:CreateCheckbox("Prevent Text Overlap", "Prevents damage text frames from overlapping each other", fallbackCheckbox, "LEFT", "RIGHT", 132, 0, DefaultConfig.preventOverlap, "Config.preventOverlap")

local dontOverlapNameplates = ConfigPanel:CreateCheckbox("Nameplates In Front", "Show text behind the nameplates", fallbackCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.dontOverlapNameplates, "Config.dontOverlapNameplates")
local inheritNameplates = ConfigPanel:CreateCheckbox("Inherit From Nameplates", "Text inherits some atributes from nameplates, like visibility and scale", overlapCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.inheritNameplates, "Config.inheritNameplates")


local areaSliderX = ConfigPanel:CreateSlider("Screen Center Text X Offset", "Horizontal offset of animation area", attachModeHeader, "TOPLEFT", "BOTTOMLEFT", 0, -48, -700, 700, 1, DefaultConfig.areaX, "Config.areaX")
local areaSliderY = ConfigPanel:CreateSlider("Screen Center Text Y Offset", "Vertical offset of animation area", areaSliderX, "LEFT", "RIGHT", 16, 0, -400, 400, 1, DefaultConfig.areaY, "Config.areaY")
local areaSliderNX = ConfigPanel:CreateSlider("Nameplate Text X Offset", "Horizontal offset of animation area", areaSliderX, "TOPLEFT", "BOTTOMLEFT", 0, -28, -400, 400, 1, DefaultConfig.areaNX, "Config.areaNX")
local areaSliderNY = ConfigPanel:CreateSlider("Nameplate Text Y Offset", "Vertical offset of animation area", areaSliderNX, "LEFT", "RIGHT", 16, 0, -400, 400, 1, DefaultConfig.areaNY, "Config.areaNY")
local spacingSliderX = ConfigPanel:CreateSlider("Anti-Overlap Horizontal Spacing", "Horizontal spacing between text", areaSliderNX, "TOPLEFT", "BOTTOMLEFT", 0, -28, 0, 200, 1, DefaultConfig.preventOverlapSpacingX, "Config.preventOverlapSpacingX")
local spacingSliderY = ConfigPanel:CreateSlider("Anti-Overlap Vertical Spacing", "Vertical spacing between text", spacingSliderX, "LEFT", "RIGHT", 16, 0, 0, 200, 1, DefaultConfig.preventOverlapSpacingY, "Config.preventOverlapSpacingY")


-- Spell Icon Options - Credit: https://github.com/akbyrd
local spellIconOptionsHeader = ConfigPanel:CreateHeader("Spell Icon Options", "GameFontNormalLarge", textPosOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -200)
local iconOffsetSliderX = ConfigPanel:CreateSlider("X Offset", "Horizontal offset of spell icon", spellIconOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -24, -20, 20, 1, DefaultConfig.spellIconOffsetX, "Config.spellIconOffsetX")
local iconOffsetSliderY = ConfigPanel:CreateSlider("Y Offset", "Vertical offset of spell icon", iconOffsetSliderX, "LEFT", "RIGHT", 16, 0, -20, 20, 1, DefaultConfig.spellIconOffsetY, "Config.spellIconOffsetY")
local iconZoomSlider = ConfigPanel:CreateSlider("Zoom", "Zoom in on the icon and trim to edge to give a more square appearance", iconOffsetSliderX, "TOPLEFT", "BOTTOMLEFT", 0, -28, 1, 2, 0.01, DefaultConfig.spellIconZoom, "Config.spellIconZoom")
local iconAspectRatioSlider = ConfigPanel:CreateSlider("Aspect Ratio", "Aspect ratio of spell icon", iconZoomSlider, "LEFT", "RIGHT", 16, 0, 1, 2, 0.01, DefaultConfig.spellIconAspectRatio, "Config.spellIconAspectRatio")



local textFormatOptionsHeader = ConfigPanel:CreateHeader("Number Formatting Options", "GameFontNormalLarge", spellIconOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -108)
local abbrevCheckbox = ConfigPanel:CreateCheckbox("Abbreviate Large Numbers", "Abbreviate large numbers (ex.1K)", textFormatOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -8, DefaultConfig.abbreviateNumbers, "Config.abbreviateNumbers")
local kiloSepCheckbox = ConfigPanel:CreateCheckbox("Add Thousands Separator", "Add thousands separator (ex.100,000,000)", abbrevCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.kiloSeparator, "Config.kiloSeparator")

local filteringOptionsHeader = ConfigPanel:CreateHeader("Filtering Options", "GameFontNormalLarge", textFormatOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -64)
local absoluteFilterCheckbox = ConfigPanel:CreateCheckbox("Hide Below Absolute Threshold", "Hide numbers smaller than an absolute value", filteringOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -8, DefaultConfig.filterAbsoluteEnabled, "Config.filterAbsoluteEnabled")
local absoluteThresholdSlider = ConfigPanel:CreateSlider("Absolute Threshold", "Absolute Value", absoluteFilterCheckbox, "LEFT", "RIGHT", 256, 0, 0, 10000, 1, DefaultConfig.filterAbsoluteThreshold, "Config.filterAbsoluteThreshold")
local relativeFilterCheckbox = ConfigPanel:CreateCheckbox("Hide Below Relative Threshold", "Hide numbers smaller than a percentage of player health", absoluteFilterCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, -20, DefaultConfig.filterRelativeEnabled, "Config.filterRelativeEnabled")
local relativeThresholdSlider = ConfigPanel:CreateSlider("% of Max Player Health", "Percentage of Max Player Health", relativeFilterCheckbox, "LEFT", "RIGHT", 256, 0, 0, 100, 0.1, DefaultConfig.filterRelativeThreshold, "Config.filterRelativeThreshold")
local relativeThresholdTimer = 0
relativeThresholdSlider:HookScript("OnUpdate", function(self)
    if not self:IsShown() then return end
    local now = GetTime()
    if ((now - relativeThresholdTimer) > 0.1) then
        getglobal(self:GetName() .. 'Text'):SetText("% of Max Player Health ("..tostring(floor(CFCT:UnitHealthMax('player') * 0.01 * CFCT.Config.filterRelativeThreshold))..")")
        relativeThresholdTimer = now
    end
end)
local averageFilterCheckbox = ConfigPanel:CreateCheckbox("Hide Below Average Threshold", "Hide numbers smaller than a percentage of average damage", relativeFilterCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, -20, DefaultConfig.filterAverageEnabled, "Config.filterAverageEnabled")
local averageThresholdSlider = ConfigPanel:CreateSlider("% of Average Damage/Healing", "Percentage of Average Damage/Healing", averageFilterCheckbox, "LEFT", "RIGHT", 256, 0, 0, 200, 0.1, DefaultConfig.filterAverageThreshold, "Config.filterAverageThreshold")
local averageThresholdTimer = 0
averageThresholdSlider:HookScript("OnUpdate", function(self)
    if not self:IsShown() then return end
    local now = GetTime()
    if ((now - averageThresholdTimer) > 0.1) then
        getglobal(self:GetName() .. 'Text'):SetText("% of Average Damage/Healing ("..tostring(floor(CFCT:DamageRollingAverage() * 0.01 * CFCT.Config.filterAverageThreshold))..")")
        averageThresholdTimer = now
    end
end)
local filterMissesCheckbox = ConfigPanel:CreateCheckbox("Hide Misses", "Hides Absorb, Block, Miss, Parry, Dodge, Deflect, Evade, Immune, Reflect and Resist.", averageFilterCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, -20, DefaultConfig.filterMissesEnabled, "Config.filterMissesEnabled")

local filteringBlacklistDropdown
local filteringBlacklistCheckbox
local FilteringBlacklistMenu = {{}}
local filteringBlacklistHeader = ConfigPanel:CreateHeader("SpellId Blacklist", "GameFontHighlightSmall", averageThresholdSlider, "TOPLEFT", "BOTTOMLEFT", 0, -30)

filteringBlacklistDropdown = ConfigPanel:CreateDropDownMenu("SpellId Blacklist", "", filteringBlacklistHeader, "LEFT", "LEFT", 68, -3, FilteringBlacklistMenu, function(self, e, value)
    if (e == "Get") then
        return value
    elseif (e == "Set") then
        for k,v in pairs(CFCT.Config.filterSpellBlacklist) do
            if (self.curValue == k) then
                filteringBlacklistCheckbox:SetChecked(v)
                return
            end
        end
        filteringBlacklistCheckbox:SetChecked(false)
    end
end)
filteringBlacklistDropdown.middle:SetWidth(170)

filteringBlacklistDropdown:HookScript("OnShow", function(self)
    wipe(FilteringBlacklistMenu)
    local spellIdTable = CFCT.Config.filterSpellBlacklist
    local color = "FFFFFF"
    for k,v in pairs(spellIdTable) do
        local spell = GetSpellInfo(k)
        if spell.name then
            CFCT.spellIdCache[k] = true
            table.insert(FilteringBlacklistMenu, {
                text = format("|T%s:12:12:0:0:120:120:10:110:10:110|t|cff%s%s(%d)|r", spell.iconID, color, spell.name, k),
                value = k
            })
        end
    end
    color = "808080"
    for k,v in pairs(CFCT.spellIdCache) do
        if (spellIdTable[k] == nil) then
            local spell = GetSpellInfo(k)
            if spell.name then
                table.insert(FilteringBlacklistMenu, {
                    text = format("|T%s:12:12:0:0:120:120:10:110:10:110|t|cff%s%s(%d)|r", spell.iconID, color, spell.name, k),
                    value = k
                })
            end
        end
    end
    if (self.curValue == nil) then 
        for k,v in pairs(spellIdTable) do
            self.curValue = k
            break
        end
    end
    if (self.curValue == nil) then 
        for k,v in pairs(CFCT.spellIdCache) do
            self.curValue = k
            break
        end
    end
    local dropDownText
    for k,v in pairs(FilteringBlacklistMenu) do
        if (v.value == self.curValue) then
            dropDownText = v.text
            break
        end
    end
    -- print(self.curValue, dropDownText)
    if (dropDownText) then
        self.Button:Enable()
        filteringBlacklistCheckbox:Enable()
    else
        self.Button:Disable()
        filteringBlacklistCheckbox:Disable()
    end
    getglobal(self:GetName().."Text"):SetText(dropDownText or "Empty: Attack a Dummy")
end)
filteringBlacklistCheckbox = ConfigPanel:CreateCheckbox("Disable By SpellId", "Stop the selected spell from showing in the damage text", filteringBlacklistDropdown, "TOPLEFT", "BOTTOMLEFT", 16, 0, false, function(self, e, value)
    local spellIdTable = CFCT.Config.filterSpellBlacklist
    if (e == "Get") then
        local spellid = filteringBlacklistDropdown.curValue
        if spellid then
            spellval = spellIdTable[spellid]
            if spellval then
                return spellval
            end
        end
        return false
    elseif (e == "Set") then
        local spellid = filteringBlacklistDropdown.curValue
        if spellid then
            if (value == false) then
                spellIdTable[spellid] = nil
            else
                spellIdTable[spellid] = value
            end
            filteringBlacklistDropdown:Hide()
            filteringBlacklistDropdown:Show()
        end
    end
end)


local sortingOptionsHeader = ConfigPanel:CreateHeader("Sorting Options", "GameFontNormalLarge", filteringOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -200)
local sortByDamageCheckbox = ConfigPanel:CreateCheckbox("Sort By Damage/Healing in Descending Order", "Sort events by amount", sortingOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -8, DefaultConfig.sortByDamage, "Config.sortByDamage")

local merginOptionsHeader = ConfigPanel:CreateHeader("Merging Options", "GameFontNormalLarge", sortingOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -40)
local mergingEnabledCheckbox = ConfigPanel:CreateCheckbox("Merge Events", "Combine damage/healings events with the same spellid into one event", merginOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -8, DefaultConfig.mergeEvents, "Config.mergeEvents")

local mergingIntervalOverrideDropdown
local mergingOverrideIntervalSlider
local mergingOverrideIntervalResetButton
local MergeIntervalOverrideMenu = {{}}
local mergingIntervalSlider = ConfigPanel:CreateSlider("Global Merge Interval", "Max time interval between events for a merge to happen (in seconds)", mergingEnabledCheckbox, "LEFT", "RIGHT", 256, 0, 0.01, 5, 0.01, DefaultConfig.mergeEventsInterval, function(self, e, value)
    if (e == "Get") then
        return CFCT.Config.mergeEventsInterval == nil and value or CFCT.Config.mergeEventsInterval
    elseif (e == "Set") then
        CFCT.Config.mergeEventsInterval = value
        local id = mergingIntervalOverrideDropdown.curValue
        if id and (CFCT.Config.mergeEventsIntervalOverrides[id] == nil) then
            mergingOverrideIntervalSlider:SetValue(value)
        end
    end
end)
local mergingCountCheckbox = ConfigPanel:CreateCheckbox("Show Merge Count", "Add number of merged events next to the damage/healing (ex '1337 x5')", mergingEnabledCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.mergeEventsCounter, "Config.mergeEventsCounter")
local intervalModeHeader = ConfigPanel:CreateHeader("Relative To", "GameFontHighlightSmall", mergingIntervalSlider, "TOPLEFT", "BOTTOMLEFT", 0, -24)
local intervalModeDropDown = ConfigPanel:CreateDropDownMenu("Relative To", "", intervalModeHeader, "LEFT", "LEFT", 68, -3, MergeIntervalModeMenu, "Config.mergeEventsIntervalMode")
intervalModeDropDown.middle:SetWidth(170)

local mergingIntervalOverrideHeader = ConfigPanel:CreateHeader("SpellId Override", "GameFontHighlightSmall", mergingIntervalSlider, "TOPLEFT", "BOTTOMLEFT", 0, -60)



mergingIntervalOverrideDropdown = ConfigPanel:CreateDropDownMenu("SpellId Override", "", mergingIntervalOverrideHeader, "LEFT", "LEFT", 68, -3, MergeIntervalOverrideMenu, function(self, e, value)
    if (e == "Get") then
        return value
    elseif (e == "Set") then
        for k,v in pairs(CFCT.Config.mergeEventsIntervalOverrides) do
            if (self.curValue == k) then
                mergingOverrideIntervalSlider:SetValue(v)
                return
            end
        end
        mergingOverrideIntervalSlider:SetValue(CFCT.Config.mergeEventsInterval)
    end
end)
mergingIntervalOverrideDropdown.middle:SetWidth(170)
mergingIntervalOverrideDropdown:HookScript("OnShow", function(self)
    wipe(MergeIntervalOverrideMenu)
    local spellIdTable = CFCT.Config.mergeEventsIntervalOverrides
    local color = "FFFFFF"
    for k,v in pairs(spellIdTable) do
        local spell = GetSpellInfo(k)
        if spell.name then
            CFCT.spellIdCache[k] = true
            table.insert(MergeIntervalOverrideMenu, {
                text = format("|T%s:12:12:0:0:120:120:10:110:10:110|t|cff%s%s(%d)|r", spell.iconID, color, spell.name, k),
                value = k
            })
        end
    end
    color = "808080"
    for k,v in pairs(CFCT.spellIdCache) do
        if (spellIdTable[k] == nil)then
            local spell = GetSpellInfo(k)
            if spell.name then
                table.insert(MergeIntervalOverrideMenu, {
                    text = format("|T%s:12:12:0:0:120:120:10:110:10:110|t|cff%s%s(%d)|r", spell.iconID, color, spell.name, k),
                    value = k
                })
            end
        end
    end
    if (self.curValue == nil) then 
        for k,v in pairs(spellIdTable) do
            self.curValue = k
            break
        end
    end
    if (self.curValue == nil) then 
        for k,v in pairs(CFCT.spellIdCache) do
            self.curValue = k
            break
        end
    end
    local dropDownText
    for k,v in pairs(MergeIntervalOverrideMenu) do
        if (v.value == self.curValue) then
            dropDownText = v.text
            break
        end
    end
    -- print(self.curValue, dropDownText)
    if (dropDownText) then
        self.Button:Enable()
        mergingOverrideIntervalSlider:Enable()
        mergingOverrideIntervalSlider.valueBox:Enable()
    else
        self.Button:Disable()
        mergingOverrideIntervalSlider:Disable()
        mergingOverrideIntervalSlider.valueBox:Disable()
        mergingOverrideIntervalResetButton:Disable()
    end
    getglobal(self:GetName().."Text"):SetText(dropDownText or "Empty: Attack a Dummy")
end)

mergingOverrideIntervalSlider = ConfigPanel:CreateSlider("Override Merge Interval", "Max time interval between chosen spell events for a merge to happen (in seconds)", mergingIntervalOverrideHeader, "TOPLEFT", "BOTTOMLEFT", 0, -20, 0.01, 5, 0.01, DefaultConfig.mergeEventsInterval, function(self, e, value)
    local spellIdTable = CFCT.Config.mergeEventsIntervalOverrides
    if (e == "Get") then
        local spellid = mergingIntervalOverrideDropdown.curValue
        if spellid then
            spellval = spellIdTable[spellid]
            if spellval then
                return spellval
            end
        end
        return CFCT.Config.mergeEventsInterval == nil and value or CFCT.Config.mergeEventsInterval
    elseif (e == "Set") then
        local spellid = mergingIntervalOverrideDropdown.curValue
        if spellid then
            if (value == CFCT.Config.mergeEventsInterval) then
                spellIdTable[spellid] = nil
                mergingOverrideIntervalResetButton:Disable()
            else
                spellIdTable[spellid] = value
                mergingOverrideIntervalResetButton:Enable()
            end
            mergingIntervalOverrideDropdown:Hide()
            mergingIntervalOverrideDropdown:Show()
        end
    end
end)
mergingOverrideIntervalResetButton = ConfigPanel:CreateButton("Reset", "Restores chosen spell merge interval to a common setting", mergingOverrideIntervalSlider, "TOPRIGHT", "BOTTOMRIGHT", -10, 3, function()
    local id = mergingIntervalOverrideDropdown.curValue
    if id then
        mergingOverrideIntervalSlider:SetValue(CFCT.Config.mergeEventsInterval)
    end
end)
mergingOverrideIntervalResetButton:SetFrameLevel(mergingOverrideIntervalSlider:GetFrameLevel()+1)


local mergingMissesCheckbox = ConfigPanel:CreateCheckbox("Separate Misses", "Dont merge dodges, parries, misses, and evades with damage events", mergingCountCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.mergeEventsMisses, "Config.mergeEventsMisses")
local mergingByGuidCheckbox = ConfigPanel:CreateCheckbox("Separate By Target", "Dont merge damage done to different targets", mergingMissesCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.mergeEventsByGuid, "Config.mergeEventsByGuid")
local mergingByIDCheckbox = ConfigPanel:CreateCheckbox("Separate By Spell ID", "Dont merge damage with different spellids", mergingByGuidCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.mergeEventsBySpellID, "Config.mergeEventsBySpellID")
local mergingByIconCheckbox = ConfigPanel:CreateCheckbox("Separate By Spell Icon", "Dont merge damage with different icons", mergingByIDCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.mergeEventsBySpellIcon, "Config.mergeEventsBySpellIcon")
local mergingByTypeCheckbox = ConfigPanel:CreateCheckbox("Separate By Damage Type", "Dont merge damage of different types", mergingByIconCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.mergeEventsBySchool, "Config.mergeEventsBySchool")

-- damage type colors
local colorTableHeader = ConfigPanel:CreateHeader("Damage Type Colors", "GameFontNormalLarge", merginOptionsHeader, "TOPLEFT", "TOPLEFT", 0, -220)
local colorTableFrame = ConfigPanel:CreateChildFrame("TOPLEFT", "BOTTOMLEFT", colorTableHeader, 0, 10, 500, 200)
local colorTableX, colorTableY, colorTableCounter = 20, 0, 0

for k,v in pairs(SCHOOL_NAMES) do
    colorTableCounter = colorTableCounter + 1
    if (colorTableY < -150) then
        colorTableX = colorTableX + 150
        colorTableY = 0
    end
    colorTableY = colorTableY - 20
    local colorWidget = colorTableFrame:CreateColorOption(v, "Custom text color for this type", colorTableFrame, "TOPLEFT", "TOPLEFT", colorTableX, colorTableY, DefaultConfig.colorTable[k], function(self, e, value)
        if (e == "Get") then
            return CFCT.Config.colorTable[k]
        else
            CFCT.Config.colorTable[k] = value
        end
    end)
end

-- damage over time type colors
local colorTableDotHeader = ConfigPanel:CreateHeader("Override Type Colors for Damage Over Time", "GameFontNormalLarge", colorTableHeader, "TOPLEFT", "TOPLEFT", 0, -200)
local colorTableDotFrame = ConfigPanel:CreateChildFrame("TOPLEFT", "BOTTOMLEFT", colorTableDotHeader, 0, -20, 500, 200)

local colorTableDotCheckbox = ConfigPanel:CreateCheckbox("Enabled", "Use separate type colors for damage over time", colorTableDotHeader, "TOPLEFT", "BOTTOMLEFT", 20, -8, DefaultConfig.colorTableDotEnabled, function(self, e, value)
    if (e == "Get") then
        local val = CFCT.Config.colorTableDotEnabled
        if (val == true) then
            colorTableDotFrame:Enable()
        else
            colorTableDotFrame:Disable()
        end
        return val
    else
        if (value == true) then
            colorTableDotFrame:Enable()
        else
            colorTableDotFrame:Disable()
        end
        CFCT.Config.colorTableDotEnabled = value
    end
end)

local copyTypeColorsBtn = ConfigPanel:CreateButton("Copy From Above", "Copies color settings from the damage types above", colorTableDotCheckbox, "LEFT", "RIGHT", 190, 0, function()
    CFCT:ConfirmAction("This will overwrite all color settings below.", function()
        for k,v in pairs(SCHOOL_NAMES) do
            CFCT.Config.colorTableDot[k] = CFCT.Config.colorTable[k]
        end
        colorTableDotFrame:Refresh()
    end)
end)


copyTypeColorsBtn:SetWidth(120)
local colorTableDotX, colorTableDotY, colorTableDotCounter = 20, 0, 0

for k,v in pairs(SCHOOL_NAMES) do
    colorTableDotCounter = colorTableDotCounter + 1
    if (colorTableDotY < -150) then
        colorTableDotX = colorTableDotX + 150
        colorTableDotY = 0
    end
    colorTableDotY = colorTableDotY - 20
    local colorWidget = colorTableDotFrame:CreateColorOption(v, "Custom text color for this type", colorTableDotFrame, "TOPLEFT", "TOPLEFT", colorTableDotX, colorTableDotY, DefaultConfig.colorTableDot[k], function(self, e, value)
        if (e == "Get") then
            return CFCT.Config.colorTableDot[k]
        else
            CFCT.Config.colorTableDot[k] = value
        end
    end)
end


local CONFIG_LAYOUT = {
    {
        catname = "Auto Attacks",
        subcatlist = {
            "auto",
            "autocrit",
            "automiss"
        }
    },
    {
        catname = "Special Attacks",
        subcatlist = {
            "spell",
            "spellcrit",
            "spellmiss"
        }
    },
    {
        catname = "Damage Over Time",
        subcatlist = {
            "spelltick",
            "spelltickcrit",
            "spelltickmiss"
        }
    },
    {
        catname = "Heals",
        subcatlist = {
            "heal",
            "healcrit",
            "healmiss"
        }
    },
    {
        catname = "Heals Over Time",
        subcatlist = {
            "healtick",
            "healtickcrit",
            "healtickmiss"
        }
    },
    {
        catname = "Pet Auto Attacks",
        subcatlist = {
            "petauto",
            "petautocrit",
            "petautomiss"
        }
    },
    {
        catname = "Pet Special Attacks",
        subcatlist = {
            "petspell",
            "petspellcrit",
            "petspellmiss"
        }
    },
    {
        catname = "Pet Damage Over Time",
        subcatlist = {
            "petspelltick",
            "petspelltickcrit",
            "petspelltickmiss"
        }
    },
    {
        catname = "Pet Heals",
        subcatlist = {
            "petheal",
            "pethealcrit",
            "pethealmiss"
        }
    },
    {
        catname = "Pet Heals Over Time",
        subcatlist = {
            "pethealtick",
            "pethealtickcrit",
            "pethealtickmiss"
        }
    }
}

ConfigPanel:HookScript("OnShow", function(self) CFCT._testMode = true end)
ConfigPanel:HookScript("OnHide", function(self) CFCT._testMode = false end)
for _, cat in ipairs(CONFIG_LAYOUT) do
    local subpanel = ConfigPanel:CreateSubPanel(cat.catname)
    subpanel:HookScript("OnShow", function(self) CFCT._testMode = true end)
    subpanel:HookScript("OnHide", function(self) CFCT._testMode = false end)
    local parent = nil
    for _, subcat in ipairs(cat.subcatlist) do
        if not parent then
            parent = subpanel:CreateCategoryPanel(subcat, subpanel, "TOPLEFT", "TOPLEFT", 6, -6)
        else
            parent = subpanel:CreateCategoryPanel(subcat, parent, "TOPLEFT", "BOTTOMLEFT", 0, -6)
        end
    end
end


