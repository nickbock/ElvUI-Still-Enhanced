local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

local sub, find = string.sub, string.find
local abs, atan2, cos, sin, sqrt2, random, floor, ceil, random = math.abs, math.atan2, math.cos, math.sin, math.sqrt(2), math.random, math.floor, math.ceil, math.random
local pairs, type, select, unpack = pairs, type, select, unpack
local GetPlayerMapPosition, GetPlayerFacing = GetPlayerMapPosition, GetPlayerFacing
local unitframeFont

local roleIconTextures = {
	TANK = [[Interface\AddOns\ElvUI\media\textures\tank.tga]],
	HEALER = [[Interface\AddOns\ElvUI\media\textures\healer.tga]],
	DAMAGER = [[Interface\AddOns\ElvUI\media\textures\dps.tga]],
	DC = [[Interface\AddOns\ElvUI_Enhanced\media\textures\dc.tga]],
}

local classes = {	DEATHKNIGHT, DRUID, HUNTER,	MAGE, MONK, PALADIN, PRIEST, ROGUE, SHAMAN, WARLOCK, WARRIOR }
local specializations = { }

for classID = 1, MAX_CLASSES do
	local _, classTag = GetClassInfoByID(classID)
	local numTabs = GetNumSpecializationsForClassID(classID)
	classes[classTag] = {}
	for i = 1, numTabs do
		local id, name = GetSpecializationInfoForClassID(classID, i)
		local role = GetSpecializationRoleByID(id)
		classes[classTag][i] = { role = role, specName = name }
		specializations[id] = role
	end
end

local function CalculateCorner(r)
	return 0.5 + cos(r) / sqrt2, 0.5 + sin(r) / sqrt2;
end

local function RotateTexture(texture, angle)
	local LRx, LRy = CalculateCorner(angle + 0.785398163);
	local LLx, LLy = CalculateCorner(angle + 2.35619449);
	local ULx, ULy = CalculateCorner(angle + 3.92699082);
	local URx, URy = CalculateCorner(angle - 0.785398163);
	
	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

function UF:UpdateGPS(frame)
	local gps = frame.gps
	if not gps then return end
	
	-- GPS Disabled or not GPS parent frame visible or not in Party or Raid, Hide gps
	if not frame:IsVisible() or UnitIsUnit(gps.unit, 'player') or not (UnitInParty(gps.unit) or UnitInRaid(gps.unit)) then
		gps:Hide()
		return
	end

	-- Arbitrary method to determine if we should try to calculate the map position
	local x, y = GetPlayerMapPosition(gps.unit)
	local distance, angle
	if not (x == 0 and y == 0) then
		-- Unit is in acceptable range, calculate position fast
		distance, angle = E:GetDistance('player', gps.unit, true)
	end
	if not angle then
		-- no bearing show - to indicate we are lost :)
		gps.Text:SetText("-")
		gps.Texture:Hide()
		gps:Show()
		return
	end
	
	RotateTexture(gps.Texture, angle)
	gps.Texture:Show()

	gps.Text:SetFormattedText("%d", distance)
	gps:Show()
end

