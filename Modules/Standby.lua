local _, core = ...;
local _G = _G;
local CommDKP = core.CommDKP;
local L = core.L;

local function CMD_Handler(...)
    local _, cmd = string.split(" ", ..., 2)

    if tonumber(cmd) then
        cmd = tonumber(cmd) -- converts it to a number if it's a valid numeric string
    end

    return cmd;
end

local function ActionHandler(...)
    local _, _, cmd = string.split(" ", ..., 3)
    return cmd;
end

function CommDKP_Standby_Announce(bossName)
    core.StandbyActive = true; -- activates opt in
    table.wipe(CommDKP:GetTable(CommDKP_Standby, true));
    if CommDKP:CheckRaidLeader() then
        SendChatMessage(bossName..L["STANDBYOPTINBEGIN"], "GUILD") -- only raid leader announces
    end
    C_Timer.After(120, function ()
        core.StandbyActive = false;  -- deactivates opt in
        if CommDKP:CheckRaidLeader() then
            SendChatMessage(L["STANDBYOPTINEND"]..bossName, "GUILD") -- only raid leader announces
            if core.DB.DKPBonus.AutoIncStandby then
                CommDKP:AutoAward(2, core.DB.DKPBonus.BossKillBonus, core.DB.bossargs.CurrentRaidZone..": "..core.DB.bossargs.LastKilledBoss)
            end
        end
    end)
end

local function AddToStandbyList(name, respondTo)
    local response
    local search = CommDKP:Table_Search(CommDKP:GetTable(CommDKP_DKPTable, true), name)
    local verify = CommDKP:Table_Search(CommDKP:GetTable(CommDKP_Standby, true), name)
    if search and not verify then
        table.insert(CommDKP:GetTable(CommDKP_Standby, true), CommDKP:GetTable(CommDKP_DKPTable, true)[search[1][1]])
        CommDKP.Sync:SendData("CommDKPStand", CommDKP:GetTable(CommDKP_Standby, true))
    end

    if name ~= respondTo then
        -- if it's !standby *name*
        name = name:gsub("%s+", "") -- removes unintended spaces from string
        if search and not verify then
            response = "CommunityDKP: "..name.." "..L["STANDBYWHISPERRESP1"]
        elseif search and verify then
            response = "CommunityDKP: "..name.." "..L["STANDBYWHISPERRESP2"]
        else
            response = "CommunityDKP: "..name.." "..L["STANDBYWHISPERRESP3"];
        end
    else
        -- if it's just !standby
        if search and not verify then
            response = "CommunityDKP: "..L["STANDBYWHISPERRESP4"]
        elseif search and verify then
            response = "CommunityDKP: "..L["STANDBYWHISPERRESP5"]
        else
            response = "CommunityDKP: "..L["STANDBYWHISPERRESP6"];
        end
    end
    if CommDKP:CheckRaidLeader() then 						 -- only raid leader responds to add.
        SendChatMessage(response, "WHISPER", nil, respondTo)
    end
end

local function RemoveFromStandbyList(name, respondTo)
    local response
    local waitlist = CommDKP:GetTable(CommDKP_Standby, true);
    local verify = CommDKP:Table_Search(waitlist, name)
    if verify then
        table.remove(waitlist, verify)
        CommDKP.Sync:SendData("CommDKPStand", CommDKP:GetTable(CommDKP_Standby, true))
    end

    if name ~= respondTo then
        -- if it's !standby *name*
        name = name:gsub("%s+", "") -- removes unintended spaces from string
        if verify then
            response = "CommunityDKP: "..name.." "..L["STANDBYWHISPERRESP1"]
        else
            response = "CommunityDKP: "..name.." "..L["STANDBYWHISPERRESP3"];
        end
    else
        -- if it's just !standby
        if verify then
            response = "CommunityDKP: "..L["STANDBYWHISPERRESP4"]
        else
            response = "CommunityDKP: "..L["STANDBYWHISPERRESP6"];
        end
    end

    if CommDKP:CheckRaidLeader() then 						 -- only raid leader responds to add.
        SendChatMessage(response, "WHISPER", nil, respondTo)
    end
end

local function ShowWaitlist(channel, to)
    local waitlist = CommDKP:GetTable(CommDKP_Standby, true);
	-- Build our message string
	local msg = "CommunityDKP: Currently on the waitlist: "
	for i=1,(#(waitlist)) do
		-- Some better logic to handle comma's could be helpful I guess
		msg = msg .. waitlist[i].player .. ", "
	end
	msg:sub(-1)
    if channel then
        SendChatMessage(msg, channel)
    else
        SendChatMessage(msg, "WHISPER", nil, to)
    end
end

function CommDKP_Standby_Handler(text, ...)
    local name = ...;
    local cmd;
    local response = L["ERRORPROCESSING"];

    if string.find(name, "-") then					-- finds and removes server name from name if exists
        local dashPos = string.find(name, "-")
        name = strsub(name, 1, dashPos-1)
    end

    if (string.find(text, "!standby") == 1 or string.find(text, "!wl") == 1) and core.IsOfficer then
        cmd = tostring(CMD_Handler(text))

        if (cmd == "add") then
            local n = ActionHandler(text)
            if n and n:gsub("%s+", "") ~= "nil" and n:gsub("%s+", "") ~= "" then
                AddToStandbyList(n, name)
            else
                AddToStandbyList(name, name)
            end
        elseif cmd == "remove" then
            -- for now don't allow others to remove from the waitlist
            RemoveFromStandbyList(name, name)
        elseif cmd == "show" then
            local n = ActionHandler(text)
            ShowWaitlist(n, name);
        end

    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(self, event, msg, ...)		-- suppresses outgoing whisper responses to limit spam
        if core.DB.defaults.SuppressTells then
            if strfind(msg, "CommunityDKP: ") then
                return true
            end
        end
    end)
end
