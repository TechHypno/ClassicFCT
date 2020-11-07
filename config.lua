local addonName, CFCT = ...
local tinsert, tremove, format, strlen, strsub, gsub, floor, sin, cos, asin, acos, random, select, pairs, ipairs, bitband = tinsert, tremove, format, strlen, strsub, gsub, floor, sin, cos, asin, acos, random, select, pairs, ipairs, bit.band

local DefaultPresets = {
    ["Classic"] = {
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
        attachMode = "tn",
        attachModeFallback = true,
        abbreviateNumbers = false,
        kiloSeparator = false,
        filterAbsoluteEnabled = false,
        filterAbsoluteThreshold = 100,
        filterRelativeEnabled = false,
        filterRelativeThreshold = 10,
        filterAverageEnabled = false,
        filterAverageThreshold = 10,
        sortByDamage = false,
        sortMissPrio = false,
        mergeEvents = false,
        mergeEventsInterval = 0.1,
        mergeEventsCounter = true,
        colorTable = {
            -- Single Schools
            [SCHOOL_MASK_PHYSICAL]			        	= "ffff0000",
            [SCHOOL_MASK_HOLY]			            	= "ffffffb6",
            [SCHOOL_MASK_FIRE]			            	= "ffff432c",
            [SCHOOL_MASK_NATURE]			        	= "ff3c9742",
            [SCHOOL_MASK_FROST]				            = "ff00abff",
            [SCHOOL_MASK_SHADOW]			        	= "ff9500b6",
            [SCHOOL_MASK_ARCANE]			        	= "ffdd4aff",
            -- Physical and a Magical
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FIRE]	= "ffff8879",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FROST]	= "ff7dd5ff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_ARCANE]	= "ffa8caff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_NATURE]	= "ffa1eaa3",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_SHADOW]	= "ffa89cff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_HOLY]	= "ffffffe6",
            -- Two Magical Schools
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST]		= "ffff64ab",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_ARCANE]		= "ffff4d5c",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_NATURE]		= "ffdfcfb6",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_SHADOW]		= "ffb92334",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_HOLY]		= "ffffca68",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE]	= "ff828ffd",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE]	= "ff5de1de",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_SHADOW]	= "ff3a00e5",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_HOLY]		= "ffbffffc",
            [SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE]	= "ff3f45ff",
            [SCHOOL_MASK_ARCANE + SCHOOL_MASK_SHADOW]	= "ff0009ff",
            [SCHOOL_MASK_ARCANE + SCHOOL_MASK_HOLY]		= "fffff9ed",
            [SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW]	= "ff462b68",
            [SCHOOL_MASK_NATURE + SCHOOL_MASK_HOLY]		= "ffe9ffa9",
            [SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY]		= "ff242d8d",
            -- Three or more schools
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE]	= "ffffa500",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW] = "ffffffff",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY] = "ff97f4ff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY] = "ff8000ff",
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
            fontSize = 64,
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
            fontSize = 64,
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
    },
    ["Mists of Pandaria"] = {
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
        attachMode = "tn",
        attachModeFallback = true,
        abbreviateNumbers = false,
        kiloSeparator = false,
        filterAbsoluteEnabled = false,
        filterAbsoluteThreshold = 100,
        filterRelativeEnabled = false,
        filterRelativeThreshold = 10,
        filterAverageEnabled = false,
        filterAverageThreshold = 10,
        sortByDamage = false,
        sortMissPrio = false,
        mergeEvents = false,
        mergeEventsInterval = 0.1,
        mergeEventsCounter = true,
        colorTable = {
            -- Single Schools
            [SCHOOL_MASK_PHYSICAL]			        	= "ffff0000",
            [SCHOOL_MASK_HOLY]			            	= "ffffffb6",
            [SCHOOL_MASK_FIRE]			            	= "ffff432c",
            [SCHOOL_MASK_NATURE]			        	= "ff3c9742",
            [SCHOOL_MASK_FROST]				            = "ff00abff",
            [SCHOOL_MASK_SHADOW]			        	= "ff9500b6",
            [SCHOOL_MASK_ARCANE]			        	= "ffdd4aff",
            -- Physical and a Magical
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FIRE]	= "ffff8879",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FROST]	= "ff7dd5ff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_ARCANE]	= "ffa8caff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_NATURE]	= "ffa1eaa3",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_SHADOW]	= "ffa89cff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_HOLY]	= "ffffffe6",
            -- Two Magical Schools
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST]		= "ffff64ab",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_ARCANE]		= "ffff4d5c",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_NATURE]		= "ffdfcfb6",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_SHADOW]		= "ffb92334",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_HOLY]		= "ffffca68",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE]	= "ff828ffd",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE]	= "ff5de1de",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_SHADOW]	= "ff3a00e5",
            [SCHOOL_MASK_FROST + SCHOOL_MASK_HOLY]		= "ffbffffc",
            [SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE]	= "ff3f45ff",
            [SCHOOL_MASK_ARCANE + SCHOOL_MASK_SHADOW]	= "ff0009ff",
            [SCHOOL_MASK_ARCANE + SCHOOL_MASK_HOLY]		= "fffff9ed",
            [SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW]	= "ff462b68",
            [SCHOOL_MASK_NATURE + SCHOOL_MASK_HOLY]		= "ffe9ffa9",
            [SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY]		= "ff242d8d",
            -- Three or more schools
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE]	= "ffffa500",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW] = "ffffffff",
            [SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY] = "ff97f4ff",
            [SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY] = "ff8000ff",
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
                initScale = 1.8,
                midScale = 1.6,
                endScale = 1,
                duration = 0.16,
                inOutRatio = 0.3
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
                initScale = 1.8,
                midScale = 1.6,
                endScale = 1,
                duration = 0.16,
                inOutRatio = 0.3
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
                initScale = 1.8,
                midScale = 1.6,
                endScale = 1,
                duration = 0.16,
                inOutRatio = 0.3
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
                initScale = 1.8,
                midScale = 1.6,
                endScale = 1,
                duration = 0.16,
                inOutRatio = 0.3
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
            fontSize = 64,
            fontStyle = "",
            fontColor = "FF00FF00",
            showIcons = false,
            colorByType = false,
            Pow = {
                enabled = true,
                initScale = 1.8,
                midScale = 1.6,
                endScale = 1,
                duration = 0.16,
                inOutRatio = 0.3
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
            fontSize = 64,
            fontStyle = "",
            fontColor = "FF00FF00",
            showIcons = false,
            colorByType = false,
            Pow = {
                enabled = true,
                initScale = 1.8,
                midScale = 1.6,
                endScale = 1,
                duration = 0.16,
                inOutRatio = 0.3
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
    }
}
local DefaultConfig = DefaultPresets["Mists of Pandaria"]
local DefaultVars = {
    enabled = true,
    hideBlizz = true,
    hideBlizzHeals = true,
    selectedPreset = "",
    lastVersion = ""
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
        ClassicFCTConfig = ClassicFCTConfig or {}
        UpdateTable(ClassicFCTConfig, DefaultConfig, DefaultConfig)
        UpdateTable(self, ClassicFCTConfig, DefaultConfig, true)
        
        ClassicFCTVars = ClassicFCTVars or {}
        UpdateTable(ClassicFCTVars, DefaultVars, DefaultVars)
        UpdateTable(CFCT, ClassicFCTVars, DefaultVars, true)

        ClassicFCTCustomPresets = ClassicFCTCustomPresets or {}
        UpdateTable(CFCT.Presets, ClassicFCTCustomPresets, ClassicFCTCustomPresets, true)
        UpdateTable(CFCT.Presets, DefaultPresets, DefaultPresets, true)
    end,
    OnSave = function(self)
        UpdateTable(self, ClassicFCTConfig, DefaultConfig)
        UpdateTable(ClassicFCTConfig, self, DefaultConfig, true)

        UpdateTable(CFCT, ClassicFCTVars, DefaultVars)
        UpdateTable(ClassicFCTVars, CFCT, DefaultVars, true)

        ClassicFCTCustomPresets = {}
        UpdateTable(ClassicFCTCustomPresets, CFCT.Presets, CFCT.Presets, true)
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
        InterfaceOptionsFrame_OpenToCategory(CFCT.ConfigPanels[1])
        InterfaceOptionsFrame_OpenToCategory(CFCT.ConfigPanels[1])
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
	[SCHOOL_MASK_PHYSICAL]				        = STRING_SCHOOL_PHYSICAL,
	[SCHOOL_MASK_HOLY]				            = STRING_SCHOOL_HOLY,
	[SCHOOL_MASK_FIRE]				            = STRING_SCHOOL_FIRE,
	[SCHOOL_MASK_NATURE]			        	= STRING_SCHOOL_NATURE,
	[SCHOOL_MASK_FROST]				            = STRING_SCHOOL_FROST,
	[SCHOOL_MASK_SHADOW]				        = STRING_SCHOOL_SHADOW,
	[SCHOOL_MASK_ARCANE]				        = STRING_SCHOOL_ARCANE,
	-- Physical and a Magical
	[SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FIRE]	= STRING_SCHOOL_FLAMESTRIKE,
	[SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FROST]	= STRING_SCHOOL_FROSTSTRIKE,
	[SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_ARCANE]	= STRING_SCHOOL_SPELLSTRIKE,
	[SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_NATURE]	= STRING_SCHOOL_STORMSTRIKE,
	[SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_SHADOW]	= STRING_SCHOOL_SHADOWSTRIKE,
	[SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_HOLY]	= STRING_SCHOOL_HOLYSTRIKE,
	-- Two Magical Schools
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST]		= STRING_SCHOOL_FROSTFIRE,
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_ARCANE]		= STRING_SCHOOL_SPELLFIRE,
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_NATURE]		= STRING_SCHOOL_FIRESTORM,
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_SHADOW]		= STRING_SCHOOL_SHADOWFLAME,
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_HOLY]		= STRING_SCHOOL_HOLYFIRE,
	[SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE]	= STRING_SCHOOL_SPELLFROST,
	[SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE]	= STRING_SCHOOL_FROSTSTORM,
	[SCHOOL_MASK_FROST + SCHOOL_MASK_SHADOW]	= STRING_SCHOOL_SHADOWFROST,
	[SCHOOL_MASK_FROST + SCHOOL_MASK_HOLY]		= STRING_SCHOOL_HOLYFROST,
	[SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE]	= STRING_SCHOOL_SPELLSTORM,
	[SCHOOL_MASK_ARCANE + SCHOOL_MASK_SHADOW]	= STRING_SCHOOL_SPELLSHADOW,
	[SCHOOL_MASK_ARCANE + SCHOOL_MASK_HOLY]		= STRING_SCHOOL_DIVINE,
	[SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW]	= STRING_SCHOOL_SHADOWSTORM,
	[SCHOOL_MASK_NATURE + SCHOOL_MASK_HOLY]		= STRING_SCHOOL_HOLYSTORM,
	[SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY]		= STRING_SCHOOL_SHADOWLIGHT,
	-- Three or more schools
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE]	= STRING_SCHOOL_ELEMENTAL,
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW] = STRING_SCHOOL_CHROMATIC,
	[SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY] = STRING_SCHOOL_MAGIC,
	[SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW + SCHOOL_MASK_HOLY] = STRING_SCHOOL_CHAOS,    
}











function ShowColorPicker(r, g, b, a, changedCallback)
    ColorPickerFrame:SetColorRGB(r,g,b);
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
    ColorPickerFrame.previousValues = {r,g,b,a};
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback;
    ColorPickerFrame:Hide();
    ColorPickerFrame:Show();
end

local function CreateHeader(self, text, headerType, parent, point1, point2, x, y)
    local header = self:CreateFontString(nil, "ARTWORK", headerType)
    self:AddFrame(header)
    header:SetText(text)
    header:SetPoint(point1, parent, point2, x, y)
    return header
end
local function CreateCheckbox(self, label, tooltip, parent, point1, point2, x, y, defVal, ConfigPath)
    local checkbox = CreateFrame("CheckButton", self:NewFrameID(), self, "InterfaceOptionsCheckButtonTemplate")
    self:AddFrame(checkbox)
    checkbox:SetPoint(point1, parent, point2, x, y)
    checkbox:SetScript("OnShow", function(self)
        self:SetChecked(GetValue(ConfigPath) == true)
    end)
    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        SetValue(ConfigPath, checked)
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
local function CreateSlider(self, label, tooltip, parent, point1, point2, x, y, minVal, maxVal, step, defVal, ConfigPath)
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
        self:SetValue(GetValue(ConfigPath) or defVal)
    end)
    slider:HookScript("OnValueChanged", function(self, val, isUserInput)
        slider.valueBox:SetText(val)
        SetValue(ConfigPath, val)
    end)

    local valueBox = CreateFrame('editbox', nil, slider, "BackdropTemplate")
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
                    fontObjects[path]:SetFont(path, 14)
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
local function CreateDropDownMenu(self, label, tooltip, parent, point1, point2, x, y, menuItems, menuFuncORConfigPath)
    local dropdown = CreateFrame('Frame', self:NewFrameID(), self, "UIDropDownMenuTemplate")
    self:AddFrame(dropdown)
    dropdown:SetPoint(point1, parent, point2, x, y)
    dropdown.left = getglobal(dropdown:GetName() .. "Left")
    dropdown.middle = getglobal(dropdown:GetName() .. "Middle")
    dropdown.middle:SetWidth(150)
    dropdown.right = getglobal(dropdown:GetName() .. "Right")
    dropdown.curValue = menuItems[1].value

    if (menuFuncORConfigPath and (type(menuFuncORConfigPath) == 'function')) then
        dropdown.menuFunc = menuFuncORConfigPath
    else
        dropdown.configPath = menuFuncORConfigPath
    end

    -- UIDropDownMenu_SetAnchor(dropdown, 300, 0, "CENTER", UIParent, "LEFT")
    local function itemOnClick(self)
        for i, item in ipairs(menuItems) do
            if (item.value == self.value) then
                dropdown.curValue = item.value
            end
        end
        -- local func = dropdown.selectedItem.func
        -- if (func and (type(func) == 'function')) then func(self, dropdown) end
        if (dropdown.menuFunc and (type(dropdown.menuFunc) == 'function')) then
            dropdown.menuFunc(self, dropdown)
        elseif (dropdown.configPath and (type(dropdown.configPath) == 'string')) then
            SetValue(dropdown.configPath, dropdown.curValue)
        end
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
        if dropdown.configPath then dropdown.curValue = GetValue(dropdown.configPath) end
        local curValue = dropdown.curValue
        for _,item in ipairs(menuItems) do
            if (item.value == curValue) then
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
        ColorPickerFrame:Hide()
        ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        ColorPickerFrame:SetFrameLevel(self:GetFrameLevel() + 10)
        ColorPickerFrame.func = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = 1 - OpacitySliderFrame:GetValue()
            if (type(ConfigPathOrFunc) == 'function') then
                ConfigPathOrFunc(CFCT.RGBA2Color(r, g, b, a))
            else
                SetValue(ConfigPathOrFunc, CFCT.RGBA2Color(r, g, b, a))
            end
            self:SetColor(r, g, b, a)
        end
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacityFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = 1 - OpacitySliderFrame:GetValue()
            if (type(ConfigPathOrFunc) == 'function') then
                ConfigPathOrFunc(CFCT.RGBA2Color(r, g, b, a))
            else
                SetValue(ConfigPathOrFunc, CFCT.RGBA2Color(r, g, b, a))
            end
            self:SetColor(r, g, b, a)
        end

        local a, r, g, b = self.value.a, self.value.r, self.value.g, self.value.b
        ColorPickerFrame.opacity = 1 - a
        ColorPickerFrame:SetColorRGB(r, g, b)

        ColorPickerFrame.cancelFunc = function()
            if (type(ConfigPathOrFunc) == 'function') then
                ConfigPathOrFunc(CFCT.RGBA2Color(r, g, b, a))
            else
                SetValue(ConfigPathOrFunc, CFCT.RGBA2Color(r, g, b, a))
            end
            self:SetColor(r, g, b, a)
        end

        ColorPickerFrame:Show()
    end)
    btn:SetScript("OnShow", function(self)
        local color
        if (type(ConfigPathOrFunc) == 'function') then
            color = ConfigPathOrFunc()
        else
            color = GetValue(ConfigPathOrFunc) or defVal
        end
        local r, g, b, a = CFCT.Color2RGBA(color)
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
    petspell = "Pet Spell Hits",
    petspellmiss = "Pet Spell Misses",
    petspellcrit = "Pet Spell Crits",

    heal = "Heals",
    healmiss = "Heal Misses",
    healcrit = "Heal Crits",
    petheal = "Pet Heals",
    pethealmiss = "Pet Heal Misses",
    pethealcrit = "Pet Heal Crits"
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
    if (cat:find("auto") == nil) then
        local showIconsCheckbox = f:CreateCheckbox("Show Spell Icons", "Enables/Disables showing spell icons next to damage text", f, "TOPLEFT", "TOPLEFT", 250, 0, DefaultConfig[cat].showIcons, "Config."..cat..".showIcons")
        showIconsCheckbox:SetFrameLevel(enabledCheckbox:GetFrameLevel() + 1)
    end
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

    local animDropDown = f:CreateDropDownMenu("Animations", "Animations", f, "TOPLEFT", "TOPLEFT", -16, -70, AnimationsMenu, function(self, dropdown)
        show(self.value)
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
    return f
end

local function CreateConfigPanel(name, parent, height)
    local Container = CreateFrame('frame', "ClassicFCTConfigPanel_"..gsub(name, " ", ""), UIParent)
    local sf = CreateFrame('ScrollFrame', Container:GetName().."_ScrollFrame", Container, "UIPanelScrollFrameTemplate")
    local sfname = sf:GetName()
    sf.scrollbar = getglobal(sfname.."ScrollBar")
    sf.scrollupbutton = getglobal(sfname.."ScrollBarScrollUpButton")
    sf.scrolldownbutton = getglobal(sfname.."ScrollBarScrollDownButton")

    sf.scrollupbutton:ClearAllPoints();
    sf.scrollupbutton:SetPoint("TOPLEFT", sf, "TOPRIGHT", -6, -2);
    
    sf.scrolldownbutton:ClearAllPoints();
    sf.scrolldownbutton:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", -6, 2);
    
    sf.scrollbar:ClearAllPoints();
    sf.scrollbar:SetPoint("TOP", sf.scrollupbutton, "BOTTOM", 0, -2);
    sf.scrollbar:SetPoint("BOTTOM", sf.scrolldownbutton, "TOP", 0, 2);

    Container.name = name
    Container.parent = parent
    Container.refresh = Refresh
    InterfaceOptions_AddCategory(Container)
    CFCT.ConfigPanels[#CFCT.ConfigPanels + 1] = Container
    Container:SetAllPoints()
    Container:Hide()

    local p = CreateFrame("Frame", Container:GetName().."_ScrollChild")
    p.refresh = function(self) Container:refresh() end 
    p.widgets = {}
    p.widgetCount = 0
    p.CreateSubPanel = function(self, name, height)
        return CreateConfigPanel(name, Container.name, height)
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
    sf:SetScrollChild(p)
    sf:SetAllPoints()
    p:HookScript("OnShow", function(self) self:SetSize(sf:GetWidth(), height or sf:GetHeight()) end)
    return p
end



--ConfigPanel Layout

local ConfigPanel = CreateConfigPanel("ClassicFCT", nil, 800)
CFCT.ConfigPanel = ConfigPanel
local headerGlobal = ConfigPanel:CreateHeader("", "GameFontNormalLarge", ConfigPanel, "TOPLEFT", "TOPLEFT", 16, -16)
local enabledCheckbox = ConfigPanel:CreateCheckbox("Enable ClassicFCT", "Enables/Disables the addon", headerGlobal, "LEFT", "LEFT", 0, -2, DefaultVars.enabled, "enabled")
local hideBlizzDamageCheckbox = ConfigPanel:CreateCheckbox("Hide Blizzard Damage", "Enables/Disables the default Blizzard Floating Damage Text", enabledCheckbox, "LEFT", "RIGHT", 16 + enabledCheckbox.label:GetWidth(), 0, DefaultVars.hideBlizz, "hideBlizz")
hideBlizzDamageCheckbox:HookScript("OnClick", function(self)
    SetCVar("floatingCombatTextCombatDamage", self:GetChecked() and "0" or "1")
    -- SetCVar("floatingCombatTextCombatHealing", self:GetChecked() and "0" or "1")
end)
hideBlizzDamageCheckbox:HookScript("OnShow", function(self)
    self:SetChecked(GetCVar("floatingCombatTextCombatDamage") == "0")
    -- self:SetChecked(GetCVar("floatingCombatTextCombatHealing") == "0")
end)
local hideBlizzHealingCheckbox = ConfigPanel:CreateCheckbox("Hide Blizzard Healing", "Enables/Disables the default Blizzard Floating Healing Text", enabledCheckbox, "LEFT", "RIGHT", 16 + enabledCheckbox.label:GetWidth() + 32 + hideBlizzDamageCheckbox.label:GetWidth(), 0, DefaultVars.hideBlizzHeals, "hideBlizzHeals")
hideBlizzHealingCheckbox:HookScript("OnClick", function(self)
    -- SetCVar("floatingCombatTextCombatDamage", self:GetChecked() and "0" or "1")
    SetCVar("floatingCombatTextCombatHealing", self:GetChecked() and "0" or "1")
end)
hideBlizzHealingCheckbox:HookScript("OnShow", function(self)
    -- self:SetChecked(GetCVar("floatingCombatTextCombatDamage") == "0")
    self:SetChecked(GetCVar("floatingCombatTextCombatHealing") == "0")
end)

local headerPresets = ConfigPanel:CreateHeader("Config Presets", "GameFontNormalLarge", headerGlobal, "TOPLEFT", "BOTTOMLEFT", 0, -20)
local newPresetBtn = ConfigPanel:CreateButton("New", "Creates a new preset", headerPresets, "TOPLEFT", "TOPRIGHT", 94, 0, function()
    CFCT.Config:CreatePreset()
end)
local copyPresetBtn = ConfigPanel:CreateButton("Copy", "Creates a copy of the selected preset", newPresetBtn, "TOPLEFT", "BOTTOMLEFT", 0, 0, function()
    CFCT.Config:CreatePresetCopy(CFCT.selectedPreset)
end)



local PresetMenu = {{}}
local presetDropDown = ConfigPanel:CreateDropDownMenu("Presets", "Configuration Presets", newPresetBtn, "LEFT", "RIGHT", -10, 0, PresetMenu, function(self)
    CFCT.selectedPreset = self.value
    ConfigPanel:refresh()
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


-- local textStrataHeader = ConfigPanel:CreateHeader("Text Strata", "GameFontHighlightSmall", textPosOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -16)
-- local textStrataDropDown = ConfigPanel:CreateDropDownMenu("Text Strata", "", textStrataHeader, "LEFT", "LEFT", 64, -3, TextStrataMenu, "Config.textStrata")
-- textStrataDropDown.middle:SetWidth(110)
-- local dontOverlapNameplates = ConfigPanel:CreateCheckbox("Nameplates In Front", "Show text behind the nameplates", textStrataDropDown.right, "LEFT", "RIGHT", -10, 0, DefaultConfig.dontOverlapNameplates, "Config.dontOverlapNameplates")
-- local inheritNameplates = ConfigPanel:CreateCheckbox("Inherit From Nameplates", "Text inherits some atributes from nameplates, like visibility and scale", dontOverlapNameplates, "LEFT", "RIGHT", 132, 0, DefaultConfig.inheritNameplates, "Config.inheritNameplates")


-- local attachModeHeader = ConfigPanel:CreateHeader("Attach Text To", "GameFontHighlightSmall", textPosOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -48)
-- local attachModeDropDown = ConfigPanel:CreateDropDownMenu("Attach Mode", "", attachModeHeader, "LEFT", "LEFT", 64, -3, AttachModesMenu, "Config.attachMode")
-- attachModeDropDown.middle:SetWidth(110)

-- local fallbackCheckbox = ConfigPanel:CreateCheckbox("Attachment Fallback", "When a nameplate isnt available, the text will temporarily attach to the screen center instead", attachModeDropDown.right, "LEFT", "RIGHT", -10, 0, DefaultConfig.attachModeFallback, "Config.attachModeFallback")
-- local overlapCheckbox = ConfigPanel:CreateCheckbox("Prevent Text Overlap", "Prevents damage text frames from overlapping each other", fallbackCheckbox, "LEFT", "RIGHT", 132, 0, DefaultConfig.preventOverlap, "Config.preventOverlap")

local attachModeHeader = ConfigPanel:CreateHeader("Attach Text To", "GameFontHighlightSmall", textPosOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -16)
local attachModeDropDown = ConfigPanel:CreateDropDownMenu("Attach Mode", "", attachModeHeader, "LEFT", "LEFT", 64, -3, AttachModesMenu, "Config.attachMode")
attachModeDropDown.middle:SetWidth(110)

local fallbackCheckbox = ConfigPanel:CreateCheckbox("Attachment Fallback", "When a nameplate isnt available, the text will temporarily attach to the screen center instead", attachModeDropDown.right, "LEFT", "RIGHT", -10, 0, DefaultConfig.attachModeFallback, "Config.attachModeFallback")
local overlapCheckbox = ConfigPanel:CreateCheckbox("Prevent Text Overlap", "Prevents damage text frames from overlapping each other", fallbackCheckbox, "LEFT", "RIGHT", 132, 0, DefaultConfig.preventOverlap, "Config.preventOverlap")

local dontOverlapNameplates = ConfigPanel:CreateCheckbox("Nameplates In Front", "Show text behind the nameplates", fallbackCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.dontOverlapNameplates, "Config.dontOverlapNameplates")
local inheritNameplates = ConfigPanel:CreateCheckbox("Inherit From Nameplates", "Text inherits some atributes from nameplates, like visibility and scale", overlapCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.inheritNameplates, "Config.inheritNameplates")


-- local areaSliderX = ConfigPanel:CreateSlider("Screen Center Text X Offset", "Horizontal offset of animation area", attachModeHeader, "TOPLEFT", "BOTTOMLEFT", 0, -28, -700, 700, 1, DefaultConfig.areaX, "Config.areaX")
local areaSliderX = ConfigPanel:CreateSlider("Screen Center Text X Offset", "Horizontal offset of animation area", attachModeHeader, "TOPLEFT", "BOTTOMLEFT", 0, -48, -700, 700, 1, DefaultConfig.areaX, "Config.areaX")
local areaSliderY = ConfigPanel:CreateSlider("Screen Center Text Y Offset", "Vertical offset of animation area", areaSliderX, "LEFT", "RIGHT", 16, 0, -400, 400, 1, DefaultConfig.areaY, "Config.areaY")
local areaSliderNX = ConfigPanel:CreateSlider("Nameplate Text X Offset", "Horizontal offset of animation area", areaSliderX, "TOPLEFT", "BOTTOMLEFT", 0, -28, -400, 400, 1, DefaultConfig.areaNX, "Config.areaNX")
local areaSliderNY = ConfigPanel:CreateSlider("Nameplate Text Y Offset", "Vertical offset of animation area", areaSliderNX, "LEFT", "RIGHT", 16, 0, -400, 400, 1, DefaultConfig.areaNY, "Config.areaNY")

local textFormatOptionsHeader = ConfigPanel:CreateHeader("Number Formatting Options", "GameFontNormalLarge", textPosOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -164)
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

local sortingOptionsHeader = ConfigPanel:CreateHeader("Sorting Options", "GameFontNormalLarge", filteringOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -128)
local sortByDamageCheckbox = ConfigPanel:CreateCheckbox("Sort By Damage/Healing in Descending Order", "Sort events by amount", sortingOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -8, DefaultConfig.sortByDamage, "Config.sortByDamage")

local merginOptionsHeader = ConfigPanel:CreateHeader("Merging Options", "GameFontNormalLarge", sortingOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 0, -40)
local mergingEnabledCheckbox = ConfigPanel:CreateCheckbox("Merge Events", "Combine damage/healings events with the same spellid into one event", merginOptionsHeader, "TOPLEFT", "BOTTOMLEFT", 20, -8, DefaultConfig.mergeEvents, "Config.mergeEvents")
local mergingIntervalSlider = ConfigPanel:CreateSlider("Max Interval", "Max time interval between events for a merge to happen (in seconds)", mergingEnabledCheckbox, "LEFT", "RIGHT", 256, 0, 0.01, 5, 0.01, DefaultConfig.mergeEventsInterval, "Config.mergeEventsInterval")
local mergingCountCheckbox = ConfigPanel:CreateCheckbox("Show Merge Count", "Add number of merged events next to the damage/healing (ex '1337 x5')", mergingEnabledCheckbox, "TOPLEFT", "BOTTOMLEFT", 0, 0, DefaultConfig.mergeEventsCounter, "Config.mergeEventsCounter")

local colorTableFrame = ConfigPanel:CreateChildFrame("TOPLEFT", "BOTTOMLEFT", merginOptionsHeader, 0, -64, 300, 340)
local colorTableHeader = colorTableFrame:CreateHeader("Damage Type Colors", "GameFontNormalLarge", colorTableFrame, "TOPLEFT", "TOPLEFT", 0, 0)
local colorTableX, colorTableY, colorTableCounter = 20, 0, 0

for k,v in pairs(SCHOOL_NAMES) do
    colorTableCounter = colorTableCounter + 1
    if (colorTableY < -150) then
        colorTableX = colorTableX + 150
        colorTableY = 0
    end
    colorTableY = colorTableY - 20
    local colorWidget = colorTableFrame:CreateColorOption(v, "Custom text color for this type", colorTableFrame, "TOPLEFT", "TOPLEFT", colorTableX, colorTableY, DefaultConfig.colorTable[k], function(val)
        if (val == nil) then
            return CFCT.Config.colorTable[k]
        else
            CFCT.Config.colorTable[k] = val
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
        catname = "Heals",
        subcatlist = {
            "heal",
            "healcrit",
            "healmiss"
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
        catname = "Pet Heals",
        subcatlist = {
            "petheal",
            "pethealcrit",
            "pethealmiss"
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


