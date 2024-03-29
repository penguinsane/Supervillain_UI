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
--LUA
local unpack        = unpack;
local select        = select;
local pairs         = pairs;
local type          = type;
local rawset        = rawset;
local rawget        = rawget;
local tostring      = tostring;
local error         = error;
local next          = next;
local pcall         = pcall;
local getmetatable  = getmetatable;
local setmetatable  = setmetatable;
local assert        = assert;
--BLIZZARD
local _G            = _G;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local format        = string.format;
local sub           = string.sub;
local upper         = string.upper;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = math;
local numMin        = math.min;
--TABLE
local table         = table;
local tsort         = table.sort;
local tremove       = table.remove;

local SV = select(2, ...)
local oUF_Villain = SV.oUF

assert(oUF_Villain, "SVUI was unable to locate oUF.")

local L = SV.L;
local MOD = SV.SVUnit

if(not MOD) then return end 
--[[ 
########################################################## 
LOCAL DATA
##########################################################
]]--
local sortMapping = {
    ["DOWN_RIGHT"] = {[1]="TOP",[2]="TOPLEFT",[3]="LEFT",[4]=1,[5]=-1,[6]=false},
    ["DOWN_LEFT"] = {[1]="TOP",[2]="TOPRIGHT",[3]="RIGHT",[4]=1,[5]=-1,[6]=false},
    ["UP_RIGHT"] = {[1]="BOTTOM",[2]="BOTTOMLEFT",[3]="LEFT",[4]=1,[5]=1,[6]=false},
    ["UP_LEFT"] = {[1]="BOTTOM",[2]="BOTTOMRIGHT",[3]="RIGHT",[4]=-1,[5]=1,[6]=false},
    ["RIGHT_DOWN"] = {[1]="LEFT",[2]="TOPLEFT",[3]="TOP",[4]=1,[5]=-1,[6]=true},
    ["RIGHT_UP"] = {[1]="LEFT",[2]="BOTTOMLEFT",[3]="BOTTOM",[4]=1,[5]=1,[6]=true},
    ["LEFT_DOWN"] = {[1]="RIGHT",[2]="TOPRIGHT",[3]="TOP",[4]=-1,[5]=-1,[6]=true},
    ["LEFT_UP"] = {[1]="RIGHT",[2]="BOTTOMRIGHT",[3]="BOTTOM",[4]=-1,[5]=1,[6]=true},
    ["UP"] = {[1]="BOTTOM",[2]="BOTTOM",[3]="BOTTOM",[4]=1,[5]=1,[6]=false},
    ["DOWN"] = {[1]="TOP",[2]="TOP",[3]="TOP",[4]=1,[5]=1,[6]=false},
}
local GroupDistributor = {
    ["CLASS"] = function(x)
        x:SetAttribute("groupingOrder","DEATHKNIGHT,DRUID,HUNTER,MAGE,PALADIN,PRIEST,SHAMAN,WARLOCK,WARRIOR,MONK")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","CLASS")
    end,
    ["MTMA"] = function(x)
        x:SetAttribute("groupingOrder","MAINTANK,MAINASSIST,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ROLE")
    end,
    ["ROLE_TDH"] = function(x)
        x:SetAttribute("groupingOrder","TANK,DAMAGER,HEALER,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["ROLE_HTD"] = function(x)
        x:SetAttribute("groupingOrder","HEALER,TANK,DAMAGER,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["ROLE_HDT"] = function(x)
        x:SetAttribute("groupingOrder","HEALER,DAMAGER,TANK,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["ROLE"] = function(x)
        x:SetAttribute("groupingOrder","TANK,HEALER,DAMAGER,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["NAME"] = function(x)
        x:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy",nil)
    end,
    ["GROUP"] = function(x)
        x:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
        x:SetAttribute("sortMethod","INDEX")
        x:SetAttribute("groupBy","GROUP")
    end,
    ["PETNAME"] = function(x)
        x:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy", nil)
        x:SetAttribute("filterOnPet", true)
    end
}
--[[
##########################################################
FRAME HELPERS
##########################################################
]]--
local DetachSubFrames = function(...)
    for i = 1, select("#", ...) do 
        local frame = select(i,...)
        frame:ClearAllPoints()
    end 
end

local UpdateTargetGlow = function(self)
    if not self.unit then return end 
    local unit = self.unit;
    if(UnitIsUnit(unit, "target")) then 
        self.TargetGlow:Show()
        local reaction = UnitReaction(unit, "player")
        if(UnitIsPlayer(unit)) then 
            local _, class = UnitClass(unit)
            if class then 
                local colors = RAID_CLASS_COLORS[class]
                self.TargetGlow:SetBackdropBorderColor(colors.r, colors.g, colors.b)
            else 
                self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
            end 
        elseif(reaction) then 
            local colors = FACTION_BAR_COLORS[reaction]
            self.TargetGlow:SetBackdropBorderColor(colors.r, colors.g, colors.b)
        else 
            self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
        end 
    else 
        self.TargetGlow:Hide()
    end 
end
--[[
##########################################################
TEMPLATES AND PROTOTYPES
##########################################################
]]--
local BuildTemplates = {};
local UpdateTemplates = {};
--[[ 
########################################################## 
COMMON
##########################################################
]]--
local AllowElement = function(self)
    if InCombatLockdown() then return; end
    
    if not self.isForced then 
        self.sourceElement = self.unit;
        self.unit = "player"
        self.isForced = true;
        self.sourceEvent = self:GetScript("OnUpdate")
    end

    self:SetScript("OnUpdate", nil)
    self.forceShowAuras = true;

    UnregisterUnitWatch(self)
    RegisterUnitWatch(self, true)

    self:Show()
    if self:IsVisible() and self.Update then 
        self:Update()
    end 
end

local RestrictElement = function(self)
    if(InCombatLockdown() or (not self.isForced)) then return; end

    self.forceShowAuras = nil
    self.isForced = nil

    UnregisterUnitWatch(self)
    RegisterUnitWatch(self)

    if self.sourceEvent then 
        self:SetScript("OnUpdate", self.sourceEvent)
        self.sourceEvent = nil 
    end

    self.unit = self.sourceElement or self.unit;

    if self:IsVisible() and self.Update then 
        self:Update()
    end 
end
--[[ 
########################################################## 
PARTY FRAMES
##########################################################
]]--
local PartyUnitUpdate = function(self)
    local db = SV.db.SVUnit.party
    self.colors = oUF_Villain.colors;
    self:RegisterForClicks(SV.db.SVUnit.fastClickTarget and 'AnyDown' or 'AnyUp')
    MOD.RefreshUnitMedia(self, "party")
    if self.isChild then 
        local altDB = db.petsGroup;
        if self == _G[self.originalParent:GetName()..'Target'] then 
            altDB = db.targetsGroup 
        end 
        if not self.originalParent.childList then 
            self.originalParent.childList = {}
        end 
        self.originalParent.childList[self] = true;
        if not InCombatLockdown()then 
            if altDB.enable then
                local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(altDB, "partychild") 
                self:SetParent(self.originalParent)
                self:Size(UNIT_WIDTH, UNIT_HEIGHT)
                self:ClearAllPoints()
                SV:SetReversePoint(self, altDB.anchorPoint, self.originalParent, altDB.xOffset, altDB.yOffset)
            else 
                self:SetParent(SV.Screen.Hidden)
            end 
        end 
        do 
            local health = self.Health;
            health.Smooth = nil;
            health.frequentUpdates = nil;
            health.colorSmooth = nil;
            health.colorHealth = nil;
            health.colorClass = true;
            health.colorReaction = true;
            health:ClearAllPoints()
            health:Point("TOPRIGHT", self, "TOPRIGHT", -1, -1)
            health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
        end 
        do 
            local nametext = self.InfoPanel.Name
            self:Tag(nametext, altDB.tags)
        end 
    else 
        if not InCombatLockdown() then
            local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db, "party")
            self:Size(UNIT_WIDTH, UNIT_HEIGHT) 
        end 
        MOD:RefreshUnitLayout(self, "party")
        MOD:UpdateAuraWatch(self, "party")
    end 
    self:EnableElement('ReadyCheck')
    self:UpdateAllElements()
end

UpdateTemplates["party"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.SVUnit.party
    local groupFrame = self:GetParent()

    if not groupFrame.positioned then 
        groupFrame:ClearAllPoints()
        groupFrame:Point("BOTTOMLEFT", SV.Dock.BottomLeft, "TOPLEFT", 0, 80)
        RegisterStateDriver(groupFrame, "visibility", "[group:raid][nogroup] hide;show")
        SV.Mentalo:Add(groupFrame, L['Party Frames'], nil, nil, nil, 'ALL,PARTY,ARENA');
        groupFrame.positioned = true;
    end

    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]
        
        if(petFrame) then 
            petFrame:UnitUpdate()
        end

        if(targetFrame) then 
            targetFrame:UnitUpdate()
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

BuildTemplates["party"] = function(self, unit)
    self.unit = unit
    self.___key = "party"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    MOD:SetActionPanel(self, "party")
    self.Health = MOD:CreateHealthBar(self, true)

    if self.isChild then 
        self.originalParent = self:GetParent()
    else
        self.Power = MOD:CreatePowerBar(self, true)
        self.Power.frequentUpdates = false
        MOD:CreatePortrait(self, true)
        self.Buffs = MOD:CreateBuffs(self, "party")
        self.Debuffs = MOD:CreateDebuffs(self, "party")
        self.AuraWatch = MOD:CreateAuraWatch(self, "party")
        self.Afflicted = MOD:CreateAfflicted(self)
        self.ResurrectIcon = MOD:CreateResurectionIcon(self)
        self.LFDRole = MOD:CreateRoleIcon(self)
        self.RaidRoleFramesAnchor = MOD:CreateRaidRoleFrames(self)
        self.RaidIcon = MOD:CreateRaidIcon(self)
        self.ReadyCheck = MOD:CreateReadyCheckIcon(self)
        self.HealPrediction = MOD:CreateHealPrediction(self)
        --self.GPS = MOD:CreateGPS(self, true)

        local shadow = CreateFrame("Frame", nil, self)
        shadow:SetFrameLevel(1)
        shadow:SetFrameStrata(self:GetFrameStrata())
        shadow:WrapOuter(self, 3, 3)
        shadow:SetBackdrop({
            edgeFile = [[Interface\AddOns\SVUI\assets\artwork\Template\GLOW]], 
            edgeSize = 3, 
            insets = {
                left = 5, 
                right = 5, 
                top = 5, 
                bottom = 5
            }
        })
        shadow:SetBackdropColor(0, 0, 0, 0)
        shadow:SetBackdropBorderColor(0, 0, 0, 0.9)
        shadow:Hide()
        self.TargetGlow = shadow
        tinsert(self.__elements, UpdateTargetGlow)
        self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
        self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)
        self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateTargetGlow)
    end 

    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = PartyUnitUpdate

    return self 
end
--[[ 
########################################################## 
RAID FRAMES
##########################################################
]]--
local RaidUnitUpdate = function(self)
    local token = self.___key
    local db = SV.db.SVUnit[token]
    self.colors = oUF_Villain.colors;
    self:RegisterForClicks(SV.db.SVUnit.fastClickTarget and "AnyDown" or "AnyUp")

    local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db)
    if not InCombatLockdown() then 
        self:Size(UNIT_WIDTH, UNIT_HEIGHT) 
    end 

    do
        local rdBuffs = self.RaidDebuffs;
        if db.rdebuffs.enable then
            if not self:IsElementEnabled('RaidDebuffs') then
                self:EnableElement("RaidDebuffs")
            end
            local actualSz = numMin(db.rdebuffs.size, (UNIT_HEIGHT - 8))
            rdBuffs:Size(actualSz)
            rdBuffs:Point("CENTER", self, "CENTER", db.rdebuffs.xOffset, db.rdebuffs.yOffset)
            rdBuffs:Show()
        else 
            self:DisableElement("RaidDebuffs")
            rdBuffs:Hide()
        end 
    end

    MOD.RefreshUnitMedia(self, token)
    MOD:UpdateAuraWatch(self, token)
    MOD:RefreshUnitLayout(self, token)

    if(token ~= "raidpet") then
        self:EnableElement("ReadyCheck")
    end
    self:UpdateAllElements()
end

UpdateTemplates["raid"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.SVUnit.raid
    local groupFrame = self:GetParent()

    if not groupFrame.positioned then
        groupFrame:ClearAllPoints()
        groupFrame:Point("BOTTOMLEFT", SV.Dock.BottomLeft, "TOPLEFT", 0, 80)
        RegisterStateDriver(groupFrame, "visibility", "[group:raid] show; hide")
        SV.Mentalo:Add(groupFrame, "Raid Frames")
        groupFrame.positioned = true 
    end

    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]
        
        if(petFrame) then 
            petFrame:UnitUpdate()
        end

        if(targetFrame) then 
            targetFrame:UnitUpdate()
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

BuildTemplates["raid"] = function(self, unit)
    self.unit = unit
    self.___key = "raid"
    MOD:SetActionPanel(self, "raid")
    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.frequentUpdates = false
    self.Power = MOD:CreatePowerBar(self, true)
    self.Power.frequentUpdates = false
    self.Buffs = MOD:CreateBuffs(self, "raid")
    self.Debuffs = MOD:CreateDebuffs(self, "raid")
    self.AuraWatch = MOD:CreateAuraWatch(self, "raid")
    self.RaidDebuffs = MOD:CreateRaidDebuffs(self)
    self.Afflicted = MOD:CreateAfflicted(self)
    self.ResurrectIcon = MOD:CreateResurectionIcon(self)
    self.LFDRole = MOD:CreateRoleIcon(self)
    self.RaidRoleFramesAnchor = MOD:CreateRaidRoleFrames(self)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.ReadyCheck = MOD:CreateReadyCheckIcon(self)
    self.HealPrediction = MOD:CreateHealPrediction(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = RaidUnitUpdate

    local shadow = CreateFrame("Frame", nil, self)
    shadow:SetFrameLevel(1)
    shadow:SetFrameStrata(self:GetFrameStrata())
    shadow:WrapOuter(self, 3, 3)
    shadow:SetBackdrop({
        edgeFile = [[Interface\AddOns\SVUI\assets\artwork\Template\GLOW]], 
        edgeSize = 3, 
        insets = {
            left = 5, 
            right = 5, 
            top = 5, 
            bottom = 5
        }
    })
    shadow:SetBackdropColor(0, 0, 0, 0)
    shadow:SetBackdropBorderColor(0, 0, 0, 0.9)
    shadow:Hide()
    self.TargetGlow = shadow

    tinsert(self.__elements, UpdateTargetGlow)

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)

    return self
end
--[[ 
########################################################## 
RAID PETS
##########################################################
]]--
UpdateTemplates["raidpet"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.SVUnit.raidpet
    local groupFrame = self:GetParent()

    if not groupFrame.positioned then 
        groupFrame:ClearAllPoints()
        groupFrame:Point("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", 4, 433)
        RegisterStateDriver(groupFrame, "visibility", "[group:raid] show; hide")
        SV.Mentalo:Add(groupFrame, L["Raid Pet Frames"], nil, nil, nil, "ALL, RAID10, RAID25, RAID40")
        groupFrame.positioned = true;
    end 

    RaidPetVisibility(groupFrame)

    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]
        
        if(petFrame) then 
            petFrame:UnitUpdate()
        end

        if(targetFrame) then 
            targetFrame:UnitUpdate()
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

BuildTemplates["raidpet"] = function(self, unit)
    self.unit = unit
    self.___key = "raidpet"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    MOD:SetActionPanel(self, "raidpet")
    self.Health = MOD:CreateHealthBar(self, true)
    self.Debuffs = MOD:CreateDebuffs(self, "raidpet")
    self.AuraWatch = MOD:CreateAuraWatch(self, "raidpet")
    self.RaidDebuffs = MOD:CreateRaidDebuffs(self)
    self.Afflicted = MOD:CreateAfflicted(self)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = RaidUnitUpdate

    local shadow = CreateFrame("Frame", nil, self)
    shadow:SetFrameLevel(1)
    shadow:SetFrameStrata(self:GetFrameStrata())
    shadow:WrapOuter(self, 3, 3)
    shadow:SetBackdrop({
        edgeFile = [[Interface\AddOns\SVUI\assets\artwork\Template\GLOW]], 
        edgeSize = 3, 
        insets = {
            left = 5, 
            right = 5, 
            top = 5, 
            bottom = 5
        }
    })
    shadow:SetBackdropColor(0, 0, 0, 0)
    shadow:SetBackdropBorderColor(0, 0, 0, 0.9)
    shadow:Hide()
    self.TargetGlow = shadow
    tinsert(self.__elements, UpdateTargetGlow)

    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)
    return self 
end
--[[ 
########################################################## 
TANK
##########################################################
]]--
local TankUnitUpdate = function(self)
    local db = SV.db.SVUnit.tank
    self.colors = oUF_Villain.colors;
    self:RegisterForClicks(SV.db.SVUnit.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "tank")
    if self.isChild and self.originalParent then 
        local targets = db.targetsGroup;
        if not self.originalParent.childList then 
            self.originalParent.childList = {}
        end 
        self.originalParent.childList[self] = true;
        if not InCombatLockdown()then 
            if targets.enable then
                local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(targets)
                self:SetParent(self.originalParent)
                self:Size(UNIT_WIDTH, UNIT_HEIGHT)
                self:ClearAllPoints()
                SV:SetReversePoint(self, targets.anchorPoint, self.originalParent, targets.xOffset, targets.yOffset)
            else 
                self:SetParent(SV.Screen.Hidden)
            end 
        end 
    elseif not InCombatLockdown() then
        local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db)
        self:Size(UNIT_WIDTH, UNIT_HEIGHT)
    end 
    MOD:RefreshUnitLayout(self, "tank")
    do 
        local nametext = self.InfoPanel.Name;
        if oUF_Villain.colors.healthclass then 
            self:Tag(nametext, "[name:10]")
        else 
            self:Tag(nametext, "[name:color][name:10]")
        end 
    end 
    self:UpdateAllElements()
end

UpdateTemplates["tank"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.SVUnit.tank

    if db.enable ~= true then 
        UnregisterAttributeDriver(self, "state-visibility")
        self:Hide()
        return 
    end

    self:Hide()
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("startingIndex", -1)
    RegisterAttributeDriver(self, "state-visibility", "show")
    self.dirtyWidth, self.dirtyHeight = self:GetSize()
    RegisterAttributeDriver(self, "state-visibility", "[@raid1, exists] show;hide")
    self:SetAttribute("startingIndex", 1)
    self:SetAttribute("point", "BOTTOM")
    self:SetAttribute("columnAnchorPoint", "LEFT")
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("yOffset", 7)

    if not self.positioned then 
        self:ClearAllPoints()
        self:Point("BOTTOMLEFT", SV.Dock.TopLeft, "BOTTOMLEFT", 0, 0)
        SV.Mentalo:Add(self, L["Tank Frames"], nil, nil, nil, "ALL, RAID10, RAID25, RAID40")
        self.Avatar.positionOverride = "TOPLEFT"
        self:SetAttribute("minHeight", self.dirtyHeight)
        self:SetAttribute("minWidth", self.dirtyWidth)
        self.positioned = true 
    end

    local childFrame, childName, petFrame, targetFrame
    for i = 1, self:GetNumChildren() do 
        childFrame = select(i, self:GetChildren())
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then 
            petFrame:UnitUpdate()
        end
        if(targetFrame) then 
            targetFrame:UnitUpdate()
        end
    end
end

BuildTemplates["tank"] = function(self, unit)
    local db = SV.db.SVUnit.tank
    self.unit = unit
    self.___key = "tank"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    MOD:SetActionPanel(self, "tank")
    self.Health = MOD:CreateHealthBar(self, true)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.RaidIcon:SetPoint("BOTTOMRIGHT")

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = TankUnitUpdate

    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self.originalParent = self:GetParent()

    self:UnitUpdate()
    return self 
end
--[[ 
########################################################## 
ASSIST
##########################################################
]]--
local AssistUnitUpdate = function(self)
    local db = SV.db.SVUnit.assist
    self.colors = oUF_Villain.colors;
    self:RegisterForClicks(SV.db.SVUnit.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "assist")
    if self.isChild and self.originalParent then 
        local targets = db.targetsGroup;
        if not self.originalParent.childList then 
            self.originalParent.childList = {}
        end 
        self.originalParent.childList[self] = true;
        if not InCombatLockdown()then 
            if targets.enable then
                local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(targets)
                self:SetParent(self.originalParent)
                self:Size(UNIT_WIDTH, UNIT_HEIGHT)
                self:ClearAllPoints()
                SV:SetReversePoint(self, targets.anchorPoint, self.originalParent, targets.xOffset, targets.yOffset)
            else 
                self:SetParent(SV.Screen.Hidden)
            end 
        end 
    elseif not InCombatLockdown() then
        local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db)
        self:Size(UNIT_WIDTH, UNIT_HEIGHT)
    end 

    MOD:RefreshUnitLayout(self, "assist")

    do 
        local nametext = self.InfoPanel.Name;
        if oUF_Villain.colors.healthclass then 
            self:Tag(nametext, "[name:10]")
        else 
            self:Tag(nametext, "[name:color][name:10]")
        end 
    end 
    self:UpdateAllElements()
end

UpdateTemplates["assist"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.SVUnit.assist

    self:Hide()
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("startingIndex", -1)
    RegisterAttributeDriver(self, "state-visibility", "show")
    self.dirtyWidth, self.dirtyHeight = self:GetSize()
    RegisterAttributeDriver(self, "state-visibility", "[@raid1, exists] show;hide")
    self:SetAttribute("startingIndex", 1)
    self:SetAttribute("point", "BOTTOM")
    self:SetAttribute("columnAnchorPoint", "LEFT")
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("yOffset", 7)

    if not self.positioned then 
        self:ClearAllPoints()
        self:Point("TOPLEFT", SV.Dock.TopLeft, "BOTTOMLEFT", 0, -10)
        SV.Mentalo:Add(self, L["Assist Frames"], nil, nil, nil, "ALL, RAID10, RAID25, RAID40")
        self.Avatar.positionOverride = "TOPLEFT"
        self:SetAttribute("minHeight", self.dirtyHeight)
        self:SetAttribute("minWidth", self.dirtyWidth)
        self.positioned = true 
    end

    local childFrame, childName, petFrame, targetFrame
    for i = 1, self:GetNumChildren() do 
        childFrame = select(i, self:GetChildren())
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then 
            petFrame:UnitUpdate()
        end
        if(targetFrame) then 
            targetFrame:UnitUpdate()
        end
    end
end

BuildTemplates["assist"] = function(self, unit)
    local db = SV.db.SVUnit.assist
    self.unit = unit
    self.___key = "assist"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    MOD:SetActionPanel(self, "assist")
    self.Health = MOD:CreateHealthBar(self, true)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.RaidIcon:SetPoint("BOTTOMRIGHT")
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = AssistUnitUpdate

    self.originalParent = self:GetParent()

    self:UnitUpdate()
    return self 
end
--[[
##########################################################
HEADER CONSTRUCTS
##########################################################
]]--
local HeaderMediaUpdate = function(self)
    local token = self.___groupkey
    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        MOD.RefreshUnitMedia(childFrame, token)
        
        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]
        
        if(petFrame) then 
            MOD.RefreshUnitMedia(petFrame, token)
        end

        if(targetFrame) then 
            MOD.RefreshUnitMedia(targetFrame, token)
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

local HeaderUnsetAttributes = function(self)
    self:Hide()
    self:SetAttribute("showPlayer", true)
    self:SetAttribute("showSolo", true)
    self:SetAttribute("showParty", true)
    self:SetAttribute("showRaid", true)
    self:SetAttribute("columnSpacing", nil)
    self:SetAttribute("columnAnchorPoint", nil)
    self:SetAttribute("sortMethod", nil)
    self:SetAttribute("groupFilter", nil)
    self:SetAttribute("groupingOrder", nil)
    self:SetAttribute("maxColumns", nil)
    self:SetAttribute("nameList", nil)
    self:SetAttribute("point", nil)
    self:SetAttribute("sortDir", nil)
    self:SetAttribute("sortMethod", "NAME")
    self:SetAttribute("startingIndex", nil)
    self:SetAttribute("strictFiltering", nil)
    self:SetAttribute("unitsPerColumn", nil)
    self:SetAttribute("xOffset", nil)
    self:SetAttribute("yOffset", nil)
end

local HeaderEnableChildren = function(self)
    self.isForced = true;
    for i=1, select("#", self:GetChildren()) do
        local childFrame = select(i, self:GetChildren())
        if(childFrame and childFrame.RegisterForClicks) then
            childFrame:RegisterForClicks(nil)
            childFrame:SetID(i)
            childFrame.TargetGlow:SetAlpha(0)
            childFrame:Allow()
        end
    end  
end

local HeaderDisableChildren = function(self)
    self.isForced = nil;
    for i=1, select("#", self:GetChildren()) do 
        local childFrame = select(i, self:GetChildren())
        if(childFrame and childFrame.RegisterForClicks) then
            childFrame:RegisterForClicks(SV.db.SVUnit.fastClickTarget and 'AnyDown' or 'AnyUp')
            childFrame.TargetGlow:SetAlpha(1)
            childFrame:Restrict()
        end
    end 
end

function MOD:SetGroupHeader(parentFrame, filter, layout, headerName, token)
    local db = SV.db.SVUnit[token]

    local template1, template2
    if(token == "raidpet") then
        template1 = "SVUI_UNITPET"
        template2 = "SecureGroupPetHeaderTemplate"
    elseif(token == "tank") then
        filter = "MAINTANK"
        template1 = "SVUI_UNITTARGET"
    elseif(token == "assist") then
        filter = "MAINASSIST"
        template1 = "SVUI_UNITTARGET"
    end

    local UNIT_WIDTH, UNIT_HEIGHT = self:GetActiveSize(db)
    local groupHeader = oUF_Villain:SpawnHeader(headerName, template2, nil, 
        "oUF-initialConfigFunction", ("self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)"):format(UNIT_WIDTH, UNIT_HEIGHT), 
        "groupFilter", filter, 
        "showParty", true, 
        "showRaid", true, 
        "showSolo", true, 
        template1 and "template", template1
    )
    groupHeader.___groupkey = token
    groupHeader:SetParent(parentFrame)
    groupHeader.Update = UpdateTemplates[token]
    groupHeader.MediaUpdate = HeaderMediaUpdate
    groupHeader.UnsetAttributes = HeaderUnsetAttributes
    groupHeader.EnableChildren = HeaderEnableChildren
    groupHeader.DisableChildren = HeaderDisableChildren

    return groupHeader 
end
--[[
##########################################################
GROUP CONSTRUCTS
##########################################################
]]--
local GroupUpdate = function(self)
    local token = self.___groupkey
    if SV.db.SVUnit[token].enable ~= true then 
        UnregisterAttributeDriver(self, "state-visibility")
        self:Hide()
        return 
    end
    for i=1,#self.groups do
        self.groups[i]:Update()
    end 
end

local GroupMediaUpdate = function(self)
    for i=1,#self.groups do
        self.groups[i]:MediaUpdate()
    end
end

local GroupSetVisibility = function(self)
    if not self.isForced then
        local token = self.___groupkey
        local db = SV.db.SVUnit[token]
        if(db) then
            for i=1,#self.groups do
                local frame = self.groups[i]
                if(i <= db.groupCount) then
                    frame:Show()
                else 
                    if frame.forceShow then 
                        frame:Hide()
                        frame:DisableChildren()
                        frame:SetAttribute('startingIndex',1)
                    else 
                        frame:UnsetAttributes()
                    end 
                end
            end
        end 
    end 
end

local GroupConfigure = function(self)
    local token = self.___groupkey
    local settings = SV.db.SVUnit[token]
    local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(settings)
    local sorting = settings.showBy
    local sortMethod = settings.sortMethod
    local widthCalc, heightCalc, xCalc, yCalc = 0, 0, 0, 0;
    local point, anchorPoint, columnAnchor, horizontal, vertical, isHorizontal = unpack(sortMapping[sorting]);
    local groupCount = settings.groupCount

    self.groupCount = groupCount

    for i = 1, groupCount do

        local frame = self.groups[i]

        if(frame) then
            if(settings.showBy == "UP") then 
                settings.showBy = "UP_RIGHT"
            end

            if(settings.showBy == "DOWN") then 
                settings.showBy = "DOWN_RIGHT"
            end

            if(isHorizontal) then 
                frame:SetAttribute("xOffset", settings.wrapXOffset * horizontal)
                frame:SetAttribute("yOffset", 0)
                frame:SetAttribute("columnSpacing", settings.wrapYOffset)
            else 
                frame:SetAttribute("xOffset", 0)
                frame:SetAttribute("yOffset", settings.wrapYOffset * vertical)
                frame:SetAttribute("columnSpacing", settings.wrapXOffset)
            end

            if(not frame.isForced) then 
                if not frame.initialized then 
                    frame:SetAttribute("startingIndex", -4)
                    frame:Show()
                    frame.initialized = true 
                end
                frame:SetAttribute("startingIndex", 1)
            end

            frame:ClearAllPoints()
            frame:SetAttribute("columnAnchorPoint", columnAnchor)

            DetachSubFrames(frame:GetChildren())

            frame:SetAttribute("point", point)

            if(not frame.isForced) then
                frame:SetAttribute("maxColumns", 1)
                frame:SetAttribute("unitsPerColumn", 5)
                GroupDistributor[sortMethod](frame)
                frame:SetAttribute("sortDir", settings.sortDir)
                frame:SetAttribute("showPlayer", settings.showPlayer)
            end

            frame:SetAttribute("groupFilter", tostring(i))
        end

        if (i - 1) % settings.gRowCol == 0 then 
            if isHorizontal then 
                if(frame) then 
                    frame:SetPoint(anchorPoint, self, anchorPoint, 0, heightCalc * vertical)
                end

                heightCalc = heightCalc + UNIT_HEIGHT + settings.wrapYOffset;
                yCalc = yCalc + 1 
            else 
                if(frame) then frame:SetPoint(anchorPoint, self, anchorPoint, widthCalc * horizontal, 0) end

                widthCalc = widthCalc + UNIT_WIDTH + settings.wrapXOffset;
                xCalc = xCalc + 1 
            end 
        else
            if isHorizontal then 
                if yCalc == 1 then 
                    if(frame) then 
                        frame:SetPoint(anchorPoint, self, anchorPoint, widthCalc * horizontal, 0)
                    end

                    widthCalc = widthCalc + (UNIT_WIDTH + settings.wrapXOffset) * 5;
                    xCalc = xCalc + 1 
                elseif(frame) then 
                    frame:SetPoint(anchorPoint, self, anchorPoint, (((UNIT_WIDTH + settings.wrapXOffset) * 5) * ((i - 1) % settings.gRowCol)) * horizontal, ((UNIT_HEIGHT + settings.wrapYOffset) * (yCalc - 1)) * vertical)
                end 
            else 
                if xCalc == 1 then 
                    if(frame) then 
                        frame:SetPoint(anchorPoint, self, anchorPoint, 0, heightCalc * vertical)
                    end

                    heightCalc = heightCalc + (UNIT_HEIGHT + settings.wrapYOffset) * 5;
                    yCalc = yCalc + 1 
                elseif(frame) then 
                    frame:SetPoint(anchorPoint, self, anchorPoint, ((UNIT_WIDTH + settings.wrapXOffset) * (xCalc - 1)) * horizontal, (((UNIT_HEIGHT + settings.wrapYOffset) * 5) * ((i - 1) % settings.gRowCol)) * vertical)
                end 
            end 
        end

        if heightCalc == 0 then 
            heightCalc = heightCalc + (UNIT_HEIGHT + settings.wrapYOffset) * 5 
        elseif widthCalc == 0 then 
            widthCalc = widthCalc + (UNIT_WIDTH + settings.wrapXOffset) * 5 
        end 
    end

    self:SetSize(widthCalc - settings.wrapXOffset, heightCalc - settings.wrapYOffset)
end

function MOD:GetGroupFrame(token, layout)
    if(not self.Headers[token]) then 
        oUF_Villain:RegisterStyle(layout, BuildTemplates[token])
        oUF_Villain:SetActiveStyle(layout)
        local groupFrame = CreateFrame("Frame", layout, SVUI_UnitFrameParent, "SecureHandlerStateTemplate")
        groupFrame.___groupkey = token;
        groupFrame.groups = {}
        groupFrame.Update = GroupUpdate
        groupFrame.MediaUpdate = GroupMediaUpdate
        groupFrame.SetVisibility = GroupSetVisibility
        groupFrame.Configure = GroupConfigure

        groupFrame:Show()
        self.Headers[token] = groupFrame
    end
    return self.Headers[token]
end

function MOD:SetCustomFrame(token, layout)
    if(not self.Headers[token]) then 
        oUF_Villain:RegisterStyle(layout, BuildTemplates[token])
        oUF_Villain:SetActiveStyle(layout)
        local groupFrame = self:SetGroupHeader(SVUI_UnitFrameParent, nil, layout, layout, token)
        self.Headers[token] = groupFrame
    end
    self.Headers[token]:Show()
    self.Headers[token]:Update()
end

function MOD:SetGroupFrame(token, forceUpdate)
    if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
    if(not SV.db.SVUnit.enable) then return end
    local settings = SV.db.SVUnit[token]
    local realName = token:gsub("(.)", upper, 1)
    local layout = "SVUI_"..realName

    if(token == "tank" or token == "assist") then
        return self:SetCustomFrame(token, layout)
    end

    local groupFrame = self:GetGroupFrame(token, layout)

    if(token ~= "raidpet" and settings.enable ~= true) then
        UnregisterStateDriver(groupFrame, "visibility")
        groupFrame:Hide()
        return 
    end

    local groupName
    for i = 1, settings.groupCount do
        if(not groupFrame.groups[i]) then
            groupName = layout .. "Group" .. i
            groupFrame.groups[i] = self:SetGroupHeader(groupFrame, i, layout, groupName, token)
            groupFrame.groups[i]:Show()
        end
    end

    groupFrame:SetVisibility()

    if(forceUpdate or not groupFrame.Avatar) then 
        groupFrame:Configure()
        if(not groupFrame.isForced and settings.visibility) then 
            RegisterStateDriver(groupFrame, "visibility", settings.visibility)
        end 
    else 
        groupFrame:Configure()
        groupFrame:Update()
    end

    if(token == "raidpet" and settings.enable ~= true) then 
        UnregisterStateDriver(groupFrame, "visibility")
        groupFrame:Hide()
        return 
    end
end