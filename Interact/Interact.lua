BINDING_HEADER_INTERACT = 'Interact'

StaticPopupDialogs['INTERACT_WARNING'] = {
   text = 'Failed to load |cffffd200Interact|cffffffff. Follow the installation instructions to ensure proper installation.',
   button1 = 'Okay',
   OnAccept = function()
      DisableAddOn('Interact')
      ReloadUI()
   end,
   timeout = 0,
   whileDead = true,
}

if not InteractNearest then
   StaticPopup_Show('INTERACT_WARNING')
end

-- ============================================================================
-- DLL Command Protocol (matches InteractCommand / ConfigKey in dllmain.cpp)
-- ============================================================================
local ADDON_VERSION            = '2.0.0'

local CMD_BLACKLIST_CLEAR      = 100
local CMD_BLACKLIST_ADD        = 101
local CMD_BLACKLIST_REMOVE     = 102
local CMD_BLACKLIST_LAST       = 103
local CMD_BLACKLIST_SYNC_BEGIN = 104
local CMD_SET_CONFIG           = 200
local CMD_RESET_CONFIG         = 201
local CMD_GET_VERSION          = 202
local CMD_SET_CONFIG           = 200
local CMD_RESET_CONFIG         = 201
local CMD_QUERY_NEAREST        = 300
local CMD_QUERY_STACK          = 301
local CMD_INTERACT_INDEX       = 302
local CMD_QUERY_SPARKLES       = 303
local CMD_FOCUS_SET            = 400
local CMD_FOCUS_CLEAR          = 401
local CMD_FOCUS_TARGET         = 402
local CMD_FOCUS_QUERY          = 403
local CMD_FOCUS_SWAP           = 404
local CMD_FOCUS_RESTORE        = 405
local CMD_FOCUS_TARGET_TOT     = 406
local CMD_FOCUS_SET_GUID       = 407
local CMD_FOCUS_GET_GUID       = 408
local CMD_FOCUS_POPULATE_MARKS = 409

local CONFIG_KEYS = {
   coneAngle        = 1,
   closeRange       = 2,
   cycleTime        = 3,
   interactEnemies  = 4,
   lootInCombat     = 5,
   prioritizeLoot   = 6,
   interactPlayers  = 7,
   ignorePassiveNPC = 8,
   skipLootedTarget = 9,
   ignoreChairs     = 10,
   ignoreSpellFocus = 11,
   ignoreMailboxes  = 12,
   ignoreDoors      = 13,
   ignoreRituals    = 14,
   ignoreGoobers    = 15,
   ignoreOtherGOs   = 16,
   enemyPlayersOOC  = 17,
   ownBobberOnly    = 18,
   restoreTarget    = 19,
   raidMarkPriority = 20,
   protectCCMarks   = 21,
   maxZDiff         = 22,
   ignoreCritters   = 23,
   losCheck         = 24,
   cameraCone       = 25,
   ignoreHerbs      = 26,
   ignoreOre        = 27,
   ignoreChests     = 28,
   ignoreTapped     = 29,
   prioritizeQuestOOC = 30,
   prioritizeLowHP  = 31,
   prioritizeCasting = 32,
   sparkleFov       = 33,
}

local DEFAULT_CONFIG = {
   coneAngle        = 106,
   closeRange       = 4.0,
   maxZDiff         = 3.5,
   cycleTime        = 3000,
   interactEnemies  = true,
   lootInCombat     = true,
   prioritizeLoot   = false,
   interactPlayers  = true,
   ignorePassiveNPC = false,
   skipLootedTarget = true,
   ignoreChairs     = false,
   ignoreSpellFocus = false,
   ignoreMailboxes  = false,
   ignoreDoors      = false,
   ignoreRituals    = false,
   ignoreGoobers    = false,
   ignoreOtherGOs   = false,
   enemyPlayersOOC  = false,
   ownBobberOnly    = true,
   restoreTarget    = false,
   raidMarkPriority = true,
   protectCCMarks   = true,
   ignoreCritters   = true,
   losCheck         = true,
   cameraCone       = false,
   ignoreHerbs      = false,
   ignoreOre        = false,
   ignoreChests     = false,
   ignoreTapped     = true,
   prioritizeQuestOOC = true,
   prioritizeLowHP  = false,
   prioritizeCasting = false,
   showPrompt       = true,
   showPromptStack  = true,
   lockPrompt       = true,
   promptX          = 0,
   promptY          = -140,
   promptScale      = 1.0,
   promptAlpha      = 0.72,
   autoProfile      = false,
   autoDismount     = true,
   interactToFish   = false,
   interactToMount  = false,
   autoSellGrey     = false,
   autoRepair       = false,
   showMinimap      = true,
   minimapAngle     = 220,
   enableFocus      = true,
   lockFocus        = false,
   showFocusToT     = true,
   showFocusCast    = true,
   showFocusAuras   = true,
   syncFocusGroup   = true,
   compactFocus     = false,
   autoFocusMarks   = false,
   focusCastAlert   = true,
   focusCastSound   = false,
   autoClearDeadFocus = false,
   dimOutOfRangeFocus = true,
   focusShiftSpell  = '',
   focusCtrlSpell   = '',
   focusAltSpell    = '',
   focusScale       = 1.0,
   focusX           = -260,
   focusY           = 120,
   showSparkles     = true,
   sparkleHerbs     = true,
   sparkleMines     = true,
   sparkleChests    = true,
   sparkleQuests    = true,
   sparkleFov       = 90,
}

local PROFILES = {
   questing = {
      label = 'Questing',
      values = {
         interactEnemies  = true,
         lootInCombat     = true,
         prioritizeLoot   = false,
         interactPlayers  = true,
         ignorePassiveNPC = false,
         skipLootedTarget = true,
         enemyPlayersOOC  = false,
         ownBobberOnly    = true,
         restoreTarget    = false,
         raidMarkPriority = true,
         protectCCMarks   = true,
         ignoreChairs     = true,
         ignoreSpellFocus = false,
         ignoreMailboxes  = false,
         ignoreDoors      = false,
         ignoreRituals    = false,
         ignoreGoobers    = false,
         ignoreOtherGOs   = false,
      },
   },
   raid = {
      label = 'Dungeon / Raid',
      values = {
         interactEnemies  = true,
         lootInCombat     = false,
         prioritizeLoot   = false,
         interactPlayers  = false,
         ignorePassiveNPC = true,
         skipLootedTarget = true,
         enemyPlayersOOC  = false,
         restoreTarget    = false,
         raidMarkPriority = true,
         protectCCMarks   = true,
         ignoreChairs     = true,
         ignoreSpellFocus = true,
         ignoreMailboxes  = true,
         ignoreDoors      = false,
         ignoreRituals    = false,
         ignoreGoobers    = false,
         ignoreOtherGOs   = true,
      },
   },
   gathering = {
      label = 'Gathering',
      values = {
         interactEnemies  = false,
         lootInCombat     = true,
         prioritizeLoot   = true,
         interactPlayers  = false,
         ignorePassiveNPC = true,
         skipLootedTarget = true,
         enemyPlayersOOC  = false,
         ownBobberOnly    = true,
         ignoreChairs     = true,
         ignoreSpellFocus = true,
         ignoreMailboxes  = true,
         ignoreDoors      = true,
         ignoreRituals    = true,
         ignoreGoobers    = true,
         ignoreOtherGOs   = true,
      },
   },
   city = {
      label = 'City / Safe',
      values = {
         interactEnemies  = false,
         lootInCombat     = false,
         prioritizeLoot   = false,
         interactPlayers  = true,
         ignorePassiveNPC = false,
         skipLootedTarget = true,
         enemyPlayersOOC  = false,
         ignoreChairs     = true,
         ignoreSpellFocus = true,
         ignoreMailboxes  = false,
         ignoreDoors      = false,
         ignoreRituals    = true,
         ignoreGoobers    = false,
         ignoreOtherGOs   = false,
      },
   },
}

local DEFAULT_BLACKLIST = {
   [179830] = true,
   [179831] = true,
   [179785] = true,
   [179786] = true,
}

local PREFIX = '|cff00ccff[Interact]|r '

local function PrintMsg(msg)
   if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. tostring(msg))
   end
end

local function CopyTable(src)
   local dst = {}
   for k, v in pairs(src) do
      dst[k] = v
   end
   return dst
end

local function EnsureDB()
   if type(InteractDB) ~= 'table' then
      InteractDB = {}
   end
   if type(InteractDB.config) ~= 'table' then
      InteractDB.config = CopyTable(DEFAULT_CONFIG)
   else
      for k, v in pairs(DEFAULT_CONFIG) do
         if InteractDB.config[k] == nil or type(InteractDB.config[k]) ~= type(v) then
            InteractDB.config[k] = v
         end
      end
   end
   if type(InteractDB.blacklist) ~= 'table' then
      InteractDB.blacklist = CopyTable(DEFAULT_BLACKLIST)
   end
   if type(InteractDB.profiles) ~= 'table' then
      InteractDB.profiles = {}
   end
   if type(InteractDB.customProfiles) ~= 'table' then
      InteractDB.customProfiles = {}
   end
   if type(InteractCharDB) ~= 'table' then
      InteractCharDB = {}
   end
end

local function ToDllVal(v)
   if type(v) == 'boolean' then
      if v then return 1 else return 0 end
   end
   return tonumber(v) or 0
end

local function SyncSettingToDLL(key, value)
   if not InteractNearest then return end
   local keyId = CONFIG_KEYS[key]
   if keyId then
      InteractNearest(CMD_SET_CONFIG, keyId, ToDllVal(value))
   end
end

local UpdatePromptPosition = nil
local UpdatePromptStyle = nil
local UpdateMinimapButton = nil
local UpdateFocusFrameStyle = nil
local activeProfileName = nil

local function SyncAllToDLL()
   if not InteractNearest then return end
   EnsureDB()

   for key, _ in pairs(CONFIG_KEYS) do
      SyncSettingToDLL(key, InteractDB.config[key])
   end

   InteractNearest(CMD_BLACKLIST_SYNC_BEGIN)
   for id, enabled in pairs(InteractDB.blacklist) do
      local numId = tonumber(id)
      if enabled and numId and numId > 0 then
         InteractNearest(CMD_BLACKLIST_ADD, numId)
      end
   end

   if UpdatePromptPosition then UpdatePromptPosition() end
   if UpdatePromptStyle then UpdatePromptStyle() end
end

local function SetConfigValue(key, value)
   EnsureDB()
   if key == 'coneAngle' then
      value = math.floor(tonumber(value) or DEFAULT_CONFIG.coneAngle)
      if value < 15 then value = 15 end
      if value > 180 then value = 180 end
   elseif key == 'closeRange' or key == 'maxZDiff' then
      value = tonumber(value)
      if value == nil then value = DEFAULT_CONFIG[key] end
      value = math.floor(value * 2 + 0.5) / 2
      local maxLim = (key == 'maxZDiff') and 20 or 8
      if value < 0 then value = 0 end
      if value > maxLim then value = maxLim end
   elseif key == 'cycleTime' then
      value = math.floor(tonumber(value) or DEFAULT_CONFIG.cycleTime)
      if value < 0 then value = 0 end
      if value > 10000 then value = 10000 end
   elseif key == 'promptX' then
      value = math.floor(tonumber(value) or DEFAULT_CONFIG.promptX)
      if value < -600 then value = -600 end
      if value > 600 then value = 600 end
   elseif key == 'promptY' then
      value = math.floor(tonumber(value) or DEFAULT_CONFIG.promptY)
      if value < -450 then value = -450 end
      if value > 450 then value = 450 end
   elseif key == 'promptScale' then
      value = tonumber(value) or DEFAULT_CONFIG.promptScale
      value = math.floor(value * 20 + 0.5) / 20
      if value < 0.7 then value = 0.7 end
      if value > 1.5 then value = 1.5 end
   elseif key == 'promptAlpha' then
      value = tonumber(value) or DEFAULT_CONFIG.promptAlpha
      value = math.floor(value * 20 + 0.5) / 20
      if value < 0.0 then value = 0.0 end
      if value > 1.0 then value = 1.0 end
   elseif key == 'minimapAngle' then
      value = tonumber(value) or DEFAULT_CONFIG.minimapAngle
      value = math.mod(value, 360)
      if value < 0 then value = value + 360 end
   elseif key == 'sparkleFov' then
      value = math.floor(tonumber(value) or DEFAULT_CONFIG.sparkleFov)
      if value < 40 then value = 40 end
      if value > 150 then value = 150 end
   elseif key == 'focusScale' then
      value = tonumber(value) or DEFAULT_CONFIG.focusScale
      value = math.floor(value * 20 + 0.5) / 20
      if value < 0.4 then value = 0.4 end
      if value > 1.5 then value = 1.5 end
   elseif key == 'focusX' then
      value = math.floor(tonumber(value) or DEFAULT_CONFIG.focusX)
      if value < -800 then value = -800 end
      if value > 800 then value = 800 end
   elseif key == 'focusY' then
      value = math.floor(tonumber(value) or DEFAULT_CONFIG.focusY)
      if value < -500 then value = -500 end
      if value > 500 then value = 500 end
   elseif key == 'focusShiftSpell' or key == 'focusCtrlSpell' or key == 'focusAltSpell' then
      value = tostring(value or '')
   else
      value = not not value
   end

   InteractDB.config[key] = value
   SyncSettingToDLL(key, value)
   if (key == 'promptX' or key == 'promptY') and UpdatePromptPosition then
      UpdatePromptPosition()
   elseif (key == 'promptScale' or key == 'promptAlpha' or key == 'lockPrompt') and UpdatePromptStyle then
      UpdatePromptStyle()
   elseif (key == 'showMinimap' or key == 'minimapAngle') and UpdateMinimapButton then
      UpdateMinimapButton()
   elseif (key == 'enableFocus' or key == 'lockFocus' or key == 'showFocusToT' or key == 'showFocusCast' or key == 'showFocusAuras' or key == 'compactFocus' or key == 'focusScale' or key == 'focusX' or key == 'focusY') and UpdateFocusFrameStyle then
      UpdateFocusFrameStyle()
   end
   return value
end

local MAX_BLACKLIST_ENTRIES = 500
local MAX_CUSTOM_PROFILES   = 30

local function CountTableEntries(tbl)
   local n = 0
   if type(tbl) == 'table' then
      for _, v in pairs(tbl) do
         if v then n = n + 1 end
      end
   end
   return n
end

local function AddBlacklistID(id, name)
   EnsureDB()
   local numId = math.floor(tonumber(id) or 0)
   if numId <= 0 or numId > 2147483647 then
      return false
   end
   if not InteractDB.blacklist[numId] and CountTableEntries(InteractDB.blacklist) >= MAX_BLACKLIST_ENTRIES then
      PrintMsg('Blacklist limit reached (' .. MAX_BLACKLIST_ENTRIES .. ' entries).')
      return false
   end
   if type(name) == 'string' and name ~= '' then
      InteractDB.blacklist[numId] = name
   elseif type(InteractDB.blacklist[numId]) ~= 'string' then
      InteractDB.blacklist[numId] = true
   end
   if InteractNearest then
      InteractNearest(CMD_BLACKLIST_ADD, numId)
   end
   return numId
end

local function RemoveBlacklistID(id)
   EnsureDB()
   local numId = math.floor(tonumber(id) or 0)
   if numId <= 0 then
      return false
   end
   InteractDB.blacklist[numId] = nil
   if InteractNearest then
      InteractNearest(CMD_BLACKLIST_REMOVE, numId)
   end
   return numId
end

local function ClearBlacklist()
   EnsureDB()
   InteractDB.blacklist = {}
   if InteractNearest then
      InteractNearest(CMD_BLACKLIST_CLEAR)
   end
end

local function ResetAllDefaults()
   local savedProfiles = (InteractDB and InteractDB.profiles) or {}
   local savedCustom = (InteractDB and InteractDB.customProfiles) or {}
   InteractDB = {
      config = CopyTable(DEFAULT_CONFIG),
      blacklist = CopyTable(DEFAULT_BLACKLIST),
      profiles = savedProfiles,
      customProfiles = savedCustom,
   }
   activeProfileName = nil
   if type(InteractCharDB) == 'table' then
      InteractCharDB.activeProfile = nil
   end
   if InteractNearest then
      InteractNearest(CMD_RESET_CONFIG)
   end
   SyncAllToDLL()
   if UpdateMinimapButton then UpdateMinimapButton() end
end

local function IsProfileCustomized(profileKey)
   EnsureDB()
   return type(InteractDB.profiles[profileKey]) == 'table'
end

local function ApplyProfile(profileKey, isAuto)
   EnsureDB()
   local p = PROFILES[profileKey]
   local values = nil
   local label = nil
   if p then
      values = InteractDB.profiles[profileKey] or p.values
      label = p.label
   elseif InteractDB.customProfiles[profileKey] then
      values = InteractDB.customProfiles[profileKey].values
      label = InteractDB.customProfiles[profileKey].label or profileKey
   else
      return false
   end

   for k, v in pairs(values) do
      InteractDB.config[k] = v
      SyncSettingToDLL(k, v)
   end
   activeProfileName = label
   if not isAuto then
      InteractCharDB.activeProfile = profileKey
   end
   if UpdatePromptPosition then UpdatePromptPosition() end
   if UpdatePromptStyle then UpdatePromptStyle() end
   if UpdateMinimapButton then UpdateMinimapButton() end
   return label
end

local function SaveProfile(profileKey)
   EnsureDB()
   if not profileKey or profileKey == '' then
      return false
   end
   if string.len(profileKey) > 32 then
      profileKey = string.sub(profileKey, 1, 32)
   end
   local snap = {}
   for k, _ in pairs(DEFAULT_CONFIG) do
      snap[k] = InteractDB.config[k]
   end
   local p = PROFILES[profileKey]
   if p then
      InteractDB.profiles[profileKey] = snap
      return p.label, false
   else
      if not InteractDB.customProfiles[profileKey] and CountTableEntries(InteractDB.customProfiles) >= MAX_CUSTOM_PROFILES then
         PrintMsg('Custom profile limit reached (' .. MAX_CUSTOM_PROFILES .. ' profiles).')
         return false
      end
      InteractDB.customProfiles[profileKey] = { label = profileKey, values = snap }
      return profileKey, true
   end
end

local function ResetProfile(profileKey)
   EnsureDB()
   if profileKey == 'all' then
      InteractDB.profiles = {}
      return 'All Profiles'
   end
   local p = PROFILES[profileKey]
   if not p then
      return false
   end
   InteractDB.profiles[profileKey] = nil
   return p.label
end

local function DeleteCustomProfile(profileKey)
   EnsureDB()
   if not profileKey or not InteractDB.customProfiles[profileKey] then
      return false
   end
   InteractDB.customProfiles[profileKey] = nil
   return profileKey
end

local function ExportProfileString()
   EnsureDB()
   local keys = {}
   for k, _ in pairs(DEFAULT_CONFIG) do
      table.insert(keys, k)
   end
   table.sort(keys)
   local parts = {}
   for _, k in ipairs(keys) do
      local v = InteractDB.config[k]
      if type(v) == 'boolean' then
         table.insert(parts, k .. '=' .. (v and '1' or '0'))
      else
         table.insert(parts, k .. '=' .. tostring(v))
      end
   end
   return 'IM1:' .. table.concat(parts, ';')
end

local function ImportProfileString(str)
   if type(str) ~= 'string' or str == '' then
      return nil, 'Empty import string.'
   end
   local _, _, body = string.find(str, '^%s*IM1:(.+)%s*$')
   if not body then
      return nil, 'Invalid format (must start with IM1:).'
   end
   EnsureDB()
   local RISKY_IMPORT_KEYS = {
      autoSellGrey = true,
      autoRepair = true,
      interactEnemies = true,
      enemyPlayersOOC = true,
   }
   local riskyChanged = {}
   local count = 0
   local pos = 1
   local len = string.len(body)
   while pos <= len do
      local semi = string.find(body, ';', pos, true)
      local token = nil
      if semi then
         token = string.sub(body, pos, semi - 1)
         pos = semi + 1
      else
         token = string.sub(body, pos)
         pos = len + 1
      end
      local _, _, k, v = string.find(token, '^%s*([%w_]+)%s*=%s*(.-)%s*$')
      if k and DEFAULT_CONFIG[k] ~= nil then
         if type(DEFAULT_CONFIG[k]) == 'boolean' then
            local newVal = (v == '1' or string.lower(v) == 'true')
            if RISKY_IMPORT_KEYS[k] and newVal and not InteractDB.config[k] then
               table.insert(riskyChanged, k)
            end
            SetConfigValue(k, newVal)
            count = count + 1
         else
            local num = tonumber(v)
            if num then
               SetConfigValue(k, num)
               count = count + 1
            end
         end
      end
   end
   if count == 0 then
      return nil, 'No valid settings found in import string.'
   end
   if table.getn(riskyChanged) > 0 then
      PrintMsg('|cffff8040Notice:|r Imported profile enabled: |cffffd200' .. table.concat(riskyChanged, ', ') .. '|r.')
   end
   return count
end

local function GetBlacklistEntries()
   EnsureDB()
   local list = {}
   for id, val in pairs(InteractDB.blacklist) do
      if val then
         local numId = tonumber(id)
         if numId and numId > 0 then
            table.insert(list, { id = numId, name = (type(val) == 'string' and val) or nil })
         end
      end
   end
   table.sort(list, function(a, b) return a.id < b.id end)
   return list
end

local function GetSortedBlacklist()
   EnsureDB()
   local list = {}
   for id, enabled in pairs(InteractDB.blacklist) do
      if enabled then
         table.insert(list, tonumber(id))
      end
   end
   table.sort(list)
   return list
end

-- ============================================================================
-- Settings UI Frame (Vanilla 1.12.1 Compatible)
-- ============================================================================
local configFrame = nil
local isRefreshingUI = false
local uiCheckboxes = {}
local uiSliders = {}
local uiProfileButtons = {}
local uiBlacklistRows = {}
local uiBlacklistPageText = nil
local uiBlacklistPrevBtn = nil
local uiBlacklistNextBtn = nil
local blPage = 1
local BL_PER_PAGE = 4
local SelectConfigTab = nil
local activeConfigTab = 1
local ToggleProfileIOFrame = nil
local RefreshProfileIOFrame = nil
local RefreshFocusSpellButtons = nil

local function RefreshUI()
   if not configFrame then return end
   EnsureDB()
   isRefreshingUI = true

   for _, item in ipairs(uiSliders) do
      local val = InteractDB.config[item.key]
      item.slider:SetValue(val)
      item.label:SetText(string.format(item.fmt, val))
   end

   for _, item in ipairs(uiCheckboxes) do
      if InteractDB.config[item.key] then
         item.cb:SetChecked(1)
      else
         item.cb:SetChecked(0)
      end
   end

   for _, pbtn in ipairs(uiProfileButtons) do
      local text = pbtn.label
      if IsProfileCustomized(pbtn.key) then
         text = text .. ' *'
      end
      if activeProfileName == pbtn.label then
         pbtn.btn:SetText('|cff00ff00> ' .. text .. ' <|r')
      else
         pbtn.btn:SetText(text)
      end
   end

   if table.getn(uiBlacklistRows) > 0 then
      local entries = GetBlacklistEntries()
      local total = table.getn(entries)
      local maxPage = math.ceil(total / BL_PER_PAGE)
      if maxPage < 1 then maxPage = 1 end
      if blPage > maxPage then blPage = maxPage end
      if blPage < 1 then blPage = 1 end

      local startIdx = (blPage - 1) * BL_PER_PAGE
      for i = 1, BL_PER_PAGE do
         local row = uiBlacklistRows[i]
         local entry = entries[startIdx + i]
         if entry then
            row.entryId = entry.id
            if entry.name then
               row.text:SetText(entry.name .. ' |cffaaaaaa(ID ' .. entry.id .. ')|r')
            else
               row.text:SetText('Entry ID ' .. entry.id)
            end
            row.frame:Show()
         else
            row.entryId = nil
            row.frame:Hide()
         end
      end
      if uiBlacklistPageText then
         uiBlacklistPageText:SetText(string.format('%d entries  (Page %d/%d)', total, blPage, maxPage))
      end
      if uiBlacklistPrevBtn then
         if blPage > 1 then uiBlacklistPrevBtn:Enable() else uiBlacklistPrevBtn:Disable() end
      end
      if uiBlacklistNextBtn then
         if blPage < maxPage then uiBlacklistNextBtn:Enable() else uiBlacklistNextBtn:Disable() end
      end
   end

   if RefreshProfileIOFrame then RefreshProfileIOFrame() end
   if RefreshFocusSpellButtons then RefreshFocusSpellButtons() end

   isRefreshingUI = false
end

local function CreateSectionHeader(parent, text, x, y)
   local fs = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
   fs:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
   fs:SetText(text)
   return fs
end

local function CreateSlider(parent, name, key, labelText, fmt, minVal, maxVal, step, lowText, highText, x, y)
   local slider = CreateFrame('Slider', name, parent, 'OptionsSliderTemplate')
   slider:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
   slider:SetWidth(190)
   slider:SetHeight(17)
   slider:SetMinMaxValues(minVal, maxVal)
   slider:SetValueStep(step)

   local label = getglobal(name .. 'Text')
   local low = getglobal(name .. 'Low')
   local high = getglobal(name .. 'High')
   if low then low:SetText(lowText) end
   if high then high:SetText(highText) end

   slider:SetScript('OnValueChanged', function()
      if isRefreshingUI then return end
      local v = SetConfigValue(key, this:GetValue())
      if label then
         label:SetText(string.format(fmt, v))
      end
   end)

   table.insert(uiSliders, { slider = slider, key = key, label = label, fmt = fmt })
   return slider
end

local function CreateCheckbox(parent, name, key, labelText, tooltipText, x, y)
   local cb = CreateFrame('CheckButton', name, parent, 'OptionsCheckButtonTemplate')
   cb:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
   cb:SetWidth(24)
   cb:SetHeight(24)

   local textObj = getglobal(name .. 'Text')
   if textObj then
      textObj:SetText(labelText)
   end

   cb:SetScript('OnClick', function()
      if isRefreshingUI then return end
      local checked = (this:GetChecked() ~= nil)
      SetConfigValue(key, checked)
   end)

   if tooltipText then
      cb:SetScript('OnEnter', function()
         GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
         GameTooltip:SetText(labelText, 1, 0.82, 0)
         GameTooltip:AddLine(tooltipText, 1, 1, 1, 1)
         GameTooltip:Show()
      end)
      cb:SetScript('OnLeave', function()
         GameTooltip:Hide()
      end)
   end

   table.insert(uiCheckboxes, { cb = cb, key = key })
   return cb
end

local function BuildConfigUI()
   if configFrame then return configFrame end

   local f = CreateFrame('Frame', 'InteractConfigFrame', UIParent)
   f:SetWidth(476)
   f:SetHeight(545)
   f:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
   f:SetFrameStrata('DIALOG')
   f:SetMovable(true)
   f:EnableMouse(true)
   f:RegisterForDrag('LeftButton')
   f:SetScript('OnDragStart', function() this:StartMoving() end)
   f:SetScript('OnDragStop', function() this:StopMovingOrSizing() end)
   f:SetBackdrop({
      bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
      edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
   })
   f:Hide()

   table.insert(UISpecialFrames, 'InteractConfigFrame')

   local title = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightLarge')
   title:SetPoint('TOP', f, 'TOP', 0, -16)
   title:SetText('InteractMod v' .. ADDON_VERSION)

   local closeBtn = CreateFrame('Button', 'InteractConfigCloseButton', f, 'UIPanelCloseButton')
   closeBtn:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -6, -6)

   -- Quick Profiles (always visible at top)
   CreateSectionHeader(f, 'Quick Profiles  |cffaaaaaa(Click: Load, Shift+Click: Save, Right-Click: Reset)|r', 22, -44)
   local profileOrder = {
      { key = 'questing',  label = 'Questing',       w = 90 },
      { key = 'raid',      label = 'Dungeon / Raid', w = 116 },
      { key = 'gathering', label = 'Gathering',      w = 94 },
      { key = 'city',      label = 'City / Safe',    w = 96 },
   }
   local px = 22
   for _, pinfo in ipairs(profileOrder) do
      local pKey = pinfo.key
      local pLabel = pinfo.label
      local btn = CreateFrame('Button', 'InteractProfileBtn_' .. pKey, f, 'UIPanelButtonTemplate')
      btn:SetWidth(pinfo.w)
      btn:SetHeight(22)
      btn:SetPoint('TOPLEFT', f, 'TOPLEFT', px, -62)
      btn:SetText(pLabel)
      btn:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
      btn:SetScript('OnClick', function()
         if arg1 == 'RightButton' then
            ResetProfile(pKey)
            RefreshUI()
            PrintMsg('Reset profile |cffffd200' .. pLabel .. '|r to built-in defaults.')
         elseif IsShiftKeyDown() then
            SaveProfile(pKey)
            RefreshUI()
            PrintMsg('Saved current settings to profile |cffffd200' .. pLabel .. '|r.')
         else
            local label = ApplyProfile(pKey)
            if label then
               RefreshUI()
               PrintMsg('Applied profile: |cffffd200' .. label .. '|r')
            end
         end
      end)
      btn:SetScript('OnEnter', function()
         GameTooltip:SetOwner(this, 'ANCHOR_BOTTOM')
         GameTooltip:SetText(pLabel, 1, 0.82, 0)
         GameTooltip:AddLine('Left-Click: Apply profile', 1, 1, 1)
         GameTooltip:AddLine('Shift+Left-Click: Save current settings to this profile', 0.4, 1, 0.4)
         GameTooltip:AddLine('Right-Click: Reset profile to built-in defaults', 1, 0.5, 0.5)
         GameTooltip:Show()
      end)
      btn:SetScript('OnLeave', function()
         GameTooltip:Hide()
      end)
      table.insert(uiProfileButtons, { key = pKey, label = pLabel, btn = btn })
      px = px + pinfo.w + 8
   end

   -- Category Tabs
   local tabFrames = {}
   local tabButtons = {}
   local tabDefs = {
      { id = 1, label = 'Targeting',          w = 104 },
      { id = 2, label = 'Filters & QoL',      w = 108 },
      { id = 3, label = 'Prompt & Blacklist', w = 132 },
      { id = 4, label = 'Focus',              w = 72 },
   }

   SelectConfigTab = function(tabId)
      activeConfigTab = tabId
      for i = 1, table.getn(tabFrames) do
         if i == tabId then
            tabFrames[i]:Show()
            tabButtons[i]:Disable()
         else
            tabFrames[i]:Hide()
            tabButtons[i]:Enable()
         end
      end
      if InteractAddon.UpdateFocusFrame then
         InteractAddon.UpdateFocusFrame(true)
      end
   end

   local tx = 22
   for _, tdef in ipairs(tabDefs) do
      local tId = tdef.id
      local tbtn = CreateFrame('Button', 'InteractTabBtn_' .. tId, f, 'UIPanelButtonTemplate')
      tbtn:SetWidth(tdef.w)
      tbtn:SetHeight(22)
      tbtn:SetPoint('TOPLEFT', f, 'TOPLEFT', tx, -94)
      tbtn:SetText(tdef.label)
      tbtn:SetScript('OnClick', function()
         SelectConfigTab(tId)
      end)
      tabButtons[tId] = tbtn

      local tf = CreateFrame('Frame', 'InteractTabFrame_' .. tId, f)
      tf:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, -122)
      tf:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 48)
      tf:Hide()
      tabFrames[tId] = tf

      tx = tx + tdef.w + 8
   end

   -- =========================================================================
   -- TAB 1: Targeting (Cone, Cycling, Combat & Rules)
   -- =========================================================================
   local t1 = tabFrames[1]
   CreateSectionHeader(t1, 'Cone & Cycling', 22, -4)
   CreateSlider(t1, 'InteractConeSlider', 'coneAngle', 'Cone Half-Angle', 'Cone Half-Angle: %d deg', 15, 180, 1, '15', '180', 26, -34)
   CreateSlider(t1, 'InteractCloseRangeSlider', 'closeRange', 'Close Proximity', 'Close Proximity: %.1f yd', 0, 8, 0.5, '0 yd', '8 yd', 248, -34)
   CreateSlider(t1, 'InteractCycleSlider', 'cycleTime', 'Cycle Window', 'Cycle Penalty: %d ms', 0, 10000, 250, '0s', '10s', 26, -82)
   CreateSlider(t1, 'InteractMaxZSlider', 'maxZDiff', 'Max Vertical Diff', 'Max Z Diff: %.1f yd', 0, 10, 0.5, 'Off', '10 yd', 248, -82)

   CreateSectionHeader(t1, 'Combat & Targeting', 22, -124)
   CreateCheckbox(t1, 'InteractCBEnemies', 'interactEnemies', 'Interact with Enemies', 'Allow attacking/targeting hostile or neutral enemies.', 22, -144)
   CreateCheckbox(t1, 'InteractCBLootCombat', 'lootInCombat', 'Loot / Gather in Combat', 'Allow looting, skinning, and gathering while in combat.', 22, -168)
   CreateCheckbox(t1, 'InteractCBPrioLoot', 'prioritizeLoot', 'Prioritize Loot in Combat', 'Prefer lootable corpses over living enemies during combat.', 22, -192)
   CreateCheckbox(t1, 'InteractCBPlayers', 'interactPlayers', 'Interact with Friendly Players', 'Allow targeting friendly players when nothing else is in range.', 22, -216)
   CreateCheckbox(t1, 'InteractCBPassiveNPC', 'ignorePassiveNPC', 'Ignore Passive NPCs', 'Ignore friendly NPCs without quest, vendor, gossip, or trainer flags.', 22, -240)
   CreateCheckbox(t1, 'InteractCBSkipLooted', 'skipLootedTarget', 'Skip Empty Dead Target', 'If your hard target is dead and empty, scan for nearby interactables.', 22, -264)
   CreateCheckbox(t1, 'InteractCBPrioCasting', 'prioritizeCasting', 'Prioritize Casting Enemies', 'Boost enemies currently casting or channeling a spell in combat.', 22, -288)

   CreateSectionHeader(t1, 'Targeting Rules', 248, -124)
   CreateCheckbox(t1, 'InteractCBEnemyPlayersOOC', 'enemyPlayersOOC', 'Enemy Players OOC', 'Allow attacking opposing-faction players while out of combat (unsafe in neutral towns).', 248, -144)
   CreateCheckbox(t1, 'InteractCBRestoreTarget', 'restoreTarget', 'Restore Previous Target', 'Re-target your previous target after looting or talking (note: clears combo points).', 248, -168)
   CreateCheckbox(t1, 'InteractCBRaidMarks', 'raidMarkPriority', 'Prioritize Skull / Cross', 'Boost Skull and Cross kill targets.', 248, -192)
   CreateCheckbox(t1, 'InteractCBProtectCC', 'protectCCMarks', 'Protect CC Raid Marks', 'Skip Moon, Square, Star, and Diamond marked enemies.', 248, -216)
   CreateCheckbox(t1, 'InteractCBLoSCheck', 'losCheck', 'Line-of-Sight Check', 'Skip targets blocked by walls or terrain.', 248, -240)
   CreateCheckbox(t1, 'InteractCBCameraCone', 'cameraCone', 'Camera-Relative Cone', 'Aim the interaction cone along your camera direction instead of character facing.', 248, -264)
   CreateCheckbox(t1, 'InteractCBTapped', 'ignoreTapped', 'Skip Tapped Enemies', 'Skip living enemies out of combat that are already tagged by another player.', 248, -288)
   CreateCheckbox(t1, 'InteractCBPrioQuest', 'prioritizeQuestOOC', 'Prioritize Questgivers OOC', 'Prefer Questgiver NPCs and Objects over enemies while out of combat.', 248, -312)
   CreateCheckbox(t1, 'InteractCBPrioLowHP', 'prioritizeLowHP', 'Prioritize Low-HP (<25%)', 'Boost enemies below 25% health in combat to finish them off.', 248, -336)

   -- =========================================================================
   -- TAB 2: Filters & QoL
   -- =========================================================================
   local t2 = tabFrames[2]
   CreateSectionHeader(t2, 'Creatures & Gatherables', 22, -4)
   CreateCheckbox(t2, 'InteractCBCritters', 'ignoreCritters', 'Ignore Critters & Pets', 'Skip level-1 critters and non-combat companion pets.', 22, -26)
   CreateCheckbox(t2, 'InteractCBHerbs', 'ignoreHerbs', 'Ignore Herbs', 'Skip Herbalism flower nodes.', 22, -50)
   CreateCheckbox(t2, 'InteractCBOre', 'ignoreOre', 'Ignore Ore Veins', 'Skip Mining ore veins and deposits.', 22, -74)
   CreateCheckbox(t2, 'InteractCBChests', 'ignoreChests', 'Ignore Chests / Crates', 'Skip chests, lockboxes, and lootable containers.', 22, -98)
   CreateCheckbox(t2, 'InteractCBOwnBobber', 'ownBobberOnly', 'Own Fishing Bobber Only', 'Ignore other players\' fishing bobbers.', 22, -122)

   CreateSectionHeader(t2, 'World Objects', 248, -4)
   CreateCheckbox(t2, 'InteractCBChairs', 'ignoreChairs', 'Ignore Chairs & Benches', 'Skip sit-able chairs and benches (type 7).', 248, -26)
   CreateCheckbox(t2, 'InteractCBCampfires', 'ignoreSpellFocus', 'Ignore Campfires / Forges', 'Skip campfires, anvils, forges, and moonwells (type 8).', 248, -50)
   CreateCheckbox(t2, 'InteractCBMailboxes', 'ignoreMailboxes', 'Ignore Mailboxes', 'Skip mailboxes (type 19).', 248, -74)
   CreateCheckbox(t2, 'InteractCBDoors', 'ignoreDoors', 'Ignore Doors', 'Skip doors (type 0).', 248, -98)
   CreateCheckbox(t2, 'InteractCBRituals', 'ignoreRituals', 'Ignore Summoning Portals', 'Skip Warlock summoning portals and rituals (type 18).', 248, -122)
   CreateCheckbox(t2, 'InteractCBGoobers', 'ignoreGoobers', 'Ignore Goobers', 'Skip goober objects (triggers, some portals/world props, type 10).', 248, -146)
   CreateCheckbox(t2, 'InteractCBOtherGOs', 'ignoreOtherGOs', 'Ignore Other Objects', 'Skip uncategorized miscellaneous GameObjects.', 248, -170)

   CreateSectionHeader(t2, 'Automation & QoL', 22, -206)
   CreateCheckbox(t2, 'InteractCBAutoProfile', 'autoProfile', 'Auto-Switch Profile by Zone', 'Automatically apply Dungeon/Raid in instances, City/Safe in capitals, and Questing elsewhere.', 22, -228)
   CreateCheckbox(t2, 'InteractCBAutoDismount', 'autoDismount', 'Auto-Dismount on Interact', 'Automatically cancel mount buff when pressing Interact on a nearby target.', 22, -252)
   CreateCheckbox(t2, 'InteractCBInteractFish', 'interactToFish', 'Interact-to-Fish', 'Cast Fishing when pressing Interact with a Fishing Pole equipped and nothing nearby.', 22, -276)
   CreateCheckbox(t2, 'InteractCBMinimap', 'showMinimap', 'Show Minimap Button', 'Show a draggable minimap button for quick settings and profile cycling.', 22, -300)
   CreateCheckbox(t2, 'InteractCBInteractMount', 'interactToMount', 'Interact-to-Mount (OOC)', 'Mount up when pressing Interact out of combat with nothing nearby.', 22, -324)

   CreateSectionHeader(t2, 'Custom Profiles & Sharing', 248, -206)
   local ioBtn = CreateFrame('Button', 'InteractOpenProfileIOBtn', t2, 'UIPanelButtonTemplate')
   ioBtn:SetWidth(185)
   ioBtn:SetHeight(24)
   ioBtn:SetPoint('TOPLEFT', t2, 'TOPLEFT', 248, -230)
   ioBtn:SetText('Custom / Export / Import')
   ioBtn:SetScript('OnClick', function()
      if ToggleProfileIOFrame then ToggleProfileIOFrame() end
   end)
   CreateCheckbox(t2, 'InteractCBAutoSellGrey', 'autoSellGrey', 'Auto-Sell Grey Items', 'Automatically sell poor-quality (grey) items when opening a vendor.', 248, -264)
   CreateCheckbox(t2, 'InteractCBAutoRepair', 'autoRepair', 'Auto-Repair at Merchants', 'Automatically repair all equipment when opening a repair vendor.', 248, -288)

   -- =========================================================================
   -- TAB 3: Prompt & Blacklist
   -- =========================================================================
   local t3 = tabFrames[3]
   CreateSectionHeader(t3, 'Soft-Target On-Screen Prompt', 22, -4)
   CreateCheckbox(t3, 'InteractCBPrompt', 'showPrompt', 'Show Soft-Target Prompt', 'Show an on-screen prompt for the nearest interactable.', 22, -24)
   CreateCheckbox(t3, 'InteractCBLockPrompt', 'lockPrompt', 'Lock Prompt Position', 'Lock prompt dragging outside this settings window (always draggable while this window is open).', 248, -24)
   CreateCheckbox(t3, 'InteractCBPromptStack', 'showPromptStack', 'Show Multi-Target Stack (Top 3)', 'Show up to 2 extra clickable nearby targets below the main prompt.', 22, -46)
   CreateCheckbox(t3, 'InteractCBSparkles', 'showSparkles', 'Show 3D World Sparkles', 'Show 3D-projected sparkles over nearby herbs, mines, chests, and active quest objects.', 248, -46)

   CreateSlider(t3, 'InteractPromptXSlider', 'promptX', 'Prompt X Offset', 'Prompt X: %d px', -600, 600, 5, '-600', '600', 26, -82)
   CreateSlider(t3, 'InteractPromptYSlider', 'promptY', 'Prompt Y Offset', 'Prompt Y: %d px', -450, 450, 5, '-450', '450', 248, -82)
   CreateSlider(t3, 'InteractPromptScaleSlider', 'promptScale', 'Prompt Scale', 'Prompt Scale: %.2fx', 0.7, 1.5, 0.05, '0.7x', '1.5x', 26, -126)
   CreateSlider(t3, 'InteractPromptAlphaSlider', 'promptAlpha', 'Prompt Frame Opacity', 'Frame Alpha: %.2f', 0.0, 1.0, 0.05, '0.0', '1.0', 248, -126)
   CreateSlider(t3, 'InteractSparkleFovSlider', 'sparkleFov', 'Sparkle Projection', 'Sparkle Projection: %d (90=Default)', 40, 150, 1, '40', '150', 26, -170)
   CreateCheckbox(t3, 'InteractCBSparkleHerbs',  'sparkleHerbs',  'Herbs',  'Show 3D world sparkles over nearby herbalism nodes.', 248, -156)
   CreateCheckbox(t3, 'InteractCBSparkleMines',  'sparkleMines',  'Mines',  'Show 3D world sparkles over nearby mining mineral veins.', 348, -156)
   CreateCheckbox(t3, 'InteractCBSparkleChests', 'sparkleChests', 'Chests', 'Show 3D world sparkles over nearby treasure chests and footlockers.', 248, -178)
   CreateCheckbox(t3, 'InteractCBSparkleQuests', 'sparkleQuests', 'Quests', 'Show 3D world sparkles over nearby active quest objects.', 348, -178)

   CreateSectionHeader(t3, 'Entry ID Blacklist (NPCs & Objects)', 22, -208)

   local idBox = CreateFrame('EditBox', 'InteractBlacklistEditBox', t3, 'InputBoxTemplate')
   idBox:SetWidth(86)
   idBox:SetHeight(22)
   idBox:SetPoint('TOPLEFT', t3, 'TOPLEFT', 28, -232)
   idBox:SetAutoFocus(false)
   idBox:SetNumeric(true)
   idBox:SetMaxLetters(10)

   local addBtn = CreateFrame('Button', 'InteractBLAddBtn', t3, 'UIPanelButtonTemplate')
   addBtn:SetWidth(66)
   addBtn:SetHeight(22)
   addBtn:SetPoint('LEFT', idBox, 'RIGHT', 6, 0)
   addBtn:SetText('Add ID')
   addBtn:SetScript('OnClick', function()
      local id = AddBlacklistID(idBox:GetText())
      if id then
         idBox:SetText('')
         idBox:ClearFocus()
         RefreshUI()
         PrintMsg('Blacklisted Entry ID ' .. id .. '.')
      end
   end)

   local remBtn = CreateFrame('Button', 'InteractBLRemoveBtn', t3, 'UIPanelButtonTemplate')
   remBtn:SetWidth(80)
   remBtn:SetHeight(22)
   remBtn:SetPoint('LEFT', addBtn, 'RIGHT', 6, 0)
   remBtn:SetText('Remove ID')
   remBtn:SetScript('OnClick', function()
      local id = RemoveBlacklistID(idBox:GetText())
      if id then
         idBox:SetText('')
         idBox:ClearFocus()
         RefreshUI()
         PrintMsg('Removed Entry ID ' .. id .. ' from blacklist.')
      end
   end)

   local blCurBtn = CreateFrame('Button', 'InteractBLCurrentBtn', t3, 'UIPanelButtonTemplate')
   blCurBtn:SetWidth(120)
   blCurBtn:SetHeight(22)
   blCurBtn:SetPoint('LEFT', remBtn, 'RIGHT', 6, 0)
   blCurBtn:SetText('BL Prompt/Last')
   blCurBtn:SetScript('OnClick', function()
      if Interact_BlacklistCurrent then
         Interact_BlacklistCurrent()
      end
   end)

   for i = 1, BL_PER_PAGE do
      local rowFrame = CreateFrame('Frame', 'InteractBLRow_' .. i, t3)
      rowFrame:SetWidth(428)
      rowFrame:SetHeight(20)
      rowFrame:SetPoint('TOPLEFT', t3, 'TOPLEFT', 24, -260 - ((i - 1) * 22))
      local rowText = rowFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
      rowText:SetPoint('LEFT', rowFrame, 'LEFT', 0, 0)
      rowText:SetWidth(355)
      rowText:SetJustifyH('LEFT')

      local rowObj = { frame = rowFrame, text = rowText, entryId = nil }
      local delBtn = CreateFrame('Button', 'InteractBLRowDel_' .. i, rowFrame, 'UIPanelButtonTemplate')
      delBtn:SetWidth(58)
      delBtn:SetHeight(18)
      delBtn:SetPoint('RIGHT', rowFrame, 'RIGHT', 0, 0)
      delBtn:SetText('Remove')
      delBtn:SetScript('OnClick', function()
         if rowObj.entryId then
            local removed = RemoveBlacklistID(rowObj.entryId)
            RefreshUI()
            if removed then
               PrintMsg('Removed Entry ID ' .. removed .. ' from blacklist.')
            end
         end
      end)
      table.insert(uiBlacklistRows, rowObj)
   end

   uiBlacklistPrevBtn = CreateFrame('Button', 'InteractBLPrevBtn', t3, 'UIPanelButtonTemplate')
   uiBlacklistPrevBtn:SetWidth(52)
   uiBlacklistPrevBtn:SetHeight(20)
   uiBlacklistPrevBtn:SetPoint('TOPLEFT', t3, 'TOPLEFT', 24, -348)
   uiBlacklistPrevBtn:SetText('< Prev')
   uiBlacklistPrevBtn:SetScript('OnClick', function()
      if blPage > 1 then
         blPage = blPage - 1
         RefreshUI()
      end
   end)

   uiBlacklistNextBtn = CreateFrame('Button', 'InteractBLNextBtn', t3, 'UIPanelButtonTemplate')
   uiBlacklistNextBtn:SetWidth(52)
   uiBlacklistNextBtn:SetHeight(20)
   uiBlacklistNextBtn:SetPoint('LEFT', uiBlacklistPrevBtn, 'RIGHT', 6, 0)
   uiBlacklistNextBtn:SetText('Next >')
   uiBlacklistNextBtn:SetScript('OnClick', function()
      blPage = blPage + 1
      RefreshUI()
   end)

   uiBlacklistPageText = t3:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
   uiBlacklistPageText:SetPoint('LEFT', uiBlacklistNextBtn, 'RIGHT', 10, 0)
   uiBlacklistPageText:SetJustifyH('LEFT')

   -- =========================================================================
   -- TAB 4: Focus Target Frame
   -- =========================================================================
   local t4 = tabFrames[4]
   CreateSectionHeader(t4, 'Focus Target Grid (Up to 9 Slots, 3x3)', 22, -4)
   CreateCheckbox(t4, 'InteractCBEnableFocus', 'enableFocus', 'Enable Focus Frame', 'Show classic TargetFrame-style Focus Frames when focus targets are set.', 22, -24)
   CreateCheckbox(t4, 'InteractCBLockFocus', 'lockFocus', 'Lock Focus Frame', 'Lock dragging of the Focus Frame group.', 248, -24)
   CreateCheckbox(t4, 'InteractCBFocusToT', 'showFocusToT', 'Show Target of Focus', 'Show who your focus is targeting.', 22, -46)
   CreateCheckbox(t4, 'InteractCBFocusCast', 'showFocusCast', 'Show Focus Castbar', 'Show spellcast bar below each Focus Frame.', 248, -46)
   CreateCheckbox(t4, 'InteractCBFocusAuras', 'showFocusAuras', 'Show Focus Buffs / Debuffs', 'Show active aura icons below each Focus Frame.', 22, -68)
   CreateCheckbox(t4, 'InteractCBSyncFocus', 'syncFocusGroup', 'Leader Focus Sync (Party/Raid)', 'Broadcast & receive Focus 1..9 GUID assignments from Party/Raid Leader.', 248, -68)
   CreateCheckbox(t4, 'InteractCBCompactFocus', 'compactFocus', 'Compact Mini-Bar Mode', 'Switch Focus 1..9 from full TargetFrames to sleek compact raid bars (148x42).', 22, -90)
   CreateCheckbox(t4, 'InteractCBAutoMarks', 'autoFocusMarks', 'Auto-Focus Raid Marks (1..8)', 'Automatically populate Focus 1..8 from Skull, Cross, Square, Moon, Triangle, Diamond, Circle, Star.', 248, -90)
   CreateCheckbox(t4, 'InteractCBCastAlert', 'focusCastAlert', 'Flash Border on Cast', 'Flash the Focus frame border red/gold whenever that Focus unit is casting or channeling.', 22, -112)
   CreateCheckbox(t4, 'InteractCBCastSound', 'focusCastSound', 'Sound Alert on Cast Start', 'Play a warning sound when any Focus 1..9 starts casting or channeling a spell.', 248, -112)
   CreateCheckbox(t4, 'InteractCBAutoClearDead', 'autoClearDeadFocus', 'Auto-Clear Dead Focus', 'Automatically clear a Focus slot when a non-player target dies.', 22, -134)
   CreateCheckbox(t4, 'InteractCBDimOOR', 'dimOutOfRangeFocus', 'Dim Out-of-Range / No-LoS', 'Dim Focus frames to 45% opacity when >40 yd away or out of Line of Sight.', 248, -134)

   CreateSlider(t4, 'InteractFocusScaleSlider', 'focusScale', 'Focus Frame Scale', 'Focus Scale: %.2fx', 0.4, 1.5, 0.05, '0.4x', '1.5x', 26, -170)
   CreateSlider(t4, 'InteractFocusXSlider', 'focusX', 'Focus X Offset', 'Focus X: %d px', -800, 800, 5, '-800', '800', 26, -216)
   CreateSlider(t4, 'InteractFocusYSlider', 'focusY', 'Focus Y Offset', 'Focus Y: %d px', -500, 500, 5, '-500', '500', 248, -216)

   local marksNowBtn = CreateFrame('Button', 'InteractFocusMarksBtn', t4, 'UIPanelButtonTemplate')
   marksNowBtn:SetWidth(66)
   marksNowBtn:SetHeight(22)
   marksNowBtn:SetPoint('TOPLEFT', t4, 'TOPLEFT', 248, -174)
   marksNowBtn:SetText('Marks')
   marksNowBtn:SetScript('OnClick', function()
      if Interact_PopulateFocusFromMarks then
         Interact_PopulateFocusFromMarks(false)
      end
   end)
   marksNowBtn:SetScript('OnEnter', function()
      GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
      GameTooltip:SetText('Populate Focus from Raid Marks', 1, 0.82, 0)
      GameTooltip:AddLine('Scans visible units for Raid Marks (Skull=1 down to Star=8) and assigns them to Focus 1..8.', 1, 1, 1, 1)
      GameTooltip:Show()
   end)
   marksNowBtn:SetScript('OnLeave', function() GameTooltip:Hide() end)

   local syncNowBtn = CreateFrame('Button', 'InteractFocusSyncBtn', t4, 'UIPanelButtonTemplate')
   syncNowBtn:SetWidth(68)
   syncNowBtn:SetHeight(22)
   syncNowBtn:SetPoint('LEFT', marksNowBtn, 'RIGHT', 4, 0)
   syncNowBtn:SetText('Broadcast')
   syncNowBtn:SetScript('OnClick', function()
      if Interact_BroadcastAllFocus then
         Interact_BroadcastAllFocus()
      end
   end)
   syncNowBtn:SetScript('OnEnter', function()
      GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
      GameTooltip:SetText('Broadcast Focus 1..9', 1, 0.82, 0)
      GameTooltip:AddLine('Party/Raid Leaders & Assistants: broadcasts your Focus 1..9 slots (64-bit GUIDs) to the group.', 1, 1, 1, 1)
      GameTooltip:Show()
   end)
   syncNowBtn:SetScript('OnLeave', function() GameTooltip:Hide() end)

   local clearAllFocusBtn = CreateFrame('Button', 'InteractFocusClearAllBtn', t4, 'UIPanelButtonTemplate')
   clearAllFocusBtn:SetWidth(64)
   clearAllFocusBtn:SetHeight(22)
   clearAllFocusBtn:SetPoint('LEFT', syncNowBtn, 'RIGHT', 4, 0)
   clearAllFocusBtn:SetText('Clear')
   clearAllFocusBtn:SetScript('OnClick', function()
      if Interact_ClearAllFocus then
         Interact_ClearAllFocus()
      end
   end)
   clearAllFocusBtn:SetScript('OnEnter', function()
      GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
      GameTooltip:SetText('Clear All Focus Slots', 1, 0.82, 0)
      GameTooltip:AddLine('Clears local Focus 1..9 (and broadcasts Clear All if you are Party/Raid Leader or Assistant).', 1, 1, 1, 1)
      GameTooltip:Show()
   end)
   clearAllFocusBtn:SetScript('OnLeave', function() GameTooltip:Hide() end)

   CreateSectionHeader(t4, 'Click-Cast Spells on Focus Frames (Select from Spellbook)', 22, -254)
   local spellDropMenu = CreateFrame('Frame', 'InteractFocusSpellDropMenu', UIParent, 'UIDropDownMenuTemplate')
   local activeSpellConfigKey = nil
   local activeSpellButton = nil

   local function GetPlayerSpellList()
      local list = {}
      local seen = {}
      local i = 1
      while true do
         local sName = GetSpellName(i, BOOKTYPE_SPELL)
         if not sName then break end
         if sName ~= 'Attack' and not seen[sName] then
            seen[sName] = true
            table.insert(list, sName)
         end
         i = i + 1
      end
      table.sort(list)
      return list
   end

   local function GetPlayerSpellIcon(spellName)
      if not spellName or spellName == '' then return nil end
      local i = 1
      while true do
         local sName = GetSpellName(i, BOOKTYPE_SPELL)
         if not sName then break end
         if sName == spellName then
            return GetSpellTexture(i, BOOKTYPE_SPELL)
         end
         i = i + 1
      end
      return 'Interface\\Icons\\INV_Misc_QuestionMark'
   end

   local spellDropdownPage = 1
   local SPELLS_PER_MENU = 20

   local function InitSpellSelectDropdown()
      EnsureDB()
      local spells = GetPlayerSpellList()
      local total = table.getn(spells)
      local maxPage = math.ceil(total / SPELLS_PER_MENU)
      if maxPage < 1 then maxPage = 1 end
      if spellDropdownPage > maxPage then spellDropdownPage = maxPage end
      if spellDropdownPage < 1 then spellDropdownPage = 1 end

      local currentVal = (activeSpellConfigKey and InteractDB.config[activeSpellConfigKey]) or ''

      local info = {}
      info.text = '|cffff6060(None - Disabled)|r'
      info.checked = (currentVal == '') and 1 or nil
      info.func = function()
         if activeSpellConfigKey then
            SetConfigValue(activeSpellConfigKey, '')
            RefreshUI()
         end
      end
      UIDropDownMenu_AddButton(info)

      if maxPage > 1 then
         info = {}
         info.text = string.format('|cffffd200<< Page %d / %d (Click for Next) >>|r', spellDropdownPage, maxPage)
         info.notCheckable = 1
         info.keepShownOnClick = 1
         info.func = function()
            spellDropdownPage = spellDropdownPage + 1
            if spellDropdownPage > maxPage then spellDropdownPage = 1 end
            CloseDropDownMenus()
            ToggleDropDownMenu(1, nil, spellDropMenu, activeSpellButton or 'cursor', 0, 0)
         end
         UIDropDownMenu_AddButton(info)
      end

      local startIdx = (spellDropdownPage - 1) * SPELLS_PER_MENU + 1
      local endIdx = startIdx + SPELLS_PER_MENU - 1
      if endIdx > total then endIdx = total end

      for idx = startIdx, endIdx do
         local sp = spells[idx]
         info = {}
         info.text = sp
         info.checked = (currentVal == sp) and 1 or nil
         info.func = function()
            if activeSpellConfigKey then
               SetConfigValue(activeSpellConfigKey, sp)
               RefreshUI()
            end
         end
         UIDropDownMenu_AddButton(info)
      end
   end

   local spellPickBtns = {}
   local function CreateSpellPickerRow(cfgKey, modLabel, x, y)
      local lbl = t4:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
      lbl:SetPoint('TOPLEFT', t4, 'TOPLEFT', x, y - 4)
      lbl:SetText(modLabel)

      local icon = t4:CreateTexture(nil, 'ARTWORK')
      icon:SetWidth(18)
      icon:SetHeight(18)
      icon:SetPoint('TOPLEFT', t4, 'TOPLEFT', x + 64, y - 1)
      icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      icon:Hide()

      local btn = CreateFrame('Button', 'InteractSpellBtn_' .. cfgKey, t4, 'UIPanelButtonTemplate')
      btn:SetWidth(122)
      btn:SetHeight(20)
      btn:SetPoint('TOPLEFT', t4, 'TOPLEFT', x + 86, y)
      btn:SetScript('OnClick', function()
         if arg1 == 'RightButton' then
            SetConfigValue(cfgKey, '')
            RefreshUI()
         else
            activeSpellConfigKey = cfgKey
            activeSpellButton = this
            spellDropdownPage = 1
            UIDropDownMenu_Initialize(spellDropMenu, InitSpellSelectDropdown, 'MENU')
            ToggleDropDownMenu(1, nil, spellDropMenu, this, 0, 0)
         end
      end)
      btn:SetScript('OnEnter', function()
         GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
         GameTooltip:SetText(modLabel .. ' Focus Spell', 1, 0.82, 0)
         GameTooltip:AddLine('Left-Click: Choose spell from your Spellbook', 1, 1, 1)
         GameTooltip:AddLine('Right-Click: Clear spell binding', 1, 0.5, 0.5)
         GameTooltip:Show()
      end)
      btn:SetScript('OnLeave', function()
         GameTooltip:Hide()
      end)
      btn:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
      table.insert(spellPickBtns, { key = cfgKey, btn = btn, icon = icon })
   end

   CreateSpellPickerRow('focusShiftSpell', 'Shift+Click:', 22, -274)
   CreateSpellPickerRow('focusCtrlSpell',  'Ctrl+Click:',  248, -274)
   CreateSpellPickerRow('focusAltSpell',   'Alt+Click:',   22, -298)

   RefreshFocusSpellButtons = function()
      for _, item in ipairs(spellPickBtns) do
         local sp = InteractDB.config[item.key]
         if sp and sp ~= '' then
            item.btn:SetText(sp)
            local tex = GetPlayerSpellIcon(sp)
            if tex then
               item.icon:SetTexture(tex)
               item.icon:Show()
            else
               item.icon:Hide()
            end
         else
            item.btn:SetText('|cff888888(None)|r')
            item.icon:Hide()
         end
      end
   end

   local focusHint = t4:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
   focusHint:SetPoint('TOPLEFT', t4, 'TOPLEFT', 22, -324)
   focusHint:SetWidth(432)
   focusHint:SetJustifyH('LEFT')
   focusHint:SetText('|cffffd200Commands:|r /focus1..9, /autofocus, /clearfocus1..9, /targetfocus1..9, /fcast1..9 <spell>, /focusmarks, /fsync\n|cffffd200Grid:|r Col 1 = 1..3 | Col 2 = 4..6 | Col 3 = 7..9. Shift/Ctrl/Alt+Left-Click casts your bound spell!')

   SelectConfigTab(1)

   if not StaticPopupDialogs['INTERACT_RESET_CONFIRM'] then
      StaticPopupDialogs['INTERACT_RESET_CONFIRM'] = {
         text = 'Reset all InteractMod settings, custom profiles, and blacklist entries to defaults?',
         button1 = 'Yes',
         button2 = 'Cancel',
         OnAccept = function()
            ResetAllDefaults()
            RefreshUI()
            PrintMsg('Settings and blacklist reset to defaults.')
         end,
         timeout = 0,
         whileDead = 1,
         hideOnEscape = 1,
      }
   end

   local resetBtn = CreateFrame('Button', 'InteractResetBtn', f, 'UIPanelButtonTemplate')
   resetBtn:SetWidth(115)
   resetBtn:SetHeight(24)
   resetBtn:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 22, 18)
   resetBtn:SetText('Reset Defaults')
   resetBtn:SetScript('OnClick', function()
      StaticPopup_Show('INTERACT_RESET_CONFIRM')
   end)

   local doneBtn = CreateFrame('Button', 'InteractDoneBtn', f, 'UIPanelButtonTemplate')
   doneBtn:SetWidth(90)
   doneBtn:SetHeight(24)
   doneBtn:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -22, 18)
   doneBtn:SetText('Close')
   doneBtn:SetScript('OnClick', function() f:Hide() end)

   configFrame = f
   RefreshUI()
   return f
end

local function ToggleConfigUI()
   local f = BuildConfigUI()
   if f:IsVisible() then
      f:Hide()
   else
      RefreshUI()
      f:Show()
   end
end

-- ============================================================================
-- Slash Commands (/interact, /im)
-- ============================================================================
local function ParseToggle(arg, currentVal)
   if not arg or arg == '' then
      return not currentVal
   end
   local lower = string.lower(arg)
   if lower == '1' or lower == 'on' or lower == 'true' or lower == 'yes' or lower == 'enable' then
      return true
   elseif lower == '0' or lower == 'off' or lower == 'false' or lower == 'no' or lower == 'disable' then
      return false
   end
   return not currentVal
end

local function BoolStr(b)
   if b then return '|cff00ff00ON|r' else return '|cffff4040OFF|r' end
end

local function PrintHelp()
   PrintMsg('Commands (or type |cffffd200/interact|r with no args to open UI):')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact ui|r - Toggle settings window')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact status|r - Show current settings')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact cone <15-180>|r - Set cone half-angle in degrees')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact range <0-8>|r - Set close proximity radius in yards')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact zdiff <0-20>|r - Set max vertical floor/ceiling diff in yards (0 = off)')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact cycle <0-10000>|r - Set cycle penalty window (ms)')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact enemies [on|off]|r - Toggle enemy targeting')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact combatloot [on|off]|r - Toggle looting/gathering in combat')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact prioloot [on|off]|r - Prioritize loot over enemies in combat')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact players [on|off]|r - Toggle friendly player interaction')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact passivenpcs [on|off]|r - Toggle ignoring flagless NPCs')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact skiplooted [on|off]|r - Skip dead empty hard target')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact pvpooc [on|off]|r - Attack enemy players out of combat')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact restoretarget [on|off]|r - Restore previous target after interact')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact ownbobber [on|off]|r - Ignore other players\' fishing bobbers')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact raidmarks [on|off]|r - Prioritize Skull/Cross raid marks')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact protectcc [on|off]|r - Skip Moon/Square/Star/Diamond marks')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact prompt [on|off]|r - Toggle soft-target on-screen prompt')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact promptpos <x> <y>|r - Set prompt frame offset from center (-600..600, -450..450)')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact critters|los|cameracone|tapped|prioquest|autoprofile|autodismount|fish|minimap [on|off]|r')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact profile <name>|r | |cffffd200profilesave <name>|r | |cffffd200profilereset <name|all>|r | |cffffd200profiledelete <name>|r')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact profilelist|r | |cffffd200profileexport|r | |cffffd200profileimport <str>|r')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact ignore <critters|herbs|ore|chests|chairs|campfires|mailboxes|doors|portals|goobers|other> [on|off]|r')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact bl <add ID | remove ID | last | list | clear>|r / |cffffd200/interact bltarget|r')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/focus|r | |cffffd200/clearfocus|r | |cffffd200/targetfocus|r | |cffffd200/fcast <spell>|r')
   DEFAULT_CHAT_FRAME:AddMessage('  |cffffd200/interact reset|r - Reset settings and blacklist to defaults')
end

local function PrintStatus()
   EnsureDB()
   local c = InteractDB.config
   PrintMsg('Current Configuration:')
   DEFAULT_CHAT_FRAME:AddMessage(string.format('  Cone: %d deg | Close Range: %.1f yd | Max Z Diff: %.1f yd | Cycle: %d ms', c.coneAngle, c.closeRange, c.maxZDiff, c.cycleTime))
   DEFAULT_CHAT_FRAME:AddMessage('  Enemies: ' .. BoolStr(c.interactEnemies) .. ' | Combat Loot: ' .. BoolStr(c.lootInCombat) .. ' | Prio Loot: ' .. BoolStr(c.prioritizeLoot))
   DEFAULT_CHAT_FRAME:AddMessage('  Players: ' .. BoolStr(c.interactPlayers) .. ' | Enemy Players OOC: ' .. BoolStr(c.enemyPlayersOOC) .. ' | Ignore Passive NPCs: ' .. BoolStr(c.ignorePassiveNPC) .. ' | Skip Empty Target: ' .. BoolStr(c.skipLootedTarget))
   DEFAULT_CHAT_FRAME:AddMessage('  Own Bobber: ' .. BoolStr(c.ownBobberOnly) .. ' | Restore Target: ' .. BoolStr(c.restoreTarget) .. ' | Raid Marks: ' .. BoolStr(c.raidMarkPriority) .. ' | Protect CC: ' .. BoolStr(c.protectCCMarks))
   DEFAULT_CHAT_FRAME:AddMessage('  LoS: ' .. BoolStr(c.losCheck) .. ' | CamCone: ' .. BoolStr(c.cameraCone) .. ' | Critters: ' .. BoolStr(c.ignoreCritters) .. ' | SkipTapped: ' .. BoolStr(c.ignoreTapped) .. ' | PrioQuestOOC: ' .. BoolStr(c.prioritizeQuestOOC))
   DEFAULT_CHAT_FRAME:AddMessage('  AutoProfile: ' .. BoolStr(c.autoProfile) .. ' | Dismount: ' .. BoolStr(c.autoDismount) .. ' | Fish: ' .. BoolStr(c.interactToFish) .. ' | Minimap: ' .. BoolStr(c.showMinimap))
   DEFAULT_CHAT_FRAME:AddMessage(string.format('  Prompt: %s (%d, %d) | Scale: %.2fx | Alpha: %.2f | Locked: %s', BoolStr(c.showPrompt), c.promptX or 0, c.promptY or -140, c.promptScale or 1.0, c.promptAlpha or 0.72, BoolStr(c.lockPrompt)))
   DEFAULT_CHAT_FRAME:AddMessage('  Ignore -> Herbs: ' .. BoolStr(c.ignoreHerbs) .. ' | Ore: ' .. BoolStr(c.ignoreOre) .. ' | Chests: ' .. BoolStr(c.ignoreChests) .. ' | Chairs: ' .. BoolStr(c.ignoreChairs) .. ' | Campfires: ' .. BoolStr(c.ignoreSpellFocus) .. ' | Mail: ' .. BoolStr(c.ignoreMailboxes) .. ' | Doors: ' .. BoolStr(c.ignoreDoors) .. ' | Portals: ' .. BoolStr(c.ignoreRituals) .. ' | Goobers: ' .. BoolStr(c.ignoreGoobers) .. ' | Other: ' .. BoolStr(c.ignoreOtherGOs))
   local ids = GetSortedBlacklist()
   if table.getn(ids) == 0 then
      DEFAULT_CHAT_FRAME:AddMessage('  Blacklist: (none)')
   else
      local parts = {}
      for _, id in ipairs(ids) do table.insert(parts, tostring(id)) end
      DEFAULT_CHAT_FRAME:AddMessage('  Blacklist: ' .. table.concat(parts, ', '))
   end
end

local IGNORE_CATEGORY_MAP = {
   chairs    = 'ignoreChairs',
   chair     = 'ignoreChairs',
   campfires = 'ignoreSpellFocus',
   campfire  = 'ignoreSpellFocus',
   forges    = 'ignoreSpellFocus',
   spellfocus = 'ignoreSpellFocus',
   mailboxes = 'ignoreMailboxes',
   mailbox   = 'ignoreMailboxes',
   mail      = 'ignoreMailboxes',
   doors     = 'ignoreDoors',
   door      = 'ignoreDoors',
   portals   = 'ignoreRituals',
   portal    = 'ignoreRituals',
   rituals   = 'ignoreRituals',
   ritual    = 'ignoreRituals',
   goobers   = 'ignoreGoobers',
   goober    = 'ignoreGoobers',
   other     = 'ignoreOtherGOs',
   critters  = 'ignoreCritters',
   critter   = 'ignoreCritters',
   herbs     = 'ignoreHerbs',
   herb      = 'ignoreHerbs',
   ore       = 'ignoreOre',
   veins     = 'ignoreOre',
   mining    = 'ignoreOre',
   chests    = 'ignoreChests',
   chest     = 'ignoreChests',
}

local TOGGLE_COMMAND_MAP = {
   enemies     = { key = 'interactEnemies',  label = 'Interact with Enemies' },
   combatloot  = { key = 'lootInCombat',     label = 'Loot / Gather in Combat' },
   prioloot    = { key = 'prioritizeLoot',   label = 'Prioritize Loot in Combat' },
   players     = { key = 'interactPlayers',  label = 'Interact with Friendly Players' },
   passivenpcs     = { key = 'ignorePassiveNPC', label = 'Ignore Passive NPCs' },
   skiplooted      = { key = 'skipLootedTarget', label = 'Skip Empty Dead Hard Target' },
   pvpooc          = { key = 'enemyPlayersOOC',  label = 'Attack Enemy Players Out of Combat' },
   enemyplayersooc = { key = 'enemyPlayersOOC',  label = 'Attack Enemy Players Out of Combat' },
   ownbobber       = { key = 'ownBobberOnly',    label = 'Own Fishing Bobber Only' },
   restoretarget   = { key = 'restoreTarget',    label = 'Restore Previous Target' },
   raidmarks       = { key = 'raidMarkPriority', label = 'Prioritize Skull / Cross Raid Marks' },
   protectcc       = { key = 'protectCCMarks',   label = 'Protect CC Raid Marks' },
   prompt          = { key = 'showPrompt',       label = 'Soft-Target On-Screen Prompt' },
   promptstack     = { key = 'showPromptStack',  label = 'Multi-Target Prompt Stack' },
   lockprompt      = { key = 'lockPrompt',       label = 'Lock Prompt Position' },
   critters        = { key = 'ignoreCritters',   label = 'Ignore Critters & Pets' },
   los             = { key = 'losCheck',         label = 'Line-of-Sight Check' },
   cameracone      = { key = 'cameraCone',       label = 'Camera-Relative Cone' },
   autoprofile     = { key = 'autoProfile',      label = 'Auto-Switch Profile by Zone' },
   autodismount    = { key = 'autoDismount',     label = 'Auto-Dismount on Interact' },
   fish            = { key = 'interactToFish',   label = 'Interact-to-Fish' },
   interacttofish  = { key = 'interactToFish',   label = 'Interact-to-Fish' },
   tapped          = { key = 'ignoreTapped',     label = 'Skip Tapped Enemies' },
   ignoretapped    = { key = 'ignoreTapped',     label = 'Skip Tapped Enemies' },
   prioquest       = { key = 'prioritizeQuestOOC', label = 'Prioritize Questgivers Out of Combat' },
   priolowhp       = { key = 'prioritizeLowHP',    label = 'Prioritize Low-HP Enemies (<25%)' },
   priocasting     = { key = 'prioritizeCasting',  label = 'Prioritize Casting Enemies' },
   mount           = { key = 'interactToMount',    label = 'Interact-to-Mount (OOC)' },
   sellgrey        = { key = 'autoSellGrey',       label = 'Auto-Sell Grey Items' },
   autorepair      = { key = 'autoRepair',         label = 'Auto-Repair at Merchants' },
   minimap         = { key = 'showMinimap',      label = 'Show Minimap Button' },
}

local function HandleSlashCommand(msg)
   EnsureDB()
   msg = msg or ''
   local _, _, cmd, rest = string.find(msg, '^%s*(%S+)%s*(.-)%s*$')
   if not cmd or cmd == '' then
      ToggleConfigUI()
      return
   end

   cmd = string.lower(cmd)

   if cmd == 'ui' or cmd == 'config' or cmd == 'options' then
      ToggleConfigUI()
   elseif cmd == 'castfocus' then
      if SlashCmdList['INTERACTFCAST'] then
         SlashCmdList['INTERACTFCAST'](rest or '')
      end
   elseif cmd == 'help' or cmd == '?' then
      PrintHelp()
   elseif cmd == 'status' then
      PrintStatus()
   elseif cmd == 'debug' then
      local c = InteractDB.config
      local qName, qVerb, qDist, qEntry = nil, nil, nil, nil
      if type(InteractNearest) == 'function' then
         qName, qVerb, qDist, qEntry = InteractNearest(CMD_QUERY_NEAREST)
      end
      PrintMsg(string.format('Debug: profile=%s los=%s mail=%s passive=%s cone=%s close=%s z=%s mount=%s',
         tostring(activeProfileName), tostring(c.losCheck), tostring(c.ignoreMailboxes),
         tostring(c.ignorePassiveNPC), tostring(c.coneAngle), tostring(c.closeRange),
         tostring(c.maxZDiff), tostring(c.interactToMount)))
      PrintMsg(string.format('Query: name=%s verb=%s dist=%s entry=%s',
         tostring(qName), tostring(qVerb), tostring(qDist), tostring(qEntry)))
   elseif cmd == 'reset' then
      ResetAllDefaults()
      RefreshUI()
      PrintMsg('All settings and blacklist reset to defaults.')
   elseif cmd == 'promptpos' then
      local _, _, xStr, yStr = string.find(rest or '', '^%s*(%-?%d+)%s+(%-?%d+)%s*$')
      local x = tonumber(xStr)
      local y = tonumber(yStr)
      if x and y then
         SetConfigValue('promptX', x)
         SetConfigValue('promptY', y)
         RefreshUI()
         PrintMsg('Prompt position set to (' .. tostring(InteractDB.config.promptX) .. ', ' .. tostring(InteractDB.config.promptY) .. ').')
      else
         PrintMsg('Usage: /interact promptpos <x> <y>  (current: ' .. tostring(InteractDB.config.promptX or 0) .. ', ' .. tostring(InteractDB.config.promptY or -140) .. ')')
      end
   elseif cmd == 'profile' then
      local key = rest and string.lower(rest) or ''
      local label = ApplyProfile(key)
      if label then
         RefreshUI()
         PrintMsg('Applied profile: |cffffd200' .. label .. '|r')
      else
         PrintMsg('Usage: /interact profile <questing|raid|gathering|city|customName>')
      end
   elseif cmd == 'profilesave' or cmd == 'saveprofile' or cmd == 'profilecreate' then
      local key = rest and string.lower(rest) or ''
      local label, isCustom = SaveProfile(key)
      if label then
         RefreshUI()
         if isCustom then
            PrintMsg('Saved custom profile |cffffd200' .. label .. '|r.')
         else
            PrintMsg('Saved current settings to profile |cffffd200' .. label .. '|r.')
         end
      else
         PrintMsg('Usage: /interact profilesave <name>')
      end
   elseif cmd == 'profilereset' or cmd == 'resetprofile' then
      local key = rest and string.lower(rest) or ''
      local label = ResetProfile(key)
      if label then
         RefreshUI()
         PrintMsg('Reset |cffffd200' .. label .. '|r to built-in defaults.')
      else
         PrintMsg('Usage: /interact profilereset <questing|raid|gathering|city|all>')
      end
   elseif cmd == 'profiledelete' or cmd == 'deleteprofile' then
      local key = rest and string.lower(rest) or ''
      local deleted = DeleteCustomProfile(key)
      if deleted then
         RefreshUI()
         PrintMsg('Deleted custom profile |cffffd200' .. deleted .. '|r.')
      else
         PrintMsg('Custom profile not found. Built-in profiles use /interact profilereset.')
      end
   elseif cmd == 'profilelist' then
      local builtins = { 'questing', 'raid', 'gathering', 'city' }
      local customs = {}
      for k, _ in pairs(InteractDB.customProfiles) do table.insert(customs, k) end
      table.sort(customs)
      PrintMsg('Built-in profiles: ' .. table.concat(builtins, ', '))
      if table.getn(customs) > 0 then
         PrintMsg('Custom profiles: ' .. table.concat(customs, ', '))
      else
         PrintMsg('Custom profiles: (none)')
      end
   elseif cmd == 'profileexport' then
      if ToggleProfileIOFrame then
         ToggleProfileIOFrame(true)
      else
         PrintMsg(ExportProfileString())
      end
   elseif cmd == 'profileimport' then
      if rest and rest ~= '' then
         local count, err = ImportProfileString(rest)
         if count then
            RefreshUI()
            PrintMsg('Imported ' .. count .. ' settings.')
         else
            PrintMsg('Import failed: ' .. tostring(err))
         end
      elseif ToggleProfileIOFrame then
         ToggleProfileIOFrame(false)
      end
   elseif cmd == 'bltarget' then
      if Interact_BlacklistCurrent then
         Interact_BlacklistCurrent()
      end
   elseif cmd == 'cone' then
      local val = tonumber(rest)
      if not val then
         PrintMsg('Usage: /interact cone <15-180>')
         return
      end
      val = SetConfigValue('coneAngle', val)
      RefreshUI()
      PrintMsg('Cone half-angle set to ' .. val .. ' degrees.')
   elseif cmd == 'range' or cmd == 'closerange' then
      local val = tonumber(rest)
      if not val then
         PrintMsg('Usage: /interact range <0-8>')
         return
      end
      val = SetConfigValue('closeRange', val)
      RefreshUI()
      PrintMsg(string.format('Close proximity radius set to %.1f yards.', val))
   elseif cmd == 'zdiff' or cmd == 'maxz' then
      local val = tonumber(rest)
      if not val then
         PrintMsg('Usage: /interact zdiff <0-20> (0 = off)')
         return
      end
      val = SetConfigValue('maxZDiff', val)
      RefreshUI()
      PrintMsg(string.format('Max vertical (Z) difference set to %.1f yards.', val))
   elseif cmd == 'cycle' or cmd == 'cycletime' then
      local val = tonumber(rest)
      if not val then
         PrintMsg('Usage: /interact cycle <0-10000>')
         return
      end
      val = SetConfigValue('cycleTime', val)
      RefreshUI()
      PrintMsg('Cycle penalty window set to ' .. val .. ' ms.')
   elseif TOGGLE_COMMAND_MAP[cmd] then
      local entry = TOGGLE_COMMAND_MAP[cmd]
      local val = SetConfigValue(entry.key, ParseToggle(rest, InteractDB.config[entry.key]))
      RefreshUI()
      PrintMsg(entry.label .. ': ' .. BoolStr(val))
   elseif cmd == 'sparkles' or cmd == 'sparkle' then
      local _, _, sub, flag = string.find(rest or '', '^%s*(%S*)%s*(.-)%s*$')
      sub = sub and string.lower(sub) or ''
      if sub == 'herbs' or sub == 'herb' then
         local val = SetConfigValue('sparkleHerbs', ParseToggle(flag, InteractDB.config.sparkleHerbs))
         PrintMsg('Sparkles (Herbs): ' .. BoolStr(val))
      elseif sub == 'mines' or sub == 'mine' or sub == 'ore' then
         local val = SetConfigValue('sparkleMines', ParseToggle(flag, InteractDB.config.sparkleMines))
         PrintMsg('Sparkles (Mines): ' .. BoolStr(val))
      elseif sub == 'chests' or sub == 'chest' then
         local val = SetConfigValue('sparkleChests', ParseToggle(flag, InteractDB.config.sparkleChests))
         PrintMsg('Sparkles (Chests): ' .. BoolStr(val))
      elseif sub == 'quests' or sub == 'quest' then
         local val = SetConfigValue('sparkleQuests', ParseToggle(flag, InteractDB.config.sparkleQuests))
         PrintMsg('Sparkles (Quest Objects): ' .. BoolStr(val))
      else
         local val = SetConfigValue('showSparkles', ParseToggle(sub, InteractDB.config.showSparkles))
         RefreshUI()
         PrintMsg('3D World Sparkles: ' .. BoolStr(val))
      end
   elseif cmd == 'ignore' then
      local _, _, cat, flag = string.find(rest or '', '^%s*(%S+)%s*(.-)%s*$')
      cat = cat and string.lower(cat) or ''
      local key = IGNORE_CATEGORY_MAP[cat]
      if not key then
         PrintMsg('Usage: /interact ignore <chairs|campfires|mailboxes|doors|portals|goobers|other> [on|off]')
         return
      end
      local val = SetConfigValue(key, ParseToggle(flag, InteractDB.config[key]))
      RefreshUI()
      PrintMsg('Ignore ' .. cat .. ': ' .. BoolStr(val))
   elseif cmd == 'bl' or cmd == 'blacklist' then
      local _, _, sub, arg = string.find(rest or '', '^%s*(%S+)%s*(.-)%s*$')
      sub = sub and string.lower(sub) or 'list'
      if sub == 'add' then
         local id = AddBlacklistID(arg)
         if id then
            RefreshUI()
            PrintMsg('Added GameObject ID ' .. id .. ' to blacklist.')
         else
            PrintMsg('Usage: /interact bl add <GameObjectEntryID>')
         end
      elseif sub == 'remove' or sub == 'rem' or sub == 'del' or sub == 'rm' then
         local id = RemoveBlacklistID(arg)
         if id then
            RefreshUI()
            PrintMsg('Removed GameObject ID ' .. id .. ' from blacklist.')
         else
            PrintMsg('Usage: /interact bl remove <GameObjectEntryID>')
         end
      elseif sub == 'last' then
         if InteractNearest then
            InteractNearest(CMD_BLACKLIST_LAST)
            PrintMsg('Blacklisted the last interacted GameObject for this session.')
         end
      elseif sub == 'clear' then
         ClearBlacklist()
         RefreshUI()
         PrintMsg('Blacklist cleared.')
      elseif sub == 'list' then
         local entries = GetBlacklistEntries()
         if table.getn(entries) == 0 then
            PrintMsg('Blacklist is empty.')
         else
            local parts = {}
            for _, e in ipairs(entries) do
               if e.name then
                  table.insert(parts, e.name .. ' (' .. e.id .. ')')
               else
                  table.insert(parts, tostring(e.id))
               end
            end
            PrintMsg('Blacklisted: ' .. table.concat(parts, ', '))
         end
      else
         PrintMsg('Usage: /interact bl <add ID | remove ID | last | list | clear>')
      end
   else
      PrintHelp()
   end
end

SLASH_INTERACT1 = '/interact'
SLASH_INTERACT2 = '/im'
SlashCmdList['INTERACT'] = HandleSlashCommand

-- ============================================================================
-- Soft-Target On-Screen Prompt (Draggable, Action-Colored, Scaled)
-- ============================================================================
local ACTION_COLORS = {
   Attack   = { 1.00, 0.35, 0.35 },
   Loot     = { 0.35, 1.00, 0.45 },
   Gather   = { 0.40, 0.95, 0.55 },
   Skin     = { 0.90, 0.70, 0.35 },
   Talk     = { 1.00, 0.85, 0.25 },
   Reel     = { 0.35, 0.85, 1.00 },
   Mailbox  = { 0.65, 0.85, 1.00 },
   Interact = { 1.00, 1.00, 1.00 },
}

local promptFrame = CreateFrame('Frame', 'InteractPromptFrame', UIParent)
promptFrame:SetWidth(280)
promptFrame:SetHeight(28)
promptFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, -140)
promptFrame:SetMovable(true)
promptFrame:RegisterForDrag('LeftButton')
promptFrame:SetBackdrop({
   bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
   edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
   tile = true, tileSize = 16, edgeSize = 12,
   insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
promptFrame:SetBackdropColor(0, 0, 0, 0.72)
promptFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
promptFrame:SetScript('OnDragStart', function()
   local unlocked = (InteractDB and InteractDB.config and not InteractDB.config.lockPrompt)
   if unlocked or (InteractConfigFrame and InteractConfigFrame:IsVisible()) then
      this:StartMoving()
   end
end)
promptFrame:SetScript('OnDragStop', function()
   this:StopMovingOrSizing()
   local scale = this:GetScale() or 1
   local px, py = this:GetCenter()
   local ux, uy = UIParent:GetCenter()
   if px and py and ux and uy then
      local dx = math.floor((px * scale - ux) + 0.5)
      local dy = math.floor((py * scale - uy) + 0.5)
      SetConfigValue('promptX', dx)
      SetConfigValue('promptY', dy)
      RefreshUI()
   end
end)
promptFrame:Hide()

local promptText = promptFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
promptText:SetPoint('CENTER', promptFrame, 'CENTER', 0, 0)

local DismountIfMounted
local promptStackFrames = {}
for idx = 2, 3 do
   local sf = CreateFrame('Button', 'InteractPromptStack' .. idx, promptFrame)
   sf:SetWidth(240)
   sf:SetHeight(20)
   if idx == 2 then
      sf:SetPoint('TOP', promptFrame, 'BOTTOM', 0, -2)
   else
      sf:SetPoint('TOP', promptStackFrames[idx - 1], 'BOTTOM', 0, -2)
   end
   sf:EnableMouse(true)
   sf:RegisterForClicks('LeftButtonUp')
   sf:SetBackdrop({
      bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true, tileSize = 12, edgeSize = 10,
      insets = { left = 2, right = 2, top = 2, bottom = 2 }
   })
   sf:SetBackdropColor(0, 0, 0, 0.65)
   sf:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.75)
   local st = sf:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
   st:SetPoint('CENTER', sf, 'CENTER', 0, 0)
   sf.text = st
   local candIdx = idx
   sf:SetScript('OnClick', function()
      if type(InteractNearest) == 'function' then
         if InteractDB and InteractDB.config and InteractDB.config.autoDismount then
            DismountIfMounted()
         end
         InteractNearest(CMD_INTERACT_INDEX, candIdx, 1)
      end
   end)
   sf:Hide()
   promptStackFrames[idx] = sf
end

local function HidePromptStack()
   for idx = 2, 3 do
      if promptStackFrames[idx] then
         promptStackFrames[idx]:Hide()
      end
   end
end

UpdatePromptPosition = function()
   EnsureDB()
   local scale = InteractDB.config.promptScale or 1.0
   local x = (InteractDB.config.promptX or 0) / scale
   local y = (InteractDB.config.promptY or -140) / scale
   promptFrame:ClearAllPoints()
   promptFrame:SetPoint('CENTER', UIParent, 'CENTER', x, y)
end

UpdatePromptStyle = function()
   EnsureDB()
   local scale = InteractDB.config.promptScale or 1.0
   local alpha = InteractDB.config.promptAlpha or 0.72
   promptFrame:SetScale(scale)
   promptFrame:SetBackdropColor(0, 0, 0, alpha)
   local br, bg, bb = promptFrame.borderR or 0.6, promptFrame.borderG or 0.6, promptFrame.borderB or 0.6
   promptFrame:SetBackdropBorderColor(br, bg, bb, alpha)
   for idx = 2, 3 do
      local sf = promptStackFrames[idx]
      if sf then
         sf:SetBackdropColor(0, 0, 0, alpha * 0.9)
         local sr, sg, sb = sf.borderR or 0.5, sf.borderG or 0.5, sf.borderB or 0.5
         sf:SetBackdropBorderColor(sr, sg, sb, alpha)
      end
   end
   local canDrag = (not InteractDB.config.lockPrompt) or (InteractConfigFrame and InteractConfigFrame:IsVisible())
   promptFrame:EnableMouse(canDrag and true or false)
   UpdatePromptPosition()
end

-- ============================================================================
-- Auto-Dismount, Interact-to-Fish, Blacklist Current & Zone Auto-Profiles
-- ============================================================================
local scanTooltip = CreateFrame('GameTooltip', 'InteractScanTooltip', nil, 'GameTooltipTemplate')
scanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')

local function IsPlayerMounted()
   for i = 0, 15 do
      local buffIdx = GetPlayerBuff(i, 'HELPFUL')
      if buffIdx and buffIdx >= 0 then
         scanTooltip:ClearLines()
         scanTooltip:SetPlayerBuff(buffIdx)
         local numLines = scanTooltip:NumLines() or 0
         for lineIdx = 1, numLines do
            local leftText = getglobal('InteractScanTooltipTextLeft' .. lineIdx)
            local txt = leftText and leftText:GetText()
            if txt and string.find(txt, 'Increases speed by') then
               return buffIdx
            end
         end
      end
   end
   return nil
end

DismountIfMounted = function()
   local buffIdx = IsPlayerMounted()
   if buffIdx then
      CancelPlayerBuff(buffIdx)
      return true
   end
   return false
end

local MOUNT_SPELLS = {
   ['Summon Charger'] = true,
   ['Summon Warhorse'] = true,
   ['Summon Dreadsteed'] = true,
   ['Summon Felsteed'] = true,
}

local cachedMountBag = nil
local cachedMountSlot = nil
local cachedMountLink = nil

local function TryUseMount()
   if IsPlayerMounted() then return false end
   if cachedMountBag and cachedMountSlot and cachedMountLink then
      local currentLink = GetContainerItemLink(cachedMountBag, cachedMountSlot)
      if currentLink == cachedMountLink then
         UseContainerItem(cachedMountBag, cachedMountSlot)
         return true
      end
      cachedMountBag = nil
      cachedMountSlot = nil
      cachedMountLink = nil
   end
   for bag = 0, 4 do
      local slots = GetContainerNumSlots(bag) or 0
      for slot = 1, slots do
         local link = GetContainerItemLink(bag, slot)
         if link then
            scanTooltip:ClearLines()
            scanTooltip:SetBagItem(bag, slot)
            local numLines = scanTooltip:NumLines() or 0
            for lineIdx = 1, numLines do
               local leftText = getglobal('InteractScanTooltipTextLeft' .. lineIdx)
               local txt = leftText and leftText:GetText()
               if txt and string.find(txt, 'Summons and dismisses a rideable') then
                  cachedMountBag = bag
                  cachedMountSlot = slot
                  cachedMountLink = link
                  UseContainerItem(bag, slot)
                  return true
               end
            end
         end
      end
   end
   local i = 1
   while true do
      local spellName = GetSpellName(i, BOOKTYPE_SPELL)
      if not spellName then break end
      if MOUNT_SPELLS[spellName] then
         CastSpellByName(spellName)
         return true
      end
      i = i + 1
   end
   return false
end

local function HasFishingPoleEquipped()
   local link = GetInventoryItemLink('player', 16)
   if not link then return false end
   local _, _, itemId = string.find(link, 'item:(%d+)')
   if not itemId then return false end
   local _, _, _, _, _, subType = GetItemInfo(tonumber(itemId))
   return subType == 'Fishing Pole'
end

function Interact_Trigger(autoloot)
   if type(InteractNearest) ~= 'function' then return end
   EnsureDB()

   if InteractDB.config.autoDismount and IsPlayerMounted() then
      local nearestName = InteractNearest(CMD_QUERY_NEAREST)
      if nearestName and nearestName ~= '' then
         DismountIfMounted()
      end
   end

   local didInteract = InteractNearest(autoloot or 0)
   if not didInteract and not UnitAffectingCombat('player') then
      if InteractDB.config.interactToFish and HasFishingPoleEquipped() then
         CastSpellByName('Fishing')
      elseif InteractDB.config.interactToMount and not IsPlayerMounted() then
         TryUseMount()
      end
   end
end

function Interact_BlacklistCurrent()
   if type(InteractNearest) ~= 'function' then return end
   EnsureDB()
   local name, _, _, entryId = InteractNearest(CMD_QUERY_NEAREST)
   if entryId and entryId > 0 then
      AddBlacklistID(entryId, name)
      RefreshUI()
      PrintMsg('Blacklisted |cffffd200' .. tostring(name or 'Target') .. '|r (Entry ID ' .. tostring(entryId) .. ').')
   else
      InteractNearest(CMD_BLACKLIST_LAST)
      PrintMsg('Blacklisted the last interacted GameObject for this session.')
   end
end

local CITY_ZONES = {
   ['Stormwind City'] = true,
   ['Ironforge']      = true,
   ['Darnassus']      = true,
   ['Orgrimmar']      = true,
   ['Thunder Bluff']  = true,
   ['Undercity']      = true,
}

local lastAutoProfile = nil

local function AutoSwitchProfileByZone()
   EnsureDB()
   if not InteractDB.config.autoProfile then return end

   local targetProfile = 'questing'
   local inInstance, instType = IsInInstance()
   if inInstance or instType == 'party' or instType == 'raid' then
      targetProfile = 'raid'
   else
      local zone = GetRealZoneText() or GetZoneText() or ''
      if CITY_ZONES[zone] then
         targetProfile = 'city'
      end
   end

   if targetProfile ~= lastAutoProfile then
      lastAutoProfile = targetProfile
      local label = ApplyProfile(targetProfile, true)
      if label then
         RefreshUI()
         PrintMsg('Auto-switched profile to |cffffd200' .. label .. '|r.')
      end
   end
end

-- ============================================================================
-- Custom Profiles & Export / Import Modal
-- ============================================================================
local profileIOFrame = nil
local profileIONameBox = nil
local profileIODataBox = nil
local profileIOCustomList = nil

RefreshProfileIOFrame = function()
   if not profileIOFrame or not profileIOCustomList then return end
   EnsureDB()
   local customs = {}
   for k, _ in pairs(InteractDB.customProfiles) do
      table.insert(customs, k)
   end
   table.sort(customs)
   if table.getn(customs) == 0 then
      profileIOCustomList:SetText('Custom profiles: (none)')
   else
      profileIOCustomList:SetText('Custom profiles: ' .. table.concat(customs, ', '))
   end
end

local function BuildProfileIOFrame()
   if profileIOFrame then return profileIOFrame end
   local f = CreateFrame('Frame', 'InteractProfileIOFrame', UIParent)
   f:SetWidth(420)
   f:SetHeight(250)
   f:SetPoint('CENTER', UIParent, 'CENTER', 0, 20)
   f:SetFrameStrata('FULLSCREEN_DIALOG')
   f:SetMovable(true)
   f:EnableMouse(true)
   f:RegisterForDrag('LeftButton')
   f:SetScript('OnDragStart', function() this:StartMoving() end)
   f:SetScript('OnDragStop', function() this:StopMovingOrSizing() end)
   f:SetBackdrop({
      bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
      edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
   })
   f:Hide()
   table.insert(UISpecialFrames, 'InteractProfileIOFrame')

   local title = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
   title:SetPoint('TOP', f, 'TOP', 0, -16)
   title:SetText('Custom Profiles & Export / Import')

   local closeBtn = CreateFrame('Button', 'InteractProfileIOClose', f, 'UIPanelCloseButton')
   closeBtn:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -6, -6)

   local nameLabel = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
   nameLabel:SetPoint('TOPLEFT', f, 'TOPLEFT', 22, -44)
   nameLabel:SetText('Custom Profile Name:')

   profileIONameBox = CreateFrame('EditBox', 'InteractCustomProfileNameBox', f, 'InputBoxTemplate')
   profileIONameBox:SetWidth(140)
   profileIONameBox:SetHeight(22)
   profileIONameBox:SetPoint('TOPLEFT', f, 'TOPLEFT', 26, -62)
   profileIONameBox:SetAutoFocus(false)
   profileIONameBox:SetMaxLetters(24)

   local saveCustomBtn = CreateFrame('Button', 'InteractCustomSaveBtn', f, 'UIPanelButtonTemplate')
   saveCustomBtn:SetWidth(64)
   saveCustomBtn:SetHeight(22)
   saveCustomBtn:SetPoint('LEFT', profileIONameBox, 'RIGHT', 8, 0)
   saveCustomBtn:SetText('Save')
   saveCustomBtn:SetScript('OnClick', function()
      local raw = profileIONameBox:GetText() or ''
      local _, _, clean = string.find(raw, '^%s*(.-)%s*$')
      if clean and clean ~= '' then
         local key = string.lower(clean)
         SaveProfile(key)
         profileIONameBox:ClearFocus()
         RefreshUI()
         PrintMsg('Saved profile |cffffd200' .. key .. '|r.')
      end
   end)

   local loadCustomBtn = CreateFrame('Button', 'InteractCustomLoadBtn', f, 'UIPanelButtonTemplate')
   loadCustomBtn:SetWidth(64)
   loadCustomBtn:SetHeight(22)
   loadCustomBtn:SetPoint('LEFT', saveCustomBtn, 'RIGHT', 6, 0)
   loadCustomBtn:SetText('Load')
   loadCustomBtn:SetScript('OnClick', function()
      local raw = profileIONameBox:GetText() or ''
      local _, _, clean = string.find(raw, '^%s*(.-)%s*$')
      if clean and clean ~= '' then
         local label = ApplyProfile(string.lower(clean))
         if label then
            profileIONameBox:ClearFocus()
            RefreshUI()
            PrintMsg('Applied profile |cffffd200' .. label .. '|r.')
         else
            PrintMsg('Profile not found: ' .. clean)
         end
      end
   end)

   local delCustomBtn = CreateFrame('Button', 'InteractCustomDelBtn', f, 'UIPanelButtonTemplate')
   delCustomBtn:SetWidth(64)
   delCustomBtn:SetHeight(22)
   delCustomBtn:SetPoint('LEFT', loadCustomBtn, 'RIGHT', 6, 0)
   delCustomBtn:SetText('Delete')
   delCustomBtn:SetScript('OnClick', function()
      local raw = profileIONameBox:GetText() or ''
      local _, _, clean = string.find(raw, '^%s*(.-)%s*$')
      if clean and clean ~= '' then
         local deleted = DeleteCustomProfile(string.lower(clean))
         if deleted then
            profileIONameBox:ClearFocus()
            RefreshUI()
            PrintMsg('Deleted custom profile |cffffd200' .. deleted .. '|r.')
         else
            PrintMsg('Custom profile not found: ' .. clean)
         end
      end
   end)

   profileIOCustomList = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
   profileIOCustomList:SetPoint('TOPLEFT', f, 'TOPLEFT', 22, -92)
   profileIOCustomList:SetWidth(376)
   profileIOCustomList:SetJustifyH('LEFT')

   local ioLabel = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
   ioLabel:SetPoint('TOPLEFT', f, 'TOPLEFT', 22, -124)
   ioLabel:SetText('Export / Import String (Ctrl+C to copy, Ctrl+V to paste):')

   profileIODataBox = CreateFrame('EditBox', 'InteractProfileIODataBox', f, 'InputBoxTemplate')
   profileIODataBox:SetWidth(370)
   profileIODataBox:SetHeight(24)
   profileIODataBox:SetPoint('TOPLEFT', f, 'TOPLEFT', 26, -144)
   profileIODataBox:SetAutoFocus(false)
   profileIODataBox:SetMaxLetters(2048)

   local expBtn = CreateFrame('Button', 'InteractProfileExportBtn', f, 'UIPanelButtonTemplate')
   expBtn:SetWidth(130)
   expBtn:SetHeight(22)
   expBtn:SetPoint('TOPLEFT', f, 'TOPLEFT', 22, -182)
   expBtn:SetText('Export Current')
   expBtn:SetScript('OnClick', function()
      profileIODataBox:SetText(ExportProfileString())
      profileIODataBox:SetFocus()
      profileIODataBox:HighlightText()
   end)

   local impBtn = CreateFrame('Button', 'InteractProfileImportBtn', f, 'UIPanelButtonTemplate')
   impBtn:SetWidth(130)
   impBtn:SetHeight(22)
   impBtn:SetPoint('LEFT', expBtn, 'RIGHT', 10, 0)
   impBtn:SetText('Import String')
   impBtn:SetScript('OnClick', function()
      local count, err = ImportProfileString(profileIODataBox:GetText())
      if count then
         profileIODataBox:ClearFocus()
         RefreshUI()
         PrintMsg('Imported ' .. count .. ' settings.')
      else
         PrintMsg('Import failed: ' .. tostring(err))
      end
   end)

   profileIOFrame = f
   return f
end

ToggleProfileIOFrame = function(autoExport)
   local f = BuildProfileIOFrame()
   if f:IsVisible() and not autoExport then
      f:Hide()
   else
      RefreshProfileIOFrame()
      f:Show()
      if autoExport and profileIODataBox then
         profileIODataBox:SetText(ExportProfileString())
         profileIODataBox:SetFocus()
         profileIODataBox:HighlightText()
      elseif profileIODataBox then
         profileIODataBox:SetText('')
      end
   end
end

-- ============================================================================
-- Minimap Button (Draggable, Left-Click UI, Right-Click Cycle Profiles)
-- ============================================================================
local minimapBtn = CreateFrame('Button', 'InteractMinimapButton', Minimap)
minimapBtn:SetWidth(31)
minimapBtn:SetHeight(31)
minimapBtn:SetFrameStrata('MEDIUM')
minimapBtn:SetFrameLevel(8)
minimapBtn:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
minimapBtn:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
minimapBtn:RegisterForDrag('LeftButton')

local mmIcon = minimapBtn:CreateTexture(nil, 'BACKGROUND')
mmIcon:SetWidth(20)
mmIcon:SetHeight(20)
mmIcon:SetPoint('CENTER', minimapBtn, 'CENTER', 0, 1)
mmIcon:SetTexture('Interface\\Icons\\Ability_Tracking')

local mmBorder = minimapBtn:CreateTexture(nil, 'OVERLAY')
mmBorder:SetWidth(52)
mmBorder:SetHeight(52)
mmBorder:SetPoint('TOPLEFT', minimapBtn, 'TOPLEFT', 0, 0)
mmBorder:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')

UpdateMinimapButton = function()
   EnsureDB()
   if not InteractDB.config.showMinimap then
      minimapBtn:Hide()
      return
   end
   local angle = InteractDB.config.minimapAngle or 220
   local rad = math.rad(angle)
   local x = math.cos(rad) * 80
   local y = math.sin(rad) * 80
   minimapBtn:ClearAllPoints()
   minimapBtn:SetPoint('CENTER', Minimap, 'CENTER', x, y)
   minimapBtn:Show()
end

minimapBtn:SetScript('OnDragStart', function()
   this:SetScript('OnUpdate', function()
      local mx, my = Minimap:GetCenter()
      local cx, cy = GetCursorPosition()
      local scale = Minimap:GetEffectiveScale() or 1
      cx = cx / scale
      cy = cy / scale
      local deg = math.deg(math.atan2(cy - my, cx - mx))
      SetConfigValue('minimapAngle', deg)
   end)
end)

minimapBtn:SetScript('OnDragStop', function()
   this:SetScript('OnUpdate', nil)
end)

local PROFILE_CYCLE_ORDER = { 'questing', 'raid', 'gathering', 'city' }
local minimapDropdown = CreateFrame('Frame', 'InteractMinimapMenu', UIParent, 'UIDropDownMenuTemplate')

local function InitMinimapDropdown()
   EnsureDB()
   local info = {}
   info.isTitle = 1
   info.text = 'InteractMod v' .. ADDON_VERSION
   info.notCheckable = 1
   UIDropDownMenu_AddButton(info)

   info = {}
   info.text = 'Open Settings (/interact)'
   info.notCheckable = 1
   info.func = function()
      ToggleConfigUI()
   end
   UIDropDownMenu_AddButton(info)

   info = {}
   info.text = 'Populate Focus from Marks (1..8)'
   info.notCheckable = 1
   info.func = function()
      if Interact_PopulateFocusFromMarks then
         Interact_PopulateFocusFromMarks(false)
      end
   end
   UIDropDownMenu_AddButton(info)

   info = {}
   info.text = 'Broadcast Focus 1..9'
   info.notCheckable = 1
   info.func = function()
      if Interact_BroadcastAllFocus then
         Interact_BroadcastAllFocus()
      end
   end
   UIDropDownMenu_AddButton(info)

   info = {}
   info.text = 'Clear All Focus (1..9)'
   info.notCheckable = 1
   info.func = function()
      if Interact_ClearAllFocus then
         Interact_ClearAllFocus()
      end
   end
   UIDropDownMenu_AddButton(info)

   for _, pKey in ipairs(PROFILE_CYCLE_ORDER) do
      local pDef = PROFILES[pKey]
      if pDef then
         local profileKey = pKey
         info = {}
         info.text = 'Profile: ' .. pDef.label
         info.checked = (activeProfileName == pDef.label) and 1 or nil
         info.func = function()
            local label = ApplyProfile(profileKey)
            if label then
               RefreshUI()
               PrintMsg('Applied profile: |cffffd200' .. label .. '|r')
            end
         end
         UIDropDownMenu_AddButton(info)
      end
   end

   info = {}
   info.text = 'Close'
   info.notCheckable = 1
   info.func = function()
      if CloseDropDownMenus then CloseDropDownMenus() end
   end
   UIDropDownMenu_AddButton(info)
end

minimapBtn:SetScript('OnClick', function()
   if arg1 == 'RightButton' then
      GameTooltip:Hide()
      UIDropDownMenu_Initialize(minimapDropdown, InitMinimapDropdown, 'MENU')
      ToggleDropDownMenu(1, nil, minimapDropdown, this, 0, 0)
   else
      ToggleConfigUI()
   end
end)

minimapBtn:SetScript('OnEnter', function()
   GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
   GameTooltip:SetText('InteractMod', 0, 0.8, 1)
   local key = GetBindingKey('Interact (auto-loot)') or GetBindingKey('Interact') or 'Unbound'
   GameTooltip:AddLine('Keybind: |cffffd200' .. key .. '|r', 1, 1, 1)
   if activeProfileName then
      GameTooltip:AddLine('Active Profile: |cffffd200' .. activeProfileName .. '|r', 1, 1, 1)
   end
   GameTooltip:AddLine('Left-Click: Open Settings', 0.8, 0.8, 0.8)
   GameTooltip:AddLine('Right-Click: Context Menu (Focus & Profiles)', 0.8, 0.8, 0.8)
   GameTooltip:AddLine('Drag: Move Button', 0.8, 0.8, 0.8)
   GameTooltip:Show()
end)

minimapBtn:SetScript('OnLeave', function()
   GameTooltip:Hide()
end)

-- ============================================================================
-- Initialization, DLL Sync & Soft-Target Prompt Polling
-- ============================================================================
InteractAddon = InteractAddon or {}
InteractAddon.CMD_FOCUS_SET        = CMD_FOCUS_SET
InteractAddon.CMD_FOCUS_CLEAR      = CMD_FOCUS_CLEAR
InteractAddon.CMD_FOCUS_TARGET     = CMD_FOCUS_TARGET
InteractAddon.CMD_FOCUS_SWAP       = CMD_FOCUS_SWAP
InteractAddon.CMD_FOCUS_RESTORE    = CMD_FOCUS_RESTORE
InteractAddon.CMD_FOCUS_QUERY      = CMD_FOCUS_QUERY
InteractAddon.CMD_FOCUS_TARGET_TOT = CMD_FOCUS_TARGET_TOT
InteractAddon.CMD_FOCUS_SET_GUID       = CMD_FOCUS_SET_GUID
InteractAddon.CMD_FOCUS_GET_GUID       = CMD_FOCUS_GET_GUID
InteractAddon.CMD_FOCUS_POPULATE_MARKS = CMD_FOCUS_POPULATE_MARKS
InteractAddon.CMD_QUERY_SPARKLES       = CMD_QUERY_SPARKLES
InteractAddon.EnsureDB             = EnsureDB
InteractAddon.PrintMsg             = PrintMsg
InteractAddon.SetConfigValue       = SetConfigValue
InteractAddon.GetActiveConfigTab   = function()
   return activeConfigTab
end
InteractAddon.RefreshUI            = function()
   if RefreshUI then RefreshUI() end
end
InteractAddon.RegisterFocusModule  = function(updateStyleFn, updateFrameFn)
   UpdateFocusFrameStyle = updateStyleFn
   InteractAddon.UpdateFocusFrame = updateFrameFn
end

local cachedInteractKey = nil
local function RefreshCachedInteractKey()
   cachedInteractKey = (GetBindingKey and (GetBindingKey('Interact (auto-loot)') or GetBindingKey('Interact'))) or 'Interact'
end

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('ADDON_LOADED')
eventFrame:RegisterEvent('PLAYER_LOGIN')
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
eventFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
eventFrame:RegisterEvent('MERCHANT_SHOW')
eventFrame:RegisterEvent('QUEST_LOG_UPDATE')
eventFrame:RegisterEvent('UPDATE_BINDINGS')
eventFrame:SetScript('OnEvent', function()
   if event == 'UPDATE_BINDINGS' then
      RefreshCachedInteractKey()
      return
   end
   if event == 'ADDON_LOADED' and arg1 == 'Interact' then
      RefreshCachedInteractKey()
      EnsureDB()
      if not InteractDB.config.autoProfile and InteractCharDB.activeProfile then
         ApplyProfile(InteractCharDB.activeProfile, true)
      end
      UpdatePromptStyle()
      if UpdateFocusFrameStyle then UpdateFocusFrameStyle() end
      UpdateMinimapButton()
      SyncAllToDLL()
   elseif event == 'PLAYER_LOGIN' then
      EnsureDB()
      UpdatePromptStyle()
      if UpdateFocusFrameStyle then UpdateFocusFrameStyle() end
      UpdateMinimapButton()
      SyncAllToDLL()
      AutoSwitchProfileByZone()
      local dllVer = (type(InteractNearest) == 'function') and InteractNearest(CMD_GET_VERSION) or nil
      if dllVer then
         PrintMsg('Loaded |cffffd200v' .. ADDON_VERSION .. '|r (DLL: |cff00ff00v' .. tostring(dllVer) .. '|r). Type |cffffd200/interact|r for settings.')
      else
         PrintMsg('Loaded |cffffd200v' .. ADDON_VERSION .. '|r (DLL: |cffff5555unknown|r). Type |cffffd200/interact|r for settings.')
      end
   elseif event == 'PLAYER_ENTERING_WORLD' or event == 'ZONE_CHANGED_NEW_AREA' then
      AutoSwitchProfileByZone()
      if InteractAddon.MarkQuestCacheDirty then InteractAddon.MarkQuestCacheDirty() end
   elseif event == 'QUEST_LOG_UPDATE' then
      if InteractAddon.MarkQuestCacheDirty then InteractAddon.MarkQuestCacheDirty() end
   elseif event == 'MERCHANT_SHOW' then
      EnsureDB()
      if InteractDB.config.autoRepair and CanMerchantRepair and CanMerchantRepair() then
         local cost = GetRepairAllCost and GetRepairAllCost()
         if cost and cost > 0 then
            RepairAllItems()
            local coinStr = GetCoinText and GetCoinText(cost, ', ') or (tostring(cost) .. 'c')
            PrintMsg('Repaired all items for |cffffd200' .. coinStr .. '|r.')
         end
      end
      if InteractDB.config.autoSellGrey then
         local sold = 0
         for bag = 0, 4 do
            local slots = GetContainerNumSlots(bag) or 0
            for slot = 1, slots do
               local link = GetContainerItemLink(bag, slot)
               if link and string.find(link, '|cff9d9d9d', 1, true) then
                  UseContainerItem(bag, slot)
                  sold = sold + 1
               end
            end
         end
         if sold > 0 then
            PrintMsg('Sold |cffffd200' .. sold .. '|r poor-quality item stack(s).')
         end
      end
   end
end)

local lastPromptText = nil
local lastPromptVerb = nil
local lastStackTexts = {}
local lastStackVerbs = {}
local stackNames = {}
local stackVerbs = {}
local stackDists = {}
local promptElapsed = 0
eventFrame:SetScript('OnUpdate', function()
   promptElapsed = promptElapsed + (arg1 or 0)
   if promptElapsed < 0.1 then return end
   promptElapsed = 0

   if InteractAddon.UpdateFocusFrame then
      InteractAddon.UpdateFocusFrame()
   end

   if not InteractDB or not InteractDB.config or not InteractDB.config.showPrompt then
      if promptFrame:IsVisible() then promptFrame:Hide() end
      HidePromptStack()
      lastPromptText = nil
      lastPromptVerb = nil
      return
   end

   local cfgOpen = (InteractConfigFrame and InteractConfigFrame:IsVisible())
   local canDrag = (not InteractDB.config.lockPrompt) or cfgOpen
   promptFrame:EnableMouse(canDrag and true or false)

   local name, actionType, dist, _, n2, v2, d2, _, n3, v3, d3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
   if type(InteractNearest) == 'function' then
      if InteractDB.config.showPromptStack then
         name, actionType, dist, _, n2, v2, d2, _, n3, v3, d3 = InteractNearest(CMD_QUERY_STACK)
      else
         name, actionType, dist = InteractNearest(CMD_QUERY_NEAREST)
      end
   end

   local key = cachedInteractKey or 'Interact'
   local promptAlpha = (InteractDB and InteractDB.config and InteractDB.config.promptAlpha) or 0.72
   if name and name ~= '' then
      local verb = actionType or 'Interact'
      local textStr = dist and string.format('[%s] %s %s (%.1f yd)', key, verb, name, dist) or string.format('[%s] %s %s', key, verb, name)
      if verb ~= lastPromptVerb then
         local col = ACTION_COLORS[verb] or ACTION_COLORS.Interact
         promptText:SetTextColor(col[1], col[2], col[3])
         promptFrame.borderR, promptFrame.borderG, promptFrame.borderB = col[1], col[2], col[3]
         promptFrame:SetBackdropBorderColor(col[1], col[2], col[3], promptAlpha)
         lastPromptVerb = verb
      end
      if textStr ~= lastPromptText then
         promptText:SetText(textStr)
         local w = (promptText:GetStringWidth() or 180) + 28
         if w < 160 then w = 160 end
         promptFrame:SetWidth(w)
         lastPromptText = textStr
      end
      promptFrame:Show()

      if InteractDB.config.showPromptStack then
         stackNames[2], stackNames[3] = n2, n3
         stackVerbs[2], stackVerbs[3] = v2, v3
         stackDists[2], stackDists[3] = d2, d3
         for idx = 2, 3 do
            local sf = promptStackFrames[idx]
            local sn = stackNames[idx]
            if sf and sn and sn ~= '' then
               local sv = stackVerbs[idx] or 'Interact'
               local stext = stackDists[idx] and string.format('%d. %s %s (%.1f yd)', idx, sv, sn, stackDists[idx]) or string.format('%d. %s %s', idx, sv, sn)
               if sv ~= lastStackVerbs[idx] then
                  local scol = ACTION_COLORS[sv] or ACTION_COLORS.Interact
                  sf.text:SetTextColor(scol[1], scol[2], scol[3])
                  sf.borderR, sf.borderG, sf.borderB = scol[1], scol[2], scol[3]
                  sf:SetBackdropBorderColor(scol[1], scol[2], scol[3], promptAlpha)
                  lastStackVerbs[idx] = sv
               end
               if stext ~= lastStackTexts[idx] then
                  sf.text:SetText(stext)
                  local sw = (sf.text:GetStringWidth() or 140) + 22
                  if sw < 140 then sw = 140 end
                  sf:SetWidth(sw)
                  lastStackTexts[idx] = stext
               end
               sf:Show()
            elseif sf then
               if sf:IsVisible() then sf:Hide() end
               lastStackTexts[idx] = nil
               lastStackVerbs[idx] = nil
            end
         end
      else
         HidePromptStack()
      end
   elseif cfgOpen and activeConfigTab == 3 then
      local prevText = string.format('[%s] Interact Prompt Preview (Drag Me)', key)
      if lastPromptVerb ~= '__PREVIEW__' then
         promptText:SetTextColor(1, 0.82, 0.25)
         promptFrame.borderR, promptFrame.borderG, promptFrame.borderB = 1, 0.82, 0.25
         promptFrame:SetBackdropBorderColor(1, 0.82, 0.25, promptAlpha)
         lastPromptVerb = '__PREVIEW__'
      end
      if prevText ~= lastPromptText then
         promptText:SetText(prevText)
         local w = (promptText:GetStringWidth() or 180) + 28
         if w < 160 then w = 160 end
         promptFrame:SetWidth(w)
         lastPromptText = prevText
      end
      promptFrame:Show()
      HidePromptStack()
   else
      if promptFrame:IsVisible() then promptFrame:Hide() end
      HidePromptStack()
      lastPromptText = nil
      lastPromptVerb = nil
   end
end)
