local addonName, CFCT = ...
CFCT._DefaultPresets = {}
function CFCT:GetDefaultPresets()
    return self._DefaultPresets
end
function CFCT:AddDefaultPreset(name, config)
    if self._DefaultPresets[name] == nil then
        self._DefaultPresets[name] = config
    else
        CFCT:Log("Preset '"..name.."' already exists.")
    end
end
