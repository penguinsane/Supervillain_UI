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
local unpack 	 =  _G.unpack;
local pairs 	 =  _G.pairs;
local tinsert 	 =  _G.tinsert;
local table 	 =  _G.table;
--[[ TABLE METHODS ]]--
local tsort = table.sort;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local Ace3Config = LibStub("AceConfig-3.0");
local Ace3ConfigDialog = LibStub("AceConfigDialog-3.0");
Ace3Config:RegisterOptionsTable(SV.NameID, SV.Options);
Ace3ConfigDialog:SetDefaultSize(SV.NameID, 890, 651);
local AceGUI = LibStub("AceGUI-3.0", true);

local sortingFunction = function(arg1, arg2) return arg1 < arg2 end 

local function CommonFontSizeUpdate()
    local STANDARDFONTSIZE = SV.db.media.fonts.size;
    local smallfont = STANDARDFONTSIZE - 2;
    local largefont = STANDARDFONTSIZE + 2;
    SV.db.SVAura.fontSize = STANDARDFONTSIZE;
    SV.db.SVStats.fontSize = STANDARDFONTSIZE;
    SV.db.SVUnit.fontSize = STANDARDFONTSIZE;
    SV.db.SVUnit.auraFontSize = smallfont;

    SV.db.SVBar.fontSize = smallfont;
    SV.db.SVPlate.fontSize = smallfont;
    
    SV.db.SVUnit.player.health.fontSize = largefont;
    SV.db.SVUnit.player.power.fontSize = largefont;
    SV.db.SVUnit.player.name.fontSize = largefont;
    SV.db.SVUnit.player.aurabar.fontSize = STANDARDFONTSIZE;

    SV.db.SVUnit.target.health.fontSize = largefont;
    SV.db.SVUnit.target.power.fontSize = largefont;
    SV.db.SVUnit.target.name.fontSize = largefont;
    SV.db.SVUnit.target.aurabar.fontSize = STANDARDFONTSIZE;

    SV.db.SVUnit.focus.health.fontSize = largefont;
    SV.db.SVUnit.focus.power.fontSize = largefont;
    SV.db.SVUnit.focus.name.fontSize = largefont;
    SV.db.SVUnit.focus.aurabar.fontSize = STANDARDFONTSIZE;

    SV.db.SVUnit.targettarget.health.fontSize = largefont;
    SV.db.SVUnit.targettarget.power.fontSize = largefont;
    SV.db.SVUnit.targettarget.name.fontSize = largefont;

    SV.db.SVUnit.focustarget.health.fontSize = largefont;
    SV.db.SVUnit.focustarget.power.fontSize = largefont;
    SV.db.SVUnit.focustarget.name.fontSize = largefont;

    SV.db.SVUnit.pet.health.fontSize = largefont;
    SV.db.SVUnit.pet.power.fontSize = largefont;
    SV.db.SVUnit.pet.name.fontSize = largefont;

    SV.db.SVUnit.pettarget.health.fontSize = largefont;
    SV.db.SVUnit.pettarget.power.fontSize = largefont;
    SV.db.SVUnit.pettarget.name.fontSize = largefont;

    SV.db.SVUnit.party.health.fontSize = largefont;
    SV.db.SVUnit.party.power.fontSize = largefont;
    SV.db.SVUnit.party.name.fontSize = largefont;

    SV.db.SVUnit.boss.health.fontSize = largefont;
    SV.db.SVUnit.boss.power.fontSize = largefont;
    SV.db.SVUnit.boss.name.fontSize = largefont;

    SV.db.SVUnit.arena.health.fontSize = largefont;
    SV.db.SVUnit.arena.power.fontSize = largefont;
    SV.db.SVUnit.arena.name.fontSize = largefont;

    SV.db.SVUnit.raid.health.fontSize = largefont;
    SV.db.SVUnit.raid.power.fontSize = largefont;
    SV.db.SVUnit.raid.name.fontSize = largefont;

    SV.db.SVUnit.tank.health.fontSize = largefont;
    SV.db.SVUnit.assist.health.fontSize = largefont;

    SV:RefreshSystemFonts()
end 
--[[ 
########################################################## 
SET PACKAGE OPTIONS
##########################################################
]]--
SV.Options.args.SVUI_Header = {
	order = 1, 
	type = "header", 
	name = ("You are using |cffff9900Super Villain UI|r - %s: |cff99ff33%s|r"):format(L["Version"], SV.Version), 
	width = "full"
}

SV.Options.args.primary = {
	type = "group", 
	order = 1, 
	name = L["Main"], 
	get = function(j)return SV.db[j[#j]]end, 
	set = function(j, value)SV.db[j[#j]] = value end, 
	args = {
		introGroup1 = {
			order = 1, 
			name = "", 
			type = "description", 
			width = "full", 
			image = function()return "Interface\\AddOns\\SVUI\\assets\\artwork\\SPLASH", 256, 128 end, 
		}, 
		introGroup2 = {
			order = 2, 
			name = L["Here are a few basic quick-change options to possibly save you some time."], 
			type = "description", 
			width = "full", 
			fontSize = "large", 
		}, 
		quickGroup1 = {
			order = 3, 
			name = "", 
			type = "group", 
			width = "full", 
			guiInline = true, 
			args = {
				Install = {
					order = 3, 
					width = "full", 
					type = "execute", 
					name = L["Install"], 
					desc = L["Run the installation process."], 
					func = function() SV.Setup:Install() SV:ToggleConfig() end
				},
				ToggleAnchors = {
					order = 4, 
					width = "full", 
					type = "execute", 
					name = L["Move Frames"], 
					desc = L["Unlock various elements of the UI to be repositioned."], 
					func = function() SV.Mentalo:Toggle() end
				},
				ResetAllMovers = {
					order = 5, 
					width = "full", 
					type = "execute", 
					name = L["Reset Anchors"], 
					desc = L["Reset all frames to their original positions."], 
					func = function() SV.Mentalo:Reset() end
				},
				toggleKeybind = {
					order = 6, 
					width = "full", 
					type = "execute", 
					name = L["Keybind Mode"], 
					func = function()
						SV.SVBar:ToggleKeyBindingMode()
						SV:ToggleConfig()
						GameTooltip:Hide()
					end, 
					disabled = function() return not SV.db.SVBar.enable end
				}
			}, 
		}, 
		quickGroup2 = {
			order = 4, 
			name = "", 
			type = "group", 
			width = "full", 
			guiInline = true, 
			args = {}, 
		}, 	
	}
};

SV.Options.args.common = {
	type = "group", 
	order = 2, 
	name = L["General"], 
	childGroups = "tab", 
	get = function(key) return SV.db[key[#key]] end, 
	set = function(key, value) SV.db[key[#key]] = value end, 
	args = {
		commonGroup = {
			order = 1, 
			type = 'group', 
			name = L['General Options'], 
			childGroups = "tree", 
			args = {
				common = {
					order = 1, 
					type = "group", 
					name = L["Misc"], 
					args = {
						baseGroup = {
							order = 1, 
							type = "group", 
							guiInline = true, 
							name = L["Common Stuff"],
							args = {
								autoScale = {
									order = 1,
									name = L["Auto Scale"],
									desc = L["Automatically scale the User Interface based on your screen resolution"],
									type = "toggle",
									get = function(j)return SV.db.general.autoScale end,
									set = function(j,value)SV.db.general.autoScale = value;SV:StaticPopup_Show("RL_CLIENT")end
								},
								multiMonitor = {
									order = 2,
									name = L["Multi Monitor"],
									desc = L["Adjust UI dimensions to accomodate for multiple monitor setups"],
									type = "toggle",
									get = function(j)return SV.db.general.multiMonitor end,
									set = function(j,value)SV.db.general.multiMonitor = value;SV:StaticPopup_Show("RL_CLIENT")end
								},
								hideErrorFrame = {
									order = 3,
									name = L["Hide Error Text"],
									desc = L["Hides the red error text at the top of the screen while in combat."],
									type = "toggle",
									get = function(j)return SV.db.general.hideErrorFrame end,
									set = function(j,value)SV.db.general.hideErrorFrame = value;SV:StaticPopup_Show("RL_CLIENT")end
								},
								LoginMessage = {
									order = 4,
									type = 'toggle',
									name = L['Login Message'],
									get = function(j)return SV.db.general.loginmessage end,
									set = function(j,value)SV.db.general.loginmessage = value end
								},
							}
						},
						lootGroup = {
							order = 2, 
							type = "group", 
							guiInline = true, 
							name = L["Loot Frame / Roll"],
							args = {
								loot = {
									order = 1,
									type = "toggle",
									name = L['Loot Frame'],
									desc = L['Enable/Disable the loot frame.'],
									get = function()return SV.db.SVOverride.loot end,
									set = function(j,value)SV.db.SVOverride.loot = value;SV:StaticPopup_Show("RL_CLIENT")end
								},
								lootRoll = {
									order = 2,
									type = "toggle",
									name = L['Loot Roll'],
									desc = L['Enable/Disable the loot roll frame.'],
									get = function()return SV.db.SVOverride.lootRoll end,
									set = function(j,value)SV.db.SVOverride.lootRoll = value;SV:StaticPopup_Show("RL_CLIENT")end
								},
								lootRollWidth = {
									order = 3,
									type = 'range',
									width = "full",
									name = L["Roll Frame Width"],
									min = 100,
									max = 328,
									step = 1,
									get = function()return SV.db.SVOverride.lootRollWidth end,
									set = function(a,b) SV.SVOverride:ChangeDBVar(b,a[#a]); end,
								},
								lootRollHeight = {
									order = 4,
									type = 'range',
									width = "full",
									name = L["Roll Frame Height"],
									min = 14,
									max = 58,
									step = 1,
									get = function()return SV.db.SVOverride.lootRollHeight end,
									set = function(a,b) SV.SVOverride:ChangeDBVar(b,a[#a]); end,
								},
							}
						},
						scriptGroup = {
							order = 3, 
							type = "group", 
							guiInline = true, 
							name = L["Fun Stuff"],
							args = {
								comix = {
									order = 1,
									type = 'toggle',
									name = L["Enable Comic Popups"],
									get = function(j)return SV.db.general.comix end,
									set = function(j,value) SV.db.general.comix = value; SV:ToggleComix() end
								},
								bigComix = {
									order = 1,
									type = 'toggle',
									name = L["Include Large Comics"],
									disabled = function() return not SV.db.general.comix end,
									get = function(j) return SV.db.general.bigComix end,
									set = function(j,value) SV.db.general.bigComix = value end
								},
								bubbles = {
									order = 2,
									type = "toggle",
									name = L['Chat Bubbles Style'],
									desc = L['Style the blizzard chat bubbles.'],
									get = function(j)return SV.db.general.bubbles end,
									set = function(j,value)SV.db.general.bubbles = value;SV:StaticPopup_Show("RL_CLIENT")end
								},
								woot = {
									order = 3,
									type = 'toggle',
									name = L["Say Thanks"],
									desc = L["Thank someone when they cast specific spells on you. Typically resurrections"], 
									get = function(j)return SV.db.general.woot end,
									set = function(j,value)SV.db.general.woot = value;SV:ToggleReactions()end
								},
								pvpinterrupt = {
									order = 4,
									type = 'toggle',
									name = L["Report PVP Actions"],
									desc = L["Announce your interrupts, as well as when you have been sapped!"],
									get = function(j)return SV.db.general.pvpinterrupt end,
									set = function(j,value)SV.db.general.pvpinterrupt = value;SV:ToggleReactions()end
								},
								lookwhaticando = {
									order = 5,
									type = 'toggle',
									name = L["Report Spells"],
									desc = L["Announce various helpful spells cast by players in your party/raid"],
									get = function(j)return SV.db.general.lookwhaticando end,
									set = function(j,value)SV.db.general.lookwhaticando = value;SV:ToggleReactions()end
								},
								sharingiscaring = {
									order = 6,
									type = 'toggle',
									name = L["Report Shareables"],
									desc = L["Announce when someone in your party/raid has laid a feast or repair bot"],
									get = function(j)return SV.db.general.sharingiscaring end,
									set = function(j,value)SV.db.general.sharingiscaring = value;SV:ToggleReactions()end
								},
								reactionChat = {
									order = 7,
									type = 'toggle',
									name = L["Report in Chat"],
									desc = L["Announcements will be sent to group chat channels"],
									get = function(j)return SV.db.general.reactionChat end,
									set = function(j,value)SV.db.general.reactionChat = value;SV:ToggleReactions()end
								},
								reactionEmote = {
									order = 8,
									type = 'toggle',
									name = L["Auto Emotes"],
									desc = L["Some announcements are accompanied by player emotes."],
									get = function(j)return SV.db.general.reactionEmote end,
									set = function(j,value)SV.db.general.reactionEmote = value;SV:ToggleReactions()end
								},
								ego = {
									order = 1,
									type = 'toggle',
									name = L["Awesome Game Menu"],
									get = function(j)return SV.db.general.ego end,
									set = function(j,value) SV.db.general.ego = value; SV.Ego:Toggle() end
								},
							}
						},
						otherGroup = {
							order = 4, 
							type = "group", 
							guiInline = true, 
							name = L["Other Stuff"],
							args = {
								threatbar = {
									order = 1, 
									type = "toggle", 
									name = L['Threat Thermometer'], 
									get = function(j)return SV.db.general.threatbar end, 
									set = function(j, value)SV.db.general.threatbar = value;SV:StaticPopup_Show("RL_CLIENT")end
								},
								totems = {
									order = 2, 
									type = "toggle", 
									name = L["Totems"], 
									get = function(j)
										return SV.db.totems.enable
									end, 
									set = function(j, value)
										SV.db.totems.enable = value;
										SV:StaticPopup_Show("RL_CLIENT")
									end
								},
								cooldownText = {
									type = "toggle", 
									order = 3, 
									name = L['Cooldown Text'], 
									desc = L["Display cooldown text on anything with the cooldown spiral."], 
									get = function(j)return SV.db.general.cooldown end, 
									set = function(j,value)SV.db.general.cooldown = value; SV:StaticPopup_Show("RL_CLIENT")end
								},
								size = {
									order = 4, 
									type = 'range',
									width = "full",
									name = L["Totem Button Size"], 
									min = 24, 
									max = 60, 
									step = 1,
									get = function(j)
										return SV.db.totems[j[#j]]
									end, 
									set = function(j, value)
										SV.db.totems[j[#j]] = value
									end
								},
								spacing = {
									order = 5, 
									type = 'range', 
									width = "full",
									name = L['Totem Button Spacing'], 
									min = 1, 
									max = 10, 
									step = 1,
									get = function(j)
										return SV.db.totems[j[#j]]
									end, 
									set = function(j, value)
										SV.db.totems[j[#j]] = value
									end
								},
								sortDirection = {
									order = 6, 
									type = 'select', 
									name = L["Totem Sort Direction"], 
									values = {
										['ASCENDING'] = L['Ascending'], 
										['DESCENDING'] = L['Descending']
									},
									get = function(j)
										return SV.db.totems[j[#j]]
									end, 
									set = function(j, value)
										SV.db.totems[j[#j]] = value
									end
								},
								showBy = {
									order = 7, 
									type = 'select', 
									name = L['Totem Bar Direction'], 
									values = {
										['VERTICAL'] = L['Vertical'], 
										['HORIZONTAL'] = L['Horizontal']
									},
									get = function(j)
										return SV.db.totems[j[#j]]
									end, 
									set = function(j, value)
										SV.db.totems[j[#j]] = value
									end
								}
							}
						}		
					}
				}, 
				media = {
					order = 2,
					type = "group", 
					name = L["Media"], 
					get = function(j)return SV.db[j[#j]] end, 
					set = function(j, value) SV.db[j[#j]] = value end, 
					args = {
						texture = {
							order = 1, 
							type = "group", 
							name = L["Textures"], 
							guiInline = true,
							get = function(key)
								return SV.db.media.textures[key[#key]]
							end,
							set = function(key, value)
								SV.db.media.textures[key[#key]] = value
								SV:RefreshEverything(true)
							end,
							args = {
								pattern = {
									type = "select",
									dialogControl = 'LSM30_Background',
									order = 1,
									name = L["Primary Texture"],
									values = AceGUIWidgetLSMlists.background
								},
								comic = {
									type = "select",
									dialogControl = 'LSM30_Background',
									order = 1,
									name = L["Secondary Texture"],
									values = AceGUIWidgetLSMlists.background
								}						
							}
						}, 
						fonts = {
							order = 2, 
							type = "group", 
							name = L["Fonts"], 
							guiInline = true, 
							args = {
								size = {
									order = 1,
									name = L["Font Size"],
									desc = L["Set/Override the global UI font size. |cffFF0000NOTE:|r |cffFF9900This WILL affect configurable fonts.|r"],
									type = "range",
									width = "full",
									min = 6,
									max = 22,
									step = 1,
									get = function(key)
										return SV.db.media.fonts[key[#key]]
									end,
									set = function(key,value)SV.db.media.fonts[key[#key]] = value; CommonFontSizeUpdate() end
								},
								unicodeSize = {
									order = 2,
									name = L["Unicode Font Size"],
									desc = L["Set/Override the global font size used by unstyled text. |cffFF0000(ie, Character stats, tooltips, other smaller texts)|r"],
									type = "range",
									width = "full",
									min = 6,
									max = 22,
									step = 1,
									get = function(key)
										return SV.db.media.fonts[key[#key]]
									end,
									set = function(key,value)SV.db.media.fonts[key[#key]] = value; CommonFontSizeUpdate() end
								},
								fontSpacer1 = {
									order = 3,
									type = "description",
									name = "",
									desc = "",
								},
								fontSpacer2 = {
									order = 4,
									type = "description",
									name = "",
									desc = "",
								},
								default = {
									type = "select",
									dialogControl = 'LSM30_Font',
									order = 5,
									name = L["Default Font"],
									desc = L["Set/Override the global UI font. |cff00FF00NOTE:|r |cff00FF99This WILL NOT affect configurable fonts.|r"],
									values = AceGUIWidgetLSMlists.font,
									get = function(j)return SV.db.media.fonts[j[#j]]end,
									set = function(j,value)SV.db.media.fonts[j[#j]] = value;SV:RefreshSystemFonts()end
								},
								name = {
									type = "select",
									dialogControl = 'LSM30_Font',
									order = 6,
									name = L["Unit Name Font"],
									desc = L["Set/Override the global name font. |cff00FF00NOTE:|r |cff00FF99This WILL NOT affect styled nameplates or unitframes.|r"],
									values = AceGUIWidgetLSMlists.font,
									get = function(j)return SV.db.media.fonts[j[#j]]end,
									set = function(j,value)SV.db.media.fonts[j[#j]] = value;SV:RefreshSystemFonts()end
								},
								combat = {
									type = "select",
									dialogControl = 'LSM30_Font',
									order = 7,
									name = L["CombatText Font"],
									desc = L["Set/Override the font that combat text will use. |cffFF0000NOTE:|r |cffFF9900This requires a game restart or re-log for this change to take effect.|r"],
									values = AceGUIWidgetLSMlists.font,
									get = function(j)return SV.db.media.fonts[j[#j]]end,
									set = function(j,value)SV.db.media.fonts[j[#j]] = value;SV:RefreshSystemFonts()SV:StaticPopup_Show("RL_CLIENT")end
								},
								number = {
									type = "select",
									dialogControl = 'LSM30_Font',
									order = 8,
									name = L["Numbers Font"],
									desc = L["Set/Override the global font used for numbers. |cff00FF00NOTE:|r |cff00FF99This WILL NOT affect all numbers.|r"],
									values = AceGUIWidgetLSMlists.font,
									get = function(j)return SV.db.media.fonts[j[#j]]end,
									set = function(j,value)SV.db.media.fonts[j[#j]] = value;SV:RefreshSystemFonts()end
								},					
							}
						}, 
						colors = {
							order = 3, 
							type = "group", 
							name = L["Colors"], 
							guiInline = true,
							args = {
								default = {
									type = "color",
									order = 1,
									name = L["Default Color"],
									desc = L["Main color used by most UI elements. (ex: Backdrop Color)"],
									hasAlpha = true,
									get = function(key)
										local color = SV.db.media.colors.default
										return color[1],color[2],color[3],color[4] 
									end,
									set = function(key, rValue, gValue, bValue, aValue)
										SV.db.media.colors.default = {rValue, gValue, bValue, aValue}
										SV:MediaUpdate()
									end,
								},
								special = {
									type = "color",
									order = 2,
									name = L["Accent Color"],
									desc = L["Color used in various frame accents.  (ex: Dressing Room Backdrop Color)"],
									hasAlpha = true,
									get = function(key)
										local color = SV.db.media.colors.special
										return color[1],color[2],color[3],color[4] 
									end,
									set = function(key, rValue, gValue, bValue, aValue)
										SV.db.media.colors.special = {rValue, gValue, bValue, aValue}
										SV.db.media.colors.specialdark = {(rValue * 0.75), (gValue * 0.75), (bValue * 0.75), aValue}
										SV:MediaUpdate()
									end,
								},
								resetbutton = {
									type = "execute",
									order = 3,
									name = L["Restore Defaults"],
									func = function()
										SV.db.media.colors.default = {0.15, 0.15, 0.15, 1};
										SV.db.media.colors.special = {0.4, 0.32, 0.2, 1};
										SV:MediaUpdate()
									end
								}
							}
						}
					}
				}, 
				gear = {
					order = 3,
					type = 'group',
					name = SV.SVGear.TitleID,
					get = function(key) return SV.db.SVGear[key[#key]]end,
					set = function(key, value) SV.db.SVGear[key[#key]] = value; SV.SVGear:ReLoad()end,
					args={
						intro={
							order = 1,
							type = 'description',
							name = function() 
								if(GetNumEquipmentSets()==0) then 
									return ("%s\n|cffFF0000Must create an equipment set to use some of these features|r"):format(L["EQUIPMENT_DESC"])
								else 
									return L["EQUIPMENT_DESC"] 
								end 
							end
						},
						specialization = {
							order = 2,
							type = "group",
							name = L["Specialization"],
							guiInline = true,
							disabled = function() return GetNumEquipmentSets() == 0 end,
							args = {
								enable = {
									type = "toggle",
									order = 1,
									name = L["Enable"],
									desc = L["Enable/Disable the specialization switch."],
									get = function(key)
										return SV.db.SVGear.specialization.enable 
									end,
									set = function(key, value) 
										SV.db.SVGear.specialization.enable = value 
									end
								},
								primary = {
									type = "select",
									order = 2,
									name = L["Primary Talent"],
									desc = L["Choose the equipment set to use for your primary specialization."],
									disabled = function()
										return not SV.db.SVGear.specialization.enable 
									end,
									values = function()
										local h = {["none"] = L["No Change"]}
										for i = 1, GetNumEquipmentSets()do 	
											local name = GetEquipmentSetInfo(i)
											if name then
												h[name] = name 
											end 
										end 
										tsort(h, sortingFunction)
										return h 
									end
								},
								secondary = {
									type = "select",
									order = 3,
									name = L["Secondary Talent"],
									desc = L["Choose the equipment set to use for your secondary specialization."],
									disabled = function() return not SV.db.SVGear.specialization.enable end,
									values = function()	
										local h = {["none"] = L["No Change"]}
										for i = 1, GetNumEquipmentSets()do 
											local name = GetEquipmentSetInfo(i)
											if name then h[name] = name end 
										end 
										tsort(h, sortingFunction)
										return h 
									end
								}
							}
						},
						battleground = {
							order = 3,
							type = "group",
							name = L["Battleground"],
							guiInline = true,
							disabled = function()return GetNumEquipmentSets() == 0 end,
							args = {
								enable = {
									type = "toggle",
									order = 1,
									name = L["Enable"],
									desc = L["Enable/Disable the battleground switch."],
									get = function(e)return SV.db.SVGear.battleground.enable end,
									set = function(e,value)SV.db.SVGear.battleground.enable = value end
								},
								equipmentset = {
									type = "select",
									order = 2,
									name = L["Equipment Set"],
									desc = L["Choose the equipment set to use when you enter a battleground or arena."],
									disabled = function()return not SV.db.SVGear.battleground.enable end,
									values = function()
										local h = {["none"] = L["No Change"]}
										for i = 1,GetNumEquipmentSets()do 
											local name = GetEquipmentSetInfo(i)
											if name then h[name] = name end 
										end 
										tsort(h, sortingFunction)
										return h 
									end
								}
							}
						},
						intro2 = {
							type = "description",
							name = L["DURABILITY_DESC"],
							order = 4
						},
						durability = {
							type = "group",
							name = DURABILITY,
							guiInline = true,
							order = 5,
							get = function(e)return SV.db.SVGear.durability[e[#e]]end,
							set = function(e,value)SV.db.SVGear.durability[e[#e]] = value; SV.SVGear:ReLoad()end,
							args = {
								enable = {
									type = "toggle",
									order = 1,
									name = L["Enable"],
									desc = L["Enable/Disable the display of durability information on the character screen."]
								},
								onlydamaged = {
									type = "toggle",
									order = 2,
									name = L["Damaged Only"],
									desc = L["Only show durability information for items that are damaged."],
									disabled = function()return not SV.db.SVGear.durability.enable end
								}
							}
						},
						intro3 = {
							type = "description",
							name = L["ITEMLEVEL_DESC"],
							order = 6
						},
						itemlevel = {
							type = "group",
							name = STAT_AVERAGE_ITEM_LEVEL,
							guiInline = true,
							order = 7,
							get = function(e)return SV.db.SVGear.itemlevel[e[#e]]end,
							set = function(e,value)SV.db.SVGear.itemlevel[e[#e]] = value; SV.SVGear:ReLoad()end,
							args = {
								enable = {
									type = "toggle",
									order = 1,
									name = L["Enable"],
									desc = L["Enable/Disable the display of item levels on the character screen."]
								}
							}
						},
						misc = {
							type = "group",
							name = L["Miscellaneous"],
							guiInline = true,
							order = 8,
							get = function(e)return SV.db.SVGear.misc[e[#e]]end,
							set = function(e,value)SV.db.SVGear.misc[e[#e]] = value end,
							disabled = function()return not SV.db.SVBag.enable end,
							args = {
								setoverlay = {
									type = "toggle",
									order = 1,
									name = L["Equipment Set Overlay"],
									desc = L["Show the associated equipment sets for the items in your bags (or bank)."],
									set = function(e,value)
										SV.db.SVGear.misc[e[#e]] = value;
										SV.SVBag:ToggleEquipmentOverlay()
									end
								}
							}
						}
					}
				} 
			}, 
		}, 
	}
};

SV.Options.args.credits = {
	type = "group", 
	name = L["Credits"], 
	order = -1, 
	args = {
		new = {
			order = 1, 
			type = "description", 
			name = SV.Credits
		}
	}
}