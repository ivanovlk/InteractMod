-- ============================================================================
-- InteractMod - 3D-Projected World Sparkles (Herbs, Mines, Chests, Quest Objects)
-- Compatible with Vanilla WoW 1.12.1 (Lua 5.0)
-- ============================================================================

local IA = InteractAddon
local CMD_QUERY_SPARKLES = IA.CMD_QUERY_SPARKLES

local MAX_SPARKLES = 6
local SPARKLE_COLORS = {
   H = { 0.25, 1.00, 0.35 }, -- Herb: emerald green
   M = { 0.35, 0.85, 1.00 }, -- Mine: icy cyan
   C = { 1.00, 0.82, 0.18 }, -- Chest: gold
   Q = { 1.00, 0.55, 0.10 }, -- Quest object: bright amber
}

local QUEST_STOP_WORDS = {
   collect = true, gather = true, bring = true, ['return'] = true,
   examine = true, inspect = true, search = true, slain = true,
   killed = true, speak = true, inside = true, outside = true,
   there = true, these = true, those = true, their = true,
   where = true, which = true, ['while'] = true, about = true,
   above = true, below = true, under = true, around = true,
   quest = true, complete = true, found = true, place = true,
}

local questCacheDirty = true
local questStrings = {}
local questWords = {}
local questMatchCache = {}

IA.MarkQuestCacheDirty = function()
   questCacheDirty = true
end

local function AddQuestWords(text)
   if not text or text == '' then return end
   local low = string.lower(text)
   table.insert(questStrings, low)
   local pos = 1
   while true do
      local s, e = string.find(low, '[a-z]+', pos)
      if not s then break end
      local w = string.sub(low, s, e)
      if string.len(w) >= 5 and not QUEST_STOP_WORDS[w] then
         questWords[w] = true
      end
      pos = e + 1
   end
end

local function RebuildQuestSparkleCache()
   questCacheDirty = false
   questStrings = {}
   questWords = {}
   questMatchCache = {}
   if not GetNumQuestLogEntries or not GetQuestLogTitle then
      return
   end
   local numEntries = GetNumQuestLogEntries() or 0
   for i = 1, numEntries do
      local title, _, _, _, isHeader = GetQuestLogTitle(i)
      if title and not isHeader then
         AddQuestWords(title)
         if GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
            local numObj = GetNumQuestLeaderBoards(i) or 0
            for j = 1, numObj do
               local objText, _, finished = GetQuestLogLeaderBoard(j, i)
               if objText and not finished then
                  AddQuestWords(objText)
               end
            end
         end
      end
   end
end

local function IsQuestSparkleMatch(objName)
   if not objName or objName == '' then return false end
   if questCacheDirty then RebuildQuestSparkleCache() end
   local cached = questMatchCache[objName]
   if cached ~= nil then
      return cached
   end
   local matched = false
   local low = string.lower(objName)
   local n = table.getn(questStrings)
   for i = 1, n do
      if string.find(questStrings[i], low, 1, true) then
         matched = true
         break
      end
   end
   if not matched then
      local pos = 1
      while true do
         local s, e = string.find(low, '[a-z]+', pos)
         if not s then break end
         local w = string.sub(low, s, e)
         if string.len(w) >= 5 and not QUEST_STOP_WORDS[w] and questWords[w] then
            matched = true
            break
         end
         pos = e + 1
      end
   end
   questMatchCache[objName] = matched
   return matched
end

local sparklePool = {}
for i = 1, MAX_SPARKLES do
   local sf = CreateFrame('Frame', 'InteractSparkle' .. i, WorldFrame)
   sf:SetWidth(28)
   sf:SetHeight(28)
   sf:SetFrameStrata('BACKGROUND')

   local outer = sf:CreateTexture(nil, 'OVERLAY')
   outer:SetAllPoints(sf)
   outer:SetTexture('Interface\\Cooldown\\star4')
   outer:SetBlendMode('ADD')
   sf.outer = outer

   local inner = sf:CreateTexture(nil, 'OVERLAY')
   inner:SetWidth(16)
   inner:SetHeight(16)
   inner:SetPoint('CENTER', sf, 'CENTER', 0, 0)
   inner:SetTexture('Interface\\Cooldown\\star4')
   inner:SetBlendMode('ADD')
   sf.inner = inner

   sf:Hide()
   sparklePool[i] = sf
end

local sparklesAnyVisible = false
local function HideAllSparkles()
   if not sparklesAnyVisible then return end
   sparklesAnyVisible = false
   for i = 1, MAX_SPARKLES do
      sparklePool[i]:Hide()
   end
end

local sparkleXs = {}
local sparkleYs = {}
local sparkleSs = {}
local sparkleFrame = CreateFrame('Frame')
local sparklePhase = 0
local sparkleElapsed = 0
local sparkleScanElapsed = 0.066
sparkleFrame:SetScript('OnUpdate', function()
   local cfg = InteractDB and InteractDB.config
   if not cfg or not cfg.showSparkles or type(InteractNearest) ~= 'function' then
      if sparklesAnyVisible then HideAllSparkles() end
      return
   end
   if not (cfg.sparkleHerbs or cfg.sparkleMines or cfg.sparkleChests or cfg.sparkleQuests) then
      if sparklesAnyVisible then HideAllSparkles() end
      return
   end

   local dt = arg1 or 0.016
   sparklePhase = sparklePhase + dt * 3.5
   sparkleElapsed = sparkleElapsed + dt
   sparkleScanElapsed = sparkleScanElapsed + dt
   if sparkleElapsed < 0.033 then return end
   sparkleElapsed = 0

   local wfW = WorldFrame and WorldFrame:GetWidth() or 0
   local wfH = WorldFrame and WorldFrame:GetHeight() or 0
   if wfW <= 0 or wfH <= 0 then
      if sparklesAnyVisible then HideAllSparkles() end
      return
   end

   if sparkleScanElapsed >= 0.066 then
      sparkleScanElapsed = 0
      local x1, y1, s1, x2, y2, s2, x3, y3, s3, x4, y4, s4, x5, y5, s5, x6, y6, s6 = InteractNearest(CMD_QUERY_SPARKLES, wfW / wfH)
      if not x1 then
         HideAllSparkles()
         sparkleXs[1] = nil
         return
      end
      sparkleXs[1], sparkleXs[2], sparkleXs[3], sparkleXs[4], sparkleXs[5], sparkleXs[6] = x1, x2, x3, x4, x5, x6
      sparkleYs[1], sparkleYs[2], sparkleYs[3], sparkleYs[4], sparkleYs[5], sparkleYs[6] = y1, y2, y3, y4, y5, y6
      sparkleSs[1], sparkleSs[2], sparkleSs[3], sparkleSs[4], sparkleSs[5], sparkleSs[6] = s1, s2, s3, s4, s5, s6
   elseif not sparkleXs[1] then
      return
   end

   local used = 0
   for i = 1, MAX_SPARKLES do
      local nx, ny, tagged = sparkleXs[i], sparkleYs[i], sparkleSs[i]
      if nx and ny and tagged then
         local kind = string.sub(tagged, 1, 1)
         local objName = string.sub(tagged, 3)
         local show = false
         local colorKey = kind

         if kind == 'H' then
            show = cfg.sparkleHerbs and true or false
         elseif kind == 'M' then
            show = cfg.sparkleMines and true or false
         elseif kind == 'C' then
            if cfg.sparkleQuests and IsQuestSparkleMatch(objName) then
               show = true
               colorKey = 'Q'
            elseif cfg.sparkleChests then
               show = true
            end
         elseif kind == 'Q' then
            if cfg.sparkleQuests and IsQuestSparkleMatch(objName) then
               show = true
               colorKey = 'Q'
            end
         end

         if show then
            used = used + 1
            local sf = sparklePool[used]
            local col = SPARKLE_COLORS[colorKey] or SPARKLE_COLORS.C
            local pulse = 0.65 + 0.35 * math.sin(sparklePhase + used * 1.1)
            local size = 22 + 8 * pulse
            sf:SetWidth(size)
            sf:SetHeight(size)
            sf.inner:SetWidth(size * 0.55)
            sf.inner:SetHeight(size * 0.55)
            sf.outer:SetVertexColor(col[1], col[2], col[3], 0.85 * pulse)
            sf.inner:SetVertexColor(1, 1, 1, 0.90 * pulse)
            sf:ClearAllPoints()
            sf:SetPoint('CENTER', WorldFrame, 'BOTTOMLEFT', nx * wfW, ny * wfH)
            sf:Show()
         end
      end
   end

   sparklesAnyVisible = (used > 0)
   for i = used + 1, MAX_SPARKLES do
      sparklePool[i]:Hide()
   end
end)

