-- sf? is it narrower?
--local FONT = "Interface\\Addons\\SharedMedia_MyMedia\\fonts\\HelveticaNeue.ttf"
local FONT = [[Interface\Addons\SharedMedia_MyMedia\fonts\sf-thin.ttf]]
local TEXTURE = "Interface\\Addons\\SharedMedia\\statusbar\\Flat.tga"
-- might want to increase this to show longer name, more debuffs (?)
--local WIDTH = 36
local WIDTH = 48


local function styleFrame(frame)
  print("styleFrame: " .. frame:GetName())

  frame.name:SetFont(FONT, 10)

  frame.healthBar:SetStatusBarTexture(TEXTURE)

  frame:SetWidth(WIDTH)
end


local function shortenName(frame)
  if not frame:IsVisible() then
    return
  end

  local name = frame.name:GetText()
  -- XXX bad argument #1 to 'sub' (string expected, got nil)
  if name then
    -- may need to be more clever with this for wider characters
    -- XXX and whether the role icon is shown or not

    --local newname = string.sub(name, 1, 2)
    --print(frame:GetName() .. ": " .. name .. " => " .. newname)
    --frame.name:SetText(newname)

    local tooBig = true
    -- XXX increase this?
    -- XXX I don't think this handles unicode properly
    local chars = 4
    while tooBig do
      local newname = string.sub(name, 1, chars)
      --print(frame:GetName() .. ": " .. name .. " => " .. newname)
      frame.name:SetText(newname)
      tooBig = frame.name:IsTruncated()
      chars = chars - 1
    end

  end
end



-- XXX these don't seem to work
hooksecurefunc("DefaultCompactUnitFrameSetup", function(...)
  print(...)
end)
--hooksecurefunc("DefaultCompactMiniFrameSetup", styleFrame) 


--[[
hooksecurefunc("CompactRaidFrameContainer_GetUnitFrame", function(self, unit, frame)
  print("CompactRaidFrameContainer_GetUnitFrame")
  styleFrame(frame)
  -- this is called at login, twice. or when leaving the raid
  -- again after joining the instance
  -- I don't see it called when reloading ui while in raid
  -- /dump CompactRaidFrame1
  -- this still exists after leaving raid, and on login
  -- (2 and 3 do not)
  -- so, this strategy may indeed work, but just not for player
end)
--]]


hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame, func)
  --print("CompactUnitFrame_SetUpFrame: " .. frame:GetName())
  -- XXX this is also getting other stuff like NamePlate6UnitFrame
  -- XXX can I find a better function to hook?

  local prefix = "CompactRaidFrame"
  if prefix == string.sub(frame:GetName(), 1, string.len(prefix)) then
    styleFrame(frame)
  end
end)


--[[
hooksecurefunc("CompactRaidFrameContainer_GetUnitFrame", function(self, unit, frameType)
  -- XXX ok, this is always the container now
  -- XXX ugh ok, self. I don't think this will work to get us the frame
  print("CompactRaidFrameContainer_GetUnitFrame: " .. frame:GetName())

  -- This is often called
  -- XXX why?
  if frame:GetName() == "CompactRaidFrameContainer" then
    return
  end

  styleFrame(frame)
end)
--]]


-- XXX name shortening isn't sticking, it might be getting changed again
-- CompactUnitFrame_UpdateName
-- can try hooking this
-- if I do, might want it to be pretty generic based on width (?)
-- XXX the role icon takes up a ton of space for the name. remove it?

-- XXX this is called a lot
-- XXX for nameplates too, which I don't want
hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
  local prefix = "CompactRaidFrame"
  if prefix == string.sub(frame:GetName(), 1, string.len(prefix)) then
    shortenName(frame)
  end
end)


-- Some frames are created before the addon loads: player frame, or if already
-- in a group
local function bootstrap()
  for i = 1,40 do
    frame = _G["CompactRaidFrame" .. i]
    if frame then
      styleFrame(frame)
      shortenName(frame)
    else
      break
    end
  end
  -- XXX trigger reflow?
end

bootstrap()

-- XXX change total size so I can move further right?

-- XXX this isn't really working for new people joining
