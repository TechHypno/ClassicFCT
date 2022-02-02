local addonName, CFCT = ...
CFCT:AddDefaultPreset("Classic", {
    animSpeed = 1,
    animDuration = 1.5,
    areaX = 0,
    areaY = 150,
    areaNX = 0,
    areaNY = 0,
    textStrata = "MEDIUM",
    dontOverlapNameplates = false,
    inheritNameplates = false,
    preventOverlap = true,
    preventOverlapSpacingX = 30,
    preventOverlapSpacingY = 50,
    attachMode = "tn",
    attachModeFallback = true,
    spellIconOffsetX = 0,
    spellIconOffsetY = 0,
    spellIconZoom = 1,
    spellIconAspectRatio = 1,
    abbreviateNumbers = false,
    kiloSeparator = false,
    filterAbsoluteEnabled = false,
    filterAbsoluteThreshold = 100,
    filterRelativeEnabled = false,
    filterRelativeThreshold = 10,
    filterAverageEnabled = false,
    filterAverageThreshold = 10,
    filterMissesEnabled = false,
    sortByDamage = false,
    sortMissPrio = false,
    mergeEvents = false,
    mergeEventsInterval = 0.1,
    mergeEventsIntervalMode = "last",
    mergeEventsCounter = true,
    mergeEventsByGuid = false,
    mergeEventsBySpellID = false,
    mergeEventsBySpellIcon = true,
    mergeEventsBySchool = true,
    mergeEventsMisses = false,
    colorTable = {
        -- Single Schools
        [Enum.Damageclass.MaskPhysical]	    = "ffff0000",
        [Enum.Damageclass.MaskHoly]		    = "ffffffb6",
        [Enum.Damageclass.MaskFire]		    = "ffff432c",
        [Enum.Damageclass.MaskNature]	    = "ff3c9742",
        [Enum.Damageclass.MaskFrost]	    = "ff00abff",
        [Enum.Damageclass.MaskShadow]	    = "ff9500b6",
        [Enum.Damageclass.MaskArcane]	    = "ffdd4aff",
        -- Physical and a Magical
        [Enum.Damageclass.MaskFlamestrike]	= "ffff8879",
        [Enum.Damageclass.MaskFroststrike]	= "ff7dd5ff",
        [Enum.Damageclass.MaskSpellstrike]	= "ffa8caff",
        [Enum.Damageclass.MaskStormstrike]	= "ffa1eaa3",
        [Enum.Damageclass.MaskShadowstrike]	= "ffa89cff",
        [Enum.Damageclass.MaskHolystrike]	= "ffffffe6",
        -- Two Magical Schools
        [Enum.Damageclass.MaskFrostfire]	= "ffff64ab",
        [Enum.Damageclass.MaskSpellfire]	= "ffff4d5c",
        [Enum.Damageclass.MaskFirestorm]	= "ffdfcfb6",
        [Enum.Damageclass.MaskShadowflame]	= "ffb92334",
        [Enum.Damageclass.MaskHolyfire]		= "ffffca68",
        [Enum.Damageclass.MaskSpellfrost]	= "ff828ffd",
        [Enum.Damageclass.MaskFroststorm]	= "ff5de1de",
        [Enum.Damageclass.MaskShadowfrost]	= "ff3a00e5",
        [Enum.Damageclass.MaskHolyfrost]	= "ffbffffc",
        [Enum.Damageclass.MaskSpellstorm]	= "ff3f45ff",
        [Enum.Damageclass.MaskSpellshadow]	= "ff0009ff",
        [Enum.Damageclass.MaskDivine]		= "fffff9ed",
        [Enum.Damageclass.MaskShadowstorm]	= "ff462b68",
        [Enum.Damageclass.MaskHolystorm]	= "ffe9ffa9",
        [Enum.Damageclass.MaskTwilight]	    = "ff242d8d",
        -- Three or more schools
        [Enum.Damageclass.MaskElemental]	= "ffffa500",
        [Enum.Damageclass.MaskChromatic]    = "ffffffff",
        [Enum.Damageclass.MaskMagical]      = "ff97f4ff",
        [Enum.Damageclass.MaskChaos]        = "ff8000ff"
    },
    colorTableDotEnabled = false,
    colorTableDot = {
        -- Single Schools
        [Enum.Damageclass.MaskPhysical]	    = "ffff0000",
        [Enum.Damageclass.MaskHoly]		    = "ffffffb6",
        [Enum.Damageclass.MaskFire]		    = "ffff432c",
        [Enum.Damageclass.MaskNature]	    = "ff3c9742",
        [Enum.Damageclass.MaskFrost]	    = "ff00abff",
        [Enum.Damageclass.MaskShadow]	    = "ff9500b6",
        [Enum.Damageclass.MaskArcane]	    = "ffdd4aff",
        -- Physical and a Magical
        [Enum.Damageclass.MaskFlamestrike]	= "ffff8879",
        [Enum.Damageclass.MaskFroststrike]	= "ff7dd5ff",
        [Enum.Damageclass.MaskSpellstrike]	= "ffa8caff",
        [Enum.Damageclass.MaskStormstrike]	= "ffa1eaa3",
        [Enum.Damageclass.MaskShadowstrike]	= "ffa89cff",
        [Enum.Damageclass.MaskHolystrike]	= "ffffffe6",
        -- Two Magical Schools
        [Enum.Damageclass.MaskFrostfire]	= "ffff64ab",
        [Enum.Damageclass.MaskSpellfire]	= "ffff4d5c",
        [Enum.Damageclass.MaskFirestorm]	= "ffdfcfb6",
        [Enum.Damageclass.MaskShadowflame]	= "ffb92334",
        [Enum.Damageclass.MaskHolyfire]		= "ffffca68",
        [Enum.Damageclass.MaskSpellfrost]	= "ff828ffd",
        [Enum.Damageclass.MaskFroststorm]	= "ff5de1de",
        [Enum.Damageclass.MaskShadowfrost]	= "ff3a00e5",
        [Enum.Damageclass.MaskHolyfrost]	= "ffbffffc",
        [Enum.Damageclass.MaskSpellstorm]	= "ff3f45ff",
        [Enum.Damageclass.MaskSpellshadow]	= "ff0009ff",
        [Enum.Damageclass.MaskDivine]		= "fffff9ed",
        [Enum.Damageclass.MaskShadowstorm]	= "ff462b68",
        [Enum.Damageclass.MaskHolystorm]	= "ffe9ffa9",
        [Enum.Damageclass.MaskTwilight]	    = "ff242d8d",
        -- Three or more schools
        [Enum.Damageclass.MaskElemental]	= "ffffa500",
        [Enum.Damageclass.MaskChromatic]    = "ffffffff",
        [Enum.Damageclass.MaskMagical]      = "ff97f4ff",
        [Enum.Damageclass.MaskChaos]        = "ff8000ff"
    },
    auto = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFFFFF",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },  
    automiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFFFFF",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },  
    autocrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FFFFFFFF",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    petauto = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFF9D00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },  
    petautomiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFF9D00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },  
    petautocrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FFFF9D00",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    spell = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    spellmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    spellcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    spelltick = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    spelltickmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    spelltickcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    petspell = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    petspellmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    petspellcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    petspelltick = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    petspelltickmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    petspelltickcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FFFFE800",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    heal = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    healmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    healcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    healtick = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    healtickmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    healtickcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    petheal = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    pethealmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    pethealcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    },
    pethealtick = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    pethealtickmiss = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 42,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        },
        Scroll = {
            enabled = true,
            direction = "UP",
            distance = 32
        }
    },
    pethealtickcrit = {
        enabled = true,
        fontPath = "Fonts\\FRIZQT__.TTF",
        fontSize = 60,
        fontStyle = "",
        fontColor = "FF00FF00",
        showIcons = false,
        colorByType = false,
        Pow = {
            enabled = true,
            initScale = 0.25,
            midScale = 1.55,
            endScale = 1,
            duration = 0.3,
            inOutRatio = 0.7
        },
        FadeIn = {
            enabled = true,
            duration = 0.07
        },
        FadeOut = {
            enabled = true,
            duration = 0.3
        }
    }
})