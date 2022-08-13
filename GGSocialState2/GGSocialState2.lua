-------------------------------------------------------------------------------
-- Upvalued Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

local string = _G.string
local pairs = _G.pairs

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local L = LibStub("AceLocale-3.0"):GetLocale("GGSocialState", false)
local LibQTip = LibStub('LibQTip-1.0')
local frame = CreateFrame("frame")

local tooltip
local LDB_ANCHOR

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("GGSocialState",
	{
		type	= "data source",
		icon	= "Interface\\Icons\\INV_Drink_08.png",
		label	= "GGSocialState",
		text	= "GGSocialState"
	})

local update_Broker
--local MyRealm = GetRealmName()

local GROUP_CHECKMARK	= "|TInterface\\Buttons\\UI-CheckBox-Check:0|t"
local ONLINE_ICON       = "|T" .. _G.FRIENDS_TEXTURE_ONLINE .. ":18|t"
local AWAY_ICON			= "|TInterface\\FriendsFrame\\StatusIcon-Away:18|t"
local BUSY_ICON			= "|TInterface\\FriendsFrame\\StatusIcon-DnD:18|t"
local MOBILE_ICON		= "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:18|t"
local MINIMIZE			= "|TInterface\\BUTTONS\\UI-PlusButton-Up:0|t"
local BROADCAST_ICON 	= "|TInterface\\FriendsFrame\\BroadcastIcon:0|t"


local FACTION_COLOR_HORDE = RED_FONT_COLOR_CODE
local FACTION_COLOR_ALLIANCE = "|cff0070dd"

local BNET_CLIENT = {}
BNET_CLIENT["WoW"]  = "World of Warcraft"
BNET_CLIENT["S1"]   = "Starcraft: Remastered"
BNET_CLIENT["S2"]   = "StarCraft 2"
BNET_CLIENT["OSI"]  = "Diablo II: Resurrected"
BNET_CLIENT["D3"]   = "Diablo III"
BNET_CLIENT["ANBS"] = "Diablo Immortal"
BNET_CLIENT["WTCG"] = "Hearthstone"
BNET_CLIENT["App"]  = "Battle.net Desktop App"
BNET_CLIENT["BSAp"] = "Battle.net Mobile App"
BNET_CLIENT["Hero"] = "Hero of the Storm"
BNET_CLIENT["Pro"]  = "Overwatch"
BNET_CLIENT["DST2"] = "Destiny 2"
BNET_CLIENT["ZEUS"] = "Call of Duty: Black Ops"
BNET_CLIENT["VIPR"] = "Call of Duty: Black Ops 4"
BNET_CLIENT["ODIN"] = "Call of Duty: Modern Warfare"
BNET_CLIENT["LAZR"] = "Call of Duty: Modern Warfare 2"
BNET_CLIENT["W3"]   = "Warcraft III: Reforged"
BNET_CLIENT["RTRO"] = "Blizzard Arcade Collection"
BNET_CLIENT["WLBY"] = "Crash Bandicoot 4"
BNET_CLIENT["FORE"] = "Call of Duty: Vanguard"
BNET_CLIENT["GRY"]  = "Warcraft Arclight Rumble"

local CLIENT_ICON_SIZE = 18

-------------------------------------------------------------------------------
-- Font definitions.
-------------------------------------------------------------------------------
-- Setup the Title Font. 14
local ssTitleFont = CreateFont("ssTitleFont")
ssTitleFont:SetTextColor(1,0.823529,0)
ssTitleFont:SetFont(GameTooltipText:GetFont(), 14)

-- Setup the Header Font. 12
local ssHeaderFont = CreateFont("ssHeaderFont")
ssHeaderFont:SetTextColor(1,0.823529,0)
ssHeaderFont:SetFont(GameTooltipHeaderText:GetFont(), 12)

-- Setup the Regular Font. 12
local ssRegFont = CreateFont("ssRegFont")
ssRegFont:SetTextColor(1,0.823529,0)
ssRegFont:SetFont(GameTooltipText:GetFont(), 12)

local list_sort = {
	CLIENTICON  =   function(a, b)
		return a["CLIENTICON"] < b["CLIENTICON"]
	end,
	STATUS      =   function(a, b)
		return a["STATUS"] < b["STATUS"]
	end,
	TOONNAME	=	function(a, b)
		return a["TOONNAME"] < b["TOONNAME"]
	end,
	LEVEL		=	function(a, b)
		if a["LEVEL"] < b["LEVEL"] then
			return true
		elseif a["LEVEL"] > b["LEVEL"] then
			return false
		else  -- TOONNAME
			return a["TOONNAME"] < b["TOONNAME"]
		end
	end,
	RANKINDEX	=	function(a, b)
		if a["RANKINDEX"] > b["RANKINDEX"] then
			return true
		elseif a["RANKINDEX"] < b["RANKINDEX"] then
			return false
		else -- TOONNAME
			return a["TOONNAME"] < b["TOONNAME"]
		end
	end,
	ZONENAME	=	function(a, b)
		if a["ZONENAME"] < b["ZONENAME"] then
			return true
		elseif a["ZONENAME"] > b["ZONENAME"] then
			return false
		else -- TOONNAME
			return a["TOONNAME"] < b["TOONNAME"]
		end
	end,
	REALMNAME	=	function(a, b)
		if a["REALMNAME"] < b["REALMNAME"] then
			return true
		elseif a["REALMNAME"] > b["REALMNAME"] then
			return false
		else -- TOONNAME
			return a["ZONENAME"] < b["ZONENAME"]
		end
	end,
	revCLIENTICON   =   function(a, b)
		return a["CLIENTICON"] > b["CLIENTICON"]
	end,
	revSTATUS       =   function(a, b)
		return a["STATUS"] > b["STATUS"]
	end,
	revTOONNAME	    =   function(a, b)
		return a["TOONNAME"] > b["TOONNAME"]
	end,
	revLEVEL		=	function(a, b)
		if a["LEVEL"] > b["LEVEL"] then
			return true
		elseif a["LEVEL"] < b["LEVEL"] then
			return false
		else  -- TOONNAME
			return a["TOONNAME"] < b["TOONNAME"]
		end
	end,
	revRANKINDEX	=	function(a, b)
		if a["RANKINDEX"] < b["RANKINDEX"] then
			return true
		elseif a["RANKINDEX"] > b["RANKINDEX"] then
			return false
		else -- TOONNAME
			return a["TOONNAME"] < b["TOONNAME"]
		end
	end,
	revZONENAME	=	function(a, b)
		if a["ZONENAME"] > b["ZONENAME"] then
			return true
		elseif a["ZONENAME"] < b["ZONENAME"] then
			return false
		else -- TOONNAME
			return a["TOONNAME"] < b["TOONNAME"]
		end
	end,
	revREALMNAME	=	function(a, b)
		if a["REALMNAME"] > b["REALMNAME"] then
			return true
		elseif a["REALMNAME"] < b["REALMNAME"] then
			return false
		else -- TOONNAME
			return a["ZONENAME"] < b["ZONENAME"]
		end
	end
}

-------------------------------------------------------------------------------
-- Ace config table
-------------------------------------------------------------------------------
local options = {
	name = L["GGSocialState"],
	type = "group",
	args = {
		confdesc = {
			order = 1,
			type = "description",
			name = L["LDB plugin that shows friends and guild list."],
			cmdHidden = true
		},
		displayheader = {
			order = 2,
			type = "header",
			name = "Tooltip Options",
		},
		hide_guildname = {
			type = "toggle", width = "normal",
			name = L["Hide Guild name"],
			desc = L["Show or hide the guild name."],
			order = 3,
			get = function() return GGSocialStateDB.hide_guildname end,
			set = function(_, v) GGSocialStateDB.hide_guildname = v end,
		},
		hide_hintline = {
			type = "toggle", width = "normal",
			name = L["Hide the Hint line"],
			desc = L["Show or hide the hint line under tooltip."],
			order = 4,
			get = function() return GGSocialStateDB.hide_hintline end,
			set = function(_, v) GGSocialStateDB.hide_hintline = v end,
		},
		hide_motd = {
			type = "toggle", width = "normal",
			name = L["Hide the MotD"],
			desc = L["Hide the guild MotD under the tooltip."],
			order = 5,
			get = function() return GGSocialStateDB.hide_gmotd end,
			set = function(_, v) GGSocialStateDB.hide_gmotd = v end,
		},
		expand_realID = {
			order = 6,
			type = "toggle", width = "normal",
			name = L["RealID 2 lines"],
			desc = L["Expand RealID to 2 lines in the tooltip for extended info."],
			get = function() return GGSocialStateDB.expand_realID end,
			set = function(_, v) GGSocialStateDB.expand_realID = v end,
		},
		tooltip_autohide = {
			order = 7,
			type = "input", width = "half",
			name = L["Autohide Delay:"],
			desc = L["The tooltip will hide when not hovered over for this (default: 0.25)"],
			get = function() return GGSocialStateDB.tooltip_autohide end,
			set = function(_, v) GGSocialStateDB.tooltip_autohide = v end,
		},
		displayheader2 = {
			order = 8,
			type = "header",
			name = L["LDB Display Options"],
		},
		hide_ldb_labels = {
			order = 9,
			type = "toggle", width = "double",
			name = L["Hide Friends/Guild Labels"],
			desc = L["Hide the Friends and Guild labels from the LDB"],
			get = function() return GGSocialStateDB.hide_LDB_labels end,
			set = function(_, v) GGSocialStateDB.hide_LDB_labels = v update_Broker() end
		},
		hide_ldb_totals = {
			order = 10,
			type = "toggle", width = "normal",
			name = L["Hide Totals"],
			desc = L["Hide the Totals field from the LDB"],
			get = function() return GGSocialStateDB.hide_LDB_totals end,
			set = function(_, v) GGSocialStateDB.hide_LDB_totals = v update_Broker() end
		},
		split_ldb_friends = {
			order = 11,
			type = "toggle", width = "double",
			name = L["Split Real ID and Normal Friends"],
			desc = L["Split Real ID and Normal Friends on the LDB"],
			get = function() return GGSocialStateDB.split_LDB_friends end,
			set = function(_, v) GGSocialStateDB.split_LDB_friends = v update_Broker() end
		},
		hide_ldb_inapp = {
			order = 12,
			type = "toggle", width = "normal",
			name = L["Hide InApp Friends"],
			desc = L["Hide RealID friends that are \"In App\""],
			get = function () return GGSocialStateDB.hide_LDB_inapp end,
			set = function(_, v) GGSocialStateDB.hide_LDB_inapp = v update_Broker() end
		}
	}
}

LibStub("AceConfig-3.0"):RegisterOptionsTable("GGSocialState", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GGSocialState")

-- MoP Fix <3 Chinchilla
local MISTS_OF_PANDARIA = GetBuildInfo():match("5") and true or false
local GetNumPartyMembers = MISTS_OF_PANDARIA and GetNumSubgroupMembers or GetNumPartyMembers
local GetNumRaidMembers = MISTS_OF_PANDARIA and GetNumGroupMembers or GetNumRaidMembers

-------------------------------------------------------------------------------
-- Helper Routines
-------------------------------------------------------------------------------

--find alias in GuildGreet
local function GGSocialState_GetGGAlias(toonName)
	if GLDG_DataChar and GLDG_DataChar[toonName] ~= nil and GLDG_DataChar[toonName].alias ~= nil then
		return GLDG_DataChar[toonName].alias
	end

	return nil
end

--find main in Guildgreet
local function GGSocialState_GetGGMain(toonName)
	if GLDG_DataChar and GLDG_DataChar[toonName] ~= nil and GLDG_DataChar[toonName].alt ~= nil then
		return string.format("|cff%s%s", GGSocialState_CLASS_COLORS[GLDG_DataChar[GLDG_DataChar[toonName].alt].class] or "B8B8B8", Ambiguate(GLDG_DataChar[toonName].alt, "guild") .. "|r") --enClass
	end

	return nil
end

--display (main / alias) from GuildGreet
local function GGSocialState_GetMainAlt(toonName)
	if GGSocialState_GetGGMain(toonName)~=nil and GGSocialState_GetGGAlias(toonName)~=nil then
		return "("..GGSocialState_GetGGMain(toonName).." / |cffffa0a0"..GGSocialState_GetGGAlias(toonName).."|r)"
	elseif GGSocialState_GetGGMain(toonName)~=nil then
		return "("..GGSocialState_GetGGMain(toonName)..")"
	elseif GGSocialState_GetGGAlias(toonName)~=nil then
		return "(|cffffa0a0"..GGSocialState_GetGGAlias(toonName).."|r)"
	end
end

local function inGroup(name)
	if GetNumSubgroupMembers() > 0 and UnitInParty(name) then
		return true
	elseif GetNumGroupMembers() > 0 and UnitInRaid(name) then
		return true
	end

	return false
end

local function player_name_to_index(name)
	local lookupname

	for i = 1, C_FriendList.GetNumFriends() do
		local info = C_FriendList.GetFriendInfoByIndex(i)

		if info.name == name then
			return i
		end
	end
end

local function guild_name_to_index(name)
	local lookupname

	for i = 1, GetNumGuildMembers() do
		lookupname = GetGuildRosterInfo(i)

		if lookupname == name then
			return i
		end
	end
end

local function ColoredLevel(level)
	if type(level) ~= "number" then
		return level
	end
	local color = _G.GetRelativeDifficultyColor(_G.UnitLevel("player"), level)
	return ("|cff%02x%02x%02x%d|r"):format(color.r * 255, color.g * 255, color.b * 255, level)
end

GGSocialState_CLASS_COLORS, color = {}, {}
GGSocialState_classes_female, GGSocialState_classes_male = {}, {}

FillLocalizedClassList(GGSocialState_classes_female, true)
FillLocalizedClassList(GGSocialState_classes_male, false)

for token, localizedName in pairs(GGSocialState_classes_female) do
	color = RAID_CLASS_COLORS[token]
	GGSocialState_CLASS_COLORS[localizedName] = string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

for token, localizedName in pairs(GGSocialState_classes_male) do
	color = RAID_CLASS_COLORS[token]
	GGSocialState_CLASS_COLORS[localizedName] = string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

---------------------
--  Update button  --
---------------------

function update_Broker()
	--	ShowFriends()

	local displayline = ""

	local NumFriends, online = C_FriendList.GetNumFriends(), C_FriendList.GetNumOnlineFriends()
	local realidTotal, realidOnline = BNGetNumFriends()

	if not GGSocialStateDB.split_LDB_friends then

		displayline = online + realidOnline

		if not GGSocialStateDB.hide_LDB_totals then
			displayline = displayline .. "/" .. NumFriends + realidTotal
		end

		if not GGSocialStateDB.hide_LDB_labels then
			displayline = L["Friends"] .. " " .. displayline
		end

	else

		-- RealID First
		if not GGSocialStateDB.hide_LDB_labels then
			displayline = displayline .. L["RealID"] .. " "
		end

		displayline = displayline .. realidOnline

		if not GGSocialStateDB.hide_LDB_totals then
			displayline = displayline .. "/" .. realidTotal
		end

		-- Normal Friends Next
		displayline = displayline .. "|r : |cffffff00"

		if not GGSocialStateDB.hide_LDB_labels then
			displayline = displayline .. L["Friends"] .. " "
		end

		displayline = displayline ..online

		if not GGSocialStateDB.hide_LDB_totals then
			displayline = displayline .. "/" .. NumFriends
		end

	end

	if IsInGuild() then
		C_GuildInfo.GuildRoster()
		local guildTotal, online = GetNumGuildMembers()
		for i = 1, GetNumGuildMembers() do
			local _, _, _, _, _, _, _, _, connected, _, _, _, _, isMobile = GetGuildRosterInfo(i)
			if isMobile then
				online = online + 1
			end
		end

		displayline = displayline .. "|r : |cff00ff00"
		if not GGSocialStateDB.hide_LDB_labels then
			displayline = displayline .. L["Guild"] .. " "
		end

		displayline = displayline .. online

		if not GGSocialStateDB.hide_LDB_totals then
			displayline = displayline .. "/" .. guildTotal
		end
	end

	LDB.text = "|cff82c5ff" .. displayline .. "|r"
end



----------------------------
--  If names are clicked  --
----------------------------

local function Entry_OnMouseUp(frame, info, button)
	local i_type, toon_name, full_name, presence_id, client, realm_name = string.split(":", info)

	if button == "LeftButton" then
		-- Invite to group/raid
		if IsAltKeyDown() then
			if i_type == "realid" then
				if client == "WoW" then
					C_PartyInfo.InviteUnit(toon_name.."-"..realm_name)
					return
				else
					C_PartyInfo.InviteUnit(toon_name.."-"..realm_name)
					return
				end
			else
				C_PartyInfo.InviteUnit(toon_name)
				return
			end
		end

		-- Lookup player via /who
		if IsShiftKeyDown() then
			SetItemRef("player:"..toon_name, "|Hplayer:"..toon_name.."|h["..toon_name.."|h", "LeftButton")
			return
		end

		-- Edit Player Note
		if IsControlKeyDown() then
			if i_type == "guild" and CanEditPublicNote() then
				SetGuildRosterSelection(guild_name_to_index(toon_name))
				StaticPopup_Show("SET_GUILDPLAYERNOTE")
				return
			end

			if i_type == "friends" then
				local info = C_FriendList.GetFriendInfo(toon_name)
				StaticPopup_Show("SET_FRIENDNOTE", info.notes)
				return
			end

			if i_type == "realid" then
				FriendsFrame.NotesID = presence_id
				StaticPopup_Show("SET_BNFRIENDNOTE", full_name)
				return
			end
		end

		-- Send a tell to player
		if i_type == "realid" then
			local name = full_name..":"..presence_id
			SetItemRef( "BNplayer:"..name, ("|HBNplayer:%1$s|h[%1$s]|h"):format(name), "LeftButton" )
		else
			SetItemRef( "player:"..full_name, ("|Hplayer:%1$s|h[%1$s]|h"):format(full_name), "LeftButton" )
		end
	elseif button == "RightButton" then
		-- Edit Guild Officer Notes
		if IsControlKeyDown() then
			if i_type == "guild" and CanEditOfficerNote() then
				SetGuildRosterSelection(guild_name_to_index(toon_name))
				StaticPopup_Show("SET_GUILDOFFICERNOTE")
			end
		end
	elseif button == "MiddleButton" then
		-- Expand RealID Broadcast
		GGSocialStateDB.expand_realID = not GGSocialStateDB.expand_realID
		LDB.OnEnter(LDB_ANCHOR)
	end
end

local function HideOnMouseUp(cell, section)
	GGSocialStateDB[section] = not GGSocialStateDB[section]
	LDB.OnEnter(LDB_ANCHOR)
end

local function SetGuildSort(cell, sortsection)
	if GGSocialStateDB["GuildSort"] == sortsection then
		GGSocialStateDB["GuildSort"] = "rev" .. sortsection
	else
		GGSocialStateDB["GuildSort"] = sortsection
	end
	LDB.OnEnter(LDB_ANCHOR)
end

local function SetRealIDSort(cell, sortsection)
	if GGSocialStateDB["RealIDSort"] == sortsection then
		GGSocialStateDB["RealIDSort"] = "rev" .. sortsection
	else
		GGSocialStateDB["RealIDSort"] = sortsection
	end
	LDB.OnEnter(LDB_ANCHOR)
end

------------------------------------------
--  Click to open friend / guild panel  --
------------------------------------------

function LDB:OnClick(button)
	if button == "LeftButton" then
		if IsAltKeyDown() then
			ToggleGuildFrame(1) -- guild toggle
		else
			ToggleFriendsFrame(1) -- friends toggle
		end
	end

	if button == "RightButton" then
		LibStub("AceConfigDialog-3.0"):Open("GGSocialState")
	end
end

function dump(o)
	if type(o) == 'table' then
		local s = "{\n"
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ",\n"
		end
		return s .. "}\n"
	else
		return tostring(o)
	end
end

---------------------
--  Event Section  --
---------------------

function LDB.OnLeave() end


---------------------
--  Get BNet List  --
---------------------

function GetBNetFriends()
	local friends = {}
	local _, numBNOnline = BNGetNumFriends()

	if (numBNOnline > 0) then
		for i = 1, numBNOnline do
			local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
			local primary, secondary = {}, {}
			local status = ONLINE_ICON
			local inApp, inBSAp
			local appBusy, appAFK, BSApBusy, BSApAFK
			local broadcastFlag = ""
			local note = accountInfo.note
			local accountName = accountInfo.accountName

			if accountInfo.customMessage ~= "" then
				-- Set broadcastFlag to a chat bubble icon if broadcast message is not being expanded
				if not GGSocialStateDB.expand_realID then
					broadcastFlag = " " .. BROADCAST_ICON
				end
				accountInfo.customMessage = "|cff7b8489" .. accountInfo.customMessage .. " (" ..
						_G.SecondsToTime(time() - accountInfo.customMessageTime, false, true, 1) .. " Ago)|r"
			end

			-- Set initial BNET account status
			if accountInfo.isDND then status = BUSY_ICON end
			if accountInfo.isAFK then status = AWAY_ICON end
			if accountInfo.isBusy then status = BUSY_ICON end

			-- Set note color
			if note and note ~= "" then note = "|cffff8800" .. note .. "|r" end

			accountInfo.accountName = "|cff82c5ff" .. accountName .."|r" .. broadcastFlag

			for gameAccountIndex = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
				local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(i, gameAccountIndex)
				local client = gameAccountInfo.clientProgram
				local projectID = gameAccountInfo.wowProjectID
				local zoneName = gameAccountInfo.areaName
				local temp = {}

				-- Set the name of the client program from BNET_CLIENT and change its color
				if (BNET_CLIENT[client]) then
					gameAccountInfo.clientProgram = BNET_CLIENT[client]
				end
				
				-- If WoW, update some variable formatting
				if (client == "WoW") then
					local name = gameAccountInfo.characterName
					local realmName = gameAccountInfo.realmName

					if (projectID == WOW_PROJECT_CLASSIC or projectID == 5) then
						realmName = gameAccountInfo.richPresence
					end

					-- Make the color of characterName be the class color
					local name = string.format("|cff%s%s",GGSocialState_CLASS_COLORS[gameAccountInfo.className] or "B8B8B8",
						name .. "|r") .. (inGroup(name) and GROUP_CHECKMARK or "")

					if gameAccountInfo.areaName and realmName then
						-- Make the color of realmName be the faction color
						if gameAccountInfo.factionName == "Horde" then
							realmName = FACTION_COLOR_HORDE .. realmName .. "|r"
						else
							realmName = FACTION_COLOR_ALLIANCE .. realmName .. "|r"
						end
					end

					rawName = gameAccountInfo.characterName
					gameAccountInfo.characterName = name
					gameAccountInfo.characterLevel = ColoredLevel(gameAccountInfo.characterLevel)
					rawRealmName = gameAccountInfo.realmName
					gameAccountInfo.realmName = realmName
				end

				if not zoneName or zoneName == "" then
					if not gameAccountInfo.richPresence or gameAccountInfo.richPresence == "" then
						if client == "App" then
							zoneName = "In App"
						elseif client == "BSAp" then
							zoneName = "Mobile"
						end
					end
				end

				temp = {
					GIVENNAME = accountInfo.accountName,
					ACCTNAME = accountName,
					BROADCAST_TEXT = accountInfo.customMessage,
					SURNAME = accountInfo.battleTag,
					PRESENCEID = accountInfo.bnetAccountID,
					TOONNAME = gameAccountInfo.characterName or "",
					TOONNAMERAW = rawName or "",
					LEVEL = gameAccountInfo.characterLevel or "",
					CLASS = gameAccountInfo.className or "",
					ZONENAME = zoneName or gameAccountInfo.richPresence or "",
					REALMNAME = gameAccountInfo.realmName or "",
					REALMNAMERAW = rawRealmName or "",
					STATUS = "",
					CLIENTICON = _G.BNet_GetClientEmbeddedTexture(client, CLIENT_ICON_SIZE, CLIENT_ICON_SIZE),
					CLIENT = gameAccountInfo.clientProgram,
					CLIENTRAW = client,
					GAMETEXT = gameAccountInfo.richPresence,
					NOTE = note,
				}

				if (client == "App" or client == "BSAp") then
					if (client == "App") then
						inApp = true
						appAFK = gameAccountInfo.isGameAFK
						appBusy = gameAccountInfo.isGameBusy
					end

					if (client == "BSAp") then
						inBSAp = true
						BSApAFK = gameAccountInfo.isGameAFK
						BSApBusy = gameAccountInfo.isGameBusy
					end

					if not GGSocialStateDB.hide_LDB_inapp then
						table.insert(secondary, temp)
					end
				else
					table.insert(primary, temp)
				end
			end

			-- Apply appropriate status if away in App or BSAp
			if (not inApp or appAFK) and (not inBSAp or BSApAFK) then
				status = AWAY_ICON
			end
			if (not inApp or appBusy) and (not inBSAp or BSApBusy) then
				status = BUSY_ICON
			end

			local skipSecondary = false
			for _, account in pairs(primary) do
				skipSecondary = true
				account["STATUS"] = status
				table.insert(friends, account)
			end

			if not skipSecondary then
				for _, account in pairs(secondary) do
					if (account["CLIENTRAW"] == "BSAp" and not inApp) or (account["CLIENTRAW"] == "App") then
						account["STATUS"] = status
						table.insert(friends, account)
					end
				end
			end
		end
	end

	return friends
end

------------------------
--      Tooltip!      --
------------------------

function LDB.OnEnter(self)
	LDB_ANCHOR = self

	if LibQTip:IsAcquired("GGSocialState") then
		tooltip:Clear()
	else
		tooltip = LibQTip:Acquire("GGSocialState", 9, "CENTER", "LEFT", "RIGHT", "LEFT", "LEFT", "CENTER", "CENTER", "RIGHT")

		tooltip:SetBackdropColor(0,0,0,1)

		tooltip:SetHeaderFont(ssHeaderFont)
		tooltip:SetFont(ssRegFont)

		tooltip:SmartAnchorTo(self)
		tooltip:SetAutoHideDelay(GGSocialStateDB.tooltip_autohide, self)
	end

	local line = tooltip:AddLine()
	tooltip:SetCell(line, 1, "GGSocialState2", ssTitleFont, "CENTER", 0)
	tooltip:AddLine(" ")

	-------------------------
	--  Begin RealID list  --
	-------------------------
	local _, numBNOnline = BNGetNumFriends()
	local numFriendsOnline = C_FriendList.GetNumOnlineFriends()

	if (numBNOnline > 0) or (numFriendsOnline > 0) then
		-- Header for Friends
		line = tooltip:AddLine()
		if not GGSocialStateDB.hide_friendsection then
			tooltip:SetCell(line, 1, "|cffffffff" .. _G.FRIENDS .. "|r", "LEFT", 3)
		else
			tooltip:SetCell(line, 1, "|cffffffff" .. MINIMIZE .. _G.FRIENDS .. "|r", "LEFT", 3)
		end
		tooltip:SetCellScript(line, 1, "OnMouseUp", HideOnMouseUp, "hide_friendsection")

		if not GGSocialStateDB.hide_friendsection then
			line = tooltip:AddHeader()
			line = tooltip:SetCell(line, 1, "  ")
			tooltip:SetCellScript(line, 1, "OnMouseUp", SetRealIDSort, "CLIENTICON")
			line = tooltip:SetCell(line, 2, _G.BATTLENET_FRIEND)
			tooltip:SetCellScript(line, 2, "OnMouseUp", SetRealIDSort, "REALID")
			line = tooltip:SetCell(line, 3, "  ")
			tooltip:SetCellScript(line, 3, "OnMouseUp", SetRealIDSort, "STATUS")
			line = tooltip:SetCell(line, 4, _G.NAME)
			tooltip:SetCellScript(line, 4, "OnMouseUp", SetRealIDSort, "TOONNAME")
			line = tooltip:SetCell(line, 5, "  ")
			tooltip:SetCellScript(line, 5, "OnMouseUp", SetRealIDSort, "LEVEL")
			line = tooltip:SetCell(line, 6, _G.LOCATION_COLON)
			tooltip:SetCellScript(line, 6, "OnMouseUp", SetRealIDSort, "ZONENAME")
			line = tooltip:SetCell(line, 7, _G.FRIENDS_LIST_REALM)
			tooltip:SetCellScript(line, 7, "OnMouseUp", SetRealIDSort, "REALMNAME")
			if not GGSocialStateDB.hide_friend_notes then
				line = tooltip:SetCell(line, 8, _G.NOTE_COLON)
			else
				line = tooltip:SetCell(line, 8, MINIMIZE .. _G.NOTE_COLON)
			end
			tooltip:SetCellScript(line, 8, "OnMouseUp", HideOnMouseUp, "hide_friend_notes")

			tooltip:AddSeparator()

			if numBNOnline > 0 then
				local realid_table = GetBNetFriends()

				if (GGSocialStateDB["RealIDSort"] ~= "REALID") and (GGSocialStateDB["RealIDSort"] ~= "revREALID") then
					table.sort(realid_table, list_sort[GGSocialStateDB["RealIDSort"]])
				end

				for _, player in pairs(realid_table) do
					line = tooltip:AddLine()
					line = tooltip:SetCell(line, 1, player["CLIENTICON"])
					line = tooltip:SetCell(line, 2, player["GIVENNAME"])
					line = tooltip:SetCell(line, 3, player["STATUS"])
					line = tooltip:SetCell(line, 4, player["TOONNAME"])
					line = tooltip:SetCell(line, 5, player["LEVEL"])
					line = tooltip:SetCell(line, 6, player["ZONENAME"])
					line = tooltip:SetCell(line, 7, player["REALMNAME"])

					if not GGSocialStateDB.hide_friend_notes then
						line = tooltip:SetCell(line, 8, player["NOTE"])
					end

					tooltip:SetLineScript(line, "OnMouseUp", Entry_OnMouseUp, string.format("realid:%s:%s:%d:%s:%s",
						player["TOONNAMERAW"], player["ACCTNAME"], player["PRESENCEID"], player["CLIENTRAW"], player["REALMNAMERAW"]))

					if GGSocialStateDB.expand_realID and player["BROADCAST_TEXT"] ~= "" then
						line = tooltip:AddLine()
						line = tooltip:SetCell(line, 1, BROADCAST_ICON .. " " .. player["BROADCAST_TEXT"], "LEFT", 0)
						tooltip:SetLineScript(line, "OnMouseUp", Entry_OnMouseUp,
							string.format("realid:%s:%s:%d:%s:%s",
								player["TOONNAMERAW"], player["ACCTNAME"], player["PRESENCEID"], player["CLIENTRAW"], player["REALMNAMERAW"]))
					end
				end
				tooltip:AddLine(" ")
			end

			if numFriendsOnline > 0 then
				local friend_table = {}
				for i = 1,numFriendsOnline do
					local note
					local status = ONLINE_ICON
					local info = C_FriendList.GetFriendInfoByIndex(i)

					note = info.notes
					note = note and "|cffff8800"..note.."|r" or ""

					if info.afk == CHAT_FLAG_AFK then
						status = AWAY_ICON
					elseif info.dnd == CHAT_FLAG_DND then
						status = BUSY_ICON
					end

					table.insert(friend_table, {
						TOONNAME = info.name,
						LEVEL = info.level,
						CLASS = info.className,
						ZONENAME = info.area,
						REALMNAME = "",
						STATUS = status,
						NOTE = note
					})
				end

				if (GGSocialStateDB["RealIDSort"] ~= "REALID") and (GGSocialStateDB["RealIDSort"] ~= "revREALID") then
					table.sort(friend_table, list_sort[GGSocialStateDB["RealIDSort"]])
				else
					table.sort(friend_table, list_sort["TOONNAME"])
				end

				for _, player in ipairs(friend_table) do
					line = tooltip:AddLine()
					line = tooltip:SetCell(line, 3, player["STATUS"])
					line = tooltip:SetCell(line, 4,
						string.format("|cff%s%s", GGSocialState_CLASS_COLORS[player["CLASS"]] or "ffffff", player["TOONNAME"] .. "|r") .. (inGroup(player["TOONNAME"]) and GROUP_CHECKMARK or ""));
					line = tooltip:SetCell(line, 5, ColoredLevel(player["LEVEL"]))
					line = tooltip:SetCell(line, 6, player["ZONENAME"])
					if not GGSocialStateDB.hide_friend_notes then
						line = tooltip:SetCell(line, 8, player["NOTE"])
					end

					tooltip:SetLineScript(line, "OnMouseUp", Entry_OnMouseUp, string.format("friends:%s:%s", player["TOONNAME"], player["TOONNAME"]))
				end
			end
		end
		tooltip:AddLine(" ")
	end

	------------------------
	--  Begin guild list  --
	------------------------

	if IsInGuild() then
		local guild_table = {}
		if not GGSocialStateDB.hide_gmotd then
			line = tooltip:AddLine()
			if not GGSocialStateDB.minimize_gmotd then
				tooltip:SetCell(line, 1, "|cffffffff" .. _G.CHAT_GUILD_MOTD_SEND .. "|r", "LEFT", 3)
			else
				tooltip:SetCell(line, 1, "|cffffffff".. MINIMIZE .. _G.CHAT_GUILD_MOTD_SEND .. "|r", "LEFT", 3)
			end
			tooltip:SetCellScript(line, 1, "OnMouseUp", HideOnMouseUp, "minimize_gmotd")

			if not GGSocialStateDB.minimize_gmotd then
				line = tooltip:AddLine()
				tooltip:SetCell(line, 1, "|cff00ff00"..GetGuildRosterMOTD().."|r", "LEFT", 0, nil, nil, nil)
			end

			tooltip:AddLine(" ")
		end

		local ssGuildName
		if not GGSocialStateDB.hide_guildname then
			ssGuildName = GetGuildInfo("player")
		else
			ssGuildName = _G.GUILD
		end

		-- Header for Guild
		line = tooltip:AddLine()
		if not GGSocialStateDB.hide_guildsection then
			tooltip:SetCell(line, 1, "|cffffffff" .. ssGuildName .."|r", "LEFT", 3)
		else
			line = tooltip:SetCell(line, 1, MINIMIZE .. "|cffffffff" .. ssGuildName .. "|r", "LEFT", 3)
		end
		tooltip:SetCellScript(line, 1, "OnMouseUp", HideOnMouseUp, "hide_guildsection")

		if not GGSocialStateDB.hide_guildsection then
			line = tooltip:AddHeader()
			line = tooltip:SetCell(line, 1, "  ")
			tooltip:SetCellScript(line, 1, "OnMouseUp", SetGuildSort, "LEVEL")
			line = tooltip:SetCell(line, 2, _G.NAME)
			tooltip:SetCellScript(line, 2, "OnMouseUp", SetGuildSort, "TOONNAME")
			line = tooltip:SetCell(line, 5, _G.ZONE)
			tooltip:SetCellScript(line, 5, "OnMouseUp", SetGuildSort, "ZONENAME")
			line = tooltip:SetCell(line, 6, _G.RANK)
			tooltip:SetCellScript(line, 6, "OnMouseUp", SetGuildSort, "RANKINDEX")

			if not GGSocialStateDB.hide_guild_onotes then
				line = tooltip:SetCell(line, 8, _G.NOTE_COLON)
			else
				line = tooltip:SetCell(line, 8, MINIMIZE .. _G.NOTE_COLON)
			end
			tooltip:SetCellScript(line, 8, "OnMouseUp", HideOnMouseUp, "hide_guild_onotes")

			tooltip:AddSeparator()

			for i = 1, GetNumGuildMembers() do
				local toonName, rank, rankindex, level, class, zoneName, note, onote, connected, status, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(i)
				if connected or isMobile then
					if note and note ~= '' then note="|cff00ff00["..note.."]|r" end
					if onote and onote ~= '' then onote = "|cff00ffff["..onote.."]|r" end

					if status == 1 then
						status = AWAY_ICON
					elseif status == 2 then
						status = BUSY_ICON
					elseif status == 0 then
						status = ''
					end

					if isMobile then
						status = MOBILE_ICON
						zoneName = "Remote Chat"
					end

					table.insert(guild_table, {
						TOONNAME = toonName, -- toonName
						TOONALIAS = GGSocialState_GetMainAlt(toonName),
						RANK = rank,
						RANKINDEX = rankindex,
						LEVEL = level or "",
						CLASS = class or "",
						ZONENAME = zoneName or "",
						NOTE = note,
						ONOTE = onote,
						STATUS = status
					})
				end
			end

			table.sort(guild_table, list_sort[GGSocialStateDB["GuildSort"]])

			for _, player in ipairs(guild_table) do
				line = tooltip:AddLine()
				line = tooltip:SetCell(line, 1, ColoredLevel(player["LEVEL"]))
				line = tooltip:SetCell(line, 2,
					string.format("|cff%s%s", GGSocialState_CLASS_COLORS[player["CLASS"]] or "ffffff", Ambiguate(player["TOONNAME"], "guild") .. "|r")
							.. (inGroup(Ambiguate(player["TOONNAME"], "guild")) and GROUP_CHECKMARK or ""))
				line = tooltip:SetCell(line, 3, player["STATUS"])
				line = tooltip:SetCell(line, 4, player["TOONALIAS"])
				line = tooltip:SetCell(line, 5, player["ZONENAME"] or "???")
				line = tooltip:SetCell(line, 6, player["RANK"])
				if not GGSocialStateDB.hide_guild_onotes then
					line = tooltip:SetCell(line, 7, player["NOTE"] .. player["ONOTE"])
				end

				tooltip:SetLineScript(line, "OnMouseUp", Entry_OnMouseUp, string.format("guild:%s:%s", player["TOONNAME"], player["TOONNAME"]))
			end
		end
		tooltip:AddLine(" ")
	end

	if not GGSocialStateDB.hide_hintline then
		line = tooltip:AddLine()
		if not GGSocialStateDB.minimize_hintline then
			tooltip:SetCell(line, 1, L["Hint:"], "LEFT", 6)
		else
			tooltip:SetCell(line, 1, MINIMIZE .. L["Hint:"], "LEFT", 6)
		end
		tooltip:SetCellScript(line, 1, "OnMouseUp", HideOnMouseUp, "minimize_hintline")

		if not GGSocialStateDB.minimize_hintline then
			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, "|cffeda55f"..L["Click"].."|r "..L["to open the friends panel."], "LEFT", 5)
			tooltip:SetCell(line, 6, "|cffeda55f"..L["Alt-Click"].."|r "..L["to open the guild panel."], "LEFT", 0)

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, "|cffeda55f"..L["Click"].."|r "..L["a line to whisper a player."], "LEFT", 5)
			tooltip:SetCell(line, 6, "|cffeda55f"..L["Shift-Click"].."|r "..L["a line to lookup a player."], "LEFT", 0)

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, "|cffeda55f"..L["Ctrl-Click"].."|r "..L["a line to edit a note."], "LEFT", 5)
			tooltip:SetCell(line, 6, "|cffeda55f"..L["Ctrl-RightClick"].."|r "..L["a line to edit an officer note."], "LEFT", 0)

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, "|cffeda55f"..L["Alt-Click"].."|r "..L["a line to invite."], "LEFT", 5)
			tooltip:SetCell(line, 6, "|cffeda55f"..L["MiddleClick"].."|r "..L["a line to expand RealID."], "LEFT", 0)

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, "|cffeda55f"..L["Click"].."|r "..L["a Header to hide it or sort it."], "LEFT", 5)
		end
	end

	tooltip:UpdateScrolling()
	tooltip:Show()
end

frame:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local DELAY = 15  --  Update every 15 seconds
local elapsed = DELAY - 5

frame:SetScript("OnUpdate",
	function (self, el)
		elapsed = elapsed + el

		if elapsed >= DELAY then
			elapsed = 0
			update_Broker()
		end
	end
)

function frame:PLAYER_LOGIN()
	if not GGSocialStateDB then
		-- Initialize default configuration
		GGSocialStateDB = {}
	end

	if not GGSocialStateDB.tooltip_autohide then
		GGSocialStateDB.tooltip_autohide = "0.25"
	end

	if not GGSocialStateDB["RealIDSort"] then
		GGSocialStateDB["RealIDSort"] = "REALID"
	end

	if not GGSocialStateDB["GuildSort"] then
		GGSocialStateDB["GuildSort"] = "RANKINDEX"
	end
end

frame:RegisterEvent("PLAYER_LOGIN")
