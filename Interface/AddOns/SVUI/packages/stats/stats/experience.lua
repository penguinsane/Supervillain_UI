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

STATS:Extend EXAMPLE USAGE: MOD:Extend(newStat,eventList,onEvents,update,click,focus,blur)

########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
if (UnitLevel("player") == GetMaxPlayerLevel()) then return end;
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
local gsub = string.gsub;
--MATH
local math          = _G.math;
local min         = math.min
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV.SVStats;
--[[ 
########################################################## 
EXPERIENCE STATS
##########################################################
]]--
local StatEvents = {"PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP", "DISABLE_XP_GAIN", "ENABLE_XP_GAIN", "UPDATE_EXHAUSTION"};

local function getUnitXP(unit)
	if unit == "pet"then
		return GetPetExperience()
	else
		return UnitXP(unit),UnitXPMax(unit)
	end 
end 

local function TruncateString(value)
    if value >= 1e9 then 
        return ("%.1fb"):format(value/1e9):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e6 then 
        return ("%.1fm"):format(value/1e6):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e3 or value <= -1e3 then 
        return ("%.1fk"):format(value/1e3):gsub("%.?0+([kmb])$","%1")
    else 
        return value 
    end 
end

local function Experience_OnEvent(self, ...)
	if self.barframe:IsShown()then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
		self.text:FontManager(LSM:Fetch("font",SV.db.SVStats.font),SV.db.SVStats.fontSize,SV.db.SVStats.fontOutline)
	end 
	local f, g = getUnitXP("player")
	local h = GetXPExhaustion()
	local i = ""
	if h and h > 0 then
		i = format("%s - %d%% R:%s [%d%%]", TruncateString(f), f / g * 100, TruncateString(h), h / g * 100)
	else
		i = format("%s - %d%%", TruncateString(f), f / g * 100)
	end 
	self.text:SetText(i)
end 

local function ExperienceBar_OnEvent(self, ...)
	if (UnitLevel("player") == GetMaxPlayerLevel())then
		self:Hide()
		MOD:UnSet(self)
		return
	end
	if (not self.barframe:IsShown())then
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture("Interface\\Addons\\SVUI\\assets\\artwork\\Icons\\STAT-XP")
		self.text:FontManager(LSM:Fetch("font",SV.db.SVStats.font),SV.db.SVStats.fontSize,"NONE")
	end
	if not self.barframe.bar.extra:IsShown() then
		self.barframe.bar.extra:Show()
	end 
	local k = self.barframe.bar;
	local f, g = getUnitXP("player")
	k:SetMinMaxValues(0, g)
	k:SetValue((f - 1) >= 0 and (f - 1) or 0)
	k:SetStatusBarColor(0, 0.5, 1)
	local h = GetXPExhaustion()
	if h and h>0 then
		k.extra:SetMinMaxValues(0, g)
		k.extra:SetValue(min(f + h, g))
		k.extra:SetStatusBarColor(0.8, 0.5, 1)
		k.extra:SetAlpha(0.5)
	else
		k.extra:SetMinMaxValues(0, 1)
		k.extra:SetValue(0)
	end 
	self.text:SetText("")
end 

local function Experience_OnEnter(self)
	MOD:Tip(self)
	local XP, maxXP = getUnitXP("player")
	local h = GetXPExhaustion()
	MOD.tooltip:AddLine(L["Experience"])
	MOD.tooltip:AddLine(" ")

	MOD.tooltip:AddDoubleLine(L["XP:"], (" %d  /  %d (%d%%)"):format(XP, maxXP, (XP / maxXP) * 100), 1, 1, 1)
	MOD.tooltip:AddDoubleLine(L["Remaining:"], (" %d (%d%% - %d "..L["Bars"]..")"):format(maxXP - XP, (maxXP - XP) / maxXP * 100, 20 * (maxXP - XP) / maxXP), 1, 1, 1)
	if h then
		MOD.tooltip:AddDoubleLine(L["Rested:"], format(" + %d (%d%%)", h, h / maxXP * 100), 1, 1, 1)
	end 
	MOD:ShowTip()
end

local function ExperienceBar_OnLoad(self)
	if (UnitLevel("player") == GetMaxPlayerLevel()) then
		self:Hide()
		MOD:UnSet(self)
	end
end 

MOD:Extend("Experience", StatEvents, Experience_OnEvent, nil, nil, Experience_OnEnter, nil, ExperienceBar_OnLoad)
MOD:Extend("Experience Bar", StatEvents, ExperienceBar_OnEvent, nil, nil, Experience_OnEnter, nil, ExperienceBar_OnLoad)