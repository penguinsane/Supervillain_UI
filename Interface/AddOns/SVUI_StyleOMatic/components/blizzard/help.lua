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
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local tinsert = _G.tinsert;
--[[ ADDON ]]--
local SV = _G.SVUI;
local L = SV.L;
local PLUGIN = select(2, ...);
local Schema = PLUGIN.Schema;
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local HelpFrameList = {
	"HelpFrameLeftInset",
	"HelpFrameMainInset",
	"HelpFrameKnowledgebase",
	"HelpFrameHeader",
	"HelpFrameKnowledgebaseErrorFrame"
}

local HelpFrameButtonList = {
	"HelpFrameOpenTicketHelpItemRestoration",
	"HelpFrameAccountSecurityOpenTicket",
	"HelpFrameOpenTicketHelpTopIssues",
	"HelpFrameOpenTicketHelpOpenTicket",
	"HelpFrameKnowledgebaseSearchButton",
	"HelpFrameKnowledgebaseNavBarHomeButton",
	"HelpFrameCharacterStuckStuck",
	"GMChatOpenLog",
	"HelpFrameTicketSubmit",
	"HelpFrameTicketCancel"
}

local function NavBarHelper(button)
	for i = 1, #button.navList do 
		local this = button.navList[i]
		local last = button.navList[i - 1]
		if this and last then
			local level = last:GetFrameLevel()
			if(level >= 2) then
				level = level - 2
			else
				level = 0
			end
			this:SetFrameLevel(level)
		end 
	end 
end 
--[[ 
########################################################## 
HELPFRAME PLUGINR
##########################################################
]]--
local function HelpFrameStyle()
	if PLUGIN.db.blizzard.enable ~= true or PLUGIN.db.blizzard.help ~= true then
		return 
	end 
	tinsert(HelpFrameButtonList, "HelpFrameButton16")
	tinsert(HelpFrameButtonList, "HelpFrameSubmitSuggestionSubmit")
	tinsert(HelpFrameButtonList, "HelpFrameReportBugSubmit")
	for d = 1, #HelpFrameList do
		_G[HelpFrameList[d]]:RemoveTextures(true)
		_G[HelpFrameList[d]]:SetPanelTemplate("Default")
	end 
	HelpFrameHeader:SetFrameLevel(HelpFrameHeader:GetFrameLevel()+2)
	HelpFrameKnowledgebaseErrorFrame:SetFrameLevel(HelpFrameKnowledgebaseErrorFrame:GetFrameLevel()+2)
	HelpFrameReportBugScrollFrame:RemoveTextures()
	HelpFrameReportBugScrollFrame:SetPanelTemplate("Default")
	HelpFrameReportBugScrollFrame.Panel:Point("TOPLEFT", -4, 4)
	HelpFrameReportBugScrollFrame.Panel:Point("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameReportBug:GetNumChildren()do 
		local e = select(d, HelpFrameReportBug:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	PLUGIN:ApplyScrollFrameStyle(HelpFrameReportBugScrollFrameScrollBar)
	HelpFrameSubmitSuggestionScrollFrame:RemoveTextures()
	HelpFrameSubmitSuggestionScrollFrame:SetPanelTemplate("Default")
	HelpFrameSubmitSuggestionScrollFrame.Panel:Point("TOPLEFT", -4, 4)
	HelpFrameSubmitSuggestionScrollFrame.Panel:Point("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameSubmitSuggestion:GetNumChildren()do 
		local e = select(d, HelpFrameSubmitSuggestion:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	PLUGIN:ApplyScrollFrameStyle(HelpFrameSubmitSuggestionScrollFrameScrollBar)
	HelpFrameTicketScrollFrame:RemoveTextures()
	HelpFrameTicketScrollFrame:SetPanelTemplate("Default")
	HelpFrameTicketScrollFrame.Panel:Point("TOPLEFT", -4, 4)
	HelpFrameTicketScrollFrame.Panel:Point("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameTicket:GetNumChildren()do 
		local e = select(d, HelpFrameTicket:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	PLUGIN:ApplyScrollFrameStyle(HelpFrameKnowledgebaseScrollFrame2ScrollBar)
	for d = 1, #HelpFrameButtonList do
		_G[HelpFrameButtonList[d]]:RemoveTextures(true)
		_G[HelpFrameButtonList[d]]:SetButtonTemplate()
		if _G[HelpFrameButtonList[d]].text then
			_G[HelpFrameButtonList[d]].text:ClearAllPoints()
			_G[HelpFrameButtonList[d]].text:SetPoint("CENTER")
			_G[HelpFrameButtonList[d]].text:SetJustifyH("CENTER")
		end 
	end 
	for d = 1, 6 do 
		local f = _G["HelpFrameButton"..d]
		f:SetButtonTemplate()
		f.text:ClearAllPoints()
		f.text:SetPoint("CENTER")
		f.text:SetJustifyH("CENTER")
	end 
	for d = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren()do 
		local f = _G["HelpFrameKnowledgebaseScrollFrameButton"..d]
		f:RemoveTextures(true)
		f:SetButtonTemplate()
	end 
	HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
	HelpFrameKnowledgebaseSearchBox:Point("TOPLEFT", HelpFrameMainInset, "TOPLEFT", 13, -10)
	HelpFrameKnowledgebaseNavBarOverlay:Die()
	HelpFrameKnowledgebaseNavBar:RemoveTextures()
	HelpFrame:RemoveTextures(true)
	HelpFrame:SetPanelTemplate("Halftone")
	HelpFrameKnowledgebaseSearchBox:SetEditboxTemplate()
	PLUGIN:ApplyScrollFrameStyle(HelpFrameKnowledgebaseScrollFrameScrollBar, 5)
	PLUGIN:ApplyScrollFrameStyle(HelpFrameTicketScrollFrameScrollBar, 4)
	PLUGIN:ApplyCloseButtonStyle(HelpFrameCloseButton, HelpFrame.Panel)
	PLUGIN:ApplyCloseButtonStyle(HelpFrameKnowledgebaseErrorFrameCloseButton, HelpFrameKnowledgebaseErrorFrame.Panel)
	HelpFrameCharacterStuckHearthstone:SetButtonTemplate()
	HelpFrameCharacterStuckHearthstone:SetFixedPanelTemplate("Default")
	HelpFrameCharacterStuckHearthstone.IconTexture:FillInner()
	HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	hooksecurefunc("NavBar_AddButton", function(h, k)
		local i = h.navList[#h.navList]
		if not i.styled then
			i:SetButtonTemplate()
			i.styled = true;
			i:HookScript("OnClick", function()
				NavBarHelper(h)
			end)
		end 
		NavBarHelper(h)
	end)
	HelpFrameGM_ResponseNeedMoreHelp:SetButtonTemplate()
	HelpFrameGM_ResponseCancel:SetButtonTemplate()
	for d = 1, HelpFrameGM_Response:GetNumChildren()do 
		local e = select(d, HelpFrameGM_Response:GetChildren())
		if e and e:GetObjectType()
		 == "Frame"and not e:GetName()
		then
			e:SetFixedPanelTemplate("Default")
		end 
	end 
end 
--[[ 
########################################################## 
PLUGIN LOADING
##########################################################
]]--
PLUGIN:SaveCustomStyle(HelpFrameStyle)