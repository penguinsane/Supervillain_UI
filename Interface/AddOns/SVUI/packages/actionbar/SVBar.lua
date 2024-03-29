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
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, split = string.find, string.format, string.split;
local gsub = string.gsub;
--[[ MATH METHODS ]]--
local ceil = math.ceil;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local LSM = LibStub("LibSharedMedia-3.0")

local MOD = SV:NewPackage("SVBar", L["ActionBars"]);
MOD.ButtonCache = {};
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local maxFlyoutCount = 0
local SetSpellFlyoutHook
local NewFrame = CreateFrame
local NewHook = hooksecurefunc
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local ICON_FILE = [[Interface\AddOns\SVUI\assets\artwork\Icons\MICROMENU]]
local ICON_DATA = {
  {"CharacterMicroButton",0,0.25,0,0.25},     -- MICRO-CHARACTER
  {"SpellbookMicroButton",0.25,0.5,0,0.25},   -- MICRO-SPELLBOOK
  {"TalentMicroButton",0.5,0.75,0,0.25},      -- MICRO-TALENTS
  {"AchievementMicroButton",0.75,1,0,0.25},   -- MICRO-ACHIEVEMENTS
  {"QuestLogMicroButton",0,0.25,0.25,0.5},    -- MICRO-QUESTS
  {"GuildMicroButton",0.25,0.5,0.25,0.5},     -- MICRO-GUILD
  {"PVPMicroButton",0.5,0.75,0.25,0.5},       -- MICRO-PVP
  {"LFDMicroButton",0.75,1,0.25,0.5},         -- MICRO-LFD
  {"EJMicroButton",0,0.25,0.5,0.75},          -- MICRO-ENCOUNTER
  {"StoreMicroButton",0.25,0.5,0.5,0.75},     -- MICRO-STORE
  {"CompanionsMicroButton",0.5,0.75,0.5,0.75},-- MICRO-COMPANION
  {"MainMenuMicroButton",0.75,1,0.5,0.75},    -- MICRO-SYSTEM
  {"HelpMicroButton",0,0.25,0.75,1},          -- MICRO-HELP
}
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local LibAB = LibStub("LibActionButton-1.0");

local function NewActionBar(barName)
	local bar = CreateFrame("Frame", barName, SV.Screen, "SecureHandlerStateTemplate")
	bar.buttons = {}
	bar.conditions = ""
	bar.config = {
		outOfRangeColoring = "button",
		tooltip = "enable",
		showGrid = true,
		colors = {
			range = {0.8, 0.1, 0.1},
			mana = {0.5, 0.5, 1.0},
			hp = {0.5, 0.5, 1.0}
		},
		hideElements = {
			macro = false,
			hotkey = false,
			equipped = false
		},
		keyBoundTarget = false,
		clickOnDown = false
	}
	return bar
end

local function NewActionButton(parent, index, name)
	return LibAB:CreateButton(index, name, parent, nil)
end

local function RefreshMicrobar()
	if not SVUI_MicroBar then return end 
	local lastParent = SVUI_MicroBar;
	local buttonSize =  SV.db.SVBar.Micro.buttonsize or 30;
	local spacing =  SV.db.SVBar.Micro.buttonspacing or 1;
	local barWidth = (buttonSize + spacing) * 13;
	SVUI_MicroBar_MOVE:Size(barWidth, buttonSize)
	SVUI_MicroBar:SetAllPoints(SVUI_MicroBar_MOVE)
	for i=1,13 do
		local data = ICON_DATA[i]
		local button = _G[data[1]]
		if(button) then
			button:ClearAllPoints()
			button:Size(buttonSize, buttonSize + 28)
			button._fade = SV.db.SVBar.Micro.mouseover
			if lastParent == SVUI_MicroBar then 
				button:SetPoint("BOTTOMLEFT", lastParent, "BOTTOMLEFT", 0, 0)
			else 
				button:SetPoint("BOTTOMLEFT", lastParent, "BOTTOMRIGHT", spacing, 0)
			end 
			lastParent = button;
			button:Show()
		end
	end 
end

local Bar_OnEnter = function(self)
	if(self._fade) then
		SV:SecureFadeIn(self, 0.2, self:GetAlpha(), self._alpha)
	end
end 

local Bar_OnLeave = function(self)
	if(self._fade) then
		SV:SecureFadeOut(self, 1, self:GetAlpha(), 0)
	end
end

local SVUIMicroButton_SetNormal = function()
	local level = MainMenuMicroButton:GetFrameLevel()
	if(level > 0) then 
		MainMenuMicroButton:SetFrameLevel(level - 1)
	else 
		MainMenuMicroButton:SetFrameLevel(0)
	end
	MainMenuMicroButton:SetFrameStrata("BACKGROUND")
	MainMenuMicroButton.overlay:SetFrameLevel(level + 1)
	MainMenuMicroButton.overlay:SetFrameStrata("HIGH")
	MainMenuBarPerformanceBar:Hide()
	HelpMicroButton:Show()
end 

local SVUIMicroButtonsParent = function(self)
	if self ~= SVUI_MicroBar then 
		self = SVUI_MicroBar 
	end 
	for i=1,13 do
		local data = ICON_DATA[i]
		if(data) then
			local mButton = _G[data[1]]
			if(mButton) then mButton:SetParent(SVUI_MicroBar) end
		end
	end 
end 

local MicroButton_OnEnter = function(self)
	if(self._fade) then
		SV:SecureFadeIn(SVUI_MicroBar,0.2,SVUI_MicroBar:GetAlpha(),1)
	end
	if InCombatLockdown()then return end 
	self.overlay:SetPanelColor("highlight")
	self.overlay.icon:SetGradient("VERTICAL", 0.75, 0.75, 0.75, 1, 1, 1)
end

local MicroButton_OnLeave = function(self)
	if(self._fade) then
		SV:SecureFadeOut(SVUI_MicroBar,1,SVUI_MicroBar:GetAlpha(),0)
	end
	if InCombatLockdown()then return end 
	self.overlay:SetPanelColor("special")
	self.overlay.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
end

local MicroButton_OnUpdate = function()
	if(not SV.db.SVBar.Micro.mouseover) then
		SVUI_MicroBar:SetAlpha(1)
	else
		SVUI_MicroBar:SetAlpha(0)
	end
	GuildMicroButtonTabard:ClearAllPoints();
	GuildMicroButtonTabard:Hide();
	RefreshMicrobar()
end

function MOD:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey']
	local hotkeyText = hotkey:GetText()
	if hotkeyText then
		hotkeyText = hotkeyText:gsub('SHIFT%-', "S")
		hotkeyText = hotkeyText:gsub('ALT%-',  "A")
		hotkeyText = hotkeyText:gsub('CTRL%-',  "C")
		hotkeyText = hotkeyText:gsub('BUTTON',  "B")
		hotkeyText = hotkeyText:gsub('MOUSEWHEELUP', "WU")
		hotkeyText = hotkeyText:gsub('MOUSEWHEELDOWN', "WD")
		hotkeyText = hotkeyText:gsub('NUMPAD',  "N")
		hotkeyText = hotkeyText:gsub('PAGEUP', "PgU")
		hotkeyText = hotkeyText:gsub('PAGEDOWN', "PgD")
		hotkeyText = hotkeyText:gsub('SPACE', "SP")
		hotkeyText = hotkeyText:gsub('INSERT', "INS")
		hotkeyText = hotkeyText:gsub('HOME', "HM")
		hotkeyText = hotkeyText:gsub('DELETE', "DEL")
		hotkeyText = hotkeyText:gsub('NMULTIPLY', "N*")
		hotkeyText = hotkeyText:gsub('NMINUS', "N-")
		hotkeyText = hotkeyText:gsub('NPLUS', "N+")
		hotkey:SetText(hotkeyText)
	end 
	hotkey:ClearAllPoints()
	hotkey:SetAllPoints()
end 

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

local function SaveActionButton(parent)
	local button = parent:GetName()
	local cooldown = _G[button.."Cooldown"]
	cooldown.SizeOverride = SV.db.SVBar.cooldownSize
	MOD:FixKeybindText(parent)
	MOD.ButtonCache[parent] = true 
	parent:SetSlotTemplate(true, 2, 0, 0, 0.75)
	parent:SetCheckedTexture("")
end 

local function SetFlyoutButton(button)
	if not button or not button.FlyoutArrow or not button.FlyoutArrow:IsShown() or not button.FlyoutBorder then return end 
	local LOCKDOWN = InCombatLockdown()
	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)
	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)
	for i = 1, GetNumFlyouts()do 
		local id = GetFlyoutID(i)
		local _, _, max, check = GetFlyoutInfo(id)
		if check then 
			maxFlyoutCount = max;
			break 
		end 
	end 
	local offset = 0;
	if SpellFlyout:IsShown() and SpellFlyout:GetParent() == button or GetMouseFocus() == button then offset = 5 else offset = 2 end 
	if button:GetParent() and button:GetParent():GetParent() and button:GetParent():GetParent():GetName() and button:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then return end 
	if button:GetParent() then 
		local point = Pinpoint(button:GetParent())
		if point:find("RIGHT") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("LEFT", button, "LEFT", -offset, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "LEFT")
			end 
		elseif point:find("LEFT") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("RIGHT", button, "RIGHT", offset, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "RIGHT")
			end 
		elseif point:find("TOP") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("BOTTOM", button, "BOTTOM", 0, -offset)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "DOWN")
			end 
		elseif point == "CENTER" or point:find("BOTTOM") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("TOP", button, "TOP", 0, offset)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "UP")
			end 
		end
	end 
end 

local function ModifyActionButton(parent)
	local button = parent:GetName()
	local icon = _G[button.."Icon"]
	local count = _G[button.."Count"]
	local flash = _G[button.."Flash"]
	local hotkey = _G[button.."HotKey"]
	local border = _G[button.."Border"]
	local normal = _G[button.."NormalTexture"]
	local cooldown = _G[button.."Cooldown"]
	local parentTex = parent:GetNormalTexture()
	local shine = _G[button.."Shine"]
	local highlight = parent:GetHighlightTexture()
	local pushed = parent:GetPushedTexture()
	local checked = parent:GetCheckedTexture()
	if cooldown then
		cooldown.SizeOverride = SV.db.SVBar.cooldownSize
		--cooldown:SetAlpha(0)
	end 
	if highlight then 
		highlight:SetTexture(1,1,1,.2)
	end 
	if pushed then 
		pushed:SetTexture(0,0,0,.4)
	end 
	if checked then 
		checked:SetTexture(1,1,1,.2)
	end 
	if flash then 
		flash:SetTexture(0,0,0,0)
	end 
	if normal then 
		normal:SetTexture(0,0,0,0)
		normal:Hide()
		normal:SetAlpha(0)
	end 
	if parentTex then 
		parentTex:SetTexture(0,0,0,0)
		parentTex:Hide()
		parentTex:SetAlpha(0)
	end 
	if border then border:Die()end 
	if count then 
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT",1,1)
		count:SetShadowOffset(1,-1)
		count:FontManager(LSM:Fetch("font",SV.db.SVBar.countFont),SV.db.SVBar.countFontSize,SV.db.SVBar.countFontOutline)
	end 
	if icon then 
		icon:SetTexCoord(.1,.9,.1,.9)
		--icon:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
		icon:FillInner(button)
	end 
	if shine then shine:SetAllPoints()end 
	if SV.db.SVBar.hotkeytext then 
		hotkey:ClearAllPoints()
		hotkey:SetAllPoints()
		hotkey:FontManager(LSM:Fetch("font",SV.db.SVBar.font),SV.db.SVBar.fontSize,SV.db.SVBar.fontOutline)
		hotkey:SetJustifyH("RIGHT")
    	hotkey:SetJustifyV("TOP")
		hotkey:SetShadowOffset(1,-1)
	end 
	-- if parent.style then 
	-- 	parent.style:SetDrawLayer('BACKGROUND',-7)
	-- end 
	parent.FlyoutUpdateFunc = SetFlyoutButton;
	MOD:FixKeybindText(parent)
end 

do
	local SpellFlyoutButton_OnEnter = function(self)
		local parent = self:GetParent()
		local anchor = select(2, parent:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent = anchor:GetParent()
		if anchorParent._fade then
			local alpha = anchorParent._alpha
			local actual = anchorParent:GetAlpha()
			SV:SecureFadeIn(anchorParent, 0.2, actual, alpha)
		end
	end

	local SpellFlyoutButton_OnLeave = function(self)
		local parent = self:GetParent()
		local anchor = select(2, parent:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent = anchor:GetParent()
		if anchorParent._fade then
			local actual = anchorParent:GetAlpha()
			SV:SecureFadeOut(anchorParent, 1, actual, 0)
		end
	end

	local SpellFlyout_OnEnter = function(self)
		local anchor = select(2,self:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent = anchor:GetParent()
		if anchorParent._fade then 
			Bar_OnEnter(anchorParent)	
		end
	end

	local SpellFlyout_OnLeave = function(self)
		local anchor = select(2, self:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent=anchor:GetParent()
		if anchorParent._fade then 
			Bar_OnLeave(anchorParent)
		end
	end

	local SpellFlyout_OnShow = function()
		for i=1,maxFlyoutCount do
			local name = ("SpellFlyoutButton%s"):format(i)
			local button = _G[name]
			if(button) then 
				ModifyActionButton(button)
				SaveActionButton(button)

				button:HookScript('OnEnter', SpellFlyoutButton_OnEnter)
				
				button:HookScript('OnLeave', SpellFlyoutButton_OnLeave)
			end 
		end 
		SpellFlyout:HookScript('OnEnter', SpellFlyout_OnEnter)
		SpellFlyout:HookScript('OnLeave', SpellFlyout_OnLeave)
	end

	local QualifyFlyouts = function()
		if InCombatLockdown() then return end 
		for button,_ in pairs(MOD.ButtonCache)do 
			if(button and button.FlyoutArrow) then
				SetFlyoutButton(button)
			end 
		end 
	end 

	function SetSpellFlyoutHook()
		SpellFlyout:HookScript("OnShow",SpellFlyout_OnShow);
		SV.Timers:ExecuteTimer(QualifyFlyouts, 5)
	end
end 
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateBarBindings(pet, stance)
	if stance == true then
		local bar = _G["SVUI_StanceBar"]
		local bindText = bar.binding

	  	for i=1,NUM_STANCE_SLOTS do
	  		local name = ("SVUI_StanceBarButton%s"):format(i)
	  		local hkname = ("SVUI_StanceBarButton%sHotKey"):format(i)
			local hotkey = _G[hkname]
		    if SV.db.SVBar.hotkeytext then
		    	local key = bindText:format(i);
		    	local binding = GetBindingKey(key)
		      	hotkey:Show()
		      	hotkey:SetText(binding)
		      	MOD:FixKeybindText(_G[name])
		    else 
		      	hotkey:Hide()
		    end 
	  	end
  	end
  	if pet == true then
  		local bar = _G["SVUI_PetActionBar"]
		local bindText = bar.binding

	  	for i=1,NUM_PET_ACTION_SLOTS do
	  		local name = ("PetActionButton%s"):format(i)
	  		local hkname = ("PetActionButton%sHotKey"):format(i)
			local hotkey = _G[hkname]
		    if SV.db.SVBar.hotkeytext then 
		      	local key = bindText:format(i);
		    	local binding = GetBindingKey(key)
		      	hotkey:Show()
		      	hotkey:SetText(binding)
		      	MOD:FixKeybindText(_G[name])
		    else
	    		hotkey:Hide()
	    	end 
	  	end
	end
end 

function MOD:UpdateAllBindings(event)
	if event == "UPDATE_BINDINGS" then 
		MOD:UpdateBarBindings(true,true)
	end 
	MOD:UnregisterEvent("PLAYER_REGEN_DISABLED")
	if InCombatLockdown() then return end 
	for i = 1, 6 do
		local barName = ("SVUI_ActionBar%d"):format(i)
		local bar = _G[barName]
		if(bar and bar.buttons) then
			local thisBinding = bar.binding

			ClearOverrideBindings(bar)

			for k = 1,#bar.buttons do 
				local binding = thisBinding:format(k);
				local btn = ("%sButton%d"):format(barName, k);
				for x = 1,select('#',GetBindingKey(binding)) do 
					local key = select(x, GetBindingKey(binding))
					if (key and key ~= "") then 
						SetOverrideBindingClick(bar, false, key, btn)
					end 
				end 
			end
		end
	end 
end 

function MOD:SetBarConfigData(bar)
	local db = SV.db.SVBar
	local thisBinding = bar.binding;
	local buttonList = bar.buttons;
	local config = bar.config
	config.hideElements.macro = db.macrotext;
	config.hideElements.hotkey = db.hotkeytext;
	config.showGrid = db.showGrid;
	config.clickOnDown = db.keyDown;
	config.colors.range = db.unc
	config.colors.mana = db.unpc
	config.colors.hp = db.unpc
	SetModifiedClick("PICKUPACTION", db.unlock)
	for i,button in pairs(buttonList)do
		if thisBinding then
			config.keyBoundTarget = thisBinding:format(i)
		end
		button.keyBoundTarget = config.keyBoundTarget;
		button.postKeybind = self.FixKeybindText;
		button:SetAttribute("buttonlock",true)
		button:SetAttribute("checkselfcast",true)
		button:SetAttribute("checkfocuscast",true)
		button:UpdateConfig(config)
	end
end 

function MOD:UpdateBarPagingDefaults()
	local parse, custom;
	if SV.db.SVBar.Bar6.enable then
		parse = "[vehicleui,mod:alt,mod:ctrl] %d; [possessbar] %d; [overridebar] %d; [form,noform] 0; [shapeshift] 13; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; %s";
	else
		parse = "[vehicleui,mod:alt,mod:ctrl] %d; [possessbar] %d; [overridebar] %d; [form,noform] 0; [shapeshift] 13; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; %s";
	end
	
	local mainbar = _G["SVUI_ActionBar1"]
	if(mainbar) then
		if SV.db.SVBar.Bar1.useCustomPaging then
			custom = SV.db.SVBar.Bar1.customPaging[SV.class];
		else
			custom = ""
		end

		mainbar.conditions = parse:format(GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex(), custom);
	end

	for i=2, 6 do
		local id = ("Bar%d"):format(i)
		local bar = _G["SVUI_Action" .. id]
		if(bar and SV.db.SVBar[id].useCustomPaging) then
			bar.conditions = SV.db.SVBar[id].customPaging[SV.class];
		end
	end 

	if((not SV.db.SVBar.enable or InCombatLockdown()) or not self.isInitialized) then return end 
	local Bar2Option = InterfaceOptionsActionBarsPanelBottomRight
	local Bar3Option = InterfaceOptionsActionBarsPanelBottomLeft
	local Bar4Option = InterfaceOptionsActionBarsPanelRightTwo
	local Bar5Option = InterfaceOptionsActionBarsPanelRight

	if (SV.db.SVBar.Bar2.enable and not Bar2Option:GetChecked()) or (not SV.db.SVBar.Bar2.enable and Bar2Option:GetChecked())  then
		Bar2Option:Click()
	end
	
	if (SV.db.SVBar.Bar3.enable and not Bar3Option:GetChecked()) or (not SV.db.SVBar.Bar3.enable and Bar3Option:GetChecked())  then
		Bar3Option:Click()
	end
	
	if not SV.db.SVBar.Bar5.enable and not SV.db.SVBar.Bar4.enable then
		if Bar4Option:GetChecked() then
			Bar4Option:Click()
		end				
		
		if Bar5Option:GetChecked() then
			Bar5Option:Click()
		end
	elseif not SV.db.SVBar.Bar5.enable then
		if not Bar5Option:GetChecked() then
			Bar5Option:Click()
		end
		
		if not Bar4Option:GetChecked() then
			Bar4Option:Click()
		end
	elseif (SV.db.SVBar.Bar4.enable and not Bar4Option:GetChecked()) or (not SV.db.SVBar.Bar4.enable and Bar4Option:GetChecked()) then
		Bar4Option:Click()
	elseif (SV.db.SVBar.Bar5.enable and not Bar5Option:GetChecked()) or (not SV.db.SVBar.Bar5.enable and Bar5Option:GetChecked()) then
		Bar5Option:Click()
	end
end 
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
do
	local Button_OnEnter = function(self)
		local parent = self:GetParent()
		if parent and parent._fade then 
			SV:SecureFadeIn(parent, 0.2, parent:GetAlpha(), parent._alpha)
		end
	end 

	local Button_OnLeave = function(self)
		local parent = self:GetParent()
		GameTooltip:Hide()
		if parent and parent._fade then 
			SV:SecureFadeOut(parent, 1, parent:GetAlpha(), 0)
		end
	end 

	local function _refreshButtons(bar, id, max, space, cols, totalButtons, size, point, selfcast)
		if InCombatLockdown() then return end 
		if not bar then return end 
		local hideByScale = id == "Pet" and true or false;
		local isStance = id == "Stance" and true or false;
		local button,lastButton,lastRow;
		for i=1, max do 
			button = bar.buttons[i]
			lastButton = bar.buttons[i - 1]
			lastRow = bar.buttons[i - cols]
			button:SetParent(bar)
			button:ClearAllPoints()
			button:Size(size)
			button:SetAttribute("showgrid",1)

			if(selfcast) then
				button:SetAttribute("unit2", "player")
			end 

			if(not button._hookFade) then 
				button:HookScript('OnEnter', Button_OnEnter)
				button:HookScript('OnLeave', Button_OnLeave)
				-- if(hideByScale) then
				-- 	NewHook(button, "SetAlpha", function(self) print(self:GetName());print(self:GetAlpha()) end)
				-- end
				button._hookFade = true;
			end 

			local x,y,anchor1,anchor2;

			if(i == 1) then
				x, y = 0, 0
				if(point:find("BOTTOM")) then
					y = space
				elseif(point:find("TOP")) then
					y = -space
				end
				if(point:find("RIGHT")) then
					x = -space
				elseif(point:find("LEFT")) then
					x = space
				end
				button:Point(point,bar,point,x,y)
			elseif((i - 1) % cols == 0) then 
				x, y = 0, -space
				anchor1, anchor2 = "TOP", "BOTTOM"
		      	if(point:find("BOTTOM")) then 
		        	y = space;
		        	anchor1 = "BOTTOM"
		        	anchor2 = "TOP"
		      	end
				button:Point(anchor1,lastRow,anchor2,x,y)
			else 
				x, y = space, 0
		      	anchor1, anchor2 = "LEFT", "RIGHT";
		      	if(point:find("RIGHT")) then 
		        	x = -space;
		        	anchor1 = "RIGHT"
		        	anchor2 = "LEFT"
		      	end
				button:Point(anchor1,lastButton,anchor2,x,y)
			end 

			if(i > totalButtons) then
				if hideByScale then
					button:SetScale(0.000001)
	      			button:SetAlpha(0)
				else 
					button:Hide()
				end
			else 
				if hideByScale then
					button:SetScale(1)
	      			button:SetAlpha(1)
				else 
					button:Show()
				end
			end 

			if (not isStance or (isStance and not button.FlyoutUpdateFunc)) then 
	      		ModifyActionButton(button);
	      		SaveActionButton(button);
	    	end
		end 
	end 

	local function _getPage(bar, defaultPage, condition)
		local page = SV.db.SVBar[bar].customPaging[SV.class]
		if not condition then condition = '' end
		if not page then page = '' end
		if page then
			condition = condition.." "..page
		end
		condition = condition.." "..defaultPage
		return condition
	end

	function MOD:RefreshBar(id)
		if(InCombatLockdown()) then return end

		local bar 
		local isPet, isStance = false, false
		local db = SV.db.SVBar[id]

		if(id == "Pet") then
			bar = _G["SVUI_PetActionBar"]
			isPet = true
		elseif(id == "Stance") then
			bar = _G["SVUI_StanceBar"]
			isStance = true
		else
			bar = _G[("SVUI_Action%s"):format(id)]
		end

		if(not bar or not db) then return end

		local selfcast = db.rightClickSelf
		local space = db.buttonspacing;
		local cols = db.buttonsPerRow;
		local size = db.buttonsize;
		local point = db.point;
		local barVisibility = db.customVisibility;
		local totalButtons = db.buttons;
		local max = (isStance and GetNumShapeshiftForms()) or (isPet and 10) or NUM_ACTIONBAR_BUTTONS;
		local rows = ceil(totalButtons  /  cols);

		if max < cols then cols = max end 
		if rows < 1 then rows = 1 end

		bar:Width(space  +  (size  *  cols)  +  ((space  *  (cols - 1))  +  space));
		bar:Height((space  +  (size  *  rows))  +  ((space  *  (rows - 1))  +  space));
		bar.backdrop:ClearAllPoints()
	  	bar.backdrop:SetAllPoints()
		bar._fade = db.mouseover;
		bar._alpha = db.alpha;

		if db.backdrop == true then 
			bar.backdrop:Show()
		else 
			bar.backdrop:Hide()
		end 

		if(not bar._hookFade) then 
			bar:HookScript('OnEnter', Bar_OnEnter)
			bar:HookScript('OnLeave', Bar_OnLeave)
			bar._hookFade = true;
		end 

		if(db.mouseover == true) then 
			bar:SetAlpha(0)
			bar._fade = true
		else 
			bar:SetAlpha(db.alpha)
			bar._fade = false 
		end 
		
		_refreshButtons(bar, id, max, space, cols, totalButtons, size, point, selfcast);

		if(isPet or isStance) then
			if db.enable then 
				bar:SetScale(1)
				bar:SetAlpha(db.alpha)
				if(db.mouseover == true) then 
					bar:SetAlpha(0)
				else 
					bar:SetAlpha(db.alpha)
				end
				RegisterStateDriver(bar, "visibility", barVisibility)
			else 
				bar:SetScale(0.000001)
				bar:SetAlpha(0)
				UnregisterStateDriver(bar, "visibility")
			end
			--RegisterStateDriver(bar, "show", barVisibility)
		else
			local p,c = bar.page, bar.conditions
		  	local page = _getPage(id, p, c)
			if c:find("[form, noform]") then
				bar:SetAttribute("hasTempBar", true)
				local newCondition = c:gsub(" %[form, noform%] 0; ", "");
				bar:SetAttribute("newCondition", newCondition)
			else
				bar:SetAttribute("hasTempBar", false)
			end

			RegisterStateDriver(bar, "page", page)
			if not bar.ready then
				bar.ready = true;
				self:RefreshBar(id) 
				return
			end
			
			if db.enable == true then
				bar:Show()
				RegisterStateDriver(bar, "visibility", barVisibility)
			else
				bar:Hide()
				UnregisterStateDriver(bar, "visibility")
			end
			SV.Mentalo:ChangeSnapOffset(("SVUI_Action%d_MOVE"):format(id), (space  /  2))
		end
	end 
end 

function MOD:RefreshActionBars()
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
	self:UpdateBarPagingDefaults()
	for button, _ in pairs(self.ButtonCache)do 
		if button then 
			ModifyActionButton(button)
			SaveActionButton(button)
			if(button.FlyoutArrow) then
				SetFlyoutButton(button)
			end
		else 
			self.ButtonCache[button] = nil 
		end 
	end

	local id, bar
	for i = 1, 6 do
		id = ("Bar%d"):format(i)
		bar = _G[("SVUI_Action%s"):format(id)]
		self:RefreshBar(id)
		self:SetBarConfigData(bar)
	end

	self:RefreshBar("Pet")
	self:RefreshBar("Stance")
	self:UpdateBarBindings(true, true)

	collectgarbage("collect");
end 

local Vehicle_Updater = function()
	local bar = _G["SVUI_ActionBar1"]
	local space = SV.db.SVBar["Bar1"].buttonspacing
	local total = SV.db.SVBar["Bar1"].buttons;
	local rows = SV.db.SVBar["Bar1"].buttonsPerRow;
	local size = SV.db.SVBar["Bar1"].buttonsize
	local point = SV.db.SVBar["Bar1"].point;
	local columns = ceil(total / rows)
	if (HasOverrideActionBar() or HasVehicleActionBar()) and total == 12 then 
		bar.backdrop:ClearAllPoints()
		bar.backdrop:Point(SV.db.SVBar["Bar1"].point, bar, SV.db.SVBar["Bar1"].point)
		bar.backdrop:Width(space + ((size * rows) + (space * (rows - 1)) + space))
		bar.backdrop:Height(space + ((size * columns) + (space * (columns - 1)) + space))
		bar.backdrop:SetFrameLevel(0);
	else 
		bar.backdrop:SetAllPoints()
		bar.backdrop:SetFrameLevel(0);
	end
	MOD:RefreshBar("Bar1")
end 
--[[ 
########################################################## 
HOOKED / REGISTERED FUNCTIONS
##########################################################
]]--
local SVUIOptionsPanel_OnEvent = function()
	InterfaceOptionsActionBarsPanelBottomRight.Text:SetText((L['Remove Bar %d Action Page']):format(2))
	InterfaceOptionsActionBarsPanelBottomLeft.Text:SetText((L['Remove Bar %d Action Page']):format(3))
	InterfaceOptionsActionBarsPanelRightTwo.Text:SetText((L['Remove Bar %d Action Page']):format(4))
	InterfaceOptionsActionBarsPanelRight.Text:SetText((L['Remove Bar %d Action Page']):format(5))
	InterfaceOptionsActionBarsPanelBottomRight:SetScript('OnEnter',nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript('OnEnter',nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript('OnEnter',nil)
	InterfaceOptionsActionBarsPanelRight:SetScript('OnEnter',nil)
end 

local SVUIButton_ShowOverlayGlow = function(self)
	if not self.overlay then return end  
	local size = self:GetWidth() / 3;
	self.overlay:WrapOuter(self, size)
end 

local ResetAllBindings = function(self)
	if InCombatLockdown() then return end

	local bar
	for i = 1, 6 do
		bar = _G[("SVUI_ActionBar%d"):format(i)]
		if(bar) then
			ClearOverrideBindings(bar)
		end
	end

	ClearOverrideBindings(_G["SVUI_PetActionBar"])
	ClearOverrideBindings(_G["SVUI_StanceBar"])

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateAllBindings")
end 
--[[ 
########################################################## 
BAR CREATION
##########################################################
]]--
local CreateActionBars, CreateStanceBar, CreatePetBar, CreateMicroBar;
local barBindingIndex = {
	"ACTIONBUTTON%d",
	"MULTIACTIONBAR2BUTTON%d",
	"MULTIACTIONBAR1BUTTON%d",
	"MULTIACTIONBAR4BUTTON%d",
	"MULTIACTIONBAR3BUTTON%d",
	"SVUIACTIONBAR6BUTTON%d"
}
local barPageIndex = {1, 5, 6, 4, 3, 2}

CreateActionBars = function(self)
	for i = 1, 6 do 
		local barID = ("Bar%d"):format(i)
		local barName = ("SVUI_Action%s"):format(barID)
		local buttonMax = NUM_ACTIONBAR_BUTTONS

		local space = SV.db.SVBar["Bar"..i].buttonspacing

		local thisBar = NewActionBar(barName)
		thisBar.binding = barBindingIndex[i]
		thisBar.page = barPageIndex[i]

		if(i == 1) then
			thisBar:Point("BOTTOM", SV.Screen, "BOTTOM", 0, 28)
		elseif(i == 2) then
			thisBar:Point("BOTTOM", _G["SVUI_ActionBar1"], "TOP", 0, -space)
		elseif(i == 3) then
			thisBar:Point("BOTTOMLEFT", _G["SVUI_ActionBar1"], "BOTTOMRIGHT", space, 0)
		elseif(i == 4) then
			thisBar:Point("RIGHT", SV.Screen, "RIGHT", -space, 0)
		elseif(i == 5) then
			thisBar:Point("BOTTOMRIGHT", _G["SVUI_ActionBar1"], "BOTTOMLEFT", -space, 0)
		else
			thisBar:Point("BOTTOM", _G["SVUI_ActionBar2"], "TOP", 0, space)
		end
			
		local bg = CreateFrame("Frame", nil, thisBar)
		bg:SetAllPoints()
		bg:SetFrameLevel(0)
		thisBar:SetFrameLevel(5)
		bg:SetPanelTemplate("Component")
		bg:SetPanelColor("dark")
		thisBar.backdrop = bg

		for k = 1, buttonMax do
			local buttonName = ("%sButton%d"):format(barName, k)
			thisBar.buttons[k] = NewActionButton(thisBar, k, buttonName)
			thisBar.buttons[k]:SetState(0, "action", k)
			for x = 1, 14 do 
				local calc = (x - 1)  *  buttonMax  +  k;
				thisBar.buttons[k]:SetState(x, "action", calc)
			end 
			if k == 12 then 
				thisBar.buttons[k]:SetState(12, "custom", {
					func = function(...) 
						if UnitExists("vehicle") then 
							VehicleExit() 
						else 
							PetDismiss() 
						end 
					end, 
					texture = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down", 
					tooltip = LEAVE_VEHICLE
				});
			end 
		end

		self:SetBarConfigData(thisBar)

		if i == 1 then 
			thisBar:SetAttribute("hasTempBar", true)
		else 
			thisBar:SetAttribute("hasTempBar", false)
		end

		thisBar:SetAttribute("_onstate-page", [[
			if HasTempShapeshiftActionBar() and self:GetAttribute("hasTempBar") then
				newstate = GetTempShapeshiftBarIndex() or newstate
			end

			if newstate ~= 0 then
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			else
				local newCondition = self:GetAttribute("newCondition")
				if newCondition then
					newstate = SecureCmdOptionParse(newCondition)
					self:SetAttribute("state", newstate)
					control:ChildUpdate("state", newstate)
				end
			end
		]])

		self:RefreshBar(barID)
		SV.Mentalo:Add(thisBar, L[barID], nil, nil, nil, "ALL, ACTIONBARS")
	end 
end

do
	local function SetStanceBarButtons()
		local maxForms = GetNumShapeshiftForms();
		local currentForm = GetShapeshiftForm();
		local maxButtons = NUM_STANCE_SLOTS;
		local texture, name, isActive, isCastable, _;
		for i = 1, maxButtons do
			local button = _G["SVUI_StanceBarButton"..i]
			local icon = _G["SVUI_StanceBarButton"..i.."Icon"]
			local cd = _G["SVUI_StanceBarButton"..i.."Cooldown"]
			if i <= maxForms then 
				texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
				if texture == "Interface\\Icons\\Spell_Nature_WispSplode" and SV.db.SVBar.Stance.style == "darkenInactive" then 
					_, _, texture = GetSpellInfo(name)
				end

				icon:SetTexture(texture)

				if texture then 
					cd:SetAlpha(1)
				else 
					cd:SetAlpha(0)
				end

				if isActive then 
					StanceBarFrame.lastSelected = button:GetID()

					if maxForms > 1 then 
						if button.checked then button.checked:SetTexture(0, 0.5, 0, 0.2) end
						button:SetBackdropBorderColor(0.4, 0.8, 0)
					end
					icon:SetVertexColor(1, 1, 1)
					button:SetChecked(true) 
				else 
					if maxForms > 1 and currentForm > 0 then 
						button:SetBackdropBorderColor(0, 0, 0)
						if button.checked then 
							button.checked:SetAlpha(1)
						end
						if SV.db.SVBar.Stance.style == "darkenInactive" then 
							icon:SetVertexColor(0.25, 0.25, 0.25)
						else 
							icon:SetVertexColor(1, 1, 1)
						end
					end

					button:SetChecked(false) 
				end 
				if isCastable then 
					icon:SetDesaturated(false)
					button:SetAlpha(1)
				else 
					icon:SetDesaturated(true)
					button:SetAlpha(0.4)
				end
			end 
		end 
	end 

	local function UpdateShapeshiftForms(self, event)
	  if InCombatLockdown() or not _G["SVUI_StanceBar"] then return end 

	  local stanceBar = _G["SVUI_StanceBar"];

	  for i = 1, #stanceBar.buttons do 
		stanceBar.buttons[i]:Hide()
	  end 

	  local ready = false;
	  local maxForms = GetNumShapeshiftForms()

	  for i = 1, NUM_STANCE_SLOTS do 
		if(not stanceBar.buttons[i]) then 
		  stanceBar.buttons[i] = CreateFrame("CheckButton", format("SVUI_StanceBarButton%d", i), stanceBar, "StanceButtonTemplate")
		  stanceBar.buttons[i]:SetID(i)
		  ready = true 
		end 
		if(i <= maxForms) then 
		  stanceBar.buttons[i]:Show()
		else 
		  stanceBar.buttons[i]:Hide()
		end 
	  end 

	  MOD:RefreshBar("Stance")

	  SetStanceBarButtons() 
	  if not C_PetBattles.IsInBattle() or ready then 
		if maxForms == 0 then 
		  UnregisterStateDriver(stanceBar, "show")
		  stanceBar:Hide()
		else 
		  stanceBar:Show()
		  RegisterStateDriver(stanceBar, "show", "[petbattle] hide;show")
		end 
	  end 
	end 

	local function UpdateShapeshiftCD()
	  local maxForms = GetNumShapeshiftForms()
	  for i = 1, NUM_STANCE_SLOTS do 
		if i  <= maxForms then 
		  local cooldown = _G["SVUI_StanceBarButton"..i.."Cooldown"]
		  local start, duration, enable = GetShapeshiftFormCooldown(i)
		  CooldownFrame_SetTimer(cooldown, start, duration, enable)
		end 
	  end
	end 

	CreateStanceBar = function(self)
	  local barID = "Stance";
	  local parent = _G["SVUI_ActionBar1"]
	  local maxForms = GetNumShapeshiftForms();
	  if SV.db.SVBar["Bar2"].enable then 
		parent = _G["SVUI_ActionBar2"]
	  end

	  local stanceBar = NewActionBar("SVUI_StanceBar")
	  stanceBar.binding = "CLICK SVUI_StanceBarButton%d:LeftButton"

	  stanceBar:Point("BOTTOMRIGHT",parent,"TOPRIGHT",0,2);
	  stanceBar:SetFrameLevel(5);

	  local bg = CreateFrame("Frame", nil, stanceBar)
	  bg:SetAllPoints();
	  bg:SetFrameLevel(0);
	  bg:SetPanelTemplate("Component")
	  bg:SetPanelColor("dark")
	  stanceBar.backdrop = bg;

	  for i = 1, NUM_STANCE_SLOTS do
		stanceBar.buttons[i] = _G["SVUI_StanceBarButton"..i]
	  end

	  stanceBar:SetAttribute("_onstate-show", [[    
		if newstate == "hide" then
		  self:Hide();
		else
		  self:Show();
		end 
	  ]]);

	  self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", UpdateShapeshiftForms)
	  self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", UpdateShapeshiftCD)
	  self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", SetStanceBarButtons)
	  self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", SetStanceBarButtons)
	  self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", SetStanceBarButtons)
	  UpdateShapeshiftForms()
	  SV.Mentalo:Add(stanceBar, L["Stance Bar"], nil, -3, nil, "ALL, ACTIONBARS")
	  self:RefreshBar("Stance")
	  SetStanceBarButtons()
	  self:UpdateBarBindings(false, true)
	end 
end

do
	local RefreshPet = function(self, event, arg)
		if event == "UNIT_AURA" and arg  ~= "pet" then return end 
		for i = 1, NUM_PET_ACTION_SLOTS, 1 do 
			local name = "PetActionButton"..i;
			local button = _G[name]
			local icon = _G[name.."Icon"]
			local auto = _G[name.."AutoCastable"]
			local shine = _G[name.."Shine"]
			local checked = button:GetCheckedTexture()
			local actionName, subtext, actionIcon, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
			button:SetChecked(false)
			button:SetBackdropBorderColor(0, 0, 0)
			checked:SetAlpha(0)
			if(not isToken) then 
				icon:SetTexture(actionIcon)
				button.tooltipName = actionName 
			else 
				icon:SetTexture(_G[actionIcon])
				button.tooltipName = _G[actionName]
			end 
			button.isToken = isToken;
			button.tooltipSubtext = subtext;
			if arg and actionName  ~= "PET_ACTION_FOLLOW" then
				if(IsPetAttackAction(i)) then PetActionButton_StartFlash(button) end
			else
				if(IsPetAttackAction(i)) then PetActionButton_StopFlash(button) end
			end 
			if autoCastAllowed then 
				auto:Show()
			else 
				auto:Hide()
			end 
			if (isActive and actionName  ~= "PET_ACTION_FOLLOW") then
				button:SetChecked(true)
				checked:SetAlpha(1)
				button:SetBackdropBorderColor(0.4, 0.8, 0)
			else
				button:SetChecked(false)
				checked:SetAlpha(0)
				button:SetBackdropBorderColor(0, 0, 0)
			end 
			if(autoCastEnabled) then 
				AutoCastShine_AutoCastStart(shine)
			else
				AutoCastShine_AutoCastStop(shine)
			end
			button:SetAlpha(1)
			if actionIcon then 
				icon:Show()
				if GetPetActionSlotUsable(i)then 
					SetDesaturation(icon, nil)
				else 
					SetDesaturation(icon, 1)
				end 
			else 
				icon:Hide() 
			end 
			if(not PetHasActionBar() and actionIcon and actionName  ~= "PET_ACTION_FOLLOW") then 
				PetActionButton_StopFlash(button)
				SetDesaturation(icon, 1)
				button:SetChecked(false)
			end 
		end
	end 

	CreatePetBar = function(self)
		local barID = "Pet";
		local parent = _G["SVUI_ActionBar1"]
		if SV.db.SVBar["Bar2"].enable then 
			parent = _G["SVUI_ActionBar2"]
		end

		local petBar = NewActionBar("SVUI_PetActionBar")
		petBar.binding = "BONUSACTIONBUTTON%d"

		petBar:Point("BOTTOMLEFT",parent,"TOPLEFT",0,2);
		petBar:SetFrameLevel(5);
		local bg = CreateFrame("Frame", nil, petBar)
		bg:SetAllPoints();
		bg:SetFrameLevel(0);
		bg:SetPanelTemplate("Component")
		bg:SetPanelColor("dark")
		petBar.backdrop = bg;
		for i = 1, NUM_PET_ACTION_SLOTS do 
			petBar.buttons[i] = _G["PetActionButton"..i]
		end
		petBar:SetAttribute("_onstate-show", [[    
			if newstate == "hide" then
			  self:Hide();
			else
			  self:Show();
			end 
		]]);

		PetActionBarFrame.showgrid = 1;
		PetActionBar_ShowGrid();

		self:RefreshBar("Pet")
		self:UpdateBarBindings(true, false)

		self:RegisterEvent("PLAYER_CONTROL_GAINED", RefreshPet)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", RefreshPet)
		self:RegisterEvent("PLAYER_CONTROL_LOST", RefreshPet)
		self:RegisterEvent("PET_BAR_UPDATE", RefreshPet)
		self:RegisterEvent("UNIT_PET", RefreshPet)
		self:RegisterEvent("UNIT_FLAGS", RefreshPet)
		self:RegisterEvent("UNIT_AURA", RefreshPet)
		self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", RefreshPet)
		self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", PetActionBar_UpdateCooldowns)

		SV.Mentalo:Add(petBar, L["Pet Bar"], nil, nil, nil, "ALL, ACTIONBARS")
	end 
end

CreateMicroBar = function(self)
	local buttonSize = SV.db.SVBar.Micro.buttonsize or 30;
	local spacing =  SV.db.SVBar.Micro.buttonspacing or 1;
	local barWidth = (buttonSize + spacing) * 13;
	local barHeight = (buttonSize + 6);
	local microBar = NewFrame('Frame','SVUI_MicroBar',SV.Screen)
	microBar:Size(barWidth, barHeight)
	microBar:SetFrameStrata("HIGH")
	microBar:SetFrameLevel(0)
	microBar:Point('BOTTOMLEFT', SV.Dock.TopLeft.Bar.ToolBar, 'BOTTOMRIGHT', 4, 0)
	SV:AddToDisplayAudit(microBar)

	for i=1,13 do
		local data = ICON_DATA[i]
		if(data) then
			local button = _G[data[1]]
			if(button) then
				button:SetParent(SVUI_MicroBar)
				button:Size(buttonSize, buttonSize + 28)
				button.Flash:SetTexture(0,0,0,0)
				if button.SetPushedTexture then 
					button:SetPushedTexture("")
				end 
				if button.SetNormalTexture then 
					button:SetNormalTexture("")
				end 
				if button.SetDisabledTexture then 
					button:SetDisabledTexture("")
				end 
				if button.SetHighlightTexture then 
					button:SetHighlightTexture("")
				end 
				button:RemoveTextures()

				local buttonMask = NewFrame("Frame",nil,button)
				buttonMask:SetPoint("TOPLEFT",button,"TOPLEFT",0,-28)
				buttonMask:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",0,0)
				buttonMask:SetFramedButtonTemplate()
				buttonMask:SetPanelColor()
				buttonMask.icon = buttonMask:CreateTexture(nil,"OVERLAY",nil,2)
				buttonMask.icon:FillInner(buttonMask,2,2)
				buttonMask.icon:SetTexture(ICON_FILE)
				buttonMask.icon:SetTexCoord(data[2],data[3],data[4],data[5])
				buttonMask.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
				button.overlay = buttonMask;
				button._fade = SV.db.SVBar.Micro.mouseover
				button:HookScript('OnEnter', MicroButton_OnEnter)
				button:HookScript('OnLeave', MicroButton_OnLeave)
				button:Show()
			end
		end
	end 

	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:Hide()
	MainMenuBarPerformanceBar:ClearAllPoints()
	MainMenuBarPerformanceBar:Hide()

	NewHook('MainMenuMicroButton_SetNormal', SVUIMicroButton_SetNormal)
	NewHook('UpdateMicroButtonsParent', SVUIMicroButtonsParent)
	NewHook('MoveMicroButtons', RefreshMicrobar)
	NewHook('UpdateMicroButtons', MicroButton_OnUpdate)

	SVUIMicroButtonsParent(microBar)
	SVUIMicroButton_SetNormal()

	SV.Mentalo:Add(microBar, L["Micro Bar"])

	RefreshMicrobar()
	SVUI_MicroBar:SetAlpha(0)
end

local CreateExtraBar = function(self)
	local specialBarSize = ExtraActionBarFrame:GetSize()
	local specialBar = CreateFrame("Frame", "SVUI_SpecialAbility", SV.Screen)
	specialBar:Point("BOTTOM", SV.Screen, "BOTTOM", 0, (275 + specialBarSize))
	specialBar:Size(specialBarSize)
	ExtraActionBarFrame:SetParent(specialBar)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", specialBar, "CENTER")
	ExtraActionBarFrame.ignoreFramePositionManager = true;
	local max = ExtraActionBarFrame:GetNumChildren()
	for i = 1, max do 
		local name = ("ExtraActionButton%d"):format(i)
		local icon = ("%sIcon"):format(name)
		local cool = ("%sCooldown"):format(name)
		local button = _G[name]
		if(button) then 
			button.noResize = true;
			button.pushed = true;
			button.checked = true;
			ModifyActionButton(button)
			button:SetFixedPanelTemplate()
			_G[icon]:SetDrawLayer("ARTWORK")
			_G[cool]:FillInner()
			local checkedTexture = button:CreateTexture(nil, "OVERLAY")
			checkedTexture:SetTexture(0.9, 0.8, 0.1, 0.3)
			checkedTexture:FillInner()
			button:SetCheckedTexture(checkedTexture)
		end 
	end
	if HasExtraActionBar()then 
		ExtraActionBarFrame:Show()
	end

	DraenorZoneAbilityFrame:SetParent(specialBar)
	DraenorZoneAbilityFrame:ClearAllPoints()
	DraenorZoneAbilityFrame:SetPoint('CENTER', specialBar, 'CENTER')
	DraenorZoneAbilityFrame.ignoreFramePositionManager = true

	SV.Mentalo:Add(specialBar, L["Boss Button"], nil, nil, nil, "ALL, ACTIONBAR")
end
--[[ 
########################################################## 
DEFAULT REMOVAL
##########################################################
]]--
local function RemoveDefaults()
	local removalManager = CreateFrame("Frame")
	removalManager:Hide()
	MultiBarBottomLeft:SetParent(removalManager)
	MultiBarBottomRight:SetParent(removalManager)
	MultiBarLeft:SetParent(removalManager)
	MultiBarRight:SetParent(removalManager)
	for i = 1, 12 do
		local ab = _G[("ActionButton%d"):format(i)]
		ab:Hide()
		ab:UnregisterAllEvents()
		ab:SetAttribute("statehidden", true)
		local mbl = _G[("MultiBarLeftButton%d"):format(i)]
		mbl:Hide()
		mbl:UnregisterAllEvents()
		mbl:SetAttribute("statehidden", true)
		local mbr = _G[("MultiBarRightButton%d"):format(i)]
		mbr:Hide()
		mbr:UnregisterAllEvents()
		mbr:SetAttribute("statehidden", true)
		local mbbl = _G[("MultiBarBottomLeftButton%d"):format(i)]
		mbbl:Hide()
		mbbl:UnregisterAllEvents()
		mbbl:SetAttribute("statehidden", true)
		local mbbr = _G[("MultiBarBottomRightButton%d"):format(i)]
		mbbr:Hide()
		mbbr:UnregisterAllEvents()
		mbbr:SetAttribute("statehidden", true)
		local mca = _G[("MultiCastActionButton%d"):format(i)]
		mca:Hide()
		mca:UnregisterAllEvents()
		mca:SetAttribute("statehidden", true)
		local vb = _G[("VehicleMenuBarActionButton%d"):format(i)]
		if(vb) then 
			vb:Hide()
			vb:UnregisterAllEvents()
			vb:SetAttribute("statehidden", true)
		end
		local ob = _G[("OverrideActionBarButton%d"):format(i)]
		if(ob) then 
			ob:Hide()
			ob:UnregisterAllEvents()
			ob:SetAttribute("statehidden", true)
		end 
	end 
	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(removalManager)
	local maxChildren = MainMenuBar:GetNumChildren();
	for i = 1, maxChildren do
		local child = select(i, MainMenuBar:GetChildren())
		if child then 
			child:UnregisterAllEvents()
			child:Hide()
			child:SetParent(removalManager)
		end 
	end 
	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(removalManager)
	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(removalManager)
	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(removalManager)
	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(removalManager)
	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(removalManager)
	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(removalManager)
	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(removalManager)
	IconIntroTracker:UnregisterAllEvents()
	IconIntroTracker:Hide()
	IconIntroTracker:SetParent(removalManager)
	
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetScale(0.0001)
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.00001)
	InterfaceOptionsStatusTextPanelXP:SetAlpha(0)
	InterfaceOptionsStatusTextPanelXP:SetScale(0.00001)
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function MOD:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:RefreshActionBars()
end
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
MOD.UpdateMicroButtons = MicroButton_OnUpdate

function MOD:ReLoad()
	self:RefreshActionBars();
end 

function MOD:Load()
	if not SV.db.SVBar.enable then return end 
	RemoveDefaults();
	
	self:UpdateBarPagingDefaults()

	CreateActionBars(self)
	CreateStanceBar(self)
	CreatePetBar(self)
	CreateMicroBar(self)
	CreateExtraBar(self)
	
	self:LoadKeyBinder()

	self:RegisterEvent("UPDATE_BINDINGS", "UpdateAllBindings")
	self:RegisterEvent("PET_BATTLE_CLOSE", "UpdateAllBindings")
	self:RegisterEvent("PET_BATTLE_OPENING_DONE", ResetAllBindings)
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", Vehicle_Updater)
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", Vehicle_Updater)
	if C_PetBattles.IsInBattle()then 
		ResetAllBindings(self)
	else 
		self:UpdateAllBindings()
	end 
	NewHook("BlizzardOptionsPanel_OnEvent", SVUIOptionsPanel_OnEvent)
	NewHook("ActionButton_ShowOverlayGlow", SVUIButton_ShowOverlayGlow)
	if not GetCVarBool("lockActionBars") then SetCVar("lockActionBars", 1) end 
	SetSpellFlyoutHook()

	self.IsLoaded = true
end