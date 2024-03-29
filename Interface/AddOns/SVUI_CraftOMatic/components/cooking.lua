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
local unpack 	= _G.unpack;
local select 	= _G.select;
local type 		= _G.type;
local string    = _G.string;
local math 		= _G.math;
local table 	= _G.table;
local rept      = string.rep; 
local tsort,twipe = table.sort,table.wipe;
local floor,ceil  = math.floor, math.ceil;
local band 		= _G.bit.band;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G.SVUI;
local L = SV.L;
local PLUGIN = select(2, ...);
local Schema = PLUGIN.Schema;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local cookingSpell, campFire, skillRank, skillModifier, DockButton;
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function UpdateChefWear()
	if(GetItemCount(46349) > 0) then
		PLUGIN.WornItems["HEAD"] = GetInventoryItemID("player", INVSLOT_HEAD);
		EquipItemByName(46349)
		PLUGIN.InModeGear = true
	end
	if(GetItemCount(86468) > 0) then
		PLUGIN.WornItems["TAB"] = GetInventoryItemID("player", INVSLOT_TABARD);
		EquipItemByName(86468)
		PLUGIN.InModeGear = true
	end
	if(GetItemCount(86559) > 0) then
		PLUGIN.WornItems["MAIN"] = GetInventoryItemID("player", INVSLOT_MAINHAND);
		EquipItemByName(86559)
		PLUGIN.InModeGear = true
	end
	if(GetItemCount(86558) > 0) then
		PLUGIN.WornItems["OFF"] = GetInventoryItemID("player", INVSLOT_OFFHAND);
		EquipItemByName(86558)
		PLUGIN.InModeGear = true
	end
end 

local function GetTitleAndSkill()
	local msg = "|cff22ff11Cooking Mode|r"
	if(skillRank) then
		if(skillModifier) then
			skillRank = skillRank + skillModifier;
		end
		msg = msg .. " (|cff00ddff" .. skillRank .. "|r)";
	end 
	return msg
end 

local function SendModeMessage(...)
	if not CombatText_AddMessage then return end 
	CombatText_AddMessage(...)
end 
--[[ 
########################################################## 
CORE NAMESPACE
##########################################################
]]--
PLUGIN.Cooking = {};
PLUGIN.Cooking.Log = {};
PLUGIN.Cooking.Loaded = false;
--[[ 
########################################################## 
EVENT HANDLER
##########################################################
]]--
local EnableListener, DisableListener
do
	local proxyTest = false;
	local CookEventHandler = CreateFrame("Frame")
	local LootProxy = function(item, name)
		if(item) then
			local mask = [[0x10000]];
			local itemType = GetItemFamily(item);
			local pass = band(itemType, mask);
			if pass > 0 then
				proxyTest = true;
			end
		end
	end 

	local Cook_OnEvent = function(self, event, ...)
		if(InCombatLockdown()) then return end
		if(event == "BAG_UPDATE" or event == "CHAT_MSG_SKILL") then
			local msg = GetTitleAndSkill()
			PLUGIN.TitleWindow:Clear()
			PLUGIN.TitleWindow:AddMessage(msg)
		elseif(event == "CHAT_MSG_LOOT") then
			local item, amt = PLUGIN:CheckForModeLoot(...);
			if item then
				local name, lnk, rarity, lvl, mlvl, itype, stype, cnt, ieq, tex, price = GetItemInfo(item);
				if proxyTest == false then 
					LootProxy(lnk, name)
				end 
				if proxyTest == false then return end 
				if not PLUGIN.Cooking.Log[name] then 
					PLUGIN.Cooking.Log[name] = {amount = 0, texture = ""}; 
				end 
				local r, g, b, hex = GetItemQualityColor(rarity);
				local stored = PLUGIN.Cooking.Log
				local mod = stored[name];
				local newAmt = mod.amount + 1;
				if amt >= 2 then newAmt = mod.amount + amt end 
				PLUGIN.Cooking.Log[name].amount = newAmt;
				PLUGIN.Cooking.Log[name].texture = tex;
				PLUGIN.LogWindow:Clear();
				for name,data in pairs(stored) do
					if type(data) == "table" and data.amount and data.texture then
						PLUGIN.LogWindow:AddMessage("|cff55FF55"..data.amount.." x|r |T".. data.texture ..":16:16:0:0:64:64:4:60:4:60|t".." "..name, r, g, b);
					end
				end 
				PLUGIN.LogWindow:AddMessage("----------------", 0, 0, 0);
				PLUGIN.LogWindow:AddMessage("Cooked So Far...", 0, 1, 1);
				PLUGIN.LogWindow:AddMessage(" ", 0, 0, 0);
				proxyTest = false;
			end
		end
	end 

	function EnableListener()
		CookEventHandler:RegisterEvent("ZONE_CHANGED")
		CookEventHandler:RegisterEvent("BAG_UPDATE")
		CookEventHandler:RegisterEvent("CHAT_MSG_SKILL")
		CookEventHandler:SetScript("OnEvent", Cook_OnEvent)
	end

	function DisableListener()
		CookEventHandler:UnregisterAllEvents()
		CookEventHandler:SetScript("OnEvent", nil)
	end
end
--[[ 
########################################################## 
CORE METHODS
##########################################################
]]--
function PLUGIN.Cooking:Enable()
	PLUGIN.Cooking:Update()
	if(not PLUGIN.Docklet:IsShown()) then PLUGIN.Docklet.DockButton:Click() end
	if(PLUGIN.db.cooking.autoequip) then
		UpdateChefWear();
	end
	PlaySoundFile("Sound\\Spells\\Tradeskills\\CookingPrepareA.wav")
	PLUGIN.ModeAlert:SetBackdropColor(0.25, 0.52, 0.1)

	if(not IsSpellKnown(818)) then
		PLUGIN:ModeLootLoader("Cooking", "WTF is Cooking?", "You have no clue how to cook! \nEven toast is a mystery to you. \nGo find a trainer and learn \nhow to do this simple job.");
	else
		local msg = GetTitleAndSkill();
		if cookingSpell and GetSpellCooldown(campFire) > 0 then
			PLUGIN:ModeLootLoader("Cooking", msg, "Double-Right-Click anywhere on the screen \nto open your cookbook.");
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', cookingSpell)
		else
			PLUGIN:ModeLootLoader("Cooking", msg, "Double-Right-Click anywhere on the screen \nto start a cooking fire.");
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', campFire)
		end
	end
	EnableListener()
	PLUGIN.ModeAlert:Show()
	SendModeMessage("Cooking Mode Enabled", CombatText_StandardScroll, 0.28, 0.9, 0.1);
end

function PLUGIN.Cooking:Disable()
	DisableListener()
end

function PLUGIN.Cooking:Bind()
	if InCombatLockdown() then return end
	if cookingSpell then
		if cookingSpell and GetSpellCooldown(campFire) > 0 then
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', cookingSpell)
			PLUGIN.ModeAlert.HelpText = 'Double-Right-Click to open the cooking window.'
		end
		SetOverrideBindingClick(_G["SVUI_ModeCaptureWindow"], true, "BUTTON2", "SVUI_ModeCaptureWindow");
		_G["SVUI_ModeCaptureWindow"].Grip:Show();
	end
end

function PLUGIN.Cooking:Update()
	campFire = GetSpellInfo(818);
	local _,_,_,_,cook,_ = GetProfessions();
	if cook ~= nil then
		cookingSpell, _, skillRank, _, _, _, _, skillModifier = GetProfessionInfo(cook)
	end 
end
--[[ 
########################################################## 
LOADER
##########################################################
]]--
function PLUGIN:LoadCookingMode()
	self.Cooking:Update()
end