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
local pairs 	= _G.pairs;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local find, format, match, sub, gsub = string.find, string.format, string.match, string.sub, string.gsub;
--[[ MATH METHODS ]]--
local floor,min = math.floor, math.min;
--[[ TABLE METHODS ]]--
local twipe, tconcat = table.wipe, table.concat;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV:NewPackage("SVTip", L["Tooltip"]);
local ID = _G.ID;
--[[ 
########################################################## 
LOCAL VARIABLES
##########################################################
]]--
local NewHook = hooksecurefunc;
local _G = getfenv(0);
local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"];
local playerGUID = UnitGUID("player");
local targetList, inspectCache = {}, {};
local NIL_COLOR = { r = 1, g = 1, b = 1 };
local TAPPED_COLOR = { r = .6, g = .6, b = .6 };
local SKULL_ICON = "|TInterface\\TARGETINGFRAME\\UI-TargetingFrame-Skull.blp:16:16|t";
local TAMABLE_INDICATOR = "|cffFFFF00Tamable|r";
local TT_BG = [[Interface\Addons\SVUI\assets\artwork\Template\Tooltip\TOOLTIP]]
local TT_TOP = [[Interface\Addons\SVUI\assets\artwork\Template\Tooltip\TT-TOP]]
local TT_BOTTOM = [[Interface\Addons\SVUI\assets\artwork\Template\Tooltip\TT-BOTTOM]]
local TT_RIGHT = [[Interface\Addons\SVUI\assets\artwork\Template\Tooltip\TT-RIGHT]]
local TT_LEFT = [[Interface\Addons\SVUI\assets\artwork\Template\Tooltip\TT-LEFT]]

local TAMABLE_FAMILIES = {
	["Basilisk"] = true, 	 ["Bat"] = true, 		  ["Bear"] = true, 		   ["Beetle"] = true, 
	["Bird of Prey"] = true, ["Boar"] = true, 		  ["Carrion Bird"] = true, ["Cat"] = true, 
	["Chimaera"] = true, 	 ["Core Hound"] = true,   ["Crab"] = true, 		   ["Crane"] = true, 
	["Crocolisk"] = true, 	 ["Devilsaur"] = true, 	  ["Direhorn"] = true, 	   ["Dog"] = true, 
	["Dragonhawk"] = true, 	 ["Fox"] = true, 		  ["Goat"] = true, 		   ["Gorilla"] = true, 
	["Wasp"] = true, 		 ["Hydra"] = true, 		  ["Hyena"] = true, 	   ["Monkey"] = true, 
	["Moth"] = true, 		 ["Nether Ray"] = true,   ["Porcupine"] = true,    ["Quilen"] = true, 
	["Raptor"] = true, 		 ["Ravager"] = true, 	  ["Rhino"] = true, 	   ["Riverbeast"] = true, 
	["Scorpid"] = true, 	 ["Shale Spider"] = true, ["Spirit Beast"] = true, ["Serpent"] = true, 
	["Silithid"] = true, 	 ["Spider"] = true, 	  ["Sporebat"] = true, 	   ["Tallstrider"] = true, 
	["Turtle"] = true,		 ["Warp Stalker"] = true, ["Wasp"] = true, 		   ["Water strider"] = true, 
	["Wind Serpent"] = true, ["Wolf"] = true, 		  ["Worm"] = true
}

local tooltips = {
	GameTooltip, ItemRefTooltip, ItemRefShoppingTooltip1, 
	ItemRefShoppingTooltip2, ItemRefShoppingTooltip3, AutoCompleteBox, 
	FriendsTooltip, ConsolidatedBuffsTooltip, ShoppingTooltip1, 
	ShoppingTooltip2, ShoppingTooltip3, WorldMapTooltip, 
	WorldMapCompareTooltip1, WorldMapCompareTooltip2, 
	WorldMapCompareTooltip3, DropDownList1MenuBackdrop, 
	DropDownList2MenuBackdrop, DropDownList3MenuBackdrop, BNToastFrame,
	PetBattlePrimaryAbilityTooltip, PetBattlePrimaryUnitTooltip,
	BattlePetTooltip, FloatingBattlePetTooltip, FloatingPetBattleAbilityTooltip
}

local classification = {
	worldboss = format("|cffAF5050%s|r", BOSS), 
	rareelite = format("|cffAF5050+%s|r", ITEM_QUALITY3_DESC), 
	elite = "|cffAF5050+|r", 
	rare = format("|cffAF5050%s|r", ITEM_QUALITY3_DESC)
}
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function Pinpoint(parent)
    local centerX,centerY = parent:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local result;
    if not centerX or not centerY then 
        return "CENTER"
    end 
    local heightTop = screenHeight * 0.75;
    local heightBottom = screenHeight * 0.25;
    local widthLeft = screenWidth * 0.25;
    local widthRight = screenWidth * 0.75;
    if(((centerX > widthLeft) and (centerX < widthRight)) and (centerY > heightTop)) then 
        result="TOP"
    elseif((centerX < widthLeft) and (centerY > heightTop)) then 
        result="TOPLEFT"
    elseif((centerX > widthRight) and (centerY > heightTop)) then 
        result="TOPRIGHT"
    elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then 
        result="BOTTOM"
    elseif((centerX < widthLeft) and (centerY < heightBottom)) then 
        result="BOTTOMLEFT"
    elseif((centerX > widthRight) and (centerY < heightBottom)) then 
        result="BOTTOMRIGHT"
    elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then 
        result="LEFT"
    elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then 
        result="RIGHT"
    else 
        result="CENTER"
    end 
    return result 
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

local function GetTalentSpec(unit,isPlayer)
	local spec;
	if isPlayer then 
		spec = GetSpecialization()
	else 
		spec = GetInspectSpecialization(unit)
	end 
	if spec ~= nil and spec > 0 then 
		if not isPlayer then 
			local byRole = GetSpecializationRoleByID(spec)
			if byRole ~= nil then 
				local _,byRoleData = GetSpecializationInfoByID(spec)
				return byRoleData 
			end 
		else 
			local _,specData = GetSpecializationInfo(spec)
			return specData 
		end 
	end 
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
local SetMaskBorder = function(self, r, g, b)
	r,g,b = (r * 0.5),(g * 0.5),(b * 0.5)
	self[5]:SetTexture(r, g, b)
	self[6]:SetTexture(r, g, b)
	self[7]:SetTexture(r, g, b)
	self[8]:SetTexture(r, g, b)
end

local SetBurstColor = function(self, r, g, b)
	local a = self.ToggleAlpha
	self[1]:SetVertexColor(r, g, b, a)
	self[2]:SetVertexColor(r, g, b, a)
	self[3]:SetVertexColor(0, 0, 0, 0)
	self[4]:SetVertexColor(0, 0, 0, 0)
	self:SetMaskBorder(r, g, b)
end

local SetToneColor = function(self, r, g, b)
	local a = self.ToggleAlpha
	self[1]:SetVertexColor(0, 0, 0, 0)
	self[2]:SetVertexColor(0, 0, 0, 0)
	self[3]:SetVertexColor(r, g, b, a)
	self[4]:SetVertexColor(r, g, b, a)
	self:SetMaskBorder(r, g, b)
end

local ClearMaskColors = function(self)
	self[1]:SetVertexColor(0, 0, 0, 0)
	self[2]:SetVertexColor(0, 0, 0, 0)
	self[3]:SetVertexColor(0, 0, 0, 0)
	self[4]:SetVertexColor(0, 0, 0, 0)

	self[5]:SetTexture(0, 0, 0)
	self[6]:SetTexture(0, 0, 0)
	self[7]:SetTexture(0, 0, 0)
	self[8]:SetTexture(0, 0, 0)
end

function MOD:INSPECT_READY(_,guid)
	if MOD.lastGUID ~= guid then return end 
	local unit = "mouseover"
	if UnitExists(unit) then 
		local itemLevel = SV:ParseGearSlots(unit, true)
		local spec = GetTalentSpec(unit)
		inspectCache[guid] = {time = GetTime()}
		if spec then 
			inspectCache[guid].talent=spec 
		end 
		if itemLevel then 
			inspectCache[guid].itemLevel = itemLevel 
		end 
		GameTooltip:SetUnit(unit)
	end 
	MOD:UnregisterEvent("INSPECT_READY")
end 

local function ShowInspectInfo(this,unit,unitLevel,r,g,b,iteration)
	local inspectable = CanInspect(unit)
	if not inspectable or unitLevel < 10 or iteration > 2 then return end 
	local guid = UnitGUID(unit)
	if guid == playerGUID then 
		this:AddDoubleLine(L["Talent Specialization:"],GetTalentSpec(unit,true),nil,nil,nil,r,g,b)
		this:AddDoubleLine(L["Item Level:"],floor(select(2,GetAverageItemLevel())),nil,nil,nil,1,1,1)
	elseif inspectCache[guid] then 
		local talent = inspectCache[guid].talent;
		local itemLevel = inspectCache[guid].itemLevel;
		if GetTime() - inspectCache[guid].time > 900 or not talent or not itemLevel then 
			inspectCache[guid] = nil;
			return ShowInspectInfo(this,unit,unitLevel,r,g,b,iteration+1)
		end 
		this:AddDoubleLine(L["Talent Specialization:"],talent,nil,nil,nil,r,g,b)
		this:AddDoubleLine(L["Item Level:"],itemLevel,nil,nil,nil,1,1,1)
	else 
		if(not inspectable or (InspectFrame and InspectFrame:IsShown())) then 
			return 
		end 
		MOD.lastGUID = guid;
		NotifyInspect(unit)
		MOD:RegisterEvent("INSPECT_READY")
	end 
end 

local function tipcleaner(this)
	for i=3, this:NumLines() do 
		local tip = _G["GameTooltipTextLeft"..i]
		local tipText = tip:GetText()
		if tipText:find(PVP) or tipText:find(FACTION_ALLIANCE) or tipText:find(FACTION_HORDE) then 
			tip:SetText(nil)
			tip:Hide()
		end 
	end 
end 

local function tiplevel(this, start)
	for i = start, this:NumLines() do 
		local tip = _G["GameTooltipTextLeft"..i]
		if tip:GetText() and tip:GetText():find(LEVEL) then 
			return tip 
		end 
	end 
end

local _hook_GameTooltip_OnTooltipSetUnit = function(self)
	self.SuperBorder:ClearMaskColors()
	local unit = select(2, self:GetUnit())
	local TamablePet;
	if self:GetOwner()  ~= UIParent and SV.db.SVTip.visibility.unitFrames  ~= "NONE" then 
		local vis = SV.db.SVTip.visibility.unitFrames;
		if vis == "ALL" or not (vis == "SHIFT" and IsShiftKeyDown() or vis == "CTRL" and IsControlKeyDown() or vis == "ALT" and IsAltKeyDown()) then 
			self:Hide()
			return 
		end 
	end 
	if not unit then 
		local mFocus = GetMouseFocus()
		if mFocus and mFocus:GetAttribute("unit") then 
			unit = mFocus:GetAttribute("unit")
		end 
		if not unit or not UnitExists(unit) then return end 
	end 
	tipcleaner(self)
	local unitLevel = UnitLevel(unit)
	local colors, qColor, totColor;
	local lvlLine;
	local isShiftKeyDown = IsShiftKeyDown()

	if UnitIsPlayer(unit) then 
		local className, classToken = UnitClass(unit)
		local unitName, unitRealm = UnitName(unit)
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		local realmRelation = UnitRealmRelationship(unit)
		colors = RAID_CLASS_COLORS[classToken]

		local burst = SVUI_CLASS_COLORS[classToken]

		self.SuperBorder:SetBurstColor(burst.r, burst.g, burst.b)

		if SV.db.SVTip.playerTitles and pvpName then 
			unitName = pvpName 
		end 
		if unitRealm and unitRealm ~= "" then 
			if(isShiftKeyDown) then 
				unitName = unitName.."-"..unitRealm 
			elseif(realmRelation == LE_REALM_RELATION_COALESCED) then 
				unitName = unitName..FOREIGN_SERVER_LABEL 
			elseif(realmRelation == LE_REALM_RELATION_VIRTUAL) then 
				unitName = unitName..INTERACTIVE_SERVER_LABEL 
			end 
		end

		if(UnitIsAFK(unit)) then
			GameTooltipTextLeft1:SetFormattedText("[|cffFF0000%s|r] |c%s%s|r ", L["AFK"], colors.colorStr, unitName)
		elseif(UnitIsDND(unit)) then
			GameTooltipTextLeft1:SetFormattedText("[|cffFF9900%s|r] |c%s%s|r ", L["DND"], colors.colorStr, unitName)
		else
			GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", colors.colorStr, unitName)
		end

		if(guildName) then
			if(guildRealm and isShiftKeyDown) then
				guildName = guildName.."-"..guildRealm
			end

			if guildRankName and SV.db.SVTip.guildRanks then 
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r> [|cff00ff10%s|r]"):format(guildName, guildRankName))
			else 
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r>"):format(guildName))
			end 
			lvlLine = tiplevel(self, 3)
		else
			lvlLine = tiplevel(self, 2)
		end 

		if(lvlLine) then 
			qColor = GetQuestDifficultyColor(unitLevel)
			local race, englishRace = UnitRace(unit)
			local _, factionGroup = UnitFactionGroup(unit)
			if(factionGroup and englishRace == "Pandaren") then
				race = factionGroup.." "..race
			end	
			lvlLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", qColor.r * 255, qColor.g * 255, qColor.b * 255, unitLevel > 0 and unitLevel or SKULL_ICON, race or "", colors.colorStr, className)
		end 

		if(not IsAddOnLoaded("HealBot") and (SV.db.SVTip.inspectInfo or isShiftKeyDown)) then 
			ShowInspectInfo(self, unit, unitLevel, colors.r, colors.g, colors.b, 0)
		end 
	else
		if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then 
			colors = TAPPED_COLOR
		else 
			colors = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		end 
		if(colors) then self.SuperBorder:SetToneColor(colors.r, colors.g, colors.b) end
		lvlLine = tiplevel(self, 2)

		if(lvlLine) then
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local temp = ""
			if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then 
				unitLevel = UnitBattlePetLevel(unit)
				local ab = C_PetJournal.GetPetTeamAverageLevel()
				if ab then 
					qColor = GetRelativeDifficultyColor(ab, unitLevel)
				else 
					qColor = GetQuestDifficultyColor(unitLevel)
				end 
			else 
				qColor = GetQuestDifficultyColor(unitLevel)
			end 

			if UnitIsPVP(unit) then 
				temp = format(" (%s)", PVP)
			end 

			if(creatureType) then
				local family = UnitCreatureFamily(unit) or creatureType
				if(SV.class == "HUNTER" and creatureType == PET_TYPE_SUFFIX[8] and (family and TAMABLE_FAMILIES[family])) then
					local hunterLevel = UnitLevel("player")
					if(unitLevel <= hunterLevel) then
						TamablePet = true
					end
				end
				creatureType = family
			else
				creatureType = ""
			end

			lvlLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", qColor.r * 255, qColor.g * 255, qColor.b * 255, unitLevel > 0 and unitLevel or "??", classification[creatureClassification] or "", creatureType, temp)
		end 
	end
	if(TamablePet) then
		GameTooltip:AddLine(TAMABLE_INDICATOR)
	end
	if SV.db.SVTip.targetInfo then
		local unitTarget = unit.."target"
		if(unit ~= "player" and UnitExists(unitTarget)) then 
			if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then 
				totColor = RAID_CLASS_COLORS[select(2, UnitClass(unitTarget))]
			else 
				totColor = FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
			end 
			GameTooltip:AddDoubleLine(format("%s:", TARGET), format("|cff%02x%02x%02x%s|r", totColor.r * 255, totColor.g * 255, totColor.b * 255, UnitName(unitTarget)))
		end 
		if IsInGroup() then 
			for i = 1, GetNumGroupMembers() do 
				local groupedUnit = IsInRaid() and "raid"..i or "party"..i;
				if UnitIsUnit(groupedUnit.."target", unit) and not UnitIsUnit(groupedUnit, "player") then 
					local _, classToken = UnitClass(groupedUnit)
					tinsert(targetList, format("|c%s%s|r", RAID_CLASS_COLORS[classToken].colorStr, UnitName(groupedUnit)))
				end 
			end 
			local maxTargets = #targetList;
			if maxTargets > 0 then 
				GameTooltip:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted By:"], maxTargets, tconcat(targetList, ", ")), nil, nil, nil, true)
				twipe(targetList)
			end 
		end 
	end 
	if colors then 
		GameTooltipStatusBar:SetStatusBarColor(colors.r, colors.g, colors.b)
	else 
		GameTooltipStatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end 
end 

local _hook_GameTooltipStatusBar_OnValueChanged = function(self, value)
	if not value or not SV.db.SVTip.healthBar.text or not self.text then return end 
	local unit = select(2,self:GetParent():GetUnit())
	if not unit then 
		local mFocus = GetMouseFocus()
		if mFocus and mFocus:GetAttribute("unit") then 
			unit = mFocus:GetAttribute("unit")
		end 
	end 
	local min,max = self:GetMinMaxValues()
	if value > 0 and max==1 then 
		self.text:SetText(format("%d%%",floor(value * 100)))
		self:SetStatusBarColor(TAPPED_COLOR.r,TAPPED_COLOR.g,TAPPED_COLOR.b)
	elseif value==0 or unit and UnitIsDeadOrGhost(unit) then 
		self.text:SetText(DEAD)
	else 
		self.text:SetText(TruncateString(value).." / "..TruncateString(max))
	end 
end 

local _hook_GameTooltip_OnTooltipSetItem = function(self)
	if not self.itemCleared then
		self.SuperBorder:ClearMaskColors()
		local key,itemID = self:GetItem()
		if(key) then
			local quality = select(3, GetItemInfo(key))
			if(quality) then
				local r,g,b = GetItemQualityColor(quality)
				self.SuperBorder:SetToneColor(r,g,b)
			end
		end
		local left = "";
		local right = "";
		if itemID ~= nil and SV.db.SVTip.spellID then 
			left = "|cFFCA3C3CSpell ID: |r"
			right = ("|cFFCA3C3C%s|r %s"):format(ID,itemID):match(":(%w+)")
		end 
		if left ~= "" or right ~= "" then 
			self:AddLine(" ")
			self:AddDoubleLine(left,right)
		end 
		self.itemCleared = true 
	end
end 

local _hook_GameTooltip_ShowStatusBar = function(self, ...)
	local name = self:GetName()
	local barName = ("%sStatusBar%d"):format(name, self.shownStatusBars)
	local bar = _G[barName]
	if bar and not bar.styled then 
		bar:RemoveTextures()
		bar:SetStatusBarTexture([[Interface\AddOns\SVUI\assets\artwork\Template\DEFAULT]])
		bar:SetFixedPanelTemplate('Inset',true)
		if not bar.border then 
			local border=CreateFrame("Frame",nil,bar)
			border:WrapOuter(bar,1,1)
			border:SetFrameLevel(bar:GetFrameLevel() - 1)
			border:SetBackdrop({
				edgeFile=[[Interface\BUTTONS\WHITE8X8]],
				edgeSize=1,
				insets={left=1,right=1,top=1,bottom=1}
			})
			border:SetBackdropBorderColor(0,0,0,1)
			bar.border=border 
		end 
		bar.styled=true 
	end 
end 

local _hook_OnSetUnitAura = function(self, unit, index, filter)
	local _, _, _, _, _, _, _, caster, _, _, spellID = UnitAura(unit, index, filter)
	if spellID and SV.db.SVTip.spellID then 
		self.SuperBorder:ClearMaskColors()
		if caster then 
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			if color then
				self.SuperBorder:SetMaskBorder(color.r, color.g, color.b)
				self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, spellID), format("|c%s%s|r", color.colorStr, name))
			end
		else 
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, spellID))
		end 
		self:Show()
	end 
end 

local _hook_OnSetHyperUnitAura = function(self, unit, index, filter)
	if unit ~= "player" then return end
	local auraName, _, _, _, _, _, _, caster, _, shouldConsolidate, spellID = UnitAura(unit, index, filter)
	if shouldConsolidate then
		self.SuperBorder:ClearMaskColors()
		if caster then 
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			if color then
				self.SuperBorder:SetMaskBorder(color.r, color.g, color.b)
				self:AddDoubleLine(("|cFFCA3C3C%s|r"):format(auraName), format("|c%s%s|r", color.colorStr, name))
			end
		else 
			self:AddLine(("|cFFCA3C3C%s|r"):format(auraName))
		end 
		self:Show()
	end 
end 

local _hook_GameTooltip_OnTooltipSetSpell = function(self)
	local ref = select(3, self:GetSpell())
	if not ref then return end 
	local text = ("|cFFCA3C3C%s|r%d"):format(ID, ref)
	local max = self:NumLines()
	local check;
	for i = 1, max do 
		local tip = _G[("GameTooltipTextLeft%d"):format(i)]
		if tip and tip:GetText() and tip:GetText():find(text) then 
			check = true;
			break 
		end 
	end 
	if not check then
		self.SuperBorder:ClearMaskColors() 
		self:AddLine(text)
		self:Show()
	end 
end 

local _hook_GameTooltip_SetDefaultAnchor = function(self, parent)
	if SV.db.SVTip.enable ~= true then return end
	if(self:GetAnchorType() ~= "ANCHOR_NONE") then return end 
	if InCombatLockdown() and SV.db.SVTip.visibility.combat then 
		self:Hide()
		return 
	end 
	if parent then 
		if(SV.db.SVTip.cursorAnchor) then 
			self:SetOwner(parent, "ANCHOR_CURSOR")
			return 
		else 
			self:SetOwner(parent, "ANCHOR_NONE")
		end 
	end 
	if not SV.Mentalo:HasMoved("SVUI_ToolTip_MOVE")then
		self:ClearAllPoints()
		if(SV.SVBag.BagFrame and SV.SVBag.BagFrame:IsShown()) then
			self:SetPoint("BOTTOMLEFT", SV.SVBag.BagFrame, "TOPLEFT", 0, 20)
		elseif(SV.Dock.BottomRight:GetAlpha() == 1 and SV.Dock.BottomRight:IsShown()) then 
			self:SetPoint("BOTTOMLEFT", SV.Dock.BottomRight, "TOPLEFT", 0, 20)
		else 
			self:SetPoint("BOTTOMLEFT", SV.Dock.BottomRight.Bar, "TOPLEFT", 0, 20)
		end 
	else
		local point = Pinpoint(SVUI_ToolTip_MOVE)
		if(point == "TOPLEFT") then 
			self:SetPoint("TOPLEFT", SVUI_ToolTip_MOVE, "TOPLEFT", 0, 0)
		elseif(point == "TOPRIGHT") then 
			self:SetPoint("TOPRIGHT", SVUI_ToolTip_MOVE, "TOPRIGHT", 0, 0)
		elseif(point == "BOTTOMLEFT" or point == "LEFT" )then 
			self:SetPoint("BOTTOMLEFT", SVUI_ToolTip_MOVE, "BOTTOMLEFT", 0, 0)
		else 
			self:SetPoint("BOTTOMRIGHT", SVUI_ToolTip_MOVE, "BOTTOMRIGHT", 0, 0)
		end 
	end 
end 
MOD.GameTooltip_SetDefaultAnchor = _hook_GameTooltip_SetDefaultAnchor

local _hook_BNToastOnShow = function(self,anchor,parent,relative,x,y)
	if parent ~= BattleNetToasts_MOVE then 
		BNToastFrame:ClearAllPoints()
		BNToastFrame:Point('TOPLEFT',BattleNetToasts_MOVE,'TOPLEFT')
	end
end

local _hook_OnTipCleared = function(self)
	self.itemCleared = nil 
end

local _hook_OnItemRef = function(link, text, button, chatFrame)
	if link:find("^spell:") then 
		local ref = sub(link,7)
		ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, ref))
		ItemRefTooltip:Show()
	end 
end

local TooltipModifierChangeHandler = function(self, event, mod)
	if (mod == "LSHIFT" or mod == "RSHIFT") and UnitExists("mouseover") then 
		GameTooltip:SetUnit("mouseover")
	end 
end 

local Override_BGColor = function(self, r, g, b, a) 
	if(b ~= 0 or (a and a ~= 0)) then
		self:SetBackdropColor(0, 0, 0, 0)
		self.SuperBorder:SetBackdropColor(0, 0, 0, 0.8) 
	end
end

local Override_BorderColor = function(self, r, g, b, a) 
	if(b ~= 0 or (a and a ~= 0)) then
		self:SetBackdropBorderColor(0, 0, 0, 0)
		self.SuperBorder:SetBackdropBorderColor(0, 0, 0)
		self.SuperBorder:SetToneColor(r, g, b)
	end 
end

local _hook_OnTipShow = function(self)
	local width,height = self:GetSize()
	local heightScale = min(64, height)
	local widthScale = min(128, width)
	local heightWidth = widthScale * 0.35

	self:SetBackdrop({
		bgFile = TT_BG, 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = true, 
		tileSize = 128,
		edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1}
	})
	self:SetBackdropColor(0, 0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0, 0)

	local mask = self.SuperBorder
	mask:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	if(GameTooltipStatusBar:IsShown()) then
		mask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, mask.ToggleHeight)
	else
		mask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	end

	mask[1]:SetSize(widthScale,heightWidth)
	mask[2]:SetSize(widthScale,heightWidth)
	mask[3]:SetSize(heightScale,heightScale)
	mask[4]:SetSize(heightScale,heightScale)

	mask:SetBackdrop({
		bgFile = TT_BG, 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = true, 
		tileSize = 128,
		edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1}
	})
	mask:SetBackdropColor(0, 0, 0, 1)
	mask:SetBackdropBorderColor(0, 0, 0, 1)
end

local _hook_OnTipHide = function(self)
	self.SuperBorder:ClearMaskColors()
end

local function ApplyTooltipSkins()
	local barHeight = GameTooltipStatusBar:GetHeight()

	for i, tooltip in pairs(tooltips) do
		if(not tooltip) then return end
		if(not tooltip.SuperBorder) then 
			local barOffset = 0
			local alpha = 0.2
			if(tooltip == GameTooltip) then
				barOffset = (barHeight + 6) * -1
				alpha = 0.5
			end

			local mask = CreateFrame("Frame", nil, tooltip)
			mask:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 0, 0)
			mask:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMRIGHT", 0, barOffset)
			mask:SetFrameLevel(0)
			mask.ToggleHeight = barOffset
			mask.ToggleAlpha = alpha

			--[[ STARBURST TOP ]]
			mask[1] = mask:CreateTexture(nil, "BACKGROUND")
			mask[1]:SetPoint("BOTTOMLEFT", mask, "TOPLEFT", 0, 0)
			mask[1]:SetHeight(mask:GetWidth() * 0.25)
			mask[1]:SetWidth(mask:GetWidth() * 0.25)
			mask[1]:SetTexture(TT_TOP)
			mask[1]:SetVertexColor(0,0,0)
			mask[1]:SetBlendMode("BLEND")
			mask[1]:SetAlpha(alpha)
			--[[ STARBURST BOTTOM ]]
			mask[2] = mask:CreateTexture(nil, "BACKGROUND")
			mask[2]:SetPoint("TOPRIGHT", mask, "BOTTOMRIGHT", 0, 0)
			mask[2]:SetHeight(mask:GetWidth() * 0.25)
			mask[2]:SetWidth(mask:GetWidth() * 0.25)
			mask[2]:SetTexture(TT_BOTTOM)
			mask[2]:SetVertexColor(0,0,0)
			mask[2]:SetBlendMode("BLEND")
			mask[2]:SetAlpha(alpha)
			--[[ HALFTONE RIGHT ]]
			mask[3] = mask:CreateTexture(nil, "BACKGROUND")
			mask[3]:SetPoint("LEFT", mask, "RIGHT", 0, 0)
			mask[3]:SetSize(64,64)
			mask[3]:SetTexture(TT_RIGHT)
			mask[3]:SetVertexColor(0,0,0)
			mask[3]:SetBlendMode("BLEND")
			mask[3]:SetAlpha(alpha)
			--[[ HALFTONE LEFT ]]
			mask[4] = mask:CreateTexture(nil, "BACKGROUND")
			mask[4]:SetPoint("RIGHT", mask, "LEFT", 0, 0)
			mask[4]:SetSize(64,64)
			mask[4]:SetTexture(TT_LEFT)
			mask[4]:SetVertexColor(0,0,0)
			mask[4]:SetBlendMode("BLEND")
			mask[4]:SetAlpha(alpha)

			--[[ BORDER TOP ]]
			mask[5] = mask:CreateTexture(nil, "OVERLAY")
			mask[5]:SetPoint("TOPLEFT", mask, "TOPLEFT", 0, 0)
			mask[5]:SetPoint("TOPRIGHT", mask, "TOPRIGHT", 0, 0)
			mask[5]:SetHeight(1)
			mask[5]:SetTexture(0,0,0)
			--[[ BORDER BOTTOM ]]
			mask[6] = mask:CreateTexture(nil, "OVERLAY")
			mask[6]:SetPoint("BOTTOMLEFT", mask, "BOTTOMLEFT", 0, 0)
			mask[6]:SetPoint("BOTTOMRIGHT", mask, "BOTTOMRIGHT", 0, 0)
			mask[6]:SetHeight(1)
			mask[6]:SetTexture(0,0,0)
			--[[ BORDER RIGHT ]]
			mask[7] = mask:CreateTexture(nil, "OVERLAY")
			mask[7]:SetPoint("TOPRIGHT", mask, "TOPRIGHT", 0, 0)
			mask[7]:SetPoint("BOTTOMRIGHT", mask, "BOTTOMRIGHT", 0, 0)
			mask[7]:SetWidth(1)
			mask[7]:SetTexture(0,0,0)
			--[[ BORDER LEFT ]]
			mask[8] = mask:CreateTexture(nil, "OVERLAY")
			mask[8]:SetPoint("TOPLEFT", mask, "TOPLEFT", 0, 0)
			mask[8]:SetPoint("BOTTOMLEFT", mask, "BOTTOMLEFT", 0, 0)
			mask[8]:SetWidth(1)
			mask[8]:SetTexture(0,0,0)

			mask:SetBackdrop({
				bgFile = TT_BG, 
				edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
				tile = true,
				tileSize = 128,
				edgeSize = 1,
				insets = {left = 1, right = 1, top = 1, bottom = 1}
			})
			mask:SetBackdropColor(0, 0, 0, 1)
			mask:SetBackdropBorderColor(0, 0, 0)

			mask.SetMaskBorder = SetMaskBorder
			mask.SetBurstColor = SetBurstColor
			mask.SetToneColor = SetToneColor
			mask.ClearMaskColors = ClearMaskColors

			tooltip.SuperBorder = mask

			if tooltip.Background then
				tooltip.Background:SetTexture(0,0,0,0)
			end

			if tooltip.Delimiter1 then 
				tooltip.Delimiter1:SetTexture(0,0,0,0)
				tooltip.Delimiter2:SetTexture(0,0,0,0)
			end

			if tooltip.BorderTop then
				tooltip.BorderTop:SetTexture(0,0,0,0)
			end

			if tooltip.BorderTopLeft then
				tooltip.BorderTopLeft:SetTexture(0,0,0,0)
			end

			if tooltip.BorderTopRight then
				tooltip.BorderTopRight:SetTexture(0,0,0,0)
			end

			if tooltip.BorderLeft then
				tooltip.BorderLeft:SetTexture(0,0,0,0)
			end

			if tooltip.BorderRight then
				tooltip.BorderRight:SetTexture(0,0,0,0)
			end

			if tooltip.BorderBottom then
				tooltip.BorderBottom:SetTexture(0,0,0,0)
			end

			if tooltip.BorderBottomRight then
				tooltip.BorderBottomRight:SetTexture(0,0,0,0)
			end

			if tooltip.BorderBottomLeft then
				tooltip.BorderBottomLeft:SetTexture(0,0,0,0)
			end
			
			tooltip:SetBackdrop({
				bgFile = TT_BG, 
				edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
				tileSize = 128,
				tile = true, 
				edgeSize = 1,
				insets = {left = 1, right = 1, top = 1, bottom = 1}
			})
			tooltip:SetBackdropColor(0, 0, 0, 0)
			tooltip:SetBackdropBorderColor(0, 0, 0, 0)

			tooltip.SetBackdrop = Override_BG
			NewHook(tooltip, "SetBackdropColor", Override_BGColor)
			NewHook(tooltip, "SetBackdropBorderColor", Override_BorderColor)
			tooltip:HookScript("OnShow", _hook_OnTipShow)
			tooltip:HookScript("OnHide", _hook_OnTipHide)
		end
		tremove(tooltips, i)	
	end
	if(not tooltips[1]) then
		MOD.AllSkinned = true
	end
end

function MOD:ReLoad()
	if(not self.AllSkinned) then
		ApplyTooltipSkins()
	end
end

function MOD:Load()
	BNToastFrame:ClearAllPoints()
	BNToastFrame:Point("BOTTOMRIGHT", SV.Dock.BottomLeft, "TOPRIGHT", 0, 20)
	SV.Mentalo:Add(BNToastFrame, L["BattleNet Frame"], nil, nil, nil, nil, "BattleNetToasts")
	NewHook(BNToastFrame, "SetPoint", _hook_BNToastOnShow)
	if not SV.db.SVTip.enable then return end

	local anchor = CreateFrame("Frame", "SVUI_ToolTip", SV.Screen)
	anchor:Point("BOTTOMLEFT", SV.Dock.BottomRight, "TOPLEFT", 0, 20)
	anchor:Size(130, 20)
	anchor:SetFrameLevel(anchor:GetFrameLevel()  +  50)
	SV.Mentalo:Add(anchor, L["Tooltip"])

	local barHeight = SV.db.SVTip.healthBar.height
	GameTooltipStatusBar:SetHeight(barHeight)
	GameTooltipStatusBar:SetStatusBarTexture(SV.Media.bar.default)

	ApplyTooltipSkins()
	
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip.SuperBorder, "BOTTOMLEFT", 3, 3)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip.SuperBorder, "BOTTOMRIGHT", -3, 3)
	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, "CENTER", 0, 0)
	GameTooltipStatusBar.text:FontManager(LSM:Fetch("font", SV.db.SVTip.healthBar.font), SV.db.SVTip.healthBar.fontSize, "OUTLINE")


	if not GameTooltipStatusBar.border then 
		local border = CreateFrame("Frame", nil, GameTooltipStatusBar)
		border:WrapOuter(GameTooltipStatusBar, 1, 1)
		border:SetFrameLevel(GameTooltipStatusBar:GetFrameLevel() - 1)
		border:SetBackdrop({edgeFile = [[Interface\BUTTONS\WHITE8X8]], edgeSize = 1})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		GameTooltipStatusBar.border = border 
	end

	NewHook("GameTooltip_SetDefaultAnchor", _hook_GameTooltip_SetDefaultAnchor)
	NewHook("GameTooltip_ShowStatusBar", _hook_GameTooltip_ShowStatusBar)

	--NewHook("GameTooltip_ShowCompareItem", _hook_GameTooltip_ShowCompareItem) -- BROKEN IN WOD, REMOVING NOW

	NewHook(GameTooltip, "SetUnitAura", _hook_OnSetUnitAura)
	NewHook(GameTooltip, "SetUnitBuff", _hook_OnSetUnitAura)
	NewHook(GameTooltip, "SetUnitDebuff", _hook_OnSetUnitAura)
	NewHook(GameTooltip, "SetUnitConsolidatedBuff", _hook_OnSetHyperUnitAura)

	if SV.db.SVTip.spellID then
		NewHook("SetItemRef", _hook_OnItemRef)
		GameTooltip:HookScript("OnTooltipSetSpell", _hook_GameTooltip_OnTooltipSetSpell)
	end

	GameTooltip:HookScript("OnTooltipCleared", _hook_OnTipCleared)
	GameTooltip:HookScript("OnTooltipSetItem", _hook_GameTooltip_OnTooltipSetItem)
	GameTooltip:HookScript("OnTooltipSetUnit", _hook_GameTooltip_OnTooltipSetUnit)
	GameTooltipStatusBar:HookScript("OnValueChanged", _hook_GameTooltipStatusBar_OnValueChanged)
	self:RegisterEvent("MODIFIER_STATE_CHANGED", TooltipModifierChangeHandler)
end