-- ============================================================================
-- InteractMod - Focus Targets (1..9, 3x3 Grid) & Party/Raid Leader Addon Sync
-- Compatible with Vanilla WoW 1.12.1 (Lua 5.0)
-- ============================================================================

local IA = InteractAddon
local CMD_FOCUS_SET        = IA.CMD_FOCUS_SET
local CMD_FOCUS_CLEAR      = IA.CMD_FOCUS_CLEAR
local CMD_FOCUS_TARGET     = IA.CMD_FOCUS_TARGET
local CMD_FOCUS_SWAP       = IA.CMD_FOCUS_SWAP
local CMD_FOCUS_RESTORE    = IA.CMD_FOCUS_RESTORE
local CMD_FOCUS_QUERY      = IA.CMD_FOCUS_QUERY
local CMD_FOCUS_TARGET_TOT = IA.CMD_FOCUS_TARGET_TOT
local CMD_FOCUS_SET_GUID       = IA.CMD_FOCUS_SET_GUID
local CMD_FOCUS_GET_GUID       = IA.CMD_FOCUS_GET_GUID
local CMD_FOCUS_POPULATE_MARKS = IA.CMD_FOCUS_POPULATE_MARKS
local EnsureDB                 = IA.EnsureDB
local PrintMsg             = IA.PrintMsg
local SetConfigValue       = IA.SetConfigValue

local MAX_FOCUS_SLOTS      = 9
local FOCUS_ADDON_PREFIX   = 'IM_FOCUS'
local focusSlots = {}

local function CreateFocusSlotFrame(slot)
   local suffix = (slot == 1) and '' or tostring(slot)
   local f = CreateFrame('Button', 'InteractFocusFrame' .. suffix, UIParent)
   f:SetWidth(232)
   f:SetHeight(100)
   f:SetPoint('CENTER', UIParent, 'CENTER', -260, 120)
   if slot == 1 then
      f:SetMovable(true)
   end
   f:RegisterForDrag('LeftButton')
   f:EnableMouse(true)
   f:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
   f:Hide()

   local portrait = f:CreateTexture('InteractFocusPortrait' .. suffix, 'BACKGROUND')
   portrait:SetWidth(58)
   portrait:SetHeight(58)
   portrait:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -42, -12)
   SetPortraitToTexture(portrait, 'Interface\\Icons\\Ability_Tracking')

   local nameBG = f:CreateTexture('InteractFocusNameBG' .. suffix, 'BORDER')
   nameBG:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground')
   nameBG:SetWidth(119)
   nameBG:SetHeight(19)
   nameBG:SetPoint('TOPLEFT', f, 'TOPLEFT', 7, -22)

   local hp = CreateFrame('StatusBar', 'InteractFocusHealthBar' .. suffix, f)
   hp:SetWidth(119)
   hp:SetHeight(12)
   hp:SetPoint('TOPLEFT', f, 'TOPLEFT', 7, -41)
   hp:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
   hp:SetStatusBarColor(0, 1, 0)
   hp:SetMinMaxValues(0, 1)
   hp:SetValue(1)

   local mana = CreateFrame('StatusBar', 'InteractFocusManaBar' .. suffix, f)
   mana:SetWidth(119)
   mana:SetHeight(12)
   mana:SetPoint('TOPLEFT', f, 'TOPLEFT', 7, -52)
   mana:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
   mana:SetStatusBarColor(0, 0, 1)
   mana:SetMinMaxValues(0, 1)
   mana:SetValue(1)

   local border = f:CreateTexture('InteractFocusBorder' .. suffix, 'ARTWORK')
   border:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame')
   border:SetTexCoord(0.09375, 1.0, 0, 0.78125)
   border:SetWidth(232)
   border:SetHeight(100)
   border:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)

   local overlay = CreateFrame('Frame', nil, f)
   overlay:SetAllPoints(f)
   overlay:SetFrameLevel(f:GetFrameLevel() + 2)

   local borderGlow = overlay:CreateTexture('InteractFocusBorderGlow' .. suffix, 'ARTWORK')
   borderGlow:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame')
   borderGlow:SetTexCoord(0.09375, 1.0, 0, 0.78125)
   borderGlow:SetWidth(232)
   borderGlow:SetHeight(100)
   borderGlow:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
   borderGlow:SetBlendMode('ADD')
   borderGlow:SetVertexColor(1.0, 0.1, 0.1, 0.85)
   borderGlow:Hide()

   local nameText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
   nameText:SetPoint('CENTER', nameBG, 'CENTER', 0, 0)
   nameText:SetWidth(112)
   nameText:SetText('Focus ' .. slot)

   local hpText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
   hpText:SetPoint('CENTER', hp, 'CENTER', 0, 0)

   local manaText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
   manaText:SetPoint('CENTER', mana, 'CENTER', 0, 0)

   local levelText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
   levelText:SetPoint('CENTER', f, 'BOTTOMRIGHT', -53, 34)

   local distText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
   distText:SetPoint('TOPLEFT', f, 'TOPLEFT', 10, -7)
   distText:SetTextColor(0.85, 0.85, 0.85)

   local deadText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
   deadText:SetPoint('CENTER', hp, 'CENTER', 0, 0)
   deadText:Hide()

   local combatIcon = overlay:CreateTexture(nil, 'OVERLAY')
   combatIcon:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
   combatIcon:SetTexCoord(0.5, 1.0, 0.0, 0.5)
   combatIcon:SetWidth(24)
   combatIcon:SetHeight(24)
   combatIcon:SetPoint('CENTER', f, 'BOTTOMRIGHT', -53, 34)
   combatIcon:Hide()

   local raidIcon = overlay:CreateTexture(nil, 'OVERLAY')
   raidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
   raidIcon:SetWidth(24)
   raidIcon:SetHeight(24)
   raidIcon:SetPoint('CENTER', portrait, 'TOP', 0, 2)
   raidIcon:Hide()

   local tot = CreateFrame('Button', 'InteractFocusToTFrame' .. suffix, f)
   tot:SetWidth(93)
   tot:SetHeight(45)
   tot:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -35, -12)
   tot:EnableMouse(true)
   tot:RegisterForClicks('LeftButtonUp')
   local slotNum = slot
   tot:SetScript('OnClick', function()
      if type(InteractNearest) == 'function' then
         InteractNearest(CMD_FOCUS_TARGET_TOT, slotNum)
      end
   end)
   tot:Hide()

   local totPortrait = tot:CreateTexture(nil, 'BACKGROUND')
   totPortrait:SetWidth(35)
   totPortrait:SetHeight(35)
   totPortrait:SetPoint('TOPLEFT', tot, 'TOPLEFT', 5, -5)
   SetPortraitToTexture(totPortrait, 'Interface\\Icons\\INV_Misc_QuestionMark')

   local totHP = CreateFrame('StatusBar', 'InteractFocusToTHP' .. suffix, tot)
   totHP:SetWidth(46)
   totHP:SetHeight(7)
   totHP:SetPoint('TOPLEFT', tot, 'TOPLEFT', 42, -15)
   totHP:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
   totHP:SetStatusBarColor(0, 1, 0)
   totHP:SetMinMaxValues(0, 100)
   totHP:SetValue(100)

   local totBorder = tot:CreateTexture(nil, 'ARTWORK')
   totBorder:SetTexture('Interface\\TargetingFrame\\UI-TargetofTargetFrame')
   totBorder:SetTexCoord(0.015625, 0.7265625, 0, 0.703125)
   totBorder:SetWidth(93)
   totBorder:SetHeight(45)
   totBorder:SetPoint('TOPLEFT', tot, 'TOPLEFT', 0, 0)

   local totOverlay = CreateFrame('Frame', nil, tot)
   totOverlay:SetAllPoints(tot)
   totOverlay:SetFrameLevel(tot:GetFrameLevel() + 2)

   local totNameText = totOverlay:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
   totNameText:SetPoint('TOPLEFT', tot, 'TOPLEFT', 42, -2)
   totNameText:SetWidth(52)
   totNameText:SetJustifyH('LEFT')

   local cast = CreateFrame('StatusBar', 'InteractFocusCastBar' .. suffix, f)
   cast:SetWidth(150)
   cast:SetHeight(11)
   cast:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 12, -14)
   cast:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
   cast:SetStatusBarColor(1.0, 0.7, 0.0)
   cast:SetMinMaxValues(0, 1)
   cast:SetValue(0)
   cast:Hide()

   local castBG = cast:CreateTexture(nil, 'BACKGROUND')
   castBG:SetAllPoints(cast)
   castBG:SetTexture(0, 0, 0, 0.65)

   local castBorder = cast:CreateTexture(nil, 'OVERLAY')
   castBorder:SetTexture('Interface\\CastingBar\\UI-CastingBar-Border-Small')
   castBorder:SetWidth(197)
   castBorder:SetHeight(49)
   castBorder:SetPoint('CENTER', cast, 'CENTER', 0, 0)

   local castText = cast:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
   castText:SetPoint('CENTER', cast, 'CENTER', 0, 0)
   castText:SetWidth(142)

   local castIconTex = cast:CreateTexture(nil, 'ARTWORK')
   castIconTex:SetWidth(14)
   castIconTex:SetHeight(14)
   castIconTex:SetPoint('RIGHT', cast, 'LEFT', -4, 0)
   castIconTex:Hide()

   local compactBG = f:CreateTexture(nil, 'BACKGROUND')
   compactBG:SetAllPoints(f)
   compactBG:SetTexture(0.05, 0.05, 0.08, 0.85)
   compactBG:Hide()

   local alertFlash = CreateFrame('Frame', nil, overlay)
   alertFlash:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -9)
   alertFlash:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -34, 20)
   alertFlash:SetBackdrop({
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      edgeSize = 14,
   })
   alertFlash:SetBackdropBorderColor(1.0, 0.25, 0.1, 0.85)
   alertFlash:Hide()

   local alertFlashBG = alertFlash:CreateTexture(nil, 'BACKGROUND')
   alertFlashBG:SetPoint('TOPLEFT', nameBG, 'TOPLEFT', 0, 0)
   alertFlashBG:SetPoint('BOTTOMRIGHT', mana, 'BOTTOMRIGHT', 0, 0)
   alertFlashBG:SetTexture(1.0, 0.05, 0.05, 0.4)

   local auraFrames = {}
   for i = 1, 16 do
      local af = CreateFrame('Frame', 'InteractFocusAura' .. suffix .. '_' .. i, f)
      af:SetWidth(18)
      af:SetHeight(18)
      local row = (i <= 8) and 0 or 1
      local col = (i <= 8) and (i - 1) or (i - 9)
      af:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 8 + (col * 20), 14 - (row * 20))
      local tex = af:CreateTexture(nil, 'ARTWORK')
      tex:SetAllPoints(af)
      af.icon = tex
      local db = af:CreateTexture(nil, 'OVERLAY')
      db:SetTexture('Interface\\Buttons\\UI-Debuff-Overlays')
      db:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
      db:SetWidth(20)
      db:SetHeight(20)
      db:SetPoint('CENTER', af, 'CENTER', 0, 0)
      db:SetVertexColor(0.85, 0.1, 0.1)
      db:Hide()
      af.debuffBorder = db
      local cnt = af:CreateFontString(nil, 'OVERLAY', 'NumberFontNormalSmall')
      cnt:SetPoint('BOTTOMRIGHT', af, 'BOTTOMRIGHT', 1, -1)
      cnt:Hide()
      af.count = cnt
      af:Hide()
      auraFrames[i] = af
   end

   f:SetScript('OnDragStart', function()
      local unlocked = (InteractDB and InteractDB.config and not InteractDB.config.lockFocus)
      if unlocked or (InteractConfigFrame and InteractConfigFrame:IsVisible()) then
         local root = focusSlots[1] and focusSlots[1].frame
         if root then
            root:StartMoving()
         end
      end
   end)
   f:SetScript('OnDragStop', function()
      local root = focusSlots[1] and focusSlots[1].frame
      if not root then return end
      root:StopMovingOrSizing()
      local scale = root:GetScale() or 1
      local px, py = root:GetCenter()
      local ux, uy = UIParent:GetCenter()
      if px and py and ux and uy then
         local dx = math.floor((px * scale - ux) + 0.5)
         local dy = math.floor((py * scale - uy) + 0.5)
         SetConfigValue('focusX', dx)
         SetConfigValue('focusY', dy)
         IA.RefreshUI()
      end
   end)

   f:SetScript('OnClick', function()
      if arg1 == 'RightButton' then
         Interact_ClearFocus(slotNum)
      else
         local cfg = InteractDB and InteractDB.config
         if cfg then
            if IsShiftKeyDown and IsShiftKeyDown() and cfg.focusShiftSpell and cfg.focusShiftSpell ~= '' then
               Interact_CastOnFocus(cfg.focusShiftSpell, slotNum)
               return
            elseif IsControlKeyDown and IsControlKeyDown() and cfg.focusCtrlSpell and cfg.focusCtrlSpell ~= '' then
               Interact_CastOnFocus(cfg.focusCtrlSpell, slotNum)
               return
            elseif IsAltKeyDown and IsAltKeyDown() and cfg.focusAltSpell and cfg.focusAltSpell ~= '' then
               Interact_CastOnFocus(cfg.focusAltSpell, slotNum)
               return
            end
         end
         Interact_TargetFocus(slotNum)
      end
   end)

   f:SetScript('OnEnter', function()
      GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
      GameTooltip:SetText('Interact Focus ' .. slotNum, 1, 0.82, 0)
      GameTooltip:AddLine('Left-Click: Target Focus ' .. slotNum, 1, 1, 1)
      local cfg = InteractDB and InteractDB.config
      if cfg then
         if cfg.focusShiftSpell and cfg.focusShiftSpell ~= '' then
            GameTooltip:AddLine('Shift+Left-Click: Cast ' .. cfg.focusShiftSpell, 0.4, 1, 0.4)
         end
         if cfg.focusCtrlSpell and cfg.focusCtrlSpell ~= '' then
            GameTooltip:AddLine('Ctrl+Left-Click: Cast ' .. cfg.focusCtrlSpell, 0.4, 0.85, 1)
         end
         if cfg.focusAltSpell and cfg.focusAltSpell ~= '' then
            GameTooltip:AddLine('Alt+Left-Click: Cast ' .. cfg.focusAltSpell, 1, 0.75, 0.3)
         end
      end
      GameTooltip:AddLine('Right-Click: Clear Focus ' .. slotNum, 1, 0.5, 0.5)
      GameTooltip:AddLine('Drag: Move All 9 Focus Frames (when unlocked or Config open)', 0.8, 0.8, 0.8)
      GameTooltip:Show()
   end)

   f:SetScript('OnLeave', function()
      GameTooltip:Hide()
   end)

   return {
      slot = slot,
      frame = f,
      portrait = portrait,
      nameBG = nameBG,
      hp = hp,
      mana = mana,
      border = border,
      borderGlow = borderGlow,
      compactBG = compactBG,
      alertFlash = alertFlash,
      alertFlashBG = alertFlashBG,
      nameText = nameText,
      hpText = hpText,
      manaText = manaText,
      levelText = levelText,
      distText = distText,
      deadText = deadText,
      combatIcon = combatIcon,
      raidIcon = raidIcon,
      tot = tot,
      totHP = totHP,
      totNameText = totNameText,
      cast = cast,
      castBorder = castBorder,
      castText = castText,
      castIconTex = castIconTex,
      auraFrames = auraFrames,
      castStart = 0,
      lastSpellId = 0,
      wasFriendlyPlayer = false,
      cachedGroupUnit = nil,
      cachedGroupName = nil,
      lastAuraIcons = nil,
      lastHasBuffs = false,
      lastHasDebuffs = false,
      remoteName = nil,
   }
end

for slot = 1, MAX_FOCUS_SLOTS do
   focusSlots[slot] = CreateFocusSlotFrame(slot)
end

local COMPACT_BACKDROP = {
   edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
   edgeSize = 10,
   insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local function ApplySlotCompactGeometry(fs, compact)
   local f = fs.frame
   if compact then
      f:SetWidth(148)
      f:SetHeight(42)
      f:SetBackdrop(COMPACT_BACKDROP)
      f:SetBackdropBorderColor(0.65, 0.55, 0.25, 0.9)
      fs.portrait:Hide()
      fs.border:Hide()
      fs.compactBG:Show()

      fs.nameBG:ClearAllPoints()
      fs.nameBG:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -2)
      fs.nameBG:SetWidth(144)
      fs.nameBG:SetHeight(14)

      fs.nameText:ClearAllPoints()
      fs.nameText:SetPoint('LEFT', fs.nameBG, 'LEFT', 20, 0)
      fs.nameText:SetWidth(88)
      fs.nameText:SetJustifyH('LEFT')

      fs.distText:ClearAllPoints()
      fs.distText:SetPoint('RIGHT', fs.nameBG, 'RIGHT', -3, 0)

      fs.hp:ClearAllPoints()
      fs.hp:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -17)
      fs.hp:SetWidth(144)
      fs.hp:SetHeight(14)

      fs.mana:ClearAllPoints()
      fs.mana:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -32)
      fs.mana:SetWidth(144)
      fs.mana:SetHeight(8)
      fs.manaText:Hide()

      fs.raidIcon:ClearAllPoints()
      fs.raidIcon:SetPoint('LEFT', fs.nameBG, 'LEFT', 2, 0)
      fs.raidIcon:SetWidth(14)
      fs.raidIcon:SetHeight(14)

      fs.combatIcon:ClearAllPoints()
      fs.combatIcon:SetPoint('RIGHT', fs.hp, 'RIGHT', -2, 0)
      fs.combatIcon:SetWidth(14)
      fs.combatIcon:SetHeight(14)
      fs.levelText:Hide()

      fs.cast:SetWidth(130)
      fs.cast:SetHeight(10)
      fs.castBorder:Hide()
      fs.castText:SetWidth(124)

      fs.alertFlash:ClearAllPoints()
      fs.alertFlash:SetPoint('TOPLEFT', f, 'TOPLEFT', -2, 2)
      fs.alertFlash:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 2, -2)
      fs.alertFlashBG:ClearAllPoints()
      fs.alertFlashBG:SetAllPoints(f)
      fs.border:SetVertexColor(1.0, 1.0, 1.0)
      fs.borderGlow:Hide()
      fs.portrait:SetVertexColor(1.0, 1.0, 1.0)
      fs.compactBG:SetTexture(0.05, 0.05, 0.08, 0.85)

      for i = 1, 16 do
         local af = fs.auraFrames[i]
         af:SetWidth(15)
         af:SetHeight(15)
         local row = (i <= 8) and 0 or 1
         local col = (i <= 8) and (i - 1) or (i - 9)
         af:ClearAllPoints()
         af:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 2 + (col * 18), -2 - (row * 17))
      end
   else
      f:SetWidth(232)
      f:SetHeight(100)
      f:SetBackdrop(nil)
      fs.portrait:Show()
      fs.border:Show()
      fs.compactBG:Hide()

      fs.nameBG:ClearAllPoints()
      fs.nameBG:SetPoint('TOPLEFT', f, 'TOPLEFT', 7, -22)
      fs.nameBG:SetWidth(119)
      fs.nameBG:SetHeight(19)

      fs.nameText:ClearAllPoints()
      fs.nameText:SetPoint('CENTER', fs.nameBG, 'CENTER', 0, 0)
      fs.nameText:SetWidth(112)
      fs.nameText:SetJustifyH('CENTER')

      fs.distText:ClearAllPoints()
      fs.distText:SetPoint('TOPLEFT', f, 'TOPLEFT', 10, -7)

      fs.hp:ClearAllPoints()
      fs.hp:SetPoint('TOPLEFT', f, 'TOPLEFT', 7, -41)
      fs.hp:SetWidth(119)
      fs.hp:SetHeight(12)

      fs.mana:ClearAllPoints()
      fs.mana:SetPoint('TOPLEFT', f, 'TOPLEFT', 7, -52)
      fs.mana:SetWidth(119)
      fs.mana:SetHeight(12)
      fs.manaText:Show()

      fs.raidIcon:ClearAllPoints()
      fs.raidIcon:SetPoint('CENTER', fs.portrait, 'TOP', 0, 2)
      fs.raidIcon:SetWidth(24)
      fs.raidIcon:SetHeight(24)

      fs.combatIcon:ClearAllPoints()
      fs.combatIcon:SetPoint('CENTER', f, 'BOTTOMRIGHT', -53, 34)
      fs.combatIcon:SetWidth(24)
      fs.combatIcon:SetHeight(24)

      fs.alertFlash:ClearAllPoints()
      fs.alertFlash:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -9)
      fs.alertFlash:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -34, 20)
      fs.alertFlashBG:ClearAllPoints()
      fs.alertFlashBG:SetPoint('TOPLEFT', fs.nameBG, 'TOPLEFT', 0, 0)
      fs.alertFlashBG:SetPoint('BOTTOMRIGHT', fs.mana, 'BOTTOMRIGHT', 0, 0)
      fs.border:SetVertexColor(1.0, 1.0, 1.0)
      fs.borderGlow:Hide()
      fs.portrait:SetVertexColor(1.0, 1.0, 1.0)

      fs.cast:SetWidth(150)
      fs.cast:SetHeight(11)
      fs.castBorder:Show()
      fs.castText:SetWidth(142)

      for i = 1, 16 do
         local af = fs.auraFrames[i]
         af:SetWidth(18)
         af:SetHeight(18)
         local row = (i <= 8) and 0 or 1
         local col = (i <= 8) and (i - 1) or (i - 9)
         af:ClearAllPoints()
         af:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 8 + (col * 20), 14 - (row * 20))
      end
   end
end

local function UpdateFocusFrameStyle()
   EnsureDB()
   local scale = InteractDB.config.focusScale or 1.0
   local x = (InteractDB.config.focusX or -260) / scale
   local y = (InteractDB.config.focusY or 120) / scale
   local compact = InteractDB.config.compactFocus and true or false
   local gapY = compact and -6 or 10
   local gapX = compact and 8 or 12
   if InteractDB.config.showFocusAuras then
      gapY = compact and -38 or -32
   elseif InteractDB.config.showFocusCast then
      gapY = compact and -18 or -10
   end
   for slot = 1, MAX_FOCUS_SLOTS do
      local fs = focusSlots[slot]
      ApplySlotCompactGeometry(fs, compact)
      fs.frame:SetScale(scale)
      fs.frame:ClearAllPoints()
      if slot == 1 then
         fs.frame:SetPoint('CENTER', UIParent, 'CENTER', x, y)
      elseif slot == 4 then
         fs.frame:SetPoint('TOPLEFT', focusSlots[1].frame, 'TOPRIGHT', gapX, 0)
      elseif slot == 7 then
         fs.frame:SetPoint('TOPLEFT', focusSlots[4].frame, 'TOPRIGHT', gapX, 0)
      else
         fs.frame:SetPoint('TOPLEFT', focusSlots[slot - 1].frame, 'BOTTOMLEFT', 0, gapY)
      end
      if not InteractDB.config.enableFocus then
         fs.frame:Hide()
      end
   end
end

-- ============================================================================
-- Party / Raid Leader Addon Message Sync (IM_FOCUS)
-- ============================================================================
local function GetFocusSyncChannel()
   if (GetNumRaidMembers() or 0) > 0 then
      return 'RAID'
   elseif (GetNumPartyMembers() or 0) > 0 then
      return 'PARTY'
   end
   return nil
end

local function IsPlayerGroupLeader()
   if (GetNumRaidMembers() or 0) > 0 then
      return (IsRaidLeader and IsRaidLeader() == 1) and true or false
   elseif (GetNumPartyMembers() or 0) > 0 then
      return (IsPartyLeader and IsPartyLeader() == 1) and true or false
   end
   return false
end

local cachedLeaderName = nil

local function RefreshCachedLeaderName()
   local numRaid = GetNumRaidMembers() or 0
   if numRaid > 0 and GetRaidRosterInfo then
      for i = 1, numRaid do
         local rName, rRank = GetRaidRosterInfo(i)
         if rRank == 2 then
            cachedLeaderName = rName
            return
         end
      end
      cachedLeaderName = nil
      return
   end
   local numParty = GetNumPartyMembers() or 0
   if numParty > 0 then
      if IsPartyLeader and IsPartyLeader() == 1 then
         cachedLeaderName = UnitName('player')
         return
      end
      for i = 1, numParty do
         local u = 'party' .. i
         if UnitExists(u) and UnitIsPartyLeader and UnitIsPartyLeader(u) then
            cachedLeaderName = UnitName(u)
            return
         end
      end
   end
   cachedLeaderName = nil
end

local function IsSenderGroupLeader(senderName)
   if not senderName or senderName == '' then return false end
   if cachedLeaderName == nil then
      RefreshCachedLeaderName()
   end
   return cachedLeaderName ~= nil and cachedLeaderName == senderName
end

local function BroadcastFocusSlotIfLeader(slot, isClear)
   if not SendAddonMessage or type(InteractNearest) ~= 'function' then return end
   if not InteractDB or not InteractDB.config or not InteractDB.config.syncFocusGroup then return end
   if not IsPlayerGroupLeader() then return end
   local chan = GetFocusSyncChannel()
   if not chan then return end

   if isClear then
      SendAddonMessage(FOCUS_ADDON_PREFIX, string.format('CLR;%d', slot), chan)
   else
      local low32, high32, unitName = InteractNearest(CMD_FOCUS_GET_GUID, slot)
      if low32 and high32 then
         local safeName = string.gsub(unitName or 'Focus', ';', ':')
         SendAddonMessage(FOCUS_ADDON_PREFIX, string.format('SET;%d;%.0f;%.0f;%s', slot, low32, high32, safeName), chan)
      end
   end
end

function Interact_BroadcastAllFocus()
   EnsureDB()
   if not SendAddonMessage or type(InteractNearest) ~= 'function' then return end
   local chan = GetFocusSyncChannel()
   if not chan then
      PrintMsg('You must be in a Party or Raid to broadcast Focus targets.')
      return
   end
   if not IsPlayerGroupLeader() then
      PrintMsg('Only the Party Leader or Raid Leader can broadcast Focus targets.')
      return
   end
   local sent = 0
   for slot = 1, MAX_FOCUS_SLOTS do
      local low32, high32, unitName = InteractNearest(CMD_FOCUS_GET_GUID, slot)
      if low32 and high32 then
         local safeName = string.gsub(unitName or 'Focus', ';', ':')
         SendAddonMessage(FOCUS_ADDON_PREFIX, string.format('SET;%d;%.0f;%.0f;%s', slot, low32, high32, safeName), chan)
         sent = sent + 1
      else
         SendAddonMessage(FOCUS_ADDON_PREFIX, string.format('CLR;%d', slot), chan)
      end
   end
   PrintMsg('Broadcasted Focus 1..9 (' .. sent .. ' active) to ' .. chan .. '.')
end

function Interact_PopulateFocusFromMarks(silent)
   EnsureDB()
   if type(InteractNearest) ~= 'function' then return 0 end
   local count = InteractNearest(CMD_FOCUS_POPULATE_MARKS, 0) or 0
   if count > 0 then
      for s = 1, 8 do
         if focusSlots[s] then focusSlots[s].isAssigned = true end
      end
   end
   if not silent then
      if count > 0 then
         PrintMsg('Populated |cffffd200' .. count .. '|r Focus slot(s) from Raid Target Marks (Skull -> 1, Cross -> 2, ...).')
         if InteractDB.config.syncFocusGroup and IsPlayerGroupLeader() and GetFocusSyncChannel() then
            Interact_BroadcastAllFocus()
         end
      else
         PrintMsg('No active Raid Target Marks (Skull..Star) found in memory.')
      end
   end
   return count
end

function Interact_SetFocus(slot)
   slot = tonumber(slot) or 1
   if slot < 1 or slot > MAX_FOCUS_SLOTS then slot = 1 end
   if type(InteractNearest) ~= 'function' then return end
   EnsureDB()
   local restoredPrev = false
   if not UnitExists('target') and UnitExists('mouseover') then
      TargetUnit('mouseover')
      restoredPrev = true
   end
   local ok = InteractNearest(CMD_FOCUS_SET, slot)
   local targetName = UnitName('target')
   if restoredPrev then
      ClearTarget()
   end
   if focusSlots[slot] then
      focusSlots[slot].lastAuraIcons = nil
      focusSlots[slot].cachedGroupUnit = nil
      focusSlots[slot].remoteName = targetName
   end
   if ok == 1 then
      if focusSlots[slot] then
         focusSlots[slot].isAssigned = true
      end
      PrintMsg('Focus ' .. slot .. ' set to |cffffd200' .. tostring(targetName or 'Target') .. '|r.')
      BroadcastFocusSlotIfLeader(slot, false)
   elseif ok == nil and (UnitExists('target') or restoredPrev) then
      PrintMsg('|cffff4040Focus command not recognized by InteractMod.dll — rebuild Release|Win32 in Visual Studio and copy the new DLL to WoW.|r')
   else
      PrintMsg('No valid unit targeted or moused over to focus.')
   end
end

function Interact_AutoFocus()
   if type(InteractNearest) ~= 'function' then return end
   EnsureDB()
   if not UnitExists('target') and not UnitExists('mouseover') then
      PrintMsg('No valid unit targeted or moused over to focus.')
      return
   end
   for slot = 1, MAX_FOCUS_SLOTS do
      local low32, high32 = InteractNearest(CMD_FOCUS_GET_GUID, slot)
      local fs = focusSlots[slot]
      local hasRemote = fs and fs.remoteName and fs.remoteName ~= ''
      if (not low32 or not high32) and not hasRemote then
         Interact_SetFocus(slot)
         return
      end
   end
   PrintMsg('All Focus slots (1..9) are already assigned. Use /clearfocus1..9 or /clearfocus all.')
end

function Interact_ClearFocus(slot)
   slot = tonumber(slot) or 1
   if slot < 1 or slot > MAX_FOCUS_SLOTS then slot = 1 end
   if type(InteractNearest) ~= 'function' then return end
   InteractNearest(CMD_FOCUS_CLEAR, slot)
   if focusSlots[slot] then
      focusSlots[slot].isAssigned = false
      focusSlots[slot].lastAuraIcons = nil
      focusSlots[slot].cachedGroupUnit = nil
      focusSlots[slot].remoteName = nil
      focusSlots[slot].frame:Hide()
   end
   PrintMsg('Focus ' .. slot .. ' cleared.')
   BroadcastFocusSlotIfLeader(slot, true)
end

function Interact_ClearAllFocus()
   if type(InteractNearest) ~= 'function' then return end
   EnsureDB()
   for slot = 1, MAX_FOCUS_SLOTS do
      InteractNearest(CMD_FOCUS_CLEAR, slot)
      if focusSlots[slot] then
         focusSlots[slot].isAssigned = false
         focusSlots[slot].lastAuraIcons = nil
         focusSlots[slot].cachedGroupUnit = nil
         focusSlots[slot].remoteName = nil
         focusSlots[slot].frame:Hide()
      end
   end
   if SendAddonMessage and InteractDB.config.syncFocusGroup and IsPlayerGroupLeader() then
      local chan = GetFocusSyncChannel()
      if chan then
         SendAddonMessage(FOCUS_ADDON_PREFIX, 'CLRALL', chan)
      end
   end
   PrintMsg('Cleared all Focus slots (1..9).')
end

function Interact_TargetFocus(slot)
   slot = tonumber(slot) or 1
   if slot < 1 or slot > MAX_FOCUS_SLOTS then slot = 1 end
   if type(InteractNearest) ~= 'function' then return end
   InteractNearest(CMD_FOCUS_TARGET, slot)
end

function Interact_CastOnFocus(spell, slot)
   slot = tonumber(slot) or 1
   if slot < 1 or slot > MAX_FOCUS_SLOTS then slot = 1 end
   if not spell or spell == '' then
      PrintMsg('Usage: /fcast' .. ((slot == 1) and '' or tostring(slot)) .. ' <Spell Name>')
      return
   end
   if type(InteractNearest) ~= 'function' then return end
   local swapped = InteractNearest(CMD_FOCUS_SWAP, slot)
   if swapped == 1 then
      CastSpellByName(spell)
      InteractNearest(CMD_FOCUS_RESTORE)
   else
      PrintMsg('No focus ' .. slot .. ' set.')
   end
end

local function RegisterFocusSlotSlash(slot)
   local suffix = (slot == 1) and '' or tostring(slot)
   setglobal('SLASH_INTERACTFOCUS' .. slot .. '1', '/focus' .. suffix)
   if slot == 1 then
      SLASH_INTERACTFOCUS12 = '/focus1'
   end
   SlashCmdList['INTERACTFOCUS' .. slot] = function(msg)
      local _, _, clean = string.find(msg or '', '^%s*(.-)%s*$')
      local low = string.lower(clean or '')
      if low == 'clear' then
         Interact_ClearFocus(slot)
      elseif low == 'clearall' or low == 'all' then
         Interact_ClearAllFocus()
      elseif low == 'sync' then
         Interact_BroadcastAllFocus()
      elseif UnitExists('target') or UnitExists('mouseover') then
         Interact_SetFocus(slot)
      else
         Interact_ClearFocus(slot)
      end
   end

   setglobal('SLASH_INTERACTCLEARFOCUS' .. slot .. '1', '/clearfocus' .. suffix)
   if slot == 1 then
      SLASH_INTERACTCLEARFOCUS12 = '/clearfocus1'
   end
   SlashCmdList['INTERACTCLEARFOCUS' .. slot] = function(msg)
      local _, _, clean = string.find(msg or '', '^%s*(.-)%s*$')
      local low = string.lower(clean or '')
      if slot == 1 and (low == 'all' or low == '1-9') then
         Interact_ClearAllFocus()
      else
         Interact_ClearFocus(slot)
      end
   end

   setglobal('SLASH_INTERACTTARGETFOCUS' .. slot .. '1', '/targetfocus' .. suffix)
   if slot == 1 then
      SLASH_INTERACTTARGETFOCUS12 = '/targetfocus1'
   end
   SlashCmdList['INTERACTTARGETFOCUS' .. slot] = function()
      Interact_TargetFocus(slot)
   end

   setglobal('SLASH_INTERACTFCAST' .. slot .. '1', '/fcast' .. suffix)
   if slot == 1 then
      SLASH_INTERACTFCAST12 = '/fcast1'
   end
   SlashCmdList['INTERACTFCAST' .. slot] = function(msg)
      local _, _, clean = string.find(msg or '', '^%s*(.-)%s*$')
      Interact_CastOnFocus(clean, slot)
   end
end

for slot = 1, MAX_FOCUS_SLOTS do
   RegisterFocusSlotSlash(slot)
end

SLASH_INTERACTFSYNC1 = '/fsync'
SLASH_INTERACTFSYNC2 = '/focussync'
SlashCmdList['INTERACTFSYNC'] = function()
   Interact_BroadcastAllFocus()
end

SLASH_INTERACTFMARKS1 = '/focusmarks'
SLASH_INTERACTFMARKS2 = '/fmarks'
SlashCmdList['INTERACTFMARKS'] = function()
   Interact_PopulateFocusFromMarks(false)
end

SLASH_INTERACTAUTOFOCUS1 = '/autofocus'
SlashCmdList['INTERACTAUTOFOCUS'] = function()
   Interact_AutoFocus()
end

local syncRateState = {}

local function SanitizeSyncName(rawName)
   if type(rawName) ~= 'string' or rawName == '' then return nil end
   local cleaned = string.gsub(rawName, '|', '')
   cleaned = string.gsub(cleaned, '[%c]', '')
   cleaned = string.gsub(cleaned, '[^%w%s\'%-:]', '')
   local _, _, trimmed = string.find(cleaned, '^%s*(.-)%s*$')
   if not trimmed or trimmed == '' then return nil end
   if string.len(trimmed) > 48 then
      trimmed = string.sub(trimmed, 1, 48)
   end
   return trimmed
end

local focusCommFrame = CreateFrame('Frame')
focusCommFrame:RegisterEvent('CHAT_MSG_ADDON')
focusCommFrame:RegisterEvent('PARTY_MEMBERS_CHANGED')
focusCommFrame:RegisterEvent('RAID_ROSTER_UPDATE')
focusCommFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
focusCommFrame:SetScript('OnEvent', function()
   if event == 'PARTY_MEMBERS_CHANGED' or event == 'RAID_ROSTER_UPDATE' or event == 'PLAYER_ENTERING_WORLD' then
      RefreshCachedLeaderName()
      if event == 'PLAYER_ENTERING_WORLD' then
         for s = 1, MAX_FOCUS_SLOTS do
            if focusSlots[s] then
               focusSlots[s].isAssigned = false
               focusSlots[s].lastAuraIcons = nil
               focusSlots[s].cachedGroupUnit = nil
               focusSlots[s].remoteName = nil
            end
         end
      end
      return
   end
   if event ~= 'CHAT_MSG_ADDON' or arg1 ~= FOCUS_ADDON_PREFIX then return end
   if arg3 ~= 'PARTY' and arg3 ~= 'RAID' then return end
   if not InteractDB or not InteractDB.config or not InteractDB.config.syncFocusGroup then return end
   if type(InteractNearest) ~= 'function' then return end
   local sender = arg4
   if not sender or sender == UnitName('player') then return end
   if not IsSenderGroupLeader(sender) then return end

   local now = GetTime and GetTime() or 0
   local rs = syncRateState[sender]
   if not rs or (now - rs.windowStart) >= 1.0 then
      syncRateState[sender] = { windowStart = now, count = 1 }
   else
      rs.count = rs.count + 1
      if rs.count > 20 then return end
   end

   local msg = arg2 or ''
   if msg == 'CLRALL' then
      for s = 1, MAX_FOCUS_SLOTS do
         InteractNearest(CMD_FOCUS_CLEAR, s)
         if focusSlots[s] then
            focusSlots[s].isAssigned = false
            focusSlots[s].lastAuraIcons = nil
            focusSlots[s].cachedGroupUnit = nil
            focusSlots[s].remoteName = nil
            focusSlots[s].frame:Hide()
         end
      end
      return
   end

   local _, _, clrSlotStr = string.find(msg, '^CLR;(%d+)$')
   if clrSlotStr then
      local s = tonumber(clrSlotStr)
      if s and s >= 1 and s <= MAX_FOCUS_SLOTS then
         InteractNearest(CMD_FOCUS_CLEAR, s)
         if focusSlots[s] then
            focusSlots[s].isAssigned = false
            focusSlots[s].lastAuraIcons = nil
            focusSlots[s].cachedGroupUnit = nil
            focusSlots[s].remoteName = nil
            focusSlots[s].frame:Hide()
         end
      end
      return
   end

   local _, _, slotStr, lowStr, highStr, rName = string.find(msg, '^SET;(%d+);(%d+);(%d+);(.*)$')
   if slotStr and lowStr and highStr then
      if string.len(lowStr) > 10 or string.len(highStr) > 10 then return end
      local s = tonumber(slotStr)
      local low32 = tonumber(lowStr)
      local high32 = tonumber(highStr)
      if s and s >= 1 and s <= MAX_FOCUS_SLOTS and low32 and high32
         and low32 >= 0 and low32 <= 4294967295
         and high32 >= 0 and high32 <= 4294967295 then
         local cleanName = SanitizeSyncName(rName)
         local setOk = InteractNearest(CMD_FOCUS_SET_GUID, s, low32, high32)
         if setOk == 1 and focusSlots[s] then
            focusSlots[s].isAssigned = true
            focusSlots[s].lastAuraIcons = nil
            focusSlots[s].cachedGroupUnit = nil
            focusSlots[s].remoteName = cleanName
            PrintMsg('Leader synced Focus ' .. s .. ': |cffffd200' .. (cleanName or 'Unit') .. '|r.')
         end
      end
   end
end)

local POWER_COLORS = {
   [0] = { 0.00, 0.45, 1.00 }, -- Mana
   [1] = { 1.00, 0.00, 0.00 }, -- Rage
   [2] = { 1.00, 0.50, 0.25 }, -- Focus
   [3] = { 1.00, 0.90, 0.00 }, -- Energy
}

local CLASS_PORTRAIT_ICONS = {
   [1]  = 'Interface\\Icons\\INV_Sword_27',                -- Warrior
   [2]  = 'Interface\\Icons\\Ability_ThunderBolt',         -- Paladin
   [3]  = 'Interface\\Icons\\INV_Weapon_Bow_07',           -- Hunter
   [4]  = 'Interface\\Icons\\INV_ThrowingKnife_04',        -- Rogue
   [5]  = 'Interface\\Icons\\INV_Staff_30',                -- Priest
   [7]  = 'Interface\\Icons\\Spell_Nature_BloodLust',      -- Shaman
   [8]  = 'Interface\\Icons\\INV_Staff_13',                -- Mage
   [9]  = 'Interface\\Icons\\Spell_Nature_FaerieFire',     -- Warlock
   [11] = 'Interface\\Icons\\Ability_Druid_Maul',          -- Druid
}

local CREATURE_PORTRAIT_ICONS = {
   [1]  = 'Interface\\Icons\\Ability_Hunter_Pet_Bear',     -- Beast
   [2]  = 'Interface\\Icons\\INV_Misc_Head_Dragon_01',     -- Dragonkin
   [3]  = 'Interface\\Icons\\Spell_Shadow_Metamorphosis',  -- Demon
   [4]  = 'Interface\\Icons\\Spell_Frost_SummonWaterElemental', -- Elemental
   [5]  = 'Interface\\Icons\\Ability_Racial_Avatar',       -- Giant
   [6]  = 'Interface\\Icons\\Spell_Shadow_RaiseDead',      -- Undead
   [7]  = 'Interface\\Icons\\Spell_Holy_PrayerOfHealing',  -- Humanoid
   [8]  = 'Interface\\Icons\\Ability_Hunter_Pet_Rabbit',   -- Critter
   [9]  = 'Interface\\Icons\\INV_Gizmo_02',                -- Mechanical
   [11] = 'Interface\\Icons\\Spell_Totem_WardOfDraining',  -- Totem
}

local function FindFriendlyGroupUnit(fs, targetName)
   if not targetName or targetName == '' then return nil end
   if fs.cachedGroupUnit and fs.cachedGroupName == targetName then
      local cu = fs.cachedGroupUnit
      if UnitExists(cu) and UnitIsPlayer(cu) and not UnitCanAttack('player', cu) and UnitName(cu) == targetName then
         return cu
      end
   end
   local numRaid = GetNumRaidMembers() or 0
   if numRaid > 0 then
      for i = 1, numRaid do
         local u = 'raid' .. i
         if UnitExists(u) and UnitIsPlayer(u) and not UnitCanAttack('player', u) and UnitName(u) == targetName then
            fs.cachedGroupUnit = u
            fs.cachedGroupName = targetName
            return u
         end
      end
   end
   local numParty = GetNumPartyMembers() or 0
   if numParty > 0 then
      for i = 1, numParty do
         local u = 'party' .. i
         if UnitExists(u) and UnitIsPlayer(u) and not UnitCanAttack('player', u) and UnitName(u) == targetName then
            fs.cachedGroupUnit = u
            fs.cachedGroupName = targetName
            return u
         end
      end
   end
   fs.cachedGroupUnit = nil
   return nil
end

local function HideFocusAuras(fs)
   fs.lastAuraIcons = nil
   fs.lastHasBuffs = false
   fs.lastHasDebuffs = false
   for i = 1, 16 do
      fs.auraFrames[i]:Hide()
   end
end

local function SetFocusAuraSlot(fs, idx, tex, isDebuff, stacks)
   local af = fs.auraFrames[idx]
   if not af then return end
   af.icon:SetTexture(tex)
   if isDebuff then
      af.debuffBorder:Show()
   else
      af.debuffBorder:Hide()
   end
   if stacks and stacks > 1 then
      af.count:SetText(tostring(stacks))
      af.count:Show()
   else
      af.count:Hide()
   end
   af:Show()
end

local function SetFocusClassificationBorder(fs, classification)
   local tex = 'Interface\\TargetingFrame\\UI-TargetingFrame'
   if classification == 1 or classification == 3 then
      tex = 'Interface\\TargetingFrame\\UI-TargetingFrame-Elite'
   elseif classification == 2 then
      tex = 'Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite'
   elseif classification == 4 then
      tex = 'Interface\\TargetingFrame\\UI-TargetingFrame-Rare'
   end
   fs.border:SetTexture(tex)
   fs.borderGlow:SetTexture(tex)
end

local function SetFocusCastAlert(fs, compact, active, blink)
   if active then
      if compact then
         fs.borderGlow:Hide()
         fs.frame:SetBackdropBorderColor(1.0, 0.1, 0.1, 0.35 + 0.65 * blink)
         fs.compactBG:SetTexture(0.05 + 0.65 * blink, 0.05, 0.08, 0.85)
         fs.alertFlashBG:SetTexture(1.0, 0.05, 0.05, 0.35 * blink)
         fs.alertFlash:SetBackdropBorderColor(1.0, 0.1, 0.1, 0.25 + 0.75 * blink)
      else
         local c = 1.0 - 0.85 * blink
         fs.border:SetVertexColor(1.0, c, c)
         fs.portrait:SetVertexColor(1.0, 1.0 - 0.55 * blink, 1.0 - 0.55 * blink)
         fs.borderGlow:SetVertexColor(1.0, 0.1, 0.1, 0.9 * blink)
         fs.borderGlow:Show()
         fs.alertFlashBG:SetTexture(1.0, 0.05, 0.05, 0.4 * blink)
         fs.alertFlash:SetBackdropBorderColor(1.0, 0.1, 0.1, 0)
      end
      fs.alertFlash:Show()
   else
      fs.border:SetVertexColor(1.0, 1.0, 1.0)
      fs.borderGlow:Hide()
      fs.portrait:SetVertexColor(1.0, 1.0, 1.0)
      if compact then
         fs.frame:SetBackdropBorderColor(0.65, 0.55, 0.25, 0.9)
         fs.compactBG:SetTexture(0.05, 0.05, 0.08, 0.85)
      end
      fs.alertFlash:Hide()
   end
end

local function UpdateFocusSlot(slot)
   local fs = focusSlots[slot]
   if not fs then return end
   if not InteractDB or not InteractDB.config or not InteractDB.config.enableFocus or type(InteractNearest) ~= 'function' then
      fs.frame:Hide()
      return
   end

   local cfgOpen = (InteractConfigFrame and InteractConfigFrame:IsVisible())
   local onFocusTab = (not IA.GetActiveConfigTab) or (IA.GetActiveConfigTab() == 4)
   local showPreview = cfgOpen and onFocusTab
   if not fs.isAssigned and not showPreview then
      if fs.frame:IsVisible() then fs.frame:Hide() end
      return
   end

   local inView, name, level, hp, maxHp, power, maxPower, powerType, reaction, inCombat, raidMark, dist, totInfo, castInfo, isPlayer, classOrType, auraIcons, classification, inLoS = InteractNearest(CMD_FOCUS_QUERY, slot)
   local compact = InteractDB.config.compactFocus and true or false
   if inView == nil then
      fs.isAssigned = false
      fs.wasFriendlyPlayer = false
      fs.lastAuraIcons = nil
      fs.lastSpellId = 0
      SetFocusCastAlert(fs, compact, false, 0)
      if showPreview then
         fs.frame:SetAlpha(0.85)
         if not compact then
            SetFocusClassificationBorder(fs, 0)
            SetPortraitToTexture(fs.portrait, 'Interface\\Icons\\Ability_Tracking')
         end
         fs.nameBG:SetVertexColor(0.25, 0.55, 0.85)
         fs.nameText:SetText('[' .. slot .. '] Focus Preview')
         fs.hp:SetMinMaxValues(0, 100)
         fs.hp:SetValue(100)
         fs.hpText:SetText(compact and '100%' or '100 / 100 (100%)')
         fs.deadText:Hide()
         local pc = POWER_COLORS[0]
         fs.mana:SetStatusBarColor(pc[1], pc[2], pc[3])
         fs.mana:SetMinMaxValues(0, 100)
         fs.mana:SetValue(100)
         if not compact then
            fs.manaText:SetText('100 / 100')
            fs.levelText:SetText('60')
            fs.levelText:Show()
         else
            fs.levelText:Hide()
         end
         fs.combatIcon:Hide()
         fs.distText:SetText(compact and 'Drag' or 'Preview (Drag)')
         fs.raidIcon:Hide()
         fs.tot:Hide()
         fs.cast:Hide()
         HideFocusAuras(fs)
         fs.frame:Show()
      else
         fs.frame:Hide()
      end
      return
   end

   if (not name or name == '' or name == 'Unknown' or name == 'Remote Focus') and fs.remoteName then
      name = fs.remoteName
   elseif inView == 1 and name and name ~= '' and name ~= 'Unknown' then
      fs.remoteName = name
   end

   if slot > 1 then
      fs.nameText:SetText('[' .. slot .. '] ' .. (name or 'Unknown'))
   else
      fs.nameText:SetText(name or 'Unknown')
   end

   local groupUnit = nil
   if inView == 0 and (fs.wasFriendlyPlayer or fs.remoteName) then
      groupUnit = FindFriendlyGroupUnit(fs, name)
   elseif inView == 1 then
      fs.wasFriendlyPlayer = (isPlayer == 1 and reaction and reaction >= 4) and true or false
   end

   local hasBuffs = false
   local hasDebuffs = false

   if inView == 0 and groupUnit then
      fs.frame:SetAlpha(0.85)
      SetFocusClassificationBorder(fs, 0)
      SetPortraitTexture(fs.portrait, groupUnit)
      fs.nameBG:SetVertexColor(0.15, 0.75, 0.2)

      hp = UnitHealth(groupUnit) or 0
      maxHp = UnitHealthMax(groupUnit) or 1
      if maxHp <= 0 then maxHp = 1 end
      fs.hp:SetMinMaxValues(0, maxHp)
      fs.hp:SetValue(hp)

      if UnitIsDeadOrGhost(groupUnit) or hp <= 0 then
         fs.hpText:SetText('')
         fs.deadText:SetText('Dead')
         fs.deadText:Show()
      else
         fs.deadText:Hide()
         local pct = math.floor((hp * 100) / maxHp)
         if compact then
            fs.hpText:SetText(string.format('%d%%', pct))
         else
            fs.hpText:SetText(string.format('%d / %d (%d%%)', hp, maxHp, pct))
         end
      end

      powerType = UnitPowerType(groupUnit) or 0
      power = UnitMana(groupUnit) or 0
      maxPower = UnitManaMax(groupUnit) or 0
      local pc = POWER_COLORS[powerType] or POWER_COLORS[0]
      fs.mana:SetStatusBarColor(pc[1], pc[2], pc[3])
      if maxPower > 0 then
         fs.mana:SetMinMaxValues(0, maxPower)
         fs.mana:SetValue(power)
         if not compact then
            fs.manaText:SetText(string.format('%d / %d', power, maxPower))
         end
      else
         fs.mana:SetMinMaxValues(0, 1)
         fs.mana:SetValue(0)
         if not compact then
            fs.manaText:SetText('')
         end
      end

      level = UnitLevel(groupUnit) or 0
      fs.levelText:SetText((level > 0) and tostring(level) or '??')
      fs.distText:SetText(compact and '>100y' or 'Group (>100y)')
      if UnitAffectingCombat(groupUnit) then
         fs.combatIcon:Show()
         fs.levelText:Hide()
      else
         fs.combatIcon:Hide()
         if not compact then
            fs.levelText:Show()
         else
            fs.levelText:Hide()
         end
      end

      raidMark = GetRaidTargetIndex(groupUnit) or raidMark
      fs.tot:Hide()
      fs.cast:Hide()
      SetFocusCastAlert(fs, compact, false, 0)

      if InteractDB.config.showFocusAuras then
         fs.lastAuraIcons = nil
         local bIdx = 1
         for i = 1, 8 do
            local tex, apps = UnitBuff(groupUnit, i)
            if tex and bIdx <= 8 then
               SetFocusAuraSlot(fs, bIdx, tex, false, apps or 1)
               bIdx = bIdx + 1
               hasBuffs = true
            end
         end
         for i = bIdx, 8 do
            fs.auraFrames[i]:Hide()
         end
         local dIdx = 9
         for i = 1, 8 do
            local tex, apps = UnitDebuff(groupUnit, i)
            if tex and dIdx <= 16 then
               SetFocusAuraSlot(fs, dIdx, tex, true, apps or 1)
               dIdx = dIdx + 1
               hasDebuffs = true
            end
         end
         for i = dIdx, 16 do
            fs.auraFrames[i]:Hide()
         end
      else
         HideFocusAuras(fs)
      end
   elseif inView == 0 then
      fs.frame:SetAlpha(0.6)
      SetFocusClassificationBorder(fs, 0)
      fs.nameBG:SetVertexColor(0.4, 0.4, 0.4)
      fs.hp:SetMinMaxValues(0, 1)
      fs.hp:SetValue(0)
      fs.mana:SetMinMaxValues(0, 1)
      fs.mana:SetValue(0)
      fs.hpText:SetText('')
      fs.manaText:SetText('')
      fs.deadText:SetText('Out of Range')
      fs.deadText:Show()
      fs.levelText:SetText('')
      fs.distText:SetText('')
      fs.combatIcon:Hide()
      fs.tot:Hide()
      fs.cast:Hide()
      SetFocusCastAlert(fs, compact, false, 0)
      HideFocusAuras(fs)
      if not compact then
         SetPortraitToTexture(fs.portrait, 'Interface\\Icons\\Ability_Tracking')
      end
   else
      fs.frame:SetAlpha(1.0)
      if not compact then
         SetFocusClassificationBorder(fs, classification or 0)
         if UnitExists('target') and UnitName('target') == name then
            SetPortraitTexture(fs.portrait, 'target')
         else
            local iconPath = nil
            if isPlayer == 1 then
               iconPath = CLASS_PORTRAIT_ICONS[classOrType]
            else
               iconPath = CREATURE_PORTRAIT_ICONS[classOrType]
            end
            SetPortraitToTexture(fs.portrait, iconPath or 'Interface\\Icons\\Ability_Tracking')
         end
      end

      if reaction and reaction < 4 then
         if reaction < 3 then
            fs.nameBG:SetVertexColor(0.85, 0.15, 0.15)
         else
            fs.nameBG:SetVertexColor(0.85, 0.75, 0.15)
         end
      else
         fs.nameBG:SetVertexColor(0.15, 0.75, 0.2)
      end

      maxHp = (maxHp and maxHp > 0) and maxHp or 1
      hp = hp or 0
      fs.hp:SetMinMaxValues(0, maxHp)
      fs.hp:SetValue(hp)

      if hp <= 0 then
         if isPlayer ~= 1 and InteractDB.config.autoClearDeadFocus then
            Interact_ClearFocus(slot)
            return
         end
         fs.hpText:SetText('')
         fs.deadText:SetText('Dead')
         fs.deadText:Show()
      else
         fs.deadText:Hide()
         local pct = math.floor((hp * 100) / maxHp)
         if compact then
            fs.hpText:SetText(string.format('%d%%', pct))
         else
            fs.hpText:SetText(string.format('%d / %d (%d%%)', hp, maxHp, pct))
         end
      end

      local pc = POWER_COLORS[powerType or 0] or POWER_COLORS[0]
      fs.mana:SetStatusBarColor(pc[1], pc[2], pc[3])
      if maxPower and maxPower > 0 then
         fs.mana:SetMinMaxValues(0, maxPower)
         fs.mana:SetValue(power or 0)
         if not compact then
            fs.manaText:SetText(string.format('%d / %d', power or 0, maxPower))
         end
      else
         fs.mana:SetMinMaxValues(0, 1)
         fs.mana:SetValue(0)
         if not compact then
            fs.manaText:SetText('')
         end
      end

      if level and level > 0 then
         fs.levelText:SetText(tostring(level))
      else
         fs.levelText:SetText('??')
      end

      if dist and dist >= 0 then
         if inLoS == 0 then
            fs.distText:SetText(compact and string.format('|cffff4040%.0fy!|r', dist) or string.format('%.1f yd |cffff4040(No LoS)|r', dist))
         else
            fs.distText:SetText(compact and string.format('%.0fy', dist) or string.format('%.1f yd', dist))
         end
      else
         fs.distText:SetText('')
      end

      if InteractDB.config.dimOutOfRangeFocus and ((dist and dist > 40) or inLoS == 0) then
         fs.frame:SetAlpha(0.45)
      else
         fs.frame:SetAlpha(1.0)
      end

      if inCombat == 1 then
         fs.combatIcon:Show()
         fs.levelText:Hide()
      else
         fs.combatIcon:Hide()
         if not compact then
            fs.levelText:Show()
         else
            fs.levelText:Hide()
         end
      end

      local totName = nil
      local totHpPct = 0
      if totInfo and totInfo ~= '' then
         local sep = string.find(totInfo, ';', 1, true)
         if sep then
            totHpPct = tonumber(string.sub(totInfo, 1, sep - 1)) or 0
            totName = string.sub(totInfo, sep + 1)
         end
      end

      if not compact and InteractDB.config.showFocusToT and totName and totName ~= '' then
         fs.totNameText:SetText(totName)
         local tp = (totHpPct and totHpPct >= 0) and totHpPct or 0
         fs.totHP:SetValue(tp)
         fs.tot:Show()
      else
         fs.tot:Hide()
      end

      if InteractDB.config.showFocusAuras and auraIcons and auraIcons ~= '' then
         if auraIcons == fs.lastAuraIcons then
            hasBuffs = fs.lastHasBuffs
            hasDebuffs = fs.lastHasDebuffs
         else
            fs.lastAuraIcons = auraIcons
            local bIdx = 1
            local dIdx = 9
            local pos = 1
            local slen = string.len(auraIcons)
            while pos <= slen do
               local sep = string.find(auraIcons, '|', pos, true)
               local item = nil
               if sep then
                  item = string.sub(auraIcons, pos, sep - 1)
                  pos = sep + 1
               else
                  item = string.sub(auraIcons, pos)
                  pos = slen + 1
               end
               if item and item ~= '' then
                  local s1 = string.find(item, ';', 1, true)
                  local tex = s1 and string.sub(item, 1, s1 - 1) or item
                  local isDebuff = false
                  local stacks = 1
                  if s1 then
                     local s2 = string.find(item, ';', s1 + 1, true)
                     local dStr = s2 and string.sub(item, s1 + 1, s2 - 1) or string.sub(item, s1 + 1)
                     isDebuff = (tonumber(dStr) == 1)
                     if s2 then
                        stacks = tonumber(string.sub(item, s2 + 1)) or 1
                     end
                  end
                  if tex and tex ~= '' then
                     if isDebuff and dIdx <= 16 then
                        SetFocusAuraSlot(fs, dIdx, tex, true, stacks)
                        dIdx = dIdx + 1
                        hasDebuffs = true
                     elseif not isDebuff and bIdx <= 8 then
                        SetFocusAuraSlot(fs, bIdx, tex, false, stacks)
                        bIdx = bIdx + 1
                        hasBuffs = true
                     end
                  end
               end
            end
            for i = bIdx, 8 do
               fs.auraFrames[i]:Hide()
            end
            for i = dIdx, 16 do
               fs.auraFrames[i]:Hide()
            end
            fs.lastHasBuffs = hasBuffs
            fs.lastHasDebuffs = hasDebuffs
         end
      else
         HideFocusAuras(fs)
      end

      local castSpellId = 0
      local isChannel = 0
      local castSpellName = nil
      local castIcon = nil
      if castInfo and castInfo ~= '' then
         local c1 = string.find(castInfo, ';', 1, true)
         if c1 then
            castSpellId = tonumber(string.sub(castInfo, 1, c1 - 1)) or 0
            local c2 = string.find(castInfo, ';', c1 + 1, true)
            if c2 then
               isChannel = tonumber(string.sub(castInfo, c1 + 1, c2 - 1)) or 0
               local c3 = string.find(castInfo, ';', c2 + 1, true)
               if c3 then
                  castSpellName = string.sub(castInfo, c2 + 1, c3 - 1)
                  castIcon = string.sub(castInfo, c3 + 1)
               else
                  castSpellName = string.sub(castInfo, c2 + 1)
               end
            end
         end
      end

      if castSpellId and castSpellId > 0 and castSpellName and castSpellName ~= '' then
         if castSpellId ~= fs.lastSpellId then
            fs.lastSpellId = castSpellId
            fs.castStart = GetTime()
            if InteractDB.config.focusCastSound and PlaySound then
               PlaySound('RaidWarning')
            end
         end
         local elapsed = GetTime() - fs.castStart
         if InteractDB.config.focusCastAlert then
            local blink = 0.5 + 0.5 * math.sin(elapsed * 12.0)
            SetFocusCastAlert(fs, compact, true, blink)
         else
            SetFocusCastAlert(fs, compact, false, 0)
         end
         if InteractDB.config.showFocusCast then
            local yOff = compact and -2 or -4
            if hasDebuffs then
               yOff = compact and -36 or -42
            elseif hasBuffs then
               yOff = compact and -19 or -22
            end
            fs.cast:ClearAllPoints()
            fs.cast:SetPoint('TOPLEFT', fs.frame, 'BOTTOMLEFT', compact and 16 or 12, yOff)
            if isChannel == 1 then
               fs.cast:SetStatusBarColor(0.0, 0.7, 1.0)
            else
               fs.cast:SetStatusBarColor(1.0, 0.7, 0.0)
            end
            if castIcon and castIcon ~= '' then
               fs.castIconTex:SetTexture(castIcon)
               fs.castIconTex:Show()
            else
               fs.castIconTex:Hide()
            end
            local fill = elapsed - math.floor(elapsed / 2.0) * 2.0
            fs.cast:SetMinMaxValues(0, 2.0)
            fs.cast:SetValue(fill)
            fs.castText:SetText(string.format('%s (%.1fs)', castSpellName, elapsed))
            fs.cast:Show()
         else
            fs.castIconTex:Hide()
            fs.cast:Hide()
         end
      else
         fs.lastSpellId = 0
         SetFocusCastAlert(fs, compact, false, 0)
         fs.castIconTex:Hide()
         fs.cast:Hide()
      end
   end

   if raidMark and raidMark >= 1 and raidMark <= 8 then
      SetRaidTargetIconTexture(fs.raidIcon, raidMark)
      fs.raidIcon:Show()
   else
      fs.raidIcon:Hide()
   end

   fs.frame:Show()
end

local autoMarkTick = 0
local function UpdateFocusFrame()
   if InteractDB and InteractDB.config and InteractDB.config.autoFocusMarks and type(InteractNearest) == 'function' then
      autoMarkTick = autoMarkTick + 1
      if autoMarkTick >= 5 then
         autoMarkTick = 0
         local marked = InteractNearest(CMD_FOCUS_POPULATE_MARKS, 0) or 0
         if marked > 0 then
            for s = 1, 8 do
               if focusSlots[s] then focusSlots[s].isAssigned = true end
            end
         end
      end
   end
   for slot = 1, MAX_FOCUS_SLOTS do
      UpdateFocusSlot(slot)
   end
end

IA.RegisterFocusModule(UpdateFocusFrameStyle, UpdateFocusFrame)

