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
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;

local AddonName, AddonObject = ...

assert(LibSuperVillain, AddonName .. " requires LibSuperVillain")

AddonObject.configs = {
	["blizzard"] = {
		["enable"] = true, 
		["bags"] = true, 
		["bmah"] = true,
		["chat"] = true, 
		["reforge"] = true, 
		["calendar"] = true, 
		["achievement"] = true, 
		["lfguild"] = true, 
		["inspect"] = true, 
		["binding"] = true, 
		["gbank"] = true, 
		["archaeology"] = true, 
		["guildcontrol"] = true, 
		["gossip"] = true, 
		["guild"] = true, 
		["tradeskill"] = true, 
		["raid"] = false, 
		["talent"] = true, 
		["auctionhouse"] = true, 
		["barber"] = true, 
		["macro"] = true, 
		["debug"] = true, 
		["trainer"] = true, 
		["socket"] = true, 
		["loot"] = true, 
		["alertframes"] = true, 
		["bgscore"] = true, 
		["merchant"] = true, 
		["mail"] = true, 
		["help"] = true, 
		["trade"] = true, 
		["gossip"] = true, 
		["greeting"] = true, 
		["worldmap"] = true, 
		["taxi"] = true, 
		["quest"] = true, 
		["petition"] = true, 
		["dressingroom"] = true, 
		["pvp"] = true, 
		["lfg"] = true, 
		["nonraid"] = true, 
		["friends"] = true, 
		["spellbook"] = true, 
		["character"] = true, 
		["misc"] = true, 
		["tabard"] = true, 
		["guildregistrar"] = true, 
		["timemanager"] = true, 
		["encounterjournal"] = true, 
		["voidstorage"] = true, 
		["transmogrify"] = true, 
		["stable"] = true, 
		["bgmap"] = true, 
		["mounts"] = true, 
		["petbattleui"] = true, 
		["losscontrol"] = true, 
		["itemUpgrade"] = true, 
	}, 
	["addons"] = {
		["enable"] = true,
		["Skada"] = true, 
		["Recount"] = true,
		["AuctionLite"] = true,  
		["AtlasLoot"] = true, 
		["SexyCooldown"] = true, 
		["Lightheaded"] = true, 
		["Outfitter"] = true,
		["Quartz"] = true, 
		["TomTom"] = true, 
		["TinyDPS"] = true, 
		["Clique"] = true, 
		["CoolLine"] = true, 
		["ACP"] = true, 
		["DXE"] = true,
		["DBM-Core"] = true,
		["VEM"] = true,
		["MogIt"] = true, 
		["alDamageMeter"] = true, 
		["Omen"] = true, 
		["TradeSkillDW"] = true, 
	},
	["docklets"] = {
		["DockletMain"] = "None", 
		["MainWindow"] = "None", 
		["DockletExtra"] = "None", 
		["ExtraWindow"] = "None", 
		["enableExtra"] = false, 
		["DockletCombatFade"] = true
	},
};

local PLUGIN = LibSuperVillain("Registry"):NewPlugin(AddonName, AddonObject, "StyleOMatic_Profile", "StyleOMatic_Global", "StyleOMatic_Cache")
local Schema = PLUGIN.Schema;
local SV = _G["SVUI"];
local L = SV.L
--[[ 
########################################################## 
CONFIG OPTIONS
##########################################################
]]--
SV.Options.args.plugins.args.pluginOptions.args[Schema].args["blizzardEnable"] = {
    order = 2, 
	name = "Standard UI Styling", 
    type = "toggle",
    get = function(key) return PLUGIN.db.blizzard.enable end,
    set = function(key,value) PLUGIN.db.blizzard.enable = value; SV:StaticPopup_Show("RL_CLIENT") end
}
SV.Options.args.plugins.args.pluginOptions.args[Schema].args["addonEnable"] = {
    order = 3,
	name = "Addon Styling",
    type = "toggle",
    get = function(key) return PLUGIN.db.addons.enable end,
    set = function(key,value) PLUGIN.db.addons.enable = value; SV:StaticPopup_Show("RL_CLIENT") end
}
SV.Options.args.plugins.args.pluginOptions.args[Schema].args["addons"] = {
	order = 4, 
	type = "group", 
	name = "Addon Styling", 
	get = function(key) return PLUGIN.db.addons[key[#key]] end, 
	set = function(key,value) PLUGIN.db.addons[key[#key]] = value; SV:StaticPopup_Show("RL_CLIENT")end,
	disabled = function() return not PLUGIN.db.addons.enable end,
	guiInline = true, 
	args = {
		ace3 = {
			type = "toggle",
			order = 1,
			name = "Ace3"
		},
	}
}
SV.Options.args.plugins.args.pluginOptions.args[Schema].args["blizzard"] = {
	order = 300, 
	type = "group", 
	name = "Individual Mods", 
	get = function(key) return PLUGIN.db.blizzard[key[#key]] end, 
	set = function(key,value) PLUGIN.db.blizzard[key[#key]] = value; SV:StaticPopup_Show("RL_CLIENT") end, 
	disabled = function() return not PLUGIN.db.blizzard.enable end, 
	guiInline = true, 
	args = {
		bmah = {
			type = "toggle", 
			name = L["Black Market AH"], 
			desc = L["TOGGLEART_DESC"]
		},
		chat = {
			type = "toggle", 
			name = L["Chat Menus"], 
			desc = L["TOGGLEART_DESC"]
		},
		transmogrify = {
			type = "toggle", 
			name = L["Transmogrify Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		encounterjournal = {
			type = "toggle", 
			name = L["Encounter Journal"], 
			desc = L["TOGGLEART_DESC"]
		},
		reforge = {
			type = "toggle", 
			name = L["Reforge Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		calendar = {
			type = "toggle", 
			name = L["Calendar Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		achievement = {
			type = "toggle", 
			name = L["Achievement Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		lfguild = {
			type = "toggle", 
			name = L["LF Guild Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		inspect = {
			type = "toggle", 
			name = L["Inspect Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		binding = {
			type = "toggle", 
			name = L["KeyBinding Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		gbank = {
			type = "toggle", 
			name = L["Guild Bank"], 
			desc = L["TOGGLEART_DESC"]
		},
		archaeology = {
			type = "toggle", 
			name = L["Archaeology Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		guildcontrol = {
			type = "toggle", 
			name = L["Guild Control Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		guild = {
			type = "toggle", 
			name = L["Guild Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		tradeskill = {
			type = "toggle", 
			name = L["TradeSkill Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		raid = {
			type = "toggle", 
			name = L["Raid Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		talent = {
			type = "toggle", 
			name = L["Talent Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		auctionhouse = {
			type = "toggle", 
			name = L["Auction Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		timemanager = {
			type = "toggle", 
			name = L["Time Manager"], 
			desc = L["TOGGLEART_DESC"]
		},
		barber = {
			type = "toggle", 
			name = L["Barbershop Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		macro = {
			type = "toggle", 
			name = L["Macro Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		debug = {
			type = "toggle", 
			name = L["Debug Tools"], 
			desc = L["TOGGLEART_DESC"]
		},
		trainer = {
			type = "toggle", 
			name = L["Trainer Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		socket = {
			type = "toggle", 
			name = L["Socket Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		alertframes = {
			type = "toggle", 
			name = L["Alert Frames"], 
			desc = L["TOGGLEART_DESC"]
		},
		loot = {
			type = "toggle", 
			name = L["Loot Frames"], 
			desc = L["TOGGLEART_DESC"]
		},
		bgscore = {
			type = "toggle", 
			name = L["BG Score"], 
			desc = L["TOGGLEART_DESC"]
		},
		merchant = {
			type = "toggle", 
			name = L["Merchant Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		mail = {
			type = "toggle", 
			name = L["Mail Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		help = {
			type = "toggle", 
			name = L["Help Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		trade = {
			type = "toggle", 
			name = L["Trade Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		gossip = {
			type = "toggle", 
			name = L["Gossip Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		greeting = {
			type = "toggle", 
			name = L["Greeting Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		worldmap = {
			type = "toggle", 
			name = L["World Map"], 
			desc = L["TOGGLEART_DESC"]
		},
		taxi = {
			type = "toggle", 
			name = L["Taxi Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		lfg = {
			type = "toggle", 
			name = L["LFG Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		mounts = {
			type = "toggle", 
			name = L["Mounts & Pets"], 
			desc = L["TOGGLEART_DESC"]
		},
		quest = {
			type = "toggle", 
			name = L["Quest Frames"], 
			desc = L["TOGGLEART_DESC"]
		},
		petition = {
			type = "toggle", 
			name = L["Petition Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		dressingroom = {
			type = "toggle", 
			name = L["Dressing Room"], 
			desc = L["TOGGLEART_DESC"]
		},
		pvp = {
			type = "toggle", 
			name = L["PvP Frames"], 
			desc = L["TOGGLEART_DESC"]
		},
		nonraid = {
			type = "toggle", 
			name = L["Non-Raid Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		friends = {
			type = "toggle", 
			name = L["Friends"], 
			desc = L["TOGGLEART_DESC"]
		},
		spellbook = {
			type = "toggle", 
			name = L["Spellbook"], 
			desc = L["TOGGLEART_DESC"]
		},
		character = {
			type = "toggle", 
			name = L["Character Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		misc = {
			type = "toggle", 
			name = L["Misc Frames"], 
			desc = L["TOGGLEART_DESC"]
		},
		tabard = {
			type = "toggle", 
			name = L["Tabard Frame"], 
			desc = L["TOGGLEART_DESC"]
		},
		guildregistrar = {
			type = "toggle", 
			name = L["Guild Registrar"], 
			desc = L["TOGGLEART_DESC"]
		},
		bags = {
			type = "toggle", 
			name = L["Bags"], 
			desc = L["TOGGLEART_DESC"]
		},
		stable = {
			type = "toggle", 
			name = L["Stable"], 
			desc = L["TOGGLEART_DESC"]
		},
		bgmap = {
			type = "toggle", 
			name = L["BG Map"], 
			desc = L["TOGGLEART_DESC"]
		},
		petbattleui = {
			type = "toggle", 
			name = L["Pet Battle"], 
			desc = L["TOGGLEART_DESC"]
		},
		losscontrol = {
			type = "toggle", 
			name = L["Loss Control"], 
			desc = L["TOGGLEART_DESC"]
		},
		voidstorage = {
			type = "toggle", 
			name = L["Void Storage"], 
			desc = L["TOGGLEART_DESC"]
		},
		itemUpgrade = {
			type = "toggle", 
			name = L["Item Upgrade"], 
			desc = L["TOGGLEART_DESC"]
		}
	}
}