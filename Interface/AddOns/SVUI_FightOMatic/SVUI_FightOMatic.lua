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
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local assert    = _G.assert;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
local bit       = _G.bit;
--[[ STRING METHODS ]]--
local format, sub = string.format, string.sub;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round, random = math.abs, math.ceil, math.floor, math.round, math.random;
--[[ TABLE METHODS ]]--
local tremove, wipe = table.remove, table.wipe;
--[[ BINARY METHODS ]]--
local band, bor = bit.band, bit.bor;

--[[  CONSTANTS ]]--

_G.BINDING_HEADER_SVUIFIGHT = "Supervillain UI: Fight-O-Matic";
_G.BINDING_NAME_SVUIFIGHT_RADIO = "Call Out Incoming";
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local PLUGIN = select(2, ...)
local Schema = PLUGIN.Schema;

local SV = _G["SVUI"];
local L = SV.L;

local NewHook = hooksecurefunc;
--[[ 
########################################################## 
GLOBAL SLASH FUNCTIONS
##########################################################
]]--
function SVUISayIncoming()
	local subzoneText = GetSubZoneText()
	local msg = ("{rt8} Incoming %s {rt8}"):format(subzoneText)
	SendChatMessage(msg, "INSTANCE_CHAT")
	return
end
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function HeadsUpAlarm(...)
	if not CombatText_AddMessage then return end 
	CombatText_AddMessage(...)
end
--[[ 
########################################################## 
MUNGLUNCH's FAVORITE EMOTE GENERATOR
##########################################################
]]--
local SpecialEmotes = {
	"ROFL",
	"CACKLE",
	"GIGGLE",
	"GRIN",
	"SMIRK",
	"MOON",
	"LICK",
	"YAWN",
	"FLEX",
	"TICKLE",
	"TAUNT",
	"SHOO",
	"PRAY",
	"SPIT",
	"MOCK",
	"GLOAT",
	"PITY",
	"VIOLIN",
	"BYE",
}

local LowHealthPlayerEmotes = {
	"ROFL",
	"CACKLE",
	"GIGGLE",
	"GRIN",
	"SMIRK",
	"MOON",
	"LICK",
	"YAWN",
	"BITE",
	"NOSEPICK"
}

local LowHealthTargetEmotes = {
	"ROFL",
	"CACKLE",
	"FLEX",
	"TICKLE",
	"TAUNT",
	"SHOO",
	"PRAY",
	"SPIT",
	"MOCK",
	"GLOAT",
	"PITY",
	"VIOLIN",
	"BYE",
}

local KOSEmotes = {
	"THREATEN",
	"CRACK",
	"POINT",
	"GRIN",
	"SMIRK",
	"TAUNT",
	"CHICKEN"
}

local StealthEmotes = {
	"CURIOUS",
	"EYE",
	"GASP",
	"GAZE",
	"MOCK",
	"NOSEPICK",
	"PEER",
	"POINT",
	"READY",
	"STARE",
	"TAP",
}


function SVUIEmote()
	local index = random(1,#SpecialEmotes)
	DoEmote(SpecialEmotes[index])
end

local function LowHealth_PlayerEmote()
	local index = random(1,#LowHealthPlayerEmotes)
	DoEmote(LowHealthPlayerEmotes[index])
end

local function LowHealth_TargetEmote()
	local index = random(1,#LowHealthTargetEmotes)
	DoEmote(LowHealthTargetEmotes[index])
end

local function KOS_Emote()
	local index = random(1,#KOSEmotes)
	DoEmote(KOSEmotes[index])
end

local function Stealth_Emote(name)
	local index = random(1,#StealthEmotes)
	DoEmote(StealthEmotes[index], name)
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
local EnemyCache, AlertedCache = {},{}

local playerGUID = UnitGUID('player')
local playerFaction = UnitFactionGroup("player")
local classColor = RAID_CLASS_COLORS
local classColors = SVUI_CLASS_COLORS[SV.class]
local classR, classG, classB = classColors.r, classColors.g, classColors.b
local classA = 0.35
local fallbackColor = {r=1,g=1,b=1}
local ACTIVE_ZONE = ""
--[[ ICONS ]]--
local INFO_ICON = [[Interface\AddOns\SVUI_FightOMatic\artwork\PVP-INFO]]
local UTILITY_ICON = [[Interface\AddOns\SVUI_FightOMatic\artwork\PVP-UTILITIES]]
local RADIO_ICON = [[Interface\AddOns\SVUI_FightOMatic\artwork\PVP-RADIO]]
local SCANNER_ICON = [[Interface\AddOns\SVUI_FightOMatic\artwork\PVP-SCANNER]]
local ICON_FILE = [[Interface\AddOns\SVUI_FightOMatic\artwork\DOCK-PVP]]
local PVP_SAFE = [[Interface\AddOns\SVUI_FightOMatic\artwork\PVP-SAFE]]
local PVP_HELP = [[Interface\AddOns\SVUI_FightOMatic\artwork\PVP-INCOMING]]
local PVP_LOST = [[Interface\WorldMap\Skull_64Red]]
local linkString = "|Hplayer:%s:1|h%s|h"
--[[ BG MAP DATA ]]--
local PVP_NODES = {
	[461] = { --Arathi Basin (5)
		"Stables", "Lumber", "Blacksmith", "Mine", "Farm"
	},
	[935] = { --Deepwind Gorge (3)
		"Center Mine", "North Mine", "South Mine"
	},
	[482] = { --Eye of the Storm (4)
		"Fel Reaver", "Blood Elf", "Draenei", "Mage"
	},
	[736] = { --The Battle for Gilneas (3)
		"LightHouse", "WaterWorks", "Mines"
	},
}

-- local PVP_POI = {
-- 	[401] = { --Alterac Valley (15)
-- 		"Stormpike Aid Station", "Dun Baldar North Bunker", "Dun Baldar South Bunker",
-- 		"Stormpike Graveyard", "Icewing Bunker", "Stonehearth Graveyard",
-- 		"Stonehearth Bunker", "Snowfall Graveyard", "Iceblood Tower",
-- 		"Iceblood Graveyard", "Tower Point", "Frostwolf Graveyard",
-- 		"West Frostwolf Tower", "East Frostwolf Tower", "Frostwolf Relief Hut"
-- 	},
-- 	[935] = { --Deepwind Gorge (2)
-- 		"Horde Cart", "Alliance Cart"
-- 	},
-- 	[482] = { --Eye of the Storm (1)
-- 		"Flag"
-- 	},
-- 	[860] = { --Silvershard Mines (1)
-- 		"Cart"
-- 	},
-- 	[512] = { --Strand of the Ancients (5)
-- 		"Green Emerald", "Blue Sapphire", "Purple Amethyst", "Red Sun", "Yellow Moon"
-- 	},
-- 	[540] = { --Isle of Conquest (5)
-- 		"Quarry", "Hangar", "Workshop", "Docks", "Refinery"
-- 	},
-- 	[856] = { --Temple of Kotmogu (4)
-- 		"Red Orb", "Blue Orb", "Orange Orb", "Purple Orb"
-- 	},
-- 	[626] = { --Twin Peaks (2)
-- 		"Horde Flag", "Alliance Flag"
-- 	},
-- 	[443] = { --Warsong Gulch (2)
-- 		"Horde Flag", "Alliance Flag"
-- 	},
-- }

local Safe_OnEnter = function(self)
	if InCombatLockdown() then return end
	local zone = self.name
	if(zone and zone ~= "") then
		self:SetBackdropBorderColor(1,0.45,0)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(("%s Is Safe!"):format(zone), 1, 1, 1)
		GameTooltip:Show()
	end
end

local Safe_OnLeave = function(self)
	if InCombatLockdown() then return end 
	self:SetBackdropBorderColor(0,0,0)
	if(GameTooltip:IsShown()) then GameTooltip:Hide() end
end

local Safe_OnClick = function(self)
	local zone = self.name
	if(zone and zone ~= "") then
		SendChatMessage(("{rt4} %s Is Safe {rt4}"):format(zone), "INSTANCE_CHAT")
	end
end

local Help_OnEnter = function(self)
	if InCombatLockdown() then return end
	local zone = self.name
	if(zone and zone ~= "") then
		self:SetBackdropBorderColor(1,0.45,0)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(("%s Needs Help!"):format(zone), 1, 1, 1)
		GameTooltip:Show()
	end
end

local Help_OnLeave = function(self)
	if InCombatLockdown() then return end 
	self:SetBackdropBorderColor(0,0,0)
	if(GameTooltip:IsShown()) then GameTooltip:Hide() end
end

local Help_OnClick = function(self)
	if(self.name and self.name ~= "") then
		local msg = ("{rt8} Incoming %s {rt8}"):format(self.name)
		SendChatMessage(msg, "INSTANCE_CHAT")
	end
end

local function AddEnemyScan(guid, timestamp)
	if(EnemyCache[guid]) then
		return EnemyCache[guid]
	end
	local class, classToken, race, raceToken, sex, name, realm = GetPlayerInfoByGUID(guid)
	local colors = classColor[classToken] or fallbackColor
	EnemyCache[guid] = {
        ["name"] = name,
        ["realm"] = realm,
        ["class"] = class,
        ["race"] = race,
        ["sex"] = sex,
        ["colors"] = colors,
        ["time"] = timestamp
    }
    PLUGIN:ScannerLog(EnemyCache[guid])
    return EnemyCache[guid];
end

local function SaveEnemyScan(guid, timestamp)
	local enemy = EnemyCache[guid]
	if(not enemy) then enemy = AddEnemyScan(guid, timestamp) end
	PLUGIN.cache[guid] = {
        ["name"] = enemy.name,
        ["realm"] = enemy.realm,
        ["class"] = enemy.class,
        ["race"] = enemy.race,
        ["sex"] = enemy.sex,
        ["colors"] = enemy.colors,
        ["time"] = enemy.timestamp
    }
    local msg = ("Killed By: %s"):format(enemy.name);
    HeadsUpAlarm(msg, CombatText_StandardScroll, enemy.colors.r, enemy.colors.g, enemy.colors.b, "sticky");
    PLUGIN:UpdateSummary()
end

local function KilledEnemyHandler(guid)
	local enemy = PLUGIN.cache[guid]
	if(enemy and enemy.name) then
		HeadsUpAlarm(("Killed Mortal Enemy: %s"):format(enemy.name), CombatText_StandardScroll, 0.2, 1, 0.1, "sticky");
	end
	enemy = EnemyCache[guid]
	if(enemy) then
		HeadsUpAlarm(("Killed Enemy: %s"):format(enemy.name), CombatText_StandardScroll, 0.1, 0.8, 0);
	end
end

local function ClearCacheScans()
	wipe(EnemyCache)
	wipe(AlertedCache)
	if(PLUGIN.LOG and PLUGIN.LOG.Output) then PLUGIN.LOG.Output:Clear() end
end

local function ClearSavedScans()
	wipe(PLUGIN.cache)
end

local function EnemyAlarm(name, class, colors, kos)
	if not name then return end
	local inInstance, instanceType = IsInInstance()
	if(instanceType ~= "pvp" and not AlertedCache[name]) then
		local msg
		if(kos) then
			msg = ("Mortal Enemy Detected!: %s"):format(name);
			HeadsUpAlarm(msg, CombatText_StandardScroll, 1, 0, 0)
		elseif(class and colors) then
			msg = ("%s Detected"):format(class);
			HeadsUpAlarm(msg, CombatText_StandardScroll, colors.r, colors.g, colors.b)
	    end
	    AlertedCache[name] = true
	end
end

local function StealthAlarm(spell, name)
	local msg = ("%s Detected!"):format(spell);
    HeadsUpAlarm(msg, CombatText_StandardScroll, 1, 0.5, 0);
    print(("%s has %sed nearby!"):format(name, spell))
    if(self.db.annoyingEmotes) then
    	Stealth_Emote(name)
    end
end

function PLUGIN:UpdateSummary()
	self.Summary:Clear();
	local stored = self.cache;
	local amount = 0
	for _,data in pairs(stored) do
		if type(data) == "table" and data.name and data.class then
			amount = amount + 1;
		end
	end
	self.Summary:AddMessage(("You Have |cffff5500%s|r Mortal Enemies"):format(amount), 0.8, 0.8, 0.8);
end

function PLUGIN:ResetLogs()
	wipe(EnemyCache)
	self.Title:Clear();
	self.Summary:Clear();
	self.LOG.Output:Clear();
	self.Title:AddMessage(("Scanning %s"):format(ACTIVE_ZONE), 1, 1, 0);
	self.Switch:Show()
	local stored = self.cache;
	local amount = 0
	for _,data in pairs(stored) do
		if type(data) == "table" and data.name and data.class then
			amount = amount + 1;
		end
	end
	self.Summary:AddMessage(("You Have |cffff5500%s|r Mortal Enemies"):format(amount), 0.8, 0.8, 0.8)
	collectgarbage("collect") 
end

function PLUGIN:PopulateKOS()
	self.Title:Clear();
	self.Summary:Clear();
	self.LOG.Output:Clear();
	self.Title:AddMessage(("Scanning %s"):format(ACTIVE_ZONE), 1, 1, 0);
	self.Switch:Show()
	local stored = self.cache;
	local amount = 0
	for _,data in pairs(stored) do
		if type(data) == "table" and data.name and data.class and data.race then
			amount = amount + 1;
			local nameLink = linkString:format(data.name, data.name)
			local hex = ("%s - %s %s"):format(nameLink, data.race, data.class)
			self.LOG.Output:AddMessage(hex, data.colors.r, data.colors.g, data.colors.b);
		end
	end
	self.Summary:AddMessage(("You Have |cffff5500%s|r Mortal Enemies"):format(amount), 0.8, 0.8, 0.8)
end

function PLUGIN:PopulateScans()
	self.COMM.Unavailable:Hide()
	self.Title:Clear();
	self.Summary:Clear();
	self.LOG.Output:Clear();
	self.Title:AddMessage(("Scanning %s"):format(ACTIVE_ZONE), 1, 1, 0);
	self.Switch:Show()
	local stored = self.cache;
	local amount = 0
	for _,data in pairs(stored) do
		if type(data) == "table" and data.name and data.class then
			amount = amount + 1;
		end
	end
	self.Summary:AddMessage(("You Have |cffff5500%s|r Mortal Enemies"):format(amount), 0.8, 0.8, 0.8);
	for _,data in pairs(EnemyCache) do
		if type(data) == "table" and data.name and data.class and data.race then
			local nameLink = linkString:format(data.name, data.name)
			local hex = ("%s - %s %s"):format(nameLink, data.race, data.class)
			self.LOG.Output:AddMessage(hex, data.colors.r, data.colors.g, data.colors.b);
		end
	end
end

function PLUGIN:PauseScanner()
	if(not self.InPVP) then
		self.Title:Clear();
		self.Summary:Clear();
		self.LOG.Output:Clear();
		self.Title:AddMessage("Scanning Paused", 1, 0.1, 0);
		self.Summary:AddMessage(ACTIVE_ZONE, 1, 0.75, 0);
		self.Switch:Hide()
		self.LOG.Output:AddMessage(" ", 1, 1, 1);
		self.LOG.Output:AddMessage(" ", 1, 1, 1);
		self.LOG.Output:AddMessage("The Enenmy Scanner Will Resume", 0.8, 0.8, 0.8);
		self.LOG.Output:AddMessage("When You Leave This BattleGround", 0.8, 0.8, 0.8);
	else
		self:PopulateScans()
	end
end

function PLUGIN:ScannerLog(enemy)
	if(not enemy.name or not enemy.race or not enemy.class) then return end
    local nameLink = linkString:format(enemy.name, enemy.name)
	local hex = ("%s - %s %s"):format(nameLink, enemy.race, enemy.class)
	self.LOG.Output:AddMessage(hex, enemy.colors.r, enemy.colors.g, enemy.colors.b);
	EnemyAlarm(enemy.name, enemy.class, enemy.colors)
end

function PLUGIN:UpdateCommunicator()
	if(not self.InPVP) then
		local mapID = GetCurrentMapAreaID() 
		if(mapID) then
			local points = PVP_NODES[mapID]
			if(points) then
				self.COMM.Unavailable:Hide()
				for i = 1, 5 do
					local nodeName = ("SVUI_PVPNode%d"):format(i)
					local node = _G[nodeName]
					local safe = node.Safe
					local help = node.Help
					if(i <= #points) then
						local name = points[i]
						safe.name = name
						help.name = name
						node.Text:SetText(name)
						node:Show()
					else
						safe.name = ""
						help.name = ""
						node.Text:SetText("")
						node:Hide()
					end
				end
				self.InPVP = true
				self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
				self.Scanning = false
				self:PauseScanner()
			end
		end
	elseif(self.InPVP) then
		self.COMM.Unavailable:Show()
		for i = 1, 5 do
			local nodeName = ("SVUI_PVPNode%d"):format(i)
			local node = _G[nodeName]
			local safe = node.Safe
			local help = node.Help
			safe.name = ""
			help.name = ""
			node.Text:SetText("")
			node:Hide()
		end
		self.InPVP = nil
		self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
		self.Scanning = true

		self:PopulateScans()
	end
end

function PLUGIN:UpdateZoneStatus()
	if PLUGIN.ZoneTimer then return end
	local zoneText = GetRealZoneText() or GetZoneText()
	if(not zoneText or zoneText == "") then
		PLUGIN.ZoneTimer = SV.Timers:ExecuteTimer(PLUGIN.UpdateZoneStatus, 5)
		return
	end
	if(zoneText ~= ACTIVE_ZONE) then
		ClearCacheScans()
		ACTIVE_ZONE = zoneText
		PLUGIN.Title:Clear();
		PLUGIN.Title:AddMessage(("Scanning %s"):format(ACTIVE_ZONE), 1, 1, 0);
	end
	local zonePvP = GetZonePVPInfo()
	if(zonePvP == "sanctuary" or zoneText == "") then
		PLUGIN.Scanning = false
	else
		PLUGIN.Scanning = true
		local inInstance, instanceType = IsInInstance()
		if(inInstance and ((instanceType == "party") or (instanceType == "raid"))) then
			PLUGIN.Scanning = false
		elseif (not zonePvP or (zonePvP == "friendly") or (not UnitIsPVP("player"))) then
			PLUGIN.Scanning = false
		elseif(instanceType == "pvp") then
			PLUGIN:PauseScanner()
			PLUGIN.Scanning = false
			if(not PLUGIN.InPVP) then
				PLUGIN:UpdateCommunicator()
			end
		end
	end
	PLUGIN.ZoneTimer = nil
end

local function ParseIncomingLog(timestamp, event, eGuid, eName, pGuid)
	local cached = PLUGIN.cache[eGuid]
	local kos, needsUpdate = false, false

	if(cached) then
		kos = true
	else
		cached = EnemyCache[eGuid]
	end

	if(cached and cached.time) then
		needsUpdate = (cached.time + 60) < timestamp;
	else
		cached = AddEnemyScan(eGuid, timestamp)
		needsUpdate = true
	end

	if(cached) then
		if(needsUpdate) then
			EnemyAlarm(eName, cached.class, cached.colors, kos)
			cached.time = timestamp
		end

		if(pGuid == playerGUID and not AlertedCache[eName]) then
			AlertedCache[eName] = true
			local incoming = ("%s Attacking You!"):format(eName);
			HeadsUpAlarm(incoming, CombatText_StandardScroll, 1, 0.05, 0, "crit")
		end
	end
end

local function GetSourceType(guid)
	if not guid then return end
	local subStr, binStr, bitVal, srcType
	subStr  = guid:sub(3, 5)
	binStr  = ("0x%s"):format(subStr)
	bitVal  = tonumber(binStr)
	if(not bitVal) then return end
	srcType = band(bitVal, 0x00F)
	return srcType
end

function PLUGIN:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, event, _, srcGUID, srcName, srcFlags, sourceRaidFlags, dstGUID, dstName, dstFlags, destRaidFlags, _, spellName)
	if not srcFlags then return end
	local flagParse = band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE)
	local flagged = flagParse == COMBATLOG_OBJECT_REACTION_HOSTILE

	if(flagged) then
		if(srcGUID and srcName) then
			local isHostile = CombatLog_Object_IsA(srcFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS)
			local srcType = GetSourceType(srcGUID)
			if(srcType and (srcType == 0 or srcType == 8) and isHostile) then
				if(event == "SPELL_AURA_APPLIED" and (spellName == L["Stealth"] or spellName == L["Prowl"])) then
					StealthAlarm(spellName, srcName)
				end
				if(dstGUID == playerGUID) then
					PLUGIN.HitBy = srcGUID
				end
				if(not PLUGIN.Scanning) then return end
				ParseIncomingLog(timestamp, event, srcGUID, srcName, dstGUID)
			end
		end

		if(PLUGIN.Scanning and dstGUID and dstName) then
			local isHostile = CombatLog_Object_IsA(dstFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS)
			local srcType = GetSourceType(dstGUID)
			if(srcType and (srcType == 0 or srcType == 8) and isHostile) then
				ParseIncomingLog(timestamp, event, dstGUID, dstName, srcGUID)
			end
		end
	end

	if(PLUGIN.Scanning and event == "PARTY_KILL") then
		if(srcGUID == playerGUID and dstName) then
			KilledEnemyHandler(dstGUID)
		end
	end
end

function PLUGIN:EventDistributor(event, ...)
	local inInstance, instanceType = IsInInstance()

	if(event == "PLAYER_REGEN_ENABLED") then
		self.HitBy = false;
		if(instanceType == "pvp") then self.Scanning = false end
	else
		if(instanceType ~= "pvp") then
			if(event == "PLAYER_TARGET_CHANGED") then 
				if(UnitIsPlayer("target") and UnitIsEnemy("target", "player")) then
					local guid = UnitGUID("target")
					if(not EnemyCache[guid]) then
						local timestamp = time()
						AddEnemyScan(guid, timestamp)
					elseif(self.cache[guid] and self.cache[guid].name) then
						--HeadsUpAlarm("Kill On Sight!", CombatText_StandardScroll, 1, 0, 0, "crit")
						if(self.db.annoyingEmotes) then
							KOS_Emote()
						end
					end
				end
			elseif(event == "PLAYER_DEAD") then 
				local guid = self.HitBy
				if(guid and guid ~= "") then
					local stamp = time()
					SaveEnemyScan(guid, stamp)
				end 
			end
		else
			self.Scanning = false
		end
	end
end

local onMouseWheel = function(self, delta)
	if (delta > 0) then
		self:ScrollUp()
	elseif (delta < 0) then
		self:ScrollDown()
	end
end

local function MakeLogWindow()
	local frame = CreateFrame("Frame", nil, UIParent)

	frame:SetFrameStrata("MEDIUM")
	frame:SetPoint("TOPLEFT", PLUGIN.Summary, "BOTTOMLEFT",0,0)
	frame:SetPoint("BOTTOMRIGHT", PLUGIN.Docklet, "BOTTOMRIGHT",0,0)
	frame:SetParent(PLUGIN.Docklet)

	local output = CreateFrame("ScrollingMessageFrame", nil, frame)
	output:SetSpacing(4)
	output:SetClampedToScreen(false)
	output:SetFrameStrata("MEDIUM")
	output:SetAllPoints(frame)
	output:SetFont(SV.Media.font.system, 11, "OUTLINE")
	output:SetJustifyH("CENTER")
	output:SetJustifyV("MIDDLE")
	output:SetShadowColor(0, 0, 0, 0)
	output:SetMaxLines(120)
	output:EnableMouseWheel(true)
	output:SetHyperlinksEnabled(true)
	output:SetScript("OnMouseWheel", onMouseWheel)
	output:SetFading(false)
	output:SetInsertMode('TOP')

	output:SetScript("OnHyperlinkEnter", function(self, linkData, link, button)
		local t = link:explode(":")
		local name = t[2] or ""
	    SVUI_TargetScanButton:SetAttribute("macrotext", ("/tar %s"):format(name))
	    SVUI_TargetScanButton:EnableMouse(true)
	end)

	frame.Output = output

	PLUGIN.LOG = frame

	_G["SVUI_FightOMaticTool1"].Window = PLUGIN.LOG
end

local function MakeCommWindow()

	local frame = CreateFrame("Frame", nil, UIParent)

	frame:SetFrameStrata("MEDIUM")
	frame:SetPoint("TOPLEFT", PLUGIN.Summary, "BOTTOMLEFT",0,0)
	frame:SetPoint("BOTTOMRIGHT", PLUGIN.Docklet, "BOTTOMRIGHT",0,0)
	frame:SetParent(PLUGIN.Docklet)

	local fallback = CreateFrame("Frame", nil, frame)
	fallback:SetAllPoints(frame)

	local fbText = fallback:CreateFontString(nil, "OVERLAY")
	fbText:SetAllPoints(fallback)
	fbText:SetFont(SV.Media.font.roboto, 12, "NONE")
	fbText:SetText("Nothing To Broadcast Right Now")

	frame.Unavailable = fallback

	local DOCK_WIDTH = frame:GetWidth();
	local DOCK_HEIGHT = frame:GetHeight();
	local BUTTON_SIZE = (DOCK_HEIGHT * 0.25) - 4;
	local sectionWidth = (DOCK_WIDTH / 6) - 2
	local sectionHeight = (DOCK_HEIGHT / 5) - 2
	local iconSize = sectionHeight * 0.5

	for i = 1, 5 do
		local yOffset = (sectionHeight * (i - 1)) + 2

		local poiName = ("SVUI_PVPNode%d"):format(i)
		local poi = CreateFrame("Frame", poiName, frame)
		poi:SetSize((DOCK_WIDTH - 2), sectionHeight)
		poi:SetPoint("TOP", frame, "TOP", 0, -yOffset)
		poi:SetPanelTemplate("Transparent")

		local safe = CreateFrame("Button", nil, poi)
		safe:SetSize(sectionWidth, sectionHeight)
		safe:SetPoint("RIGHT", poi, "RIGHT", -2, 0)
		safe:SetButtonTemplate()
		safe:SetPanelColor("green")
		local sicon = safe:CreateTexture(nil, "OVERLAY")
		sicon:SetPoint("CENTER", safe, "CENTER", 0, 0)
		sicon:SetSize(iconSize,iconSize)
		sicon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		sicon:SetTexture(PVP_SAFE)
		safe:SetScript("OnEnter", Safe_OnEnter)
		safe:SetScript("OnLeave", Safe_OnLeave)
		safe:SetScript("OnClick", Safe_OnClick)

		poi.Safe = safe

		local help = CreateFrame("Button", nil, poi)
		help:SetSize(sectionWidth, sectionHeight)
		help:SetPoint("RIGHT", safe, "LEFT", -2, 0)
		help:SetButtonTemplate()
		help:SetPanelColor("red")
		local hicon = help:CreateTexture(nil, "OVERLAY")
		hicon:SetPoint("CENTER", help, "CENTER", 0, 0)
		hicon:SetSize(iconSize,iconSize)
		hicon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		hicon:SetTexture(PVP_HELP)
		help:SetScript("OnEnter", Help_OnEnter)
		help:SetScript("OnLeave", Help_OnLeave)
		help:SetScript("OnClick", Help_OnClick)

		poi.Help = help

		poi.Text = poi:CreateFontString(nil,"OVERLAY")
		poi.Text:SetFont(SV.Media.font.roboto, 12, "NONE")
		poi.Text:SetPoint("TOPLEFT", poi, "TOPLEFT", 2, 0)
		poi.Text:SetPoint("BOTTOMRIGHT", help, "BOTTOMLEFT", -2, 0)
		poi.Text:SetJustifyH("CENTER")
		poi.Text:SetText("")
		poi:Hide()
	end

	PLUGIN.COMM = frame

	_G["SVUI_FightOMaticTool2"].Window = PLUGIN.COMM

	PLUGIN.COMM:Hide()
end

local function MakeUtilityWindow()
	local frame = CreateFrame("Frame", nil, UIParent)

	frame:SetFrameStrata("MEDIUM")
	frame:SetPoint("TOPLEFT", PLUGIN.Summary, "BOTTOMLEFT",0,0)
	frame:SetPoint("BOTTOMRIGHT", PLUGIN.Docklet, "BOTTOMRIGHT",0,0)
	frame:SetParent(PLUGIN.Docklet)

	local fbText = frame:CreateFontString(nil, "OVERLAY")
	fbText:SetAllPoints(frame)
	fbText:SetFont(SV.Media.font.roboto, 12, "NONE")
	fbText:SetText("Utilities Coming Soon....")

	PLUGIN.TOOL = frame

	_G["SVUI_FightOMaticTool3"].Window = PLUGIN.TOOL

	PLUGIN.TOOL:Hide()
end

local function MakeInfoWindow()
	local frame = CreateFrame("Frame", nil, UIParent)

	frame:SetFrameStrata("MEDIUM")
	frame:SetPoint("TOPLEFT", PLUGIN.Summary, "BOTTOMLEFT",0,0)
	frame:SetPoint("BOTTOMRIGHT", PLUGIN.Docklet, "BOTTOMRIGHT",0,0)
	frame:SetParent(PLUGIN.Docklet)

	local DATA_WIDTH = (frame:GetWidth() * 0.5) - 2;
	local DATA_HEIGHT = frame:GetHeight() - 2;

	local leftColumn = CreateFrame("Frame", "SVUI_FightOMaticInfoLeft", frame)
	leftColumn:Size(DATA_WIDTH, DATA_HEIGHT)
	leftColumn:Point("LEFT", frame, "LEFT", 0, 0)
	leftColumn.lockedOpen = true
	SV.SVStats:NewAnchor(leftColumn, 3, "ANCHOR_CURSOR", nil, "Transparent", true)
	leftColumn:SetFrameLevel(0)

	local rightColumn = CreateFrame("Frame", "SVUI_FightOMaticInfoRight", frame)
	rightColumn:Size(DATA_WIDTH, DATA_HEIGHT)
	rightColumn:Point("LEFT", leftColumn, "RIGHT", 2, 0)
	rightColumn.lockedOpen = true
	SV.SVStats:NewAnchor(rightColumn, 3, "ANCHOR_CURSOR", nil, "Transparent", true)
	rightColumn:SetFrameLevel(0)

	PLUGIN.INFO = frame

	_G["SVUI_FightOMaticTool4"].Window = PLUGIN.INFO

	SV.SVStats.BGPanels = {
		["SVUI_FightOMaticInfoLeft"] = {top = "Honor", middle = "Kills", bottom = "Assists"},
		["SVUI_FightOMaticInfoRight"] = {top = "Damage", middle = "Healing", bottom = "Deaths"}
	}

	SV.SVStats:Generate()

	PLUGIN.INFO:Hide()
end
--[[ 
########################################################## 
DOCK ELEMENT HANDLERS
##########################################################
]]--
local FightOMaticAlert_OnEnter = function(self)
	if InCombatLockdown() then return; end
	self:SetBackdropColor(0.9, 0.15, 0.1)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.TText, 1, 1, 0)
	GameTooltip:Show()
end

local FightOMaticAlert_OnLeave = function(self)
	GameTooltip:Hide()
	if InCombatLockdown() then return end 
	self:SetBackdropColor(0.25, 0.52, 0.1)
end

local FightOMaticAlert_OnHide = function()
	if InCombatLockdown() then 
		SV:AddonMessage(ERR_NOT_IN_COMBAT);  
		return; 
	end
	SV.Dock.BottomRight.Alert:Deactivate()
end

local FightOMaticAlert_OnShow = function(self)
	if InCombatLockdown() then 
		SV:AddonMessage(ERR_NOT_IN_COMBAT); 
		self:Hide() 
		return; 
	end
	SV:SecureFadeIn(self, 0.3, 0, 1)
	SV.Dock.BottomRight.Alert:Activate(self)
end

local FightOMaticAlert_OnMouseDown = function(self)
	-- DO STUFF
	SV:SecureFadeOut(self, 0.5, 1, 0, true)
end

local FightOMaticTool_OnEnter = function(self)
	if InCombatLockdown() then return; end
	self.icon:SetGradient(unpack(SV.Media.gradient.yellow))
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.TText, 1, 1, 1)
	GameTooltip:Show()
end

local FightOMaticTool_OnLeave = function(self)
	if InCombatLockdown() then return; end
	self.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	GameTooltip:Hide()
end

local FightOMaticTool_OnMouseDown = function(self)
	SV:SecureFadeOut(PLUGIN.LOG, 0.5, 1, 0, true)
	SV:SecureFadeOut(PLUGIN.COMM, 0.5, 1, 0, true)
	SV:SecureFadeOut(PLUGIN.TOOL, 0.5, 1, 0, true)
	SV:SecureFadeOut(PLUGIN.INFO, 0.5, 1, 0, true)
	SV:SecureFadeIn(self.Window, 0.3, 0, 1)
	PLUGIN.Title:Clear();
	PLUGIN.Title:AddMessage(self.TTitle, 1, 1, 0);
end

local Scanner_OnMouseDown = function(self)
	SV:SecureFadeOut(PLUGIN.LOG, 0.5, 1, 0, true)
	SV:SecureFadeOut(PLUGIN.COMM, 0.5, 1, 0, true)
	SV:SecureFadeOut(PLUGIN.TOOL, 0.5, 1, 0, true)
	SV:SecureFadeOut(PLUGIN.INFO, 0.5, 1, 0, true)
	SV:SecureFadeIn(self.Window, 0.3, 0, 1)
	PLUGIN:PopulateScans()
end

local Switch_OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	if(self.ShowingKOS) then
		GameTooltip:AddDoubleLine("Click", "Show Scan List", 0.1, 1, 0.2, 1, 1, 1)
	else
		GameTooltip:AddDoubleLine("Click", 'Show "Kill On Sight" List', 0.1, 1, 0.2, 1, 1, 1)
	end
	GameTooltip:AddDoubleLine("[SHIFT] Click", "Clear All Scans", 0.1, 1, 0.2, 1, 1, 1)
	GameTooltip:AddDoubleLine("[CTRL] Click", 'Clear All "Kill On Sight"', 0.1, 1, 0.2, 1, 1, 1)
	GameTooltip:Show()
end

local Switch_OnLeave = function(self)
	GameTooltip:Hide()
end

local Switch_OnClick = function(self, button)
	Switch_OnLeave(self)
	if(IsControlKeyDown()) then
		ClearSavedScans()
		PLUGIN:ResetLogs()
	elseif(IsShiftKeyDown()) then
		ClearCacheScans()
	else
		if(self.ShowingKOS) then
			PLUGIN:PopulateScans()
			self.ShowingKOS = false
		else
			PLUGIN:PopulateKOS()
			self.ShowingKOS = true
		end
	end
	Switch_OnEnter(self)
end
--[[ 
########################################################## 
BUILD FUNCTION
##########################################################
]]--
function PLUGIN:Load()
	self.cache = self.cache or {}
	
	local ALERT_HEIGHT = 60;
	local DOCK_WIDTH = SV.Dock.BottomRight.Window:GetWidth();
	local DOCK_HEIGHT = SV.Dock.BottomRight.Window:GetHeight();
	local BUTTON_SIZE = (DOCK_HEIGHT * 0.25) - 4;

	self.HitBy = false;
	self.Scanning = false;
	self.InPVP = false

	self.Docklet = SV.Dock:NewDocklet("BottomRight", "SVUI_FightOMaticDock", self.TitleID, ICON_FILE)

	local toolBar = CreateFrame("Frame", "SVUI_FightOMaticToolBar", self.Docklet)
	toolBar:SetWidth(BUTTON_SIZE + 4);
	toolBar:SetHeight((BUTTON_SIZE + 4) * 4);
	toolBar:SetPoint("BOTTOMLEFT", self.Docklet, "BOTTOMLEFT", 0, 0);

	local tbDivider = toolBar:CreateTexture(nil,"OVERLAY")
    tbDivider:SetTexture(0,0,0,0.5)
    tbDivider:SetPoint("TOPRIGHT")
    tbDivider:SetPoint("BOTTOMRIGHT")
    tbDivider:SetWidth(1)

	local tool4 = CreateFrame("Frame", "SVUI_FightOMaticTool4", toolBar)
	tool4:SetPoint("BOTTOM",toolBar,"BOTTOM",0,0)
	tool4:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool4.icon = tool4:CreateTexture(nil, 'OVERLAY')
	tool4.icon:SetTexture(INFO_ICON)
	tool4.icon:FillInner(tool4)
	tool4.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool4.TText = "Stats"
	tool4.TTitle = "Statistics and Information"
	tool4:SetScript('OnEnter', FightOMaticTool_OnEnter)
	tool4:SetScript('OnLeave', FightOMaticTool_OnLeave)
	tool4:SetScript('OnMouseDown', FightOMaticTool_OnMouseDown)

	local tool3 = CreateFrame("Frame", "SVUI_FightOMaticTool3", toolBar)
	tool3:SetPoint("BOTTOM",tool4,"TOP",0,2)
	tool3:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool3.icon = tool3:CreateTexture(nil, 'OVERLAY')
	tool3.icon:SetTexture(UTILITY_ICON)
	tool3.icon:FillInner(tool3)
	tool3.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool3.TText = "Tools"
	tool3.TTitle = "Tools and Utilities"
	tool3:SetScript('OnEnter', FightOMaticTool_OnEnter)
	tool3:SetScript('OnLeave', FightOMaticTool_OnLeave)
	tool3:SetScript('OnMouseDown', FightOMaticTool_OnMouseDown)

	local tool2 = CreateFrame("Frame", "SVUI_FightOMaticTool2", toolBar)
	tool2:SetPoint("BOTTOM",tool3,"TOP",0,2)
	tool2:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool2.icon = tool2:CreateTexture(nil, 'OVERLAY')
	tool2.icon:SetTexture(RADIO_ICON)
	tool2.icon:FillInner(tool2)
	tool2.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool2.TText = "Radio"
	tool2.TTitle = "Radio Communicator"
	tool2:SetScript('OnEnter', FightOMaticTool_OnEnter)
	tool2:SetScript('OnLeave', FightOMaticTool_OnLeave)
	tool2:SetScript('OnMouseDown', FightOMaticTool_OnMouseDown)

	local tool1 = CreateFrame("Frame", "SVUI_FightOMaticTool1", toolBar)
	tool1:SetPoint("BOTTOM",tool2,"TOP",0,2)
	tool1:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool1.icon = tool1:CreateTexture(nil, 'OVERLAY')
	tool1.icon:SetTexture(SCANNER_ICON)
	tool1.icon:FillInner(tool1)
	tool1.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool1.TText = "Scanner"
	tool1.TTitle = "Enemy Scanner"
	tool1:SetScript('OnEnter', FightOMaticTool_OnEnter)
	tool1:SetScript('OnLeave', FightOMaticTool_OnLeave)
	tool1:SetScript('OnMouseDown', Scanner_OnMouseDown)

	local title = CreateFrame("ScrollingMessageFrame", nil, self.Docklet)
	title:SetSpacing(4)
	title:SetClampedToScreen(false)
	title:SetFrameStrata("MEDIUM")
	title:SetPoint("TOPLEFT", toolBar, "TOPRIGHT",0,0)
	title:SetPoint("BOTTOMRIGHT", self.Docklet, "TOPRIGHT",0,-16)
	title:FontManager(SV.Media.font.names, 16, "OUTLINE", "CENTER", "MIDDLE")
	title:SetMaxLines(1)
	title:EnableMouseWheel(false)
	title:SetFading(false)
	title:SetInsertMode('TOP')

	local divider1 = title:CreateTexture(nil,"OVERLAY")
    divider1:SetTexture(0,0,0,0.5)
    divider1:SetPoint("BOTTOMLEFT")
    divider1:SetPoint("BOTTOMRIGHT")
    divider1:SetHeight(1)

    self.Title = title

    local listbutton = CreateFrame("Button", nil, self.Docklet)
    listbutton:SetPoint("TOPLEFT", title, "BOTTOMLEFT",0,0)
	listbutton:SetPoint("BOTTOMRIGHT", title, "BOTTOMRIGHT",0,-14)
	listbutton:SetButtonTemplate(true)
	listbutton.ShowingKOS = false
	listbutton:SetScript("OnEnter", Switch_OnEnter)
	listbutton:SetScript("OnLeave", Switch_OnLeave)
	listbutton:SetScript("OnClick", Switch_OnClick)

	self.Switch = listbutton

    local summary = CreateFrame("ScrollingMessageFrame", nil, self.Docklet)
	summary:SetSpacing(4)
	summary:SetClampedToScreen(false)
	summary:SetFrameStrata("MEDIUM")
	summary:SetPoint("TOPLEFT", title, "BOTTOMLEFT",0,0)
	summary:SetPoint("BOTTOMRIGHT", title, "BOTTOMRIGHT",0,-14)
	summary:FontManager(SV.Media.font.system, 12, "OUTLINE", "CENTER", "MIDDLE")
	summary:SetMaxLines(1)
	summary:EnableMouse(false)
	summary:SetFading(false)
	summary:SetInsertMode('TOP')

	self.Summary = summary

	local divider2 = summary:CreateTexture(nil,"OVERLAY")
    divider2:SetTexture(0,0,0,0.5)
    divider2:SetPoint("BOTTOMLEFT")
    divider2:SetPoint("BOTTOMRIGHT")
    divider2:SetHeight(1)

	MakeLogWindow()
	MakeCommWindow()
	MakeUtilityWindow()
	MakeInfoWindow()

	self.Docklet:Hide()

	self:ResetLogs()

	local targetButton = CreateFrame("Button", "SVUI_TargetScanButton", UIParent, "SecureActionButtonTemplate")
	targetButton:SetAllPoints(self.LOG)
	targetButton:SetFrameLevel(99)
	targetButton:RegisterForClicks("AnyUp")
	targetButton:SetAttribute("type1", "macro")
	targetButton:SetAttribute("macrotext", "/tar")
	targetButton:EnableMouse(false)
	targetButton:HookScript("OnClick", function(this) this:EnableMouse(false) end)

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self:RegisterEvent("PLAYER_TARGET_CHANGED", "EventDistributor")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "EventDistributor")
	self:RegisterEvent("PLAYER_DEAD", "EventDistributor")

	self:RegisterEvent("ZONE_CHANGED", "UpdateZoneStatus")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateZoneStatus")
	self:RegisterEvent("UNIT_FACTION", "UpdateZoneStatus")

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateCommunicator")
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", "UpdateCommunicator")

	if(self.db.annoyingEmotes) then
		SVUI_Player.Health.LowAlertFunc = LowHealth_PlayerEmote
		SVUI_Target.Health.LowAlertFunc = LowHealth_TargetEmote
	end
end