--[[
##############################################################################
_____/\\\\\\\\\\\____/\\\________/\\\__/\\\________/\\\__/\\\\\\\\\\\_       #
 ___/\\\/////////\\\_\/\\\_______\/\\\_\/\\\_______\/\\\_\/////\\\///__      #
  __\//\\\______\///__\//\\\______/\\\__\/\\\_______\/\\\_____\/\\\_____     #
   ___\////\\\__________\//\\\____/\\\___\/\\\_______\/\\\_____\/\\\_____    #
    ______\////\\\________\//\\\__/\\\____\/\\\_______\/\\\_____\/\\\_____   #
     _________\////\\\______\//\\\/\\\_____\/\\\_______\/\\\_____\/\\\_____  #
      __/\\\______\//\\\______\//\\\\\______\//\\\______/\\\______\/\\\_____ #
       _\///\\\\\\\\\\\/________\//\\\________\///\\\\\\\\\/____/\\\\\\\\\\\_#
        ___\///////////___________\///___________\/////////_____\///////////_#
##############################################################################
S U P E R - V I L L A I N - U I   By: Munglunch                              #
##############################################################################
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local string 	= _G.string;
local table     = _G.table;
local format = string.format;
local tcopy = table.copy;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local SVLib = LibSuperVillain("Registry")
local L = SV.L;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local SVUI_CLASS_COLORS = _G.SVUI_CLASS_COLORS
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS

local CONTINUED = _G.CONTINUED
local SETTINGS = _G.SETTINGS
local HIGH = _G.HIGH
local LOW = _G.LOW
local scc = SVUI_CLASS_COLORS[SV.class];
local rcc = RAID_CLASS_COLORS[SV.class];
local r2 = .1 + (rcc.r * .1)
local g2 = .1 + (rcc.g * .1)
local b2 = .1 + (rcc.b * .1)
--[[ 
########################################################## 
LAYOUT PRESETS
##########################################################
]]--
local hasOldConfigs = function()
	return SVLib:GetSafeData("install_version")
end

local isLowRez = function()
	if SV.LowRez then 
		return L["This resolution requires that you change some settings to get everything to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["You may need to further alter these settings depending how low your resolution is."]
	else 
		return L["This resolution doesn't require that you change settings for the UI to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["This is completely optional."]
	end
end

local PRESET_DATA, CLICK_DIALOG, PAGE_DIALOG;

local function LoadPresetData()
	PRESET_DATA = {
		["media"] = {
			["link"] = "media",
			["default"] = {
				["colors"] = {
					["special"] = {.37, .32, .29, 1},
					["specialdark"] = {.23, .22, .21, 1},
				},
				["textures"] = {
					["pattern"] = "SVUI Backdrop 1",
					["comic"] = "SVUI Comic 1",
					["unitlarge"] = "SVUI Unit BG 1",
					["unitsmall"] = "SVUI Small BG 1",
				},
				["unitframes"] = {
					["buff_bars"] = {.91, .91, .31, 1},
					["health"] = {.1, .6, .02, 1},
					["casting"] = {.91, .91, .31, 1},
					["spark"] = {1, .72, 0, 1},
				},
			},
			["kaboom"] = {
				["colors"] = {
					["special"] = {.28, .31, .32, 1},
					["specialdark"] = {.21, .22, .23, 1},
				},
				["textures"] = {
					["pattern"] = "SVUI Backdrop 2",
					["comic"] = "SVUI Comic 2",
					["unitlarge"] = "SVUI Unit BG 2",
					["unitsmall"] = "SVUI Small BG 2",
				},
				["unitframes"] = {
					["buff_bars"] = {.51, .79, 0, 1},
					["health"] = {.16, .86, .22, 1},
					["casting"] = {.91, .91, 0, 1},
					["spark"] = {1, .72, 0, 1},
				},
			},
			["classy"] = {
				["colors"] = {
					["special"] = {r2, g2, b2, 1},
					["specialdark"] = {(r2 * 0.75), (g2 * 0.75), (b2 * 0.75), 1},
				},
				["textures"] = {
					["pattern"] = "SVUI Backdrop 3",
					["comic"] = "SVUI Comic 3",
					["unitlarge"] = "SVUI Unit BG 3",
					["unitsmall"] = "SVUI Small BG 3",
				},
				["unitframes"] = {
					["buff_bars"] = {scc.r, scc.g, scc.b, 1},
					["health"] = {.16, .86, .22, 1},
					["casting"] = {.91, .91, 0, 1},
					["spark"] = {1, .72, 0, 1},
				},
			},
			["dark"] = {
				["colors"] = {
					["special"] = {.25, .26, .27, 1},
					["specialdark"] = {.17, .18, .19, 1},
				},
				["textures"] = {
					["pattern"] = "SVUI Backdrop 4",
					["comic"] = "SVUI Comic 4",
					["unitlarge"] = "SVUI Unit BG 4",
					["unitsmall"] = "SVUI Small BG 4",
				},
				["unitframes"] = {
					["buff_bars"] = {.45, .55, .15, 1},
					["health"] = {.06, .06, .06, 1},
					["casting"] = {.8, .8, 0, 1},
					["spark"] = {1, .72, 0, 1},
				},
			},
		},
		["auras"] = {
			["link"] = "SVUnit",
			["default"] = {
				["player"] = {
					["buffs"] = {
						enable = false,
						attachTo = "DEBUFFS",
						anchorPoint = 'TOPLEFT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'RIGHT',
					},
					["debuffs"] = {
						enable = false,
						attachTo = "FRAME",
						anchorPoint = 'TOPLEFT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'RIGHT',
					},
					["aurabar"] = {
						enable = false
					}
				},
				["target"] = {
					["smartAuraDisplay"] = "DISABLED",
					["buffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "BUFFS",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["aurabar"] = {
						enable = false
					}
				},
				["focus"] = {
					["smartAuraDisplay"] = "DISABLED",
					["buffs"] = {
						enable = false,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["aurabar"] = {
						enable = false
					}
				}
			},
			["icons"] = {
				["player"] = {
					["buffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPLEFT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'RIGHT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "BUFFS",
						anchorPoint = 'TOPLEFT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'RIGHT',
					},
					["aurabar"] = {
						enable = false
					}
				},
				["target"] = {
					["smartAuraDisplay"] = "DISABLED",
					["buffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "BUFFS",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["aurabar"] = {
						enable = false
					}
				},
				["focus"] = {
					["smartAuraDisplay"] = "DISABLED",
					["buffs"] = {
						enable = false,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["aurabar"] = {
						enable = false
					}
				}
			},
			["bars"] = {
				["player"] = {
					["buffs"] = {
						enable = false,
						attachTo = "FRAME"
					},
					["debuffs"] = {
						enable = false,
						attachTo = "FRAME"
					},
					["aurabar"] = {
						enable = true,
						attachTo = "FRAME"
					}
				},
				["target"] = {
					["smartAuraDisplay"] = "SHOW_DEBUFFS_ON_FRIENDLIES",
					["buffs"] = {
						enable = false,
						attachTo = "FRAME"
					},
					["debuffs"] = {
						enable = false,
						attachTo = "FRAME"
					},
					["aurabar"] = {
						enable = true,
						attachTo = "FRAME"
					}
				},
				["focus"] = {
					["smartAuraDisplay"] = "SHOW_DEBUFFS_ON_FRIENDLIES",
					["buffs"] = {
						enable = false,
						attachTo = "FRAME"
					},
					["debuffs"] = {
						enable = false,
						attachTo = "FRAME"
					},
					["aurabar"] = {
						enable = true,
						attachTo = "FRAME"
					}
				}
			},
			["theworks"] = {
				["player"] = {
					["buffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPLEFT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'RIGHT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "BUFFS",
						anchorPoint = 'TOPLEFT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'RIGHT',
					},
					["aurabar"] = {
						enable = true,
						attachTo = "DEBUFFS"
					}
				},
				["target"] = {
					["smartAuraDisplay"] = "SHOW_DEBUFFS_ON_FRIENDLIES",
					["buffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "BUFFS",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["aurabar"] = {
						enable = true,
						attachTo = "DEBUFFS"
					}
				},
				["focus"] = {
					["smartAuraDisplay"] = "SHOW_DEBUFFS_ON_FRIENDLIES",
					["buffs"] = {
						enable = true,
						attachTo = "FRAME",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["debuffs"] = {
						enable = true,
						attachTo = "BUFFS",
						anchorPoint = 'TOPRIGHT',
						verticalGrowth = 'UP',
						horizontalGrowth = 'LEFT',
					},
					["aurabar"] = {
						enable = true,
						attachTo = "DEBUFFS"
					}
				}
			},
		},
		["bars"] = {
			["link"] = "SVBar",
			["default"] = {
				["Bar1"] = {
					buttonsize = 32
				},
				["Bar2"] = {
					enable = false
				},
				["Bar3"] = {
					buttons = 6,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 32
				},
				["Bar5"] = {
					buttons = 6,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 32
				}
			},
			["onebig"] = {
				["Bar1"] = {
					buttonsize = 40
				},
				["Bar2"] = {
					enable = false
				},
				["Bar3"] = {
					buttons = 6,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 40
				},
				["Bar5"] = {
					buttons = 6,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 40
				}
			},
			["twosmall"] = {
				["Bar1"] = {
					buttonsize = 32
				},
				["Bar2"] = {
					enable = true,
					buttonsize = 32
				},
				["Bar3"] = {
					buttons = 12,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 32
				},
				["Bar5"] = {
					buttons = 12,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 32
				}
			},
			["twobig"] = {
				["Bar1"] = {
					buttonsize = 40
				},
				["Bar2"] = {
					enable = true,
					buttonsize = 40
				},
				["Bar3"] = {
					buttons = 12,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 40
				},
				["Bar5"] = {
					buttons = 12,
					buttonspacing = 2,
					buttonsPerRow = 6,
					buttonsize = 40
				}
			},
		},
		["units"] = {
			["link"] = "SVUnit",
			["default"] = {
				["player"] = {
					width = 215,
					height = 60,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					}
				},
				["target"] = {
					width = 215,
					height = 60,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					}
				},
				["pet"] = {
					width = 130,
					height = 30,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					name = {
						position = "CENTER"
					},
				},
				["targettarget"] = {
					width = 130,
					height = 30,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					name = {
						position = "CENTER"
					},
				},
				["boss"] = {
					width = 200,
					height = 45,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					}
				},
				["party"] = {
					width = 75,
					height = 60,
					wrapXOffset = 9,
					wrapYOffset = 13,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					name = {
						position = "INNERTOPLEFT"
					},
				},
				["raid"] = {
					width = 50,
					height = 30,
					wrapXOffset = 6,
					wrapYOffset = 6,
				},
			},
			["super"] = {
				["player"] = {
					width = 215,
					height = 60,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					}
				},
				["target"] = {
					width = 215,
					height = 60,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					}
				},
				["pet"] = {
					width = 150,
					height = 30,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					name = {
						position = "CENTER"
					},
				},
				["targettarget"] = {
					width = 150,
					height = 30,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					name = {
						position = "CENTER"
					},
				},
				["boss"] = {
					width = 200,
					height = 45,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					}
				},
				["party"] = {
					width = 75,
					height = 60,
					wrapXOffset = 9,
					wrapYOffset = 13,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					name = {
						position = "INNERTOPLEFT"
					},
				},
				["raid"] = {
					width = 50,
					height = 30,
					wrapXOffset = 6,
					wrapYOffset = 6,
				},
			},
			["simple"] = {
				["player"] = {
					width = 215,
					height = 60,
					portrait = {
						enable = true,
						overlay = false,
						style = "2D",
						width = 60, 
					}
				},
				["target"] = {
					width = 215,
					height = 60,
					portrait = {
						enable = true,
						overlay = false,
						style = "2D",
						width = 60,
					}
				},
				["pet"] = {
					width = 150,
					height = 30,
					portrait = {
						enable = true,
						overlay = false,
						style = "2D",
						width = 30,
					},
					name = {
						position = "INNERLEFT"
					},
				},
				["targettarget"] = {
					width = 150,
					height = 30,
					portrait = {
						enable = true,
						overlay = false,
						style = "2D",
						width = 30,
					},
					name = {
						position = "INNERLEFT"
					},
				},
				["boss"] = {
					width = 200,
					height = 45,
					portrait = {
						enable = true,
						overlay = false,
						style = "2D",
						width = 45,
					}
				},
				["party"] = {
					width = 100,
					height = 35,
					wrapXOffset = 9,
					wrapYOffset = 13,
					portrait = {
						enable = true,
						overlay = false,
						style = "2D",
						width = 35,
					},
					name = {
						position = "INNERRIGHT"
					},
				},
				["raid"] = {
					width = 50,
					height = 30,
					wrapXOffset = 6,
					wrapYOffset = 6,
				},
			},
			["compact"] = {
				["player"] = {
					width = 215,
					height = 50,
					portrait = {
						enable = false
					}
				},
				["target"] = {
					width = 215,
					height = 50,
					portrait = {
						enable = false
					}
				},
				["pet"] = {
					width = 130,
					height = 30,
					portrait = {
						enable = false
					},
					name = {
						position = "CENTER"
					},
				},
				["targettarget"] = {
					width = 130,
					height = 30,
					portrait = {
						enable = false
					},
					name = {
						position = "CENTER"
					},
				},
				["boss"] = {
					width = 200,
					height = 45,
					portrait = {
						enable = false
					}
				},
				["party"] = {
					width = 70,
					height = 30,
					wrapXOffset = 9,
					wrapYOffset = 13,
					portrait = {
						enable = false
					},
					name = {
						position = "INNERTOPLEFT"
					},
				},
				["raid"] = {
					width = 50,
					height = 30,
					wrapXOffset = 6,
					wrapYOffset = 6,
				},
			},
		},
		["layouts"] = {
			["link"] = "SVUnit",
			["default"] = {
				["grid"] = {
					["enable"] = false,
				},
				["party"] = {
					width = 75,
					height = 60,
					wrapXOffset = 9,
					wrapYOffset = 13,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					icons = {
						roleIcon = {
							["attachTo"] = "INNERBOTTOMRIGHT",
							["xOffset"] = 0,
							["yOffset"] = 0,
						},
					},
					name = {
						["font"] = "SVUI Default Font",
						["fontOutline"] = "OUTLINE",
						["position"] = "INNERTOPLEFT",
						["xOffset"] = 0,
						["yOffset"] = 0,
					},
				},
				["raid"] = {
					width = 50,
					height = 30,
					gRowCol = 1,
					wrapXOffset = 9,
					wrapYOffset = 13,
					showBy = "RIGHT_DOWN",
					["power"] = {
						["enable"] = false,
					},
					["icons"] = {
						["roleIcon"] = {
							["attachTo"] = "INNERBOTTOMLEFT", 
							["xOffset"] = 8, 
							["yOffset"] = 1, 
						},
					},
					["name"] = {
						["font"] = "SVUI Default Font",
						["position"] = "INNERTOPLEFT",
						["xOffset"] = 8,
						["yOffset"] = 0,
					},
				},
			},
			["healer"] = {
				["grid"] = {
					["enable"] = false,
				},
				["party"] = {
					width = 75,
					height = 60,
					wrapXOffset = 9,
					wrapYOffset = 13,
					portrait = {
						enable = true,
						overlay = true,
						style = "3D",
					},
					["icons"] = {
						["roleIcon"] = {
							["attachTo"] = "INNERBOTTOMRIGHT",
							["xOffset"] = 0,
							["yOffset"] = 0,
						},
					},
					["name"] = {
						["font"] = "SVUI Default Font",
						["fontOutline"] = "OUTLINE",
						["position"] = "INNERTOPLEFT",
						["xOffset"] = 0,
						["yOffset"] = 0,
					},
				},
				["raid"] = {
					width = 50,
					height = 30,
					["showBy"] = "DOWN_RIGHT",
					["gRowCol"] = 1,
					["wrapXOffset"] = 4,
					["wrapYOffset"] = 4,
					["power"] = {
						["enable"] = true,
					},
					["icons"] = {
						["roleIcon"] = {
							["attachTo"] = "INNERBOTTOMLEFT", 
							["xOffset"] = 8, 
							["yOffset"] = 0, 
						},
					},
					["name"] = {
						["font"] = "SVUI Default Font",
						["position"] = "INNERTOPLEFT",
						["xOffset"] = 8,
						["yOffset"] = 0,
					},
				},
			},
			["dps"] = {
				["grid"] = {
					["enable"] = false,
				},
				["party"] = {
					width = 115,
					height = 25,
					wrapXOffset = 9,
					wrapYOffset = 13,
					["power"] = {
						["enable"] = false,
					},
					portrait = {
						enable = false,
						overlay = false,
						style = "2D",
						width = 35,
					},
					["icons"] = {
						["roleIcon"] = {
							["attachTo"] = "LEFT",
							["xOffset"] = -2,
							["yOffset"] = 0,
						},
					},
					["name"] = {
						["font"] = "Roboto",
						["fontOutline"] = "NONE",
						["position"] = "CENTER",
						["xOffset"] = 0,
						["yOffset"] = 1,
					},
				},
				["raid"] = {
					["showBy"] = "UP_RIGHT",
					["gRowCol"] = 4,
					["wrapXOffset"] = 4,
					["wrapYOffset"] = 4,
					["power"] = {
						["enable"] = false,
					},
					["icons"] = {
						["roleIcon"] = {
							["attachTo"] = "INNERLEFT",
							["xOffset"] = 10,
							["yOffset"] = 1,
						},
					},
					["name"] = {
						["font"] = "Roboto",
						["position"] = "CENTER",
						["xOffset"] = 0,
						["yOffset"] = 1,
					},
					["width"] = 80,
					["height"] = 20,
				},
			},
			["grid"] = {
				["grid"] = {
					["enable"] = true,
					["size"] = 34,
					["shownames"] = true,
				},
				["party"] = {
					["gridAllowed"] = true,
					["wrapXOffset"] = 1,
					["wrapYOffset"] = 1,
					["power"] = {
						["enable"] = false,
					},
					portrait = {
						enable = false,
					},
				},
				["raid"] = {
					["gridAllowed"] = true,
					["wrapXOffset"] = 1,
					["wrapYOffset"] = 1,
					["gRowCol"] = 1,
					["showBy"] = "RIGHT_DOWN",
				},
			},
		}
	};

	if(SV.UserPresets) then
		for key, data in pairs(SV.UserPresets) do
			for category, presets in pairs(data) do
				PRESET_DATA[key][category] = presets
			end
		end
	end
end

local function LoadPageData()
	PAGE_DIALOG = {
		--PAGE 1
		{
			["SubTitle"] = (L["This is Supervillain UI version %s!"]):format(SV.Version),

			["Desc1"] = L["Before I can turn you loose, persuing whatever villainy you feel will advance your professional career... I need to ask some questions and turn a few screws first."],
			["Desc2"] = L["At any time you can get to the config options by typing the command  / sv. For quick changes to frame, bar or color sets, call your henchman by clicking the button on the bottom right of your screen. (Its the one with his stupid face on it)"],
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option01"] = {USE.."\n"..DEFAULT.."\n"..SETTINGS, "EZDefault"},
			["Option02"] = {"PRETEND YOU\nDID THIS\nALREADY", "Complete"},
			["Option03"] = {"Keep\nSaved\n"..SETTINGS, "Complete", nil, hasOldConfigs},
		},
		--PAGE 2
		{
			["SubTitle"] = CHAT,

			["Desc1"] = L["Whether you want to or not, you will be needing a communicator so other villains can either update you on their doings-of-evil or inform you about the MANY abilities of Chuck Norris"],
			["Desc2"] = L["The chat windows function the same as standard chat windows, you can right click the tabs and drag them, rename them, slap them around, you know... whatever. Clickity-click to setup your chat windows."],
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option1"] = {CHAT_DEFAULTS, "ChatConfigs"},
		},
		--PAGE 3
		{
			["SubTitle"] = RESOLUTION,

			["Desc1"] = (L["Your current resolution is %s, this is considered a %s resolution."]):format(GetCVar("gxResolution"), (SV.LowRez and LOW or HIGH)),
			["Desc2"] = isLowRez,
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option1"] = {HIGH, "UserScreen", "high"},
			["Option2"] = {LOW, "UserScreen", "low"},
		},
		--PAGE 4
		{
			["SubTitle"] = COLOR.." "..SETTINGS,

			["Desc1"] = L["Choose a theme layout you wish to use for your initial setup."],
			["Desc2"] = L["You can always change fonts and colors of any element of Supervillain UI from the in-game configuration."],
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option1"] = {L["Kaboom!"], "ColorTheme", "kaboom"},
			["Option2"] = {L["Darkness"], "ColorTheme", "dark"},
			["Option3"] = {L["Class" .. "\n" .. "Colors"], "ColorTheme", "classy"},
			["Option4"] = {L["Vintage"], "ColorTheme"},
		},
		--PAGE 5
		{
			["SubTitle"] = UNITFRAME_LABEL.." "..SETTINGS,

			["Desc1"] = L["You can now choose what primary unitframe style you wish to use."],
			["Desc2"] = L["This will change the layout of your unitframes (ie.. Player, Target, Pet, Party, Raid ...etc)."],
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option1"] = {L["Super"], "UnitframeLayout", "super"},
			["Option2"] = {L["Simple"], "UnitframeLayout", "simple"},
			["Option3"] = {L["Compact"], "UnitframeLayout", "compact"},
		},
		--PAGE 6
		{
			["SubTitle"] = "Group Layout",

			["Desc1"] = L["You can now choose what group layout you prefer."],
			["Desc2"] = L["This will adjust various settings on group units, attempting to make certain roles more usable"],
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option1"] = {L["Standard"], "GroupframeLayout", "default"},
			["Option2"] = {L["Healer"], "GroupframeLayout", "healer"},
			["Option3"] = {L["DPS"], "GroupframeLayout", "dps"},
			["Option4"] = {L["Grid"], "GroupframeLayout", "grid"},
		},
		--PAGE 7
		{
			["SubTitle"] = ACTIONBAR_LABEL.." "..SETTINGS,

			["Desc1"] = L["Choose a layout for your action bars."],
			["Desc2"] = L["Sometimes you need big buttons, sometimes you don't. Your choice here."],
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option1"] = {L["Small" .. "\n" .. "Row"], "BarLayout", "default"},
			["Option2"] = {L["2 Small" .. "\n" .. "Rows"], "BarLayout", "twosmall"},
			["Option3"] = {L["Big" .. "\n" .. "Row"], "BarLayout", "onebig"},
			["Option4"] = {L["2 Big" .. "\n" .. "Rows"], "BarLayout", "twobig"},
		},
		--PAGE 8
		{
			["SubTitle"] = AURAS.." "..SETTINGS,

			["Desc1"] = L["Select an aura layout. \"Icons\" will display only icons and aurabars won't be used. \"Bars\" will display only aurabars and icons won't be used (duh). \"The Works!\" does just what it says.... icons, bars and awesomeness."],
			["Desc2"] = L["If you have an aura that you don't want to display simply hold down shift and right click the icon for it to suffer a painful death."],
			["Desc3"] = L["CHOOSE_OR_DIE"],

			["Option1"] = {L["Vintage"], "Auralayout"},
			["Option2"] = {L["Icons"], "Auralayout", "icons"},
			["Option3"] = {L["Bars"], "Auralayout", "bars"},
			["Option4"] = {L["The" .. "\n" .. "Works!"], "Auralayout", "theworks"},
		},
		--PAGE 9
		{
			["SubTitle"] = BASIC_OPTIONS_TOOLTIP..CONTINUED..AUCTION_TIME_LEFT0,

			["Desc1"] = L["Thats it! All done! Now we just need to hand these choices off to the henchmen so they can get you ready to (..insert evil tasks here..)!"],
			["Desc2"] = L["Click the button below to reload and get on your way! Good luck villain!"],

			["Option1"] = {L["THE_BUTTON_BELOW"], "Complete"},
		},
	};
end

local function LoadOnClickData()
	CLICK_DIALOG = {
		["Page3_Option1"] = {
			["Desc1"] = L["|cffFF9F00"..HIGH.." "..RESOLUTION.."!|r"],
			["Desc2"] = L["So what you think your better than me with your big monitor? HUH?!?!"],
			["Desc3"] = L["Dont forget whos in charge here! But enjoy the incredible detail."],
		},
		["Page3_Option2"] = {
			["Desc1"] = L["|cffFF9F00"..LOW.." "..RESOLUTION.."|r"],
			["Desc2"] = L["Why are you playing this on what I would assume is a calculator display?"],
			["Desc3"] = L["Enjoy the ONE incredible pixel that fits on this screen."],
		},
		["Page4_Option1"] = {
			["Desc1"] = L["|cffFF9F00KABOOOOM!|r"],
			["Desc2"] = L["This theme tells the world that you are a villain who can put on a show"]..CONTINUED,
			["Desc3"] = CONTINUED..L["or better yet, you ARE the show!"],
		},
		["Page4_Option2"] = {
			["Desc1"] = L["|cffAF30FFThe Darkest Night|r"],
			["Desc2"] = L["This theme indicates that you have no interest in wasting time"]..CONTINUED,
			["Desc3"] = CONTINUED..L[" the dying begins NOW!"],
		},
		["Page4_Option3"] = {
			["Desc1"] = L["|cffFFFF00"..CLASS_COLORS.."|r"],
			["Desc2"] = L["This theme is for villains who take pride in their class"]..CONTINUED,
			["Desc3"] = CONTINUED..L[" villains know how to reprezent!"],
		},
		["Page4_Option4"] = {
			["Desc1"] = L["|cff00FFFFPlain and Simple|r"],
			["Desc2"] = L["This theme is for any villain who sticks to their traditions"]..CONTINUED,
			["Desc3"] = CONTINUED..L["you don't need fancyness to kick some ass!"],
		},
		["Page5_Option1"] = {
			["Desc1"] = L["|cff00FFFFLets Do This|r"],
			["Desc2"] = L["This layout is anything but minimal! Using this is like being at a rock concert"]..CONTINUED,
			["Desc3"] = CONTINUED..L["then annihilating the crowd with frickin lazer beams!"],
		},
		["Page5_Option2"] = {
			["Desc1"] = L["|cff00FFFFSimply Simple|r"],
			["Desc2"] = L["This layout is for the villain who just wants to get things done!"]..CONTINUED,
			["Desc3"] = CONTINUED..L["but he still wants to see your face before he hits you!"],
		},
		["Page5_Option3"] = {
			["Desc1"] = L["|cff00FFFFEl Compacto|r"],
			["Desc2"] = L["Just the necessities so you can see more of the world around you"]..CONTINUED,
			["Desc3"] = CONTINUED..L["you dont need no fanciness getting in the way of world domination do you?"],
		},
		["Page6_Option1"] = {
			["Desc1"] = L["|cff00FFFFStandard|r"],
			["Desc2"] = L["You are good to go with the default layout"]..CONTINUED,
			["Desc3"] = CONTINUED..L["frames schmames, lets kill some stuff!"],
		},
		["Page6_Option2"] = {
			["Desc1"] = L["|cff00FFFFMEDIC!!|r"],
			["Desc2"] = L["You are pretty helpful.. for a VILLAIN!"]..CONTINUED,
			["Desc3"] = CONTINUED..L["Hey, even a super villain gets his ass kicked once in awhile. We need the likes of you!"],
		},
		["Page6_Option3"] = {
			["Desc1"] = L["|cff00FFFFDeath Dealer|r"],
			["Desc2"] = L["You are the kings of our craft. Handing out pain like its halloween candy."]..CONTINUED,
			["Desc3"] = CONTINUED..L["I will move and squeeze group frames out of your way so you have more room for BOOM!"],
		},
		["Page6_Option4"] = {
			["Desc1"] = L["|cff00FFFFCubed|r"],
			["Desc2"] = L["You are cold and calculated, your frames should reflect as much."]..CONTINUED,
			["Desc3"] = CONTINUED..L["I'm gonna make these frames so precise that you can cut your finger on them!"],
		},
		["Page7_Option1"] = {
			["Desc1"] = L["|cff00FFFFLean And Clean|r"],
			["Desc2"] = L["Lets keep it slim and deadly, not unlike a ninja sword."],
			["Desc3"] = L["You dont ever even look at your bar hardly, so pick this one!"],
		},
		["Page7_Option2"] = {
			["Desc1"] = L["|cff00FFFFMore For Less|r"],
			["Desc2"] = L["Granted, you dont REALLY need the buttons due to your hotkey-leetness, you just like watching cooldowns!"],
			["Desc3"] = L["Sure thing cowboy, your secret is safe with me!"],
		},
		["Page7_Option3"] = {
			["Desc1"] = L["|cff00FFFFWhat Big Buttons You Have|r"],
			["Desc2"] = L["The better to PEW-PEW you with my dear!"],
			["Desc3"] = L["When you have little time for mouse accuracy, choose this set!"],
		},
		["Page7_Option4"] = {
			["Desc1"] = L["|cff00FFFFThe Double Down|r"],
			["Desc2"] = L["Lets be honest for a moment. Who doesnt like a huge pair in their face?"],
			["Desc3"] = L["Double your bars then double their size for maximum button goodness!"],
		},
	};
end
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function _copyPresets(saved, preset)
	--if not saved then return end
	if(type(preset) == 'table') then
        for key,val in pairs(preset) do
        	if(not saved[key]) then saved[key] = {} end
    		if(type(val) == "table") then
    			_copyPresets(saved[key], val)
    		elseif(saved[key]) then
            	saved[key] = val
            end
        end
    else
    	saved = preset
    end
end

function SV.Setup:CopyPreset(category, theme)
	if(not PRESET_DATA) then LoadPresetData() end
	if(PRESET_DATA and PRESET_DATA[category] and PRESET_DATA[category]["link"]) then
		theme = theme or "default"
		local saved = PRESET_DATA[category]["link"]
		local preset =  PRESET_DATA[category][theme]
		local data = SV.db[saved]
	
		if(data) then
	    	_copyPresets(data, preset)
	    end
	end
end

function SV.Setup:CopyPage(pageNum)
	if(not PAGE_DIALOG) then LoadPageData() end
	if(PAGE_DIALOG and PAGE_DIALOG[pageNum]) then
		return PAGE_DIALOG[pageNum], #PAGE_DIALOG
	end
end

function SV.Setup:CopyOnClick(index)
	if(not CLICK_DIALOG) then LoadOnClickData() end
	if(CLICK_DIALOG and CLICK_DIALOG[index]) then
		return CLICK_DIALOG[index]
	end
end