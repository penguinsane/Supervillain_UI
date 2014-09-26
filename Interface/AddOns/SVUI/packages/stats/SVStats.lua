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
local type      = _G.type;
local string    = _G.string;
local math      = _G.math;
--[[ STRING METHODS ]]--
local join = string.join;
--[[ MATH METHODS ]]--
local min = math.min;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SVUI_ADDON_NAME, SV = ...
local SVLib = LibStub("LibSuperVillain-1.0")
local L = SVLib:Lang()
local LSM = LibStub("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local MOD = {};
MOD.Anchors = {};
MOD.Statistics = {};
MOD.StatListing = {[""] = "None"};
MOD.tooltip = CreateFrame("GameTooltip", "StatisticTooltip", UIParent, "GameTooltipTemplate")
MOD.BGPanels = {
	["TopLeftDataPanel"] = {left = "Honor", middle = "Kills", right = "Assists"},
	["TopRightDataPanel"] = {left = "Damage", middle = "Healing", right = "Deaths"}
};
MOD.BGStats = {
	["Name"] = {1, NAME}, 
	["Kills"] = {2, KILLS},
	["Assists"] = {3, PET_ASSIST},
	["Deaths"] = {4, DEATHS},
	["Honor"] = {5, HONOR},
	["Faction"] = {6, FACTION},
	["Race"] = {7, RACE},
	["Class"] = {8, CLASS},
	["Damage"] = {10, DAMAGE},
	["Healing"] = {11, SHOW_COMBAT_HEALING},
	["Rating"] = {12, BATTLEGROUND_RATING},
	["Changes"] = {13, RATING_CHANGE},
	["Spec"] = {16, SPECIALIZATION}
};
--[[ 
########################################################## 
LOCALIZED GLOBALS
##########################################################
]]--
local SVUI_CLASS_COLORS = _G.SVUI_CLASS_COLORS
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
--[[ 
########################################################## 
LOCAL VARIABLES
##########################################################
]]--
local playerName = UnitName("player");
local playerRealm = GetRealmName();
local BGStatString = "%s: %s"
local myName = UnitName("player");
local myClass = select(2,UnitClass("player"));
local classColor = RAID_CLASS_COLORS[myClass];
local StatMenuFrame = CreateFrame("Frame", "SVUI_StatMenu", UIParent);
local ListNeedsUpdate = true
local SCORE_CACHE = {};

-- When its vertical then "left" = "top" and "right" = "bottom". Yes I know thats ghetto, bite me!
local positionIndex = {{"middle", "left", "right"}, {"middle", "top", "bottom"}};
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function GrabPlot(parent, slot, max)
	if max == 1 then 
		return"CENTER", parent, "CENTER"
	else
		if(parent.vertical) then
			if slot == 1 then 
				return "CENTER", parent, "CENTER"
			elseif slot == 2 then 
				return "BOTTOM", parent.holders["middle"], "TOP", 0, 4 
			elseif slot == 3 then 
				return "TOP", parent.holders["middle"], "BOTTOM", 0, -4 
			end
		else
			if slot == 1 then 
				return "CENTER", parent, "CENTER"
			elseif slot == 2 then 
				return "RIGHT", parent.holders["middle"], "LEFT", -4, 0 
			elseif slot == 3 then 
				return "LEFT", parent.holders["middle"], "RIGHT", 4, 0 
			end
		end 
	end 
end

local UpdateAnchor = function()
	local backdrops, width, height = MOD.db.showBackground
	for _, anchor in pairs(MOD.Anchors) do
		if(anchor.vertical) then
			width = anchor:GetWidth() - 4;
			height = anchor:GetHeight() / anchor.numPoints - 4;
		else
			width = anchor:GetWidth() / anchor.numPoints - 4;
			height = anchor:GetHeight() - 4;
			if(backdrops) then
				height = RightSuperDockToggleButton:GetHeight() - 6
			end
		end

		for i = 1, anchor.numPoints do 
			local this = positionIndex[anchor.useIndex][i]
			anchor.holders[this]:Width(width)
			anchor.holders[this]:Height(height)
			anchor.holders[this]:Point(GrabPlot(anchor, i, numPoints))
		end 
	end 
end

local _hook_TooltipOnShow = function(self)
	self:SetBackdrop({
		bgFile = [[Interface\AddOns\SVUI\assets\artwork\Template\DEFAULT]], 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = false, 
		edgeSize = 1
		})
	self:SetBackdropColor(0, 0, 0, 0.8)
	self:SetBackdropBorderColor(0, 0, 0)
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
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:Tip(stat)
	local parent = stat:GetParent()
	MOD.tooltip:Hide()
	MOD.tooltip:SetOwner(parent, parent.anchor)
	MOD.tooltip:ClearLines()
	GameTooltip:Hide()
end 

function MOD:ShowTip(noSpace)
	if(not noSpace) then
		MOD.tooltip:AddLine(" ")
	end
	MOD.tooltip:AddDoubleLine("[Alt + Click]", "Swap Stats", 0, 1, 0, 0.5, 1, 0.5)
	MOD.tooltip:Show()
end 

function MOD:NewAnchor(parent, maxCount, tipAnchor, isTop, customTemplate, isVertical)
	ListNeedsUpdate = true

	local activeIndex = isVertical and 2 or 1
	local template, strata

	if(customTemplate) then
		template = customTemplate
		strata = "LOW"
	else
		template = isTop and "FramedTop" or "FramedBottom"
		strata = "HIGH"
	end

	MOD.Anchors[parent:GetName()] = parent;
	parent.holders = {};
	parent.vertical = isVertical;
	parent.numPoints = maxCount;
	parent.anchor = tipAnchor;
	parent.useIndex = activeIndex

	for i = 1, maxCount do 
		local position = positionIndex[activeIndex][i]
		if not parent.holders[position] then
			parent.holders[position] = CreateFrame("Button", "DataText"..i, parent)
			parent.holders[position]:RegisterForClicks("AnyUp")
			parent.holders[position].barframe = CreateFrame("Frame", nil, parent.holders[position])
			if(MOD.db.showBackground) then
				parent.holders[position].barframe:Point("TOPLEFT", parent.holders[position], "TOPLEFT", 24, -2)
				parent.holders[position].barframe:Point("BOTTOMRIGHT", parent.holders[position], "BOTTOMRIGHT", -2, 2)
				parent.holders[position]:SetFramedButtonTemplate(template)
			else
				parent.holders[position].barframe:Point("TOPLEFT", parent.holders[position], "TOPLEFT", 24, 2)
				parent.holders[position].barframe:Point("BOTTOMRIGHT", parent.holders[position], "BOTTOMRIGHT", 2, -2)
				parent.holders[position].barframe.bg = parent.holders[position].barframe:CreateTexture(nil, "BORDER")
				parent.holders[position].barframe.bg:FillInner(parent.holders[position].barframe, 2, 2)
				parent.holders[position].barframe.bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
				parent.holders[position].barframe.bg:SetGradient(unpack(SV.Media.gradient.dark))
			end
			parent.holders[position].barframe:SetFrameLevel(parent.holders[position]:GetFrameLevel()-1)
			parent.holders[position].barframe:SetBackdrop({
				bgFile = [[Interface\BUTTONS\WHITE8X8]], 
				edgeFile = [[Interface\AddOns\SVUI\assets\artwork\Template\GLOW]], 
				tile = false, 
				tileSize = 0, 
				edgeSize = 2, 
				insets = {left = 0, right = 0, top = 0, bottom = 0}
				})
			parent.holders[position].barframe:SetBackdropColor(0, 0, 0, 0.5)
			parent.holders[position].barframe:SetBackdropBorderColor(0, 0, 0, 0.8)
			parent.holders[position].barframe.icon = CreateFrame("Frame", nil, parent.holders[position].barframe)
			parent.holders[position].barframe.icon:Point("TOPLEFT", parent.holders[position], "TOPLEFT", 0, 6)
			parent.holders[position].barframe.icon:Point("BOTTOMRIGHT", parent.holders[position], "BOTTOMLEFT", 26, -6)
			parent.holders[position].barframe.icon.texture = parent.holders[position].barframe.icon:CreateTexture(nil, "OVERLAY")
			parent.holders[position].barframe.icon.texture:FillInner(parent.holders[position].barframe.icon, 2, 2)
			parent.holders[position].barframe.icon.texture:SetTexture("Interface\\Addons\\SVUI\\assets\\artwork\\Icons\\PLACEHOLDER")
			parent.holders[position].barframe.bar = CreateFrame("StatusBar", nil, parent.holders[position].barframe)
			parent.holders[position].barframe.bar:FillInner(parent.holders[position].barframe, 2, 2)
			parent.holders[position].barframe.bar:SetStatusBarTexture(SV.Media.bar.default)
				
			parent.holders[position].barframe.bar.extra = CreateFrame("StatusBar", nil, parent.holders[position].barframe.bar)
			parent.holders[position].barframe.bar.extra:SetAllPoints()
			parent.holders[position].barframe.bar.extra:SetStatusBarTexture(SV.Media.bar.default)
			parent.holders[position].barframe.bar.extra:Hide()
			parent.holders[position].barframe:Hide()
			parent.holders[position].textframe = CreateFrame("Frame", nil, parent.holders[position])
			parent.holders[position].textframe:SetAllPoints(parent.holders[position])
			parent.holders[position].textframe:SetFrameStrata(strata)
			parent.holders[position].text = parent.holders[position].textframe:CreateFontString(nil, "OVERLAY", nil, 7)
			parent.holders[position].text:SetAllPoints()
			if(MOD.db.showBackground) then
				parent.holders[position].text:SetFontTemplate(LSM:Fetch("font", MOD.db.font), MOD.db.fontSize, "NONE", "CENTER", "MIDDLE")
				parent.holders[position].text:SetShadowColor(0, 0, 0, 0.5)
				parent.holders[position].text:SetShadowOffset(2, -4)
			else
				parent.holders[position].text:SetFontTemplate(LSM:Fetch("font", MOD.db.font), MOD.db.fontSize, MOD.db.fontOutline)
				parent.holders[position].text:SetJustifyH("CENTER")
				parent.holders[position].text:SetJustifyV("MIDDLE")
			end
		end 
		parent.holders[position].MenuList = {};
		parent.holders[position]:Point(GrabPlot(parent, i, maxCount))
	end 
	parent:SetScript("OnSizeChanged", UpdateAnchor)
	UpdateAnchor(parent)
end 

function MOD:Extend(newStat, eventList, onEvents, update, click, focus, blur, init)
	if not newStat then return end 
	self.Statistics[newStat] = {}
	self.StatListing[newStat] = newStat
	if type(eventList) == "table" then 
		self.Statistics[newStat]["events"] = eventList;
		self.Statistics[newStat]["event_handler"] = onEvents 
	end 
	if update and type(update) == "function" then 
		self.Statistics[newStat]["update_handler"] = update 
	end 
	if click and type(click) == "function" then 
		self.Statistics[newStat]["click_handler"] = click 
	end 
	if focus and type(focus) == "function" then 
		self.Statistics[newStat]["focus_handler"] = focus 
	end 
	if blur and type(blur) == "function" then 
		self.Statistics[newStat]["blur_handler"] = blur 
	end 
	if init and type(init) == "function" then 
		self.Statistics[newStat]["init_handler"] = init 
	end 
end

function MOD:UnSet(parent)
	parent:UnregisterAllEvents()
	parent:SetScript("OnUpdate", nil)
	parent:SetScript("OnEnter", nil)
	parent:SetScript("OnLeave", nil)
	parent:SetScript("OnClick", nil)
end

do
	local dataStrings = {
		NAME, 
		KILLING_BLOWS,
		HONORABLE_KILLS,
		DEATHS,
		HONOR,
		FACTION,
		RACE,
		CLASS,
		"None",
		DAMAGE,
		SHOW_COMBAT_HEALING,
		BATTLEGROUND_RATING,
		RATING_CHANGE,
		"None",
		"None",
		SPECIALIZATION
	};

	local Stat_OnLeave = function()
		MOD.tooltip:Hide()
	end

	local DD_OnClick = function(self)
		self.func()
		self:GetParent():Hide()
	end

	local DD_OnEnter = function(self)
		self.hoverTex:Show()
	end

	local DD_OnLeave = function(self)
		self.hoverTex:Hide()
	end

	local function _locate(parent)
		local centerX, centerY = parent:GetCenter()
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
			result = "TOP"
		elseif((centerX < widthLeft) and (centerY > heightTop)) then 
			result = "TOPLEFT"
		elseif((centerX > widthRight) and (centerY > heightTop)) then 
			result = "TOPRIGHT"
		elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then 
			result = "BOTTOM"
		elseif((centerX < widthLeft) and (centerY < heightBottom)) then 
			result = "BOTTOMLEFT"
		elseif((centerX > widthRight) and (centerY < heightBottom)) then 
			result = "BOTTOMRIGHT"
		elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then 
			result = "LEFT"
		elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then 
			result = "RIGHT"
		else 
			result = "CENTER"
		end
		return result 
	end

	function MOD:SetStatMenu(self, list)
		if not StatMenuFrame.buttons then
			StatMenuFrame.buttons = {}
			StatMenuFrame:SetFrameStrata("DIALOG")
			StatMenuFrame:SetClampedToScreen(true)
			tinsert(UISpecialFrames, StatMenuFrame:GetName())
			StatMenuFrame:Hide()
		end
		local maxPerColumn = 25
		local cols = 1
		for i=1, #StatMenuFrame.buttons do
			StatMenuFrame.buttons[i]:Hide()
		end
		for i=1, #list do 
			if not StatMenuFrame.buttons[i] then
				StatMenuFrame.buttons[i] = CreateFrame("Button", nil, StatMenuFrame)
				StatMenuFrame.buttons[i].hoverTex = StatMenuFrame.buttons[i]:CreateTexture(nil, 'OVERLAY')
				StatMenuFrame.buttons[i].hoverTex:SetAllPoints()
				StatMenuFrame.buttons[i].hoverTex:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
				StatMenuFrame.buttons[i].hoverTex:SetBlendMode("ADD")
				StatMenuFrame.buttons[i].hoverTex:Hide()
				StatMenuFrame.buttons[i].text = StatMenuFrame.buttons[i]:CreateFontString(nil, 'BORDER')
				StatMenuFrame.buttons[i].text:SetAllPoints()
				StatMenuFrame.buttons[i].text:SetFont(SV.Media.font.roboto,12,"OUTLINE")
				StatMenuFrame.buttons[i].text:SetJustifyH("LEFT")
				StatMenuFrame.buttons[i]:SetScript("OnEnter", DD_OnEnter)
				StatMenuFrame.buttons[i]:SetScript("OnLeave", DD_OnLeave)           
			end
			StatMenuFrame.buttons[i]:Show()
			StatMenuFrame.buttons[i]:SetHeight(16)
			StatMenuFrame.buttons[i]:SetWidth(135)
			StatMenuFrame.buttons[i].text:SetText(list[i].text)
			StatMenuFrame.buttons[i].func = list[i].func
			StatMenuFrame.buttons[i]:SetScript("OnClick", DD_OnClick)
			if i == 1 then
				StatMenuFrame.buttons[i]:SetPoint("TOPLEFT", StatMenuFrame, "TOPLEFT", 10, -10)
			elseif((i -1) % maxPerColumn == 0) then
				StatMenuFrame.buttons[i]:SetPoint("TOPLEFT", StatMenuFrame.buttons[i - maxPerColumn], "TOPRIGHT", 10, 0)
				cols = cols + 1
			else
				StatMenuFrame.buttons[i]:SetPoint("TOPLEFT", StatMenuFrame.buttons[i - 1], "BOTTOMLEFT")
			end
		end
		local maxHeight = (min(maxPerColumn, #list) * 16) + 20
		local maxWidth = (135 * cols) + (10 * cols)
		StatMenuFrame:SetSize(maxWidth, maxHeight)    
		StatMenuFrame:ClearAllPoints()
		local point = _locate(self:GetParent()) 
		if strfind(point, "BOTTOM") then
			StatMenuFrame:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 10, 10)
		else
			StatMenuFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 10, -10)
		end
		ToggleFrame(StatMenuFrame)
	end

	local Parent_OnClick = function(self, button)
		if IsAltKeyDown() then
			MOD:SetStatMenu(self, self.MenuList);
		elseif(self.onClick) then
			if(StatMenuFrame:IsShown()) then
				ToggleFrame(StatMenuFrame)
			else
				self.onClick(self, button);
			end
		end
	end

	local function _load(parent, config)
		if config["events"]then 
			for _, event in pairs(config["events"])do 
				parent:RegisterEvent(event)
			end 
		end 
		if config["event_handler"]then 
			parent:SetScript("OnEvent", config["event_handler"])
			config["event_handler"](parent, "SVUI_FORCE_RUN")
		end 
		if config["update_handler"]then 
			parent:SetScript("OnUpdate", config["update_handler"])
			config["update_handler"](parent, 20000)
		end 
		if config["click_handler"]then
			parent.onClick = config["click_handler"]
		end
		parent:SetScript("OnClick", Parent_OnClick)
		if config["focus_handler"]then 
			parent:SetScript("OnEnter", config["focus_handler"])
		end 
		if config["blur_handler"]then 
			parent:SetScript("OnLeave", config["blur_handler"])
		else 
			parent:SetScript("OnLeave", Stat_OnLeave)
		end
		parent:Show()
		if config["init_handler"]then 
			config["init_handler"](parent)
		end
	end

	local BG_OnUpdate = function(self)
		local scoreString;
		local parentName = self:GetParent():GetName();
		local lookup = self.pointIndex
		local pointIndex = MOD.BGPanels[parentName][lookup]
		local scoreindex = MOD.BGStats[pointIndex][1]
		local scoreType = MOD.BGStats[pointIndex][2]
		local scoreCount = GetNumBattlefieldScores()
		for i = 1, scoreCount do
			SCORE_CACHE = {GetBattlefieldScore(i)}
			if(SCORE_CACHE[1] and SCORE_CACHE[1] == myName and SCORE_CACHE[scoreindex]) then
				scoreString = TruncateString(SCORE_CACHE[scoreindex])
				self.text:SetFormattedText(BGStatString, scoreType, scoreString)
				break 
			end 
		end 
	end

	local BG_OnEnter = function(self)
		MOD:Tip(self)
		local bgName;
		local mapToken = GetCurrentMapAreaID()
		local r, g, b;
		if(classColor) then
			r, g, b = classColor.r, classColor.g, classColor.b
		else
			r, g, b = 1, 1, 1
		end

		local scoreCount = GetNumBattlefieldScores()

		for i = 1, scoreCount do 
			bgName = GetBattlefieldScore(i)
			if(bgName and bgName == myName) then 
				MOD.tooltip:AddDoubleLine(L["Stats For:"], bgName, 1, 1, 1, r, g, b)
				MOD.tooltip:AddLine(" ")
				if(mapToken == 443 or mapToken == 626) then 
					MOD.tooltip:AddDoubleLine(L["Flags Captured"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.tooltip:AddDoubleLine(L["Flags Returned"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 482) then 
					MOD.tooltip:AddDoubleLine(L["Flags Captured"], GetBattlefieldStatData(i, 1), 1, 1, 1)
				elseif(mapToken == 401) then 
					MOD.tooltip:AddDoubleLine(L["Graveyards Assaulted"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.tooltip:AddDoubleLine(L["Graveyards Defended"], GetBattlefieldStatData(i, 2), 1, 1, 1)
					MOD.tooltip:AddDoubleLine(L["Towers Assaulted"], GetBattlefieldStatData(i, 3), 1, 1, 1)
					MOD.tooltip:AddDoubleLine(L["Towers Defended"], GetBattlefieldStatData(i, 4), 1, 1, 1)
				elseif(mapToken == 512) then 
					MOD.tooltip:AddDoubleLine(L["Demolishers Destroyed"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.tooltip:AddDoubleLine(L["Gates Destroyed"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 540 or mapToken == 736 or mapToken == 461) then 
					MOD.tooltip:AddDoubleLine(L["Bases Assaulted"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.tooltip:AddDoubleLine(L["Bases Defended"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 856) then 
					MOD.tooltip:AddDoubleLine(L["Orb Possessions"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.tooltip:AddDoubleLine(L["Victory Points"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 860) then 
					MOD.tooltip:AddDoubleLine(L["Carts Controlled"], GetBattlefieldStatData(i, 1), 1, 1, 1)
				end 
				break 
			end 
		end 
		MOD:ShowTip()
	end

	local ForceHideBGStats;
	local BG_OnClick = function()
		ForceHideBGStats = true;
		MOD:Generate()
		SV:AddonMessage(L["Battleground statistics temporarily hidden, to show type \"/sv bg\" or \"/sv pvp\""])
	end

	local function SetMenuLists()
		for place,parent in pairs(MOD.Anchors)do
			for i = 1, parent.numPoints do 
				local this = positionIndex[parent.useIndex][i]
				tinsert(parent.holders[this].MenuList,{text = NONE, func = function() MOD:ChangeDBVar(NONE, this, "panels", place); MOD:Generate() end});
				for name,config in pairs(MOD.Statistics) do
					tinsert(parent.holders[this].MenuList,{text = name, func = function() MOD:ChangeDBVar(name, this, "panels", place); MOD:Generate() end});
				end 
			end
			ListNeedsUpdate = false;
		end
	end 

	function MOD:Generate()
		if(ListNeedsUpdate) then
			SetMenuLists()
		end
		local instance, groupType = IsInInstance()
		local anchorTable = self.Anchors
		local statTable = self.Statistics
		local db = self.db
		local allowPvP = (db.battleground and not ForceHideBGStats) or false
		for place, parent in pairs(anchorTable) do
			local pvpTable = allowPvP and self.BGPanels[place]
			for i = 1, parent.numPoints do 
				local position = positionIndex[parent.useIndex][i]

				parent.holders[position]:UnregisterAllEvents()
				parent.holders[position]:SetScript("OnUpdate", nil)
				parent.holders[position]:SetScript("OnEnter", nil)
				parent.holders[position]:SetScript("OnLeave", nil)
				parent.holders[position]:SetScript("OnClick", nil)

				if(db.showBackground) then
					parent.holders[position].text:SetFont(LSM:Fetch("font", db.font), db.fontSize, "NONE")
				else
					parent.holders[position].text:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
				end
				
				parent.holders[position].text:SetText(nil)

				if parent.holders[position].barframe then 
					parent.holders[position].barframe:Hide()
				end 

				parent.holders[position].pointIndex = position;
				parent.holders[position]:Hide()

				if(pvpTable and ((instance and groupType == "pvp") or parent.lockedOpen)) then 
					parent.holders[position]:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
					parent.holders[position]:SetScript("OnEvent", BG_OnUpdate)
					parent.holders[position]:SetScript("OnEnter", BG_OnEnter)
					parent.holders[position]:SetScript("OnLeave", Stat_OnLeave)
					parent.holders[position]:SetScript("OnClick", BG_OnClick)

					BG_OnUpdate(parent.holders[position])

					parent.holders[position]:Show()
				else 
					for name, config in pairs(statTable)do
						for panelName, panelData in pairs(db.panels) do 
							if(panelData and type(panelData) == "table") then 
								if(panelName == place and panelData[position] and panelData[position] == name) then 
									_load(parent.holders[position], config)
								end 
							elseif(panelData and type(panelData) == "string" and panelData == name) then 
								if(name == place) then 
									_load(parent.holders[position], config)
								end 
							end 
						end
					end 
				end 
			end
		end 
		if ForceHideBGStats then ForceHideBGStats = nil end
	end
end

local function LoadStatBroker()
	local OnEnter, OnLeave, lastObj;
  	for dataName, dataObj in LDB:DataObjectIterator()do 
	    OnEnter = nil;
	    OnLeave = nil;
	    lastObj = nil;
	    if dataObj.OnEnter then 
	      	OnEnter = function(self)
				MOD:Tip(self)
				dataObj.OnTooltipShow(MOD.tooltip)
				MOD:ShowTip()
			end
	    elseif dataObj.OnTooltipShow then 
	      	OnEnter = function(self)
				MOD:Tip(self)
				dataObj.OnTooltipShow(MOD.tooltip)
				MOD:ShowTip()
			end
	    end;
	    if dataObj.OnLeave then 
			OnLeave = function(self)
				dataObj.OnLeave(self)
				MOD.tooltip:Hide()
			end 
	    end;
	    local OnClick = function(self, e)
	      	dataObj.OnClick(self, e)
	    end;
	    local CallBack = function(_, name, _, value, _)
			if(value == nil or len(value) > 5 or value == "n / a" or name == value) then 
				lastObj.text:SetText(value ~= "n / a" and value or name)
			else 
				lastObj.text:SetText(name..": "..hexString..value.."|r")
			end 
	    end;
	    local OnEvent = function(self)
			lastObj = self;
			LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..dataName.."_text", CallBack)
			LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..dataName.."_value", CallBack)
			LDB.callbacks:Fire("LibDataBroker_AttributeChanged_"..dataName.."_text", dataName, nil, dataObj.text, dataObj)
	    end;
	    MOD:Extend(dataName, {"PLAYER_ENTER_WORLD"}, OnEvent, nil, OnClick, OnEnter, OnLeave)
  	end
end
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:ReLoad()
	self:Generate()
end 

function MOD:Load()
	local SVUI_Global = _G.SVUI_Global
	local hexHighlight = SV:HexColor("highlight") or "FFFFFF"
	local hexClass = classColor.colorStr
	BGStatString = "|cff" .. hexHighlight .. "%s: |c" .. hexClass .. "%s|r";
	SVUI_Global.Accountant = SVUI_Global.Accountant or {};
	SVUI_Global.Accountant[playerRealm] = SVUI_Global.Accountant[playerRealm] or {};
	SVUI_Global.Accountant[playerRealm]["gold"] = SVUI_Global.Accountant[playerRealm]["gold"] or {};
	SVUI_Global.Accountant[playerRealm]["gold"][playerName] = SVUI_Global.Accountant[playerRealm]["gold"][playerName] or 0;
	SVUI_Global.Accountant[playerRealm]["tokens"] = SVUI_Global.Accountant[playerRealm]["tokens"] or {};
	SVUI_Global.Accountant[playerRealm]["tokens"][playerName] = SVUI_Global.Accountant[playerRealm]["tokens"][playerName] or 738;

	LoadStatBroker()

	self:LoadServerGold()
	self:CacheRepData()
	self:CacheTokenData()

	StatMenuFrame:SetParent(SV.UIParent);
	StatMenuFrame:SetPanelTemplate("Transparent");
	StatMenuFrame:Hide()
	
	self.tooltip:SetParent(SV.UIParent)
	self.tooltip:SetFrameStrata("DIALOG")
	self.tooltip:HookScript("OnShow", _hook_TooltipOnShow)

	self:Generate()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Generate")

	myName = UnitName("player");
end
--[[ 
########################################################## 
DEFINE CONFIG AND REGISTER
##########################################################
]]--
SVLib:NewPackage(MOD, "SVStats")