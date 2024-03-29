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
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L

local MOD = SV.SVTools;
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local ICON_FILE = [[Interface\AddOns\SVUI\assets\artwork\Icons\DOCK-RAIDTOOL]];

local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if ((IsInGroup() and not IsInRaid()) or UnitIsGroupLeader('player') or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

local Button_OnEnter = function(self)
	self:SetPanelColor("highlight")
end

local Button_OnLeave = function(self)
	self:SetPanelColor("inverse")
	GameTooltip:Hide()
end

local function NewToolButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, textDisplay)
	local button = CreateFrame("Button", name, parent, template)
	button:RemoveTextures()
	button:Width(width)
	button:Height(height)
	button:Point(point, relativeto, point2, xOfs, yOfs)
	button:SetFramedButtonTemplate()

	if(textDisplay) then
		local text = button:CreateFontString(nil,"OVERLAY")
		text:SetFont(SV.Media.font.roboto, 14, "NONE")
		text:SetAllPoints(button)
		text:SetJustifyH("CENTER")
		text:SetText(textDisplay)

		button:SetFontString(text)	
	end

	button:HookScript("OnEnter", Button_OnEnter)
	button:HookScript("OnLeave", Button_OnLeave)

	return button;
end

function MOD:UpdateRaidLeader(event) 
	if InCombatLockdown() then
		self.RaidLeaderNeedsUpdate = true;
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		return
	end
	if CheckRaidStatus() then
		SV.Dock.TopLeft.Bar:Add(self.RaidTool)
		if self.RaidTool.Menu.toggled == true then
			self.RaidTool.Menu:Show()		
		else
			self.RaidTool.Menu:Hide()
		end
	else
		SV.Dock.TopLeft.Bar:Remove(self.RaidTool)
		self.RaidTool.Menu:Hide()
	end
end 

function MOD:LoadRaidLeaderTools()
	local dock = SV.Dock.TopLeft.Bar
	
	self.RaidTool = SV.Dock:SetDockButton("TopLeft", RAID_CONTROL, ICON_FILE, nil, "SVUI_RaidToolDockButton");
	self.RaidTool:SetAttribute("hasDropDown", false);

	self.RaidTool.Menu = CreateFrame("Frame", "SVUI_RaidToolMenu", self.RaidTool, "SecureHandlerClickTemplate");
	self.RaidTool.Menu:SetPanelTemplate('Transparent');
	self.RaidTool.Menu:Width(120);
	self.RaidTool.Menu:Height(140);
	self.RaidTool.Menu:SetPoint("TOPLEFT", dock.ToolBar, "BOTTOMLEFT", 0, -2);
	self.RaidTool.Menu:SetFrameLevel(3);
	self.RaidTool.Menu.toggled = false;
	self.RaidTool.Menu:SetFrameStrata("HIGH");

	local SVUI_RaidToolToggle = CreateFrame("Button", "SVUI_RaidToolToggle", self.RaidTool, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate")
	SVUI_RaidToolToggle:SetAllPoints(self.RaidTool)
	SVUI_RaidToolToggle:RemoveTextures()
	SVUI_RaidToolToggle:SetFrameRef("SVUI_RaidToolMenu", SVUI_RaidToolMenu)
	SVUI_RaidToolToggle:SetAttribute("_onclick", [=[
		local raidUtil = self:GetFrameRef("SVUI_RaidToolMenu");
		local closeButton = self:GetFrameRef("SVUI_RaidToolCloseButton");
		raidUtil:Show(); 
		local point = self:GetPoint();		
		local raidUtilPoint, raidUtilRelative, closeButtonPoint, closeButtonRelative
		if point:find("BOTTOM") then
			raidUtilPoint = "BOTTOMLEFT"
			raidUtilRelative = "TOPLEFT"				
		else
			raidUtilPoint = "TOPLEFT"
			raidUtilRelative = "BOTTOMLEFT"			
		end
		
		raidUtil:ClearAllPoints()
		closeButton:ClearAllPoints()
		raidUtil:SetPoint(raidUtilPoint, self, raidUtilRelative, 2, -2)
		closeButton:SetPoint("BOTTOM", raidUtil, "BOTTOM", 0, 2)
	]=]);
	SVUI_RaidToolToggle:SetScript("PostClick", function(self) self:RemoveTextures(); SVUI_RaidToolMenu.toggled = true end);

	SV:AddToDisplayAudit(self.RaidTool);

	--Close Button
	local close = NewToolButton("SVUI_RaidToolCloseButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 30, 18, "BOTTOM", self.RaidTool.Menu, "BOTTOM", 0, 2, "X");
	close:SetAttribute("_onclick", [=[ self:GetParent():Hide(); ]=]);
	SVUI_RaidToolToggle:SetFrameRef("SVUI_RaidToolCloseButton", close)
	close:SetScript("PostClick", function() SVUI_RaidToolMenu.toggled = false end);

	local disband = NewToolButton("SVUI_RaidToolDisbandButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", self.RaidTool.Menu, "TOP", 0, -5, L['Disband Group'])
	disband:SetScript("OnMouseUp", function(self)
		if CheckRaidStatus() then
			SV:StaticPopup_Show("DISBAND_RAID")
		end
	end)

	local rolecheck = NewToolButton("SVUI_RaidToolRoleButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", disband, "BOTTOM", 0, -5, ROLE_POLL)
	rolecheck:SetScript("OnMouseUp", function(self)
		if CheckRaidStatus() then
			InitiateRolePoll()
		end
	end)

	local ready = NewToolButton("SVUI_RaidToolReadyButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", rolecheck, "BOTTOM", 0, -5, READY_CHECK)
	ready:SetScript("OnMouseUp", function(self)
		if CheckRaidStatus() then
			DoReadyCheck()
		end
	end)

	local control = NewToolButton("SVUI_RaidToolControlButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", ready, "BOTTOM", 0, -5, L['Raid Menu'])
	control:SetScript("OnMouseUp", function(self)
		ToggleFriendsFrame(4)
	end)

	local markerButton = _G["CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton"];
	local oldReadyCheck = _G["CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck"];
	local oldRollCheck = _G["CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll"];

	if(markerButton) then
		markerButton:ClearAllPoints()
		markerButton:SetPoint("TOP", control, "BOTTOM", 0, -5)
		markerButton:SetParent(self.RaidTool.Menu)
		markerButton:Height(18)
		markerButton:SetWidth(109)
		markerButton:RemoveTextures()
		markerButton:SetFramedButtonTemplate()

		local markersText = markerButton:CreateFontString(nil,"OVERLAY")
		markersText:SetFont(SV.Media.font.roboto, 14, "NONE")
		markersText:SetAllPoints(markerButton)
		markersText:SetJustifyH("CENTER")
		markersText:SetText("World Markers")

		markerButton:SetFontString(markersText)

		markerButton:HookScript("OnEnter", Button_OnEnter)
		markerButton:HookScript("OnLeave", Button_OnLeave)
	end

	if(oldReadyCheck) then
		oldReadyCheck:ClearAllPoints()
		oldReadyCheck:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLockedModeToggle, "TOPLEFT", 0, 1)
		oldReadyCheck:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 1)
		if(oldRollCheck) then
			oldRollCheck:ClearAllPoints()
			oldRollCheck:SetPoint("BOTTOMLEFT", oldReadyCheck, "TOPLEFT", 0, 1)
			oldRollCheck:SetPoint("BOTTOMRIGHT", oldReadyCheck, "TOPRIGHT", 0, 1)
		end
	end

	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateRaidLeader")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateRaidLeader")
	self:UpdateRaidLeader() 
end