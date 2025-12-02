------------------------------------------------------------
-- Ventana de Ayuda
------------------------------------------------------------

function BetterPosada_OpenHelpWindow()
    if BetterPosadaHelpFrame then
        BetterPosadaHelpFrame:Show()
        return
    end

    local f = CreateFrame("Frame", "BetterPosadaHelpFrame", UIParent)
    BetterPosadaHelpFrame = f

    f:SetSize(420, 380)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 16,
        insets   = { left = 5, right = 5, top = 5, bottom = 5 }
    })

    f:SetBackdropColor(0, 0, 0, 0.9)

    table.insert(UISpecialFrames, "BetterPosadaHelpFrame")

    ------------------------------------------------------------
    -- Cerrar
    ------------------------------------------------------------
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetSize(32, 32)

    ------------------------------------------------------------
    -- Título
    ------------------------------------------------------------
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("|cFFFFD700BetterPosada – Ayuda|r")

    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetTexture(1, 0.82, 0, 0.4)
    line:SetHeight(2)
    line:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
    line:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -35)

    ------------------------------------------------------------
    -- Texto de comandos
    ------------------------------------------------------------
    local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 20, -60)
    text:SetJustifyH("LEFT")
    text:SetWidth(380)
    text:SetText([[
|cffffff00Comandos disponibles:|r

|cffFFD700/bpreport [jugador] [mensaje]|r
Crea un reporte rápido para ese jugador.

|cffFFD700/bpreport|r  (sin argumentos)
Abre la ventana de reporte. Si tienes target de un jugador, lo usa automáticamente.

|cffFFD700/bpshowreports [jugador]|r
Muestra todos los reportes para ese jugador.

|cffFFD700/bpshowreports|r  (sin argumentos)
Si tienes target de un jugador seleccionado, muestra sus reportes.

|cffFFD700/bpclearreports [jugador]|r
Elimina todos los reportes asociados a ese jugador.
]])

    ------------------------------------------------------------
    -- Créditos
    ------------------------------------------------------------

    -- Texto principal
    local credits = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    credits:SetPoint("BOTTOM", 0, 38)
    credits:SetText("|cFFAAAAAAHecho con cariño para UltimoWoW por |r|cff99ddffNibu|r")

    -- Botón invisible para click
    local creditsBtn = CreateFrame("Button", nil, f)
    creditsBtn:SetPoint("CENTER", credits, "CENTER")
    creditsBtn:SetSize(credits:GetStringWidth(), credits:GetStringHeight())

    creditsBtn:SetScript("OnEnter", function()
        credits:SetText("|cFFAAAAAAHecho con cariño para UltimoWoW por |r|cffcce6ffNibu|r")
    end)

    creditsBtn:SetScript("OnLeave", function()
        credits:SetText("|cFFAAAAAAHecho con cariño para UltimoWoW por |r|cff99ddffNibu|r")
    end)

    local donate = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    donate:SetPoint("TOP", credits, "BOTTOM", 0, -4)
    donate:SetText("|cFFAAAAAASi por algún motivo quisieras donar:")

    -- Botón invisible para donación
    local donateBtn = CreateFrame("Button", nil, f)
    donateBtn:SetPoint("CENTER", donate, "CENTER")
    donateBtn:SetSize(donate:GetStringWidth(), donate:GetStringHeight())

    local link = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    link:SetPoint("BOTTOM", 0, 10)
    link:SetText("|r|cff99ddffko-fi.com/nibu1|r")

    local linkBtn = CreateFrame("Button", nil, f)
    linkBtn:SetPoint("CENTER", link, "CENTER")
    linkBtn:SetSize(link:GetStringWidth(), link:GetStringHeight())

    linkBtn:SetScript("OnEnter", function()
        link:SetText("|r|cffcce6ffko-fi.com/nibu1|r")
    end)
    linkBtn:SetScript("OnLeave", function()
        link:SetText("|r|cff99ddffko-fi.com/nibu1|r")
    end)
end
