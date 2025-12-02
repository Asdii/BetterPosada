local REPORT_CHANNEL = "BETTERPOSADA_REP"
BetterPosada_ChannelID = chan

if not BetterPosadaDB then BetterPosadaDB = {} end
if not BetterPosadaDB.reports then BetterPosadaDB.reports = {} end

BetterPosada_ExternalReports = {}

function BetterPosada_RegisterPrefixes()
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix("BP_ASK")
        RegisterAddonMessagePrefix("BP_ANSWER")
    end
end

function BetterPosada_SaveReport(target, text)
    target = BetterPosada_NormalizeName(target)

    if not BetterPosadaDB.reports[target] then
        BetterPosadaDB.reports[target] = {}
    end

    table.insert(BetterPosadaDB.reports[target], {
        author = UnitName("player"),
        text = text,
        time = time(),
    })
end

-------------------------------------------------------------
-- Handle para recibir reportes
-------------------------------------------------------------
function BetterPosada_ReceiveReport(player, text, time, sender)
    BetterPosada_ExternalReports = BetterPosada_ExternalReports or {}
    BetterPosada_ExternalReports[player] = BetterPosada_ExternalReports[player] or {}

    local t = BetterPosada_ExternalReports[player]
    table.insert(t, 1, {text=text, time=time, sender=sender})
end

function BetterPosada_GetLastReport(target)
    local list = BetterPosadaDB.reports[target]
    if not list or #list == 0 then return nil end
    return list[#list].text
end

function BetterPosada_HandleAsk(target, sender)
    local list = BetterPosadaDB.reports[target]
    if not list or #list == 0 then
        return
    end

    local count = #list
    local start = math.max(1, count - 1)

    for i = start, count do
        local r = list[i]
        local t = r.time or time()
        local txt = r.text or ""
        local payload = target .. "$" .. txt .. "$" .. t

        SendAddonMessage("BP_ANSWER", payload, "WHISPER", sender)
    end
end

function BetterPosada_HandleAnswer(payload, sender)
    local player, text, timeStr = strsplit("$", payload)

    local t = tonumber(timeStr) or time()
    BetterPosada_ReceiveReport(player, text, t, sender)
end
