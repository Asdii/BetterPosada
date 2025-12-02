BetterPosada_FullReportFrame = nil
local loadingTicker = nil
local desiredWidth = 0

-------------------------------------------------------------
-- Cerrar ventana
-------------------------------------------------------------
local function CloseFullReportWindow()
    if BetterPosada_FullReportFrame then
        BetterPosada_FullReportFrame:Hide()
    end
end

local function BP_Wait(seconds, callback)
    local f = CreateFrame("Frame", nil, UIParent)
    local elapsed = 0
    f:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed >= seconds then
            self:SetScript("OnUpdate", nil)
            callback()
        end
    end)
end

-------------------------------------------------------------
-- Construir la ventana
-------------------------------------------------------------
local function CreateFullReportWindow()
    if BetterPosada_FullReportFrame then return end

    local f = CreateFrame("Frame", "BetterPosada_FullReportFrame", UIParent)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(200)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 }
    })

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", 0, -12)
    f.title:SetText("|cffFFD700Reportes|r")

    if not f.headerLine then
        local line = f:CreateTexture(nil, "ARTWORK")
        f.headerLine = line
        line:SetTexture(1, 0.82, 0, 0.35)
        line:SetHeight(2)
        line:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -38)
        line:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -38)
    end

    ---------------------------------------------------------
    -- SCROLLFRAME
    ---------------------------------------------------------
    local scroll = CreateFrame("ScrollFrame", "BetterPosadaFullReportScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 15, -50)
    scroll:SetPoint("BOTTOMRIGHT", -35, 20)
    scroll:SetFrameLevel(f:GetFrameLevel() + 1)

    scroll:SetWidth(desiredWidth - 20)
    scroll:SetHeight(300)

    local content = CreateFrame("Frame", "BetterPosadaFullReportContent", scroll)
    content:SetPoint("TOPLEFT")
    content:SetWidth(desiredWidth - 20)
    content:SetHeight(1)

    scroll:SetFrameStrata("DIALOG")
    content:SetFrameStrata("DIALOG")
    content:SetFrameLevel(f:GetFrameLevel() + 10)
    for _, line in ipairs(content.lines or {}) do
        line:SetDrawLayer("OVERLAY")
        line:SetFontObject(GameFontHighlight)
    end

    scroll:SetScrollChild(content)

    f.content = content
    f.scroll = scroll

    scroll:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
        local sb = _G[self:GetName() .. "ScrollBar"]
        if sb then sb:Show() end
    end)

    ---------------------------------------------------------
    -- Botón cerrar
    ---------------------------------------------------------
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 24)
    closeBtn:SetPoint("TOPRIGHT", -15, -12)
    closeBtn:SetText("Cerrar")
    closeBtn:SetScript("OnClick", CloseFullReportWindow)
    closeBtn:SetFrameLevel(f:GetFrameLevel() + 3)
    closeBtn:SetFrameStrata("DIALOG")

    f:Hide()
end

local function FormatAgo(timestamp)
    local diff = time() - timestamp

    if diff < 60 then
        return string.format("hace %d segundos", diff)
    elseif diff < 3600 then
        return string.format("hace %d minutos", math.floor(diff/60))
    elseif diff < 86400 then
        return string.format("hace %d horas", math.floor(diff/3600))
    else
        return string.format("hace %d días", math.floor(diff/86400))
    end
end

local function PopulateFullReportWindow(target)
    if not BetterPosada_ExternalReports or not BetterPosada_ExternalReports[target] then
        return
    end
    
    CreateFullReportWindow()
    local f = BetterPosada_FullReportFrame
    local list = BetterPosada_ExternalReports[target]

    local content = f.content

    if not content.lines then
        content.lines = {}
    else
        for _, line in ipairs(content.lines) do
            if line and line.Hide then
                line:Hide()
            end
        end
        wipe(content.lines)
    end

    local y = -10
    local spacing = 20
    local totalHeight = 20

    for i, r in ipairs(list) do
        local line = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        line:SetPoint("TOPLEFT", 10, y)
        line:SetWidth(260)
        line:SetNonSpaceWrap(true)
        line:SetWordWrap(true)
        line:SetJustifyH("LEFT")
        line:SetJustifyV("TOP")
        line:SetDrawLayer("OVERLAY")
        local fulltext = string.format("|cffFFD700%s|r: %s\n|cFFAAAAAA(%s)|r",
            r.sender or "??",
            r.text or "",
            FormatAgo(r.time or time())
        )

        line:SetWidth(300)
        line:SetText(fulltext)

        table.insert(content.lines, line)

        local lineHeight = line:GetStringHeight()
        y = y - lineHeight - 8
        totalHeight = totalHeight + lineHeight + 8
    end

    content:SetHeight(math.max(totalHeight, 1))
    f:SetSize(350, math.min(400, totalHeight + 80))

    for _, line in ipairs(content.lines) do
        desiredWidth = math.max(desiredWidth, line:GetStringWidth())
    end

    desiredWidth = math.min(desiredWidth + 40, 600)

    for _, line in ipairs(content.lines) do
        local fulltext = line:GetText()

        line:SetText("")
        line:SetWidth(desiredWidth - 40)
        line:SetText(fulltext)
    end

    local MIN_WIDTH = 380

    desiredWidth = math.max(desiredWidth, MIN_WIDTH)

    for _, line in ipairs(content.lines) do
        local fulltext = line:GetText()

        line:SetText("")                  
        line:SetWidth(desiredWidth - 40)  
        line:SetText(fulltext)
    end

    f:SetWidth(desiredWidth)

    f.scroll:SetWidth(desiredWidth - 50)
    f.content:SetWidth(desiredWidth - 30)

    f.title:ClearAllPoints()
    f.title:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -15)
    f.title:SetPoint("RIGHT", f, -120, 0)

    f.title:SetText("|cffFFD700Reportes de:|r " .. target)

    f:Show()
end

-------------------------------------------------------------
-- CONSULTAR REPORTES
-------------------------------------------------------------
function BetterPosada_OpenFullReportFor(target)
    if not target then return end
    BetterPosada_ExternalReports = {}
    BetterPosada_ExternalReports[target] = {}

    if BetterPosadaReportLoadingBtn then
        BetterPosadaReportLoadingBtn:SetText("|cFFFFEE00Cargando...|r")
        BetterPosadaReportLoadingBtn:Disable()
    end

    ------------------------------------------
    -- ASK
    ------------------------------------------
    local chan = BetterPosada_ChannelID
    if chan then
        SendChatMessage("BP_ASK:" .. target, "CHANNEL", nil, chan)
    end
    BP_Wait(3, function()
        if BetterPosadaReportLoadingBtn then
            BetterPosadaReportLoadingBtn:SetText("|cFFFFEE00Consultar reportes|r")
            BetterPosadaReportLoadingBtn:Enable()
        end
        local list = BetterPosada_ExternalReports[target]

        if not list or #list == 0 then
            print("|cffffd700BetterPosada:|r No se encontraron reportes para " .. target .. ".")
            return
        end
        PopulateFullReportWindow(target)
    end)
end
