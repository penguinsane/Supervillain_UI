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
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
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
OUTFITTER
##########################################################
]]--
local function StyleOutfitter()
	assert(OutfitterFrame, "AddOn Not Loaded")
	
	CharacterFrame:HookScript("OnShow", function(self) PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "TOPRIGHT", -14, 0) end)
	OutfitterFrame:HookScript("OnShow", function(self) 
		PLUGIN:ApplyFrameStyle(OutfitterFrame)
		OutfitterFrameTab1:Size(60, 25)
		OutfitterFrameTab2:Size(60, 25)
		OutfitterFrameTab3:Size(60, 25)
		OutfitterMainFrame:RemoveTextures(true)
		for i = 0, 13 do
			if _G["OutfitterItem"..i.."OutfitSelected"] then 
				_G["OutfitterItem"..i.."OutfitSelected"]:SetButtonTemplate()
				_G["OutfitterItem"..i.."OutfitSelected"]:ClearAllPoints()
				_G["OutfitterItem"..i.."OutfitSelected"]:Size(16)
				_G["OutfitterItem"..i.."OutfitSelected"]:Point("LEFT", _G["OutfitterItem"..i.."Outfit"], "LEFT", 8, 0)
			end
		end
	end)
	OutfitterMainFrameScrollbarTrench:RemoveTextures(true)
	OutfitterFrameTab1:ClearAllPoints()
	OutfitterFrameTab2:ClearAllPoints()
	OutfitterFrameTab3:ClearAllPoints()
	OutfitterFrameTab1:Point("TOPLEFT", OutfitterFrame, "BOTTOMRIGHT", -65, -2)
	OutfitterFrameTab2:Point("LEFT", OutfitterFrameTab1, "LEFT", -65, 0)
	OutfitterFrameTab3:Point("LEFT", OutfitterFrameTab2, "LEFT", -65, 0)
	OutfitterFrameTab1:SetButtonTemplate()
	OutfitterFrameTab2:SetButtonTemplate()
	OutfitterFrameTab3:SetButtonTemplate()
	PLUGIN:ApplyScrollFrameStyle(OutfitterMainFrameScrollFrameScrollBar)
	PLUGIN:ApplyCloseButtonStyle(OutfitterCloseButton)
	OutfitterNewButton:SetButtonTemplate()
	OutfitterEnableNone:SetButtonTemplate()
	OutfitterEnableAll:SetButtonTemplate()
	OutfitterButton:ClearAllPoints()
	OutfitterButton:SetPoint("RIGHT", PaperDollSidebarTabs, "RIGHT", 26, -2)
	OutfitterButton:SetHighlightTexture(nil)
	OutfitterSlotEnables:SetFrameStrata("HIGH")
	OutfitterEnableHeadSlot:SetCheckboxTemplate(true)
	OutfitterEnableNeckSlot:SetCheckboxTemplate(true)
	OutfitterEnableShoulderSlot:SetCheckboxTemplate(true)
	OutfitterEnableBackSlot:SetCheckboxTemplate(true)
	OutfitterEnableChestSlot:SetCheckboxTemplate(true)
	OutfitterEnableShirtSlot:SetCheckboxTemplate(true)
	OutfitterEnableTabardSlot:SetCheckboxTemplate(true)
	OutfitterEnableWristSlot:SetCheckboxTemplate(true)
	OutfitterEnableMainHandSlot:SetCheckboxTemplate(true)
	OutfitterEnableSecondaryHandSlot:SetCheckboxTemplate(true)
	OutfitterEnableHandsSlot:SetCheckboxTemplate(true)
	OutfitterEnableWaistSlot:SetCheckboxTemplate(true)
	OutfitterEnableLegsSlot:SetCheckboxTemplate(true)
	OutfitterEnableFeetSlot:SetCheckboxTemplate(true)
	OutfitterEnableFinger0Slot:SetCheckboxTemplate(true)
	OutfitterEnableFinger1Slot:SetCheckboxTemplate(true)
	OutfitterEnableTrinket0Slot:SetCheckboxTemplate(true)
	OutfitterEnableTrinket1Slot:SetCheckboxTemplate(true)
	OutfitterItemComparisons:SetButtonTemplate()
	OutfitterTooltipInfo:SetButtonTemplate()
	OutfitterShowHotkeyMessages:SetButtonTemplate()
	OutfitterShowMinimapButton:SetButtonTemplate()
	OutfitterShowOutfitBar:SetButtonTemplate()
	OutfitterAutoSwitch:SetButtonTemplate()
	OutfitterItemComparisons:Size(20)
	OutfitterTooltipInfo:Size(20)
	OutfitterShowHotkeyMessages:Size(20)
	OutfitterShowMinimapButton:Size(20)
	OutfitterShowOutfitBar:Size(20)
	OutfitterAutoSwitch:Size(20)
	OutfitterShowOutfitBar:Point("TOPLEFT", OutfitterAutoSwitch, "BOTTOMLEFT", 0, -5)
	OutfitterEditScriptDialogDoneButton:SetButtonTemplate()
	OutfitterEditScriptDialogCancelButton:SetButtonTemplate()
	PLUGIN:ApplyScrollFrameStyle(OutfitterEditScriptDialogSourceScriptScrollBar)
	PLUGIN:ApplyFrameStyle(OutfitterEditScriptDialogSourceScript,"Transparent")
	PLUGIN:ApplyFrameStyle(OutfitterEditScriptDialog)
	PLUGIN:ApplyCloseButtonStyle(OutfitterEditScriptDialog.CloseButton)
	PLUGIN:ApplyTabStyle(OutfitterEditScriptDialogTab1)
	PLUGIN:ApplyTabStyle(OutfitterEditScriptDialogTab2)
end
PLUGIN:SaveAddonStyle("Outfitter", StyleOutfitter)