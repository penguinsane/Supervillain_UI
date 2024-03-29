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

--[[  CONSTANTS ]]--

_G.BINDING_HEADER_SVUICRAFT = "Supervillain UI: Craft-O-Matic";
_G.BINDING_NAME_SVUICRAFT_FISH = "Toggle Fishing Mode";
_G.BINDING_NAME_SVUICRAFT_FARM = "Toggle Farming Mode";
_G.BINDING_NAME_SVUICRAFT_COOK = "Toggle Cooking Mode";
_G.BINDING_NAME_SVUICRAFT_ARCH = "Toggle Archaeology Mode";

--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local PLUGIN = select(2, ...)
local Schema = PLUGIN.Schema;

local SV = _G["SVUI"];
local L = SV.L
local NewHook = hooksecurefunc;

local playerGUID = UnitGUID('player')
local classColor = RAID_CLASS_COLORS
--[[ 
########################################################## 
GLOBAL BINDINGS
##########################################################
]]--
function SVUIFishingMode()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and PLUGIN.CurrentMode == "Fishing" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Fishing") end
end

function SVUIFarmingMode()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and SV.CurrentMode == "Farming" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Farming") end
end

function SVUIArchaeologyMode()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and PLUGIN.CurrentMode == "Archaeology" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Archaeology") end
end

function SVUICookingMode()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and PLUGIN.CurrentMode == "Cooking" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Cooking") end
end
--[[ 
########################################################## 
LOCALIZED GLOBALS
##########################################################
]]--
local LOOT_ITEM_SELF = _G.LOOT_ITEM_SELF;
local LOOT_ITEM_CREATED_SELF = _G.LOOT_ITEM_CREATED_SELF;
local LOOT_ITEM_SELF_MULTIPLE = _G.LOOT_ITEM_SELF_MULTIPLE
local LOOT_ITEM_PUSHED_SELF_MULTIPLE = _G.LOOT_ITEM_PUSHED_SELF_MULTIPLE
local LOOT_ITEM_PUSHED_SELF = _G.LOOT_ITEM_PUSHED_SELF
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local currentModeKey = false;
local ModeLogsFrame = CreateFrame("Frame", "SVUI_ModeLogsFrame", UIParent)
local classColors = SVUI_CLASS_COLORS[SV.class]
local classR, classG, classB = classColors.r, classColors.g, classColors.b
local classA = 0.35
local lastClickTime;
local ICON_FILE = [[Interface\AddOns\SVUI_CraftOMatic\artwork\DOCK-LABORER]]
local COOK_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-COOKING]]
local FISH_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-FISHING]]
local ARCH_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-SURVEY]]
local FARM_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-FARMING]]
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function SendModeMessage(...)
	if not CombatText_AddMessage then return end 
	CombatText_AddMessage(...)
end 

local function onMouseWheel(self, delta)
	if (delta > 0) then
		self:ScrollUp()
	elseif (delta < 0) then
		self:ScrollDown()
	end
end 

local function CheckForDoubleClick()
	if lastClickTime then
		local pressTime = GetTime()
		local doubleTime = pressTime - lastClickTime
		if ( (doubleTime < 0.4) and (doubleTime > 0.05) ) then
			lastClickTime = nil
			return true
		end
	end
	lastClickTime = GetTime()
	return false
end
--[[ 
########################################################## 
WORLDFRAME HANDLER
##########################################################
]]--
local _hook_WorldFrame_OnMouseDown = function(self, button)
	if InCombatLockdown() then return end
	if(currentModeKey and button == "RightButton" and CheckForDoubleClick()) then
		local handle = PLUGIN[currentModeKey];
		if(handle and handle.Bind) then
			handle.Bind()
		end
	end
end

local ModeCapture_PostClickHandler = function(self, button)
	if InCombatLockdown() then 
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return 
	end
	ClearOverrideBindings(self)
	self.Grip:Hide()
end

local ModeCapture_EventHandler = function(self, event, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		PLUGIN:ChangeModeGear()
		ModeCapture_PostClickHandler(self)
	end
	if event == "PLAYER_ENTERING_WORLD" then
		if (IsSpellKnown(131474) or IsSpellKnown(80451) or IsSpellKnown(818)) then
			WorldFrame:HookScript("OnMouseDown", _hook_WorldFrame_OnMouseDown)
		end
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

local ModeHandler = CreateFrame("Frame")
ModeHandler:SetPoint("LEFT", UIParent, "RIGHT", 10000, 0)
local ModeCapture = CreateFrame("Button", "SVUI_ModeCaptureWindow", ModeHandler, "SecureActionButtonTemplate")
ModeCapture.Grip = ModeHandler
ModeCapture:EnableMouse(true)
ModeCapture:RegisterForClicks("RightButtonUp")
ModeCapture:RegisterEvent("PLAYER_ENTERING_WORLD")
ModeCapture:SetScript("PostClick", ModeCapture_PostClickHandler)
ModeCapture:SetScript("OnEvent", ModeCapture_EventHandler)

ModeCapture:Hide()
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function PLUGIN:CraftingReset()
	self.TitleWindow:Clear();
	self.LogWindow:Clear();
	self.TitleWindow:AddMessage("Crafting Modes", 1, 1, 0);
	self.LogWindow:AddMessage("Select a Tool to Begin", 1, 1, 1);
	self.LogWindow:AddMessage(" ", 0, 1, 1);
	collectgarbage("collect") 
end

function PLUGIN:ModeLootLoader(mode, msg, info)
	self.TitleWindow:Clear();
	self.LogWindow:Clear();
	self.ModeAlert.HelpText = info
	if(mode and self[mode]) then
		if(self[mode].Log) then
			local stored = self[mode].Log;
			self.TitleWindow:AddMessage(msg, 1, 1, 1);
			local previous = false
			for name,data in pairs(stored) do
				if type(data) == "table" and data.amount and data.texture then
					self.LogWindow:AddMessage("|cff55FF55"..data.amount.." x|r |T".. data.texture ..":16:16:0:0:64:64:4:60:4:60|t".." "..name, 0.8, 0.8, 0.8);
					previous = true
				end
			end 
			if(previous) then
				self.LogWindow:AddMessage("----------------", 0, 0, 0);
				self.LogWindow:AddMessage(" ", 0, 0, 0);
			end
			self.LogWindow:AddMessage(info, 1, 1, 1);
			self.LogWindow:AddMessage(" ", 1, 1, 1);
		end
	else
		self:CraftingReset()
	end 
end

function PLUGIN:CheckForModeLoot(msg)
  	local item, amt = SV:DeFormat(msg, LOOT_ITEM_CREATED_SELF)
	if not item then
	  item = SV:DeFormat(msg, LOOT_ITEM_SELF_MULTIPLE)
	  	if not item then
		  item = SV:DeFormat(msg, LOOT_ITEM_SELF)
		  	if not item then
		      	item = SV:DeFormat(msg, LOOT_ITEM_PUSHED_SELF_MULTIPLE)
		      	if not item then
		        	item, amt = SV:DeFormat(msg, LOOT_ITEM_PUSHED_SELF)
		        	--print(item)
		      	end
		    end
		end
	end
	--print(msg)
	if item then
		if not amt then
		  	amt = 1
		end
		return item, amt
	end
end 

function PLUGIN:SetJobMode(category)
	if InCombatLockdown() then return end
	if(not category) then 
		self:EndJobModes()
		return;
	end 
	self:ChangeModeGear()
	if(currentModeKey and self[currentModeKey] and self[currentModeKey].Disable) then
		self[currentModeKey].Disable()
	end
	currentModeKey = category;
	if(self[category] and self[category].Enable) then
		self[category].Enable()
	else
		self:EndJobModes()
		return;
	end
end

function PLUGIN:EndJobModes()
	if(currentModeKey and self[currentModeKey] and self[currentModeKey].Disable) then
		self[currentModeKey].Disable()
	end
	currentModeKey = false;
	if self.Docklet:IsShown() then self.Docklet.DockButton:Click() end
	self:ChangeModeGear()
	self.ModeAlert:Hide();
	SendModeMessage("Mode Disabled", CombatText_StandardScroll, 1, 0.35, 0);
	PlaySound("UndeadExploration");
	self:CraftingReset()
end

function PLUGIN:ChangeModeGear()
	if(not self.InModeGear) then return end
	if InCombatLockdown() then
		_G["SVUI_ModeCaptureWindow"]:RegisterEvent("PLAYER_REGEN_ENABLED");
		return
	else
		if(self.WornItems["HEAD"]) then
			EquipItemByName(self.WornItems["HEAD"])
			self.WornItems["HEAD"] = false
		end
		if(self.WornItems["TAB"]) then
			EquipItemByName(self.WornItems["TAB"])
			self.WornItems["TAB"] = false
		end
		if(self.WornItems["MAIN"]) then
			EquipItemByName(self.WornItems["MAIN"])
			self.WornItems["MAIN"] = false
		end
		if(self.WornItems["OFF"]) then
			EquipItemByName(self.WornItems["OFF"])
			self.WornItems["OFF"] = false
		end

		self.InModeGear = false
	end
end

function PLUGIN:UpdateLogWindow()
 	self.LogWindow:SetFont(SV.Media.font.system, self.db.fontSize, "OUTLINE")
end

function PLUGIN:SKILL_LINES_CHANGED()
	if(currentModeKey and self[currentModeKey] and self[currentModeKey].Update) then
		self[currentModeKey].Update()
	end
end
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
local ModeAlert_OnEnter = function(self)
	if InCombatLockdown() then return; end
	self:SetBackdropColor(0.9, 0.15, 0.1)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ModeText, 1, 1, 0)
	GameTooltip:AddLine("")
	GameTooltip:AddLine("Click here end this mode.", 0.79, 0.23, 0.23)
	GameTooltip:AddLine("")
	GameTooltip:AddLine(self.HelpText, 0.74, 1, 0.57)
	GameTooltip:Show()
end

local ModeAlert_OnLeave = function(self)
	GameTooltip:Hide()
	if InCombatLockdown() then return end 
	self:SetBackdropColor(0.25, 0.52, 0.1)
end

local ModeAlert_OnHide = function()
	if InCombatLockdown() then 
		SV:AddonMessage(ERR_NOT_IN_COMBAT);  
		return; 
	end
	PLUGIN.Docklet.Parent.Alert:Deactivate()
end

local ModeAlert_OnShow = function(self)
	if InCombatLockdown() then 
		SV:AddonMessage(ERR_NOT_IN_COMBAT); 
		self:Hide() 
		return; 
	end
	SV:SecureFadeIn(self, 0.3, 0, 1)
	PLUGIN.Docklet.Parent.Alert:Activate(self)
end

local ModeAlert_OnMouseDown = function(self)
	PLUGIN:EndJobModes()
	SV:SecureFadeOut(self, 0.5, 1, 0, true)
end

local ModeButton_OnEnter = function(self)
	if InCombatLockdown() then return; end
	local name = self.modeName
	self.icon:SetGradient(unpack(SV.Media.gradient.yellow))
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L[name .. " Mode"], 1, 1, 1)
	GameTooltip:Show()
end

local ModeButton_OnLeave = function(self)
	if InCombatLockdown() then return; end
	self.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	GameTooltip:Hide()
end

local ModeButton_OnMouseDown = function(self)
	local name = self.modeName
	PLUGIN:SetJobMode(name)
end
--[[ 
########################################################## 
SIZING CALLBACK
##########################################################
]]--
local function ResizeCraftingDock()
	local DOCK_HEIGHT = PLUGIN.Docklet.Window:GetHeight();
	local BUTTON_SIZE = (DOCK_HEIGHT * 0.25) - 4;
	SVUI_ModesDockToolBar:SetWidth(BUTTON_SIZE + 4);
	SVUI_ModesDockToolBar:SetHeight((BUTTON_SIZE + 4) * 4);
	SVUI_ModeButton4:SetSize(BUTTON_SIZE,BUTTON_SIZE);
	SVUI_ModeButton3:SetSize(BUTTON_SIZE,BUTTON_SIZE);
	SVUI_ModeButton2:SetSize(BUTTON_SIZE,BUTTON_SIZE);
	SVUI_ModeButton1:SetSize(BUTTON_SIZE,BUTTON_SIZE);
end

LibSuperVillain("Registry"):NewCallback("DOCKS_UPDATED", "ResizeCraftingDock", ResizeCraftingDock);
--[[ 
########################################################## 
BUILD FUNCTION
##########################################################
]]--
function PLUGIN:Load()
	lastClickTime = nil;
	self.WornItems = {};
	self.InModeGear = false;

	self.Docklet = SV.Dock:NewDocklet("BottomRight", "SVUI_ModesDockFrame", self.TitleID, ICON_FILE);

	local DOCK_HEIGHT = self.Docklet.Window:GetHeight();
	local DOCKLET_HEIGHT = DOCK_HEIGHT - 4;
	local BUTTON_SIZE = (DOCK_HEIGHT * 0.25) - 4;

	local modesToolBar = CreateFrame("Frame", "SVUI_ModesDockToolBar", self.Docklet)
	modesToolBar:SetWidth(BUTTON_SIZE + 4);
	modesToolBar:SetHeight((BUTTON_SIZE + 4) * 4);
	modesToolBar:SetPoint("BOTTOMLEFT", self.Docklet, "BOTTOMLEFT", 0, 0);

	local mode4Button = CreateFrame("Frame", "SVUI_ModeButton4", modesToolBar)
	mode4Button:SetPoint("BOTTOM",modesToolBar,"BOTTOM",0,0)
	mode4Button:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	mode4Button.icon = mode4Button:CreateTexture(nil, 'OVERLAY')
	mode4Button.icon:SetTexture(FARM_ICON)
	mode4Button.icon:FillInner(mode4Button)
	mode4Button.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	mode4Button.modeName = "Farming"
	mode4Button:SetScript('OnEnter', ModeButton_OnEnter)
	mode4Button:SetScript('OnLeave', ModeButton_OnLeave)
	mode4Button:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local mode3Button = CreateFrame("Frame", "SVUI_ModeButton3", modesToolBar)
	mode3Button:SetPoint("BOTTOM",mode4Button,"TOP",0,2)
	mode3Button:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	mode3Button.icon = mode3Button:CreateTexture(nil, 'OVERLAY')
	mode3Button.icon:SetTexture(ARCH_ICON)
	mode3Button.icon:FillInner(mode3Button)
	mode3Button.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	mode3Button.modeName = "Archaeology"
	mode3Button:SetScript('OnEnter', ModeButton_OnEnter)
	mode3Button:SetScript('OnLeave', ModeButton_OnLeave)
	mode3Button:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local mode2Button = CreateFrame("Frame", "SVUI_ModeButton2", modesToolBar)
	mode2Button:SetPoint("BOTTOM",mode3Button,"TOP",0,2)
	mode2Button:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	mode2Button.icon = mode2Button:CreateTexture(nil, 'OVERLAY')
	mode2Button.icon:SetTexture(FISH_ICON)
	mode2Button.icon:FillInner(mode2Button)
	mode2Button.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	mode2Button.modeName = "Fishing"
	mode2Button:SetScript('OnEnter', ModeButton_OnEnter)
	mode2Button:SetScript('OnLeave', ModeButton_OnLeave)
	mode2Button:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local mode1Button = CreateFrame("Frame", "SVUI_ModeButton1", modesToolBar)
	mode1Button:SetPoint("BOTTOM",mode2Button,"TOP",0,2)
	mode1Button:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	mode1Button.icon = mode1Button:CreateTexture(nil, 'OVERLAY')
	mode1Button.icon:SetTexture(COOK_ICON)
	mode1Button.icon:FillInner(mode1Button)
	mode1Button.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	mode1Button.modeName = "Cooking"
	mode1Button:SetScript('OnEnter', ModeButton_OnEnter)
	mode1Button:SetScript('OnLeave', ModeButton_OnLeave)
	mode1Button:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local ModeAlert = CreateFrame("Frame", nil, self.Docklet)
	ModeAlert:SetAllPoints(self.Docklet.Parent.Alert)
	ModeAlert:SetBackdrop({
        bgFile = [[Interface\AddOns\SVUI\assets\artwork\Bars\HALFTONE]],
        edgeFile = [[Interface\BUTTONS\WHITE8X8]],
        tile = true,
        tileSize = 64,
        edgeSize = 1,
        insets = {
            left = 1,
            right = 1,
            top = 1,
            bottom = 1
        }
    })

	ModeAlert:SetBackdropBorderColor(0,0,0,1)
	ModeAlert:SetBackdropColor(0.25, 0.52, 0.1)
	ModeAlert.text = ModeAlert:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
	ModeAlert.text:SetAllPoints(ModeAlert)
	ModeAlert.text:SetTextColor(1, 1, 1)
	ModeAlert.text:SetJustifyH("CENTER")
	ModeAlert.text:SetJustifyV("MIDDLE")
	ModeAlert.text:SetText("Click to Exit")
	ModeAlert.ModeText = "Click to Exit";
	ModeAlert.HelpText = "";
	ModeAlert:SetScript('OnEnter', ModeAlert_OnEnter)
	ModeAlert:SetScript('OnLeave', ModeAlert_OnLeave)
	ModeAlert:SetScript('OnHide', ModeAlert_OnHide)
	ModeAlert:SetScript('OnShow', ModeAlert_OnShow)
	ModeAlert:SetScript('OnMouseDown', ModeAlert_OnMouseDown)
	ModeAlert:Hide()

	ModeLogsFrame:SetFrameStrata("MEDIUM")
	ModeLogsFrame:SetPoint("TOPLEFT", mode1Button, "TOPRIGHT", 5, -5)
	ModeLogsFrame:SetPoint("BOTTOMRIGHT", self.Docklet, "BOTTOMRIGHT", -5, 5)
	ModeLogsFrame:SetParent(self.Docklet)

	local title = CreateFrame("ScrollingMessageFrame", nil, ModeLogsFrame)
	title:SetSpacing(4)
	title:SetClampedToScreen(false)
	title:SetFrameStrata("MEDIUM")
	title:SetPoint("TOPLEFT",ModeLogsFrame,"TOPLEFT",0,0)
	title:SetPoint("BOTTOMRIGHT",ModeLogsFrame,"TOPRIGHT",0,-20)
	title:FontManager(UNIT_NAME_FONT, 16, "OUTLINE", "CENTER", "MIDDLE")
	title:SetMaxLines(1)
	title:EnableMouseWheel(false)
	title:SetFading(false)
	title:SetInsertMode('TOP')

	title.divider = title:CreateTexture(nil,"OVERLAY")
    title.divider:SetTexture(0,0,0,0.5)
    title.divider:SetPoint("BOTTOMLEFT")
    title.divider:SetPoint("BOTTOMRIGHT")
    title.divider:SetHeight(1)

    local topleftline = title:CreateTexture(nil,"OVERLAY")
    topleftline:SetTexture(0,0,0,0.5)
    topleftline:SetPoint("TOPLEFT")
    topleftline:SetPoint("BOTTOMLEFT")
    topleftline:SetWidth(1)

	local log = CreateFrame("ScrollingMessageFrame", nil, ModeLogsFrame)
	log:SetSpacing(4)
	log:SetClampedToScreen(false)
	log:SetFrameStrata("MEDIUM")
	log:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,0)
	log:SetPoint("BOTTOMRIGHT",ModeLogsFrame,"BOTTOMRIGHT",0,0)
	log:FontManager(nil, self.db.fontSize, "OUTLINE")
	log:SetJustifyH("CENTER")
	log:SetJustifyV("MIDDLE")
	log:SetShadowColor(0, 0, 0, 0)
	log:SetMaxLines(120)
	log:EnableMouseWheel(true)
	log:SetScript("OnMouseWheel", onMouseWheel)
	log:SetFading(false)
	log:SetInsertMode('TOP')

	local bottomleftline = log:CreateTexture(nil,"OVERLAY")
    bottomleftline:SetTexture(0,0,0,0.5)
    bottomleftline:SetPoint("TOPLEFT")
    bottomleftline:SetPoint("BOTTOMLEFT")
    bottomleftline:SetWidth(1)

    self.ModeAlert = ModeAlert
	self.TitleWindow = title
	self.LogWindow = log
	self.Docklet:Hide()
	self.ListenerEnabled = false;
	self:CraftingReset()
	self:LoadCookingMode()
	self:LoadFishingMode()
	self:LoadArchaeologyMode()
	self:PrepareFarmingTools()
	
	self:RegisterEvent("SKILL_LINES_CHANGED")
end