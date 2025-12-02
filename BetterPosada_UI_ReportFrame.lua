function BetterPosada_CreateReportWindow()
    if BetterPosadaReportFrame then return end
    local f = CreateFrame("Frame", "BetterPosadaReportFrame", UIParent)
    BetterPosadaReportFrame = f

    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetSize(360, 360)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    table.insert(UISpecialFrames, "BetterPosadaReportFrame")

    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    ---------------------------------------------------------
    -- TÍTULO
    ---------------------------------------------------------
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", 0, -18)
    f.title:SetText("|cffFFD700Reportar jugador|r")

    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetTexture(1, 0.82, 0, 0.4)
    line:SetHeight(2)
    line:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -40)
    line:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -35)

    ---------------------------------------------------------
    -- CERRAR
    ---------------------------------------------------------
    f.closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeBtn:SetPoint("TOPRIGHT", -5, -5)
    f.closeBtn:SetSize(30, 30)
    f.closeBtn:GetNormalTexture():SetVertexColor(1, 1, 1)
    f.closeBtn:GetHighlightTexture():SetVertexColor(1, 0.95, 0.6)
    f.closeBtn:GetPushedTexture():SetVertexColor(1, 0.85, 0.3)
    f.closeBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    f.nameLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.nameLabel:SetPoint("TOPLEFT", 30, -55)
    f.nameLabel:SetText("Nombre del jugador:")

    local nameBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.nameBox = nameBox
    nameBox:SetSize(220, 26)
    nameBox:SetPoint("TOPLEFT", f.nameLabel, "BOTTOMLEFT", 0, -4)
    nameBox:SetAutoFocus(false)

    local namePlaceholder = nameBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    namePlaceholder:SetPoint("LEFT", nameBox, "LEFT", 8, 0)
    namePlaceholder:SetText("Nombre...")
    namePlaceholder:SetTextColor(0.7,0.7,0.7)

    local function RefreshNamePlaceholder()
        if nameBox:GetText() == "" and not nameBox:HasFocus() then
            namePlaceholder:Show()
        else
            namePlaceholder:Hide()
        end
    end

    nameBox:SetScript("OnTextChanged", RefreshNamePlaceholder)
    nameBox:SetScript("OnEditFocusGained", RefreshNamePlaceholder)
    nameBox:SetScript("OnEditFocusLost", RefreshNamePlaceholder)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    f.textLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.textLabel:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", 0, -18)
    f.textLabel:SetText("Detalle del reporte:")

    local textFrame = CreateFrame("Frame", nil, f)
    f.textFrame = textFrame
    textFrame:SetPoint("TOPLEFT", f.textLabel, "BOTTOMLEFT", 0, -4)
    textFrame:SetSize(280, 130)
    textFrame:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=12,
        insets = { left=4, right=4, top=4, bottom=4 }
    })
    textFrame:SetBackdropColor(0,0,0,0.85)

    local textBox = CreateFrame("EditBox", nil, textFrame)
    f.textBox = textBox
    textBox:SetMultiLine(true)
    textBox:SetMaxLetters(200)
    textBox:SetPoint("TOPLEFT", 6, -6)
    textBox:SetPoint("BOTTOMRIGHT", -6, 6)
    textBox:SetFontObject(GameFontHighlight)
    textBox:SetAutoFocus(false)
    textBox:EnableMouse(true)

    textBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    textBox:SetScript("OnMouseWheel", function(self, delta)
        local cursor = self:GetCursorPosition()
        self:SetCursorPosition(cursor - delta*3)
    end)

    local textPlaceholder = textFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    textPlaceholder:SetPoint("TOPLEFT", textFrame, "TOPLEFT", 10, -8)
    textPlaceholder:SetText("Escribe el reporte aquí... (200 caracteres máximo)")
    textPlaceholder:SetTextColor(0.7,0.7,0.7)

    local function RefreshTextPlaceholder()
        if textBox:GetText()=="" and not textBox:HasFocus() then
            textPlaceholder:Show()
        else
            textPlaceholder:Hide()
        end
    end

    textBox:SetScript("OnTextChanged", RefreshTextPlaceholder)
    textBox:SetScript("OnEditFocusGained", RefreshTextPlaceholder)
    textBox:SetScript("OnEditFocusLost", RefreshTextPlaceholder)

    ---------------------------------------------------------
    -- BOTÓN GUARDAR
    ---------------------------------------------------------
    f.saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.saveBtn:SetPoint("BOTTOM", 0, 45)
    f.saveBtn:SetSize(120, 30)
    f.saveBtn:SetText("|cffFFDD00Guardar|r")

    f.saveBtn:SetScript("OnClick", function()
        local name = (f.nameBox:GetText() or ""):trim()
        local text = (f.textBox:GetText() or ""):trim()

        if name == "" or text == "" then
            print("|cffff0000BetterPosada:|r Debes ingresar nombre y reporte.")
            return
        end

        name = BetterPosada_NormalizeName(name)
        BetterPosada_SaveReport(name, text)

        print("|cff00ff00BetterPosada:|r Reporte guardado para " .. name)
        f:Hide()
    end)

    local importante = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    importante:SetPoint("BOTTOM", 0, 20)
    importante:SetText("|cffFFDD00Importante:|r Este sistema de reporte es de uso comunitario.\nNo es una herramienta de reporte oficial.|r")

    f:Hide()
end

function BetterPosada_OpenReportWindow(prefillName)
    BetterPosada_CreateReportWindow()

    local f = BetterPosadaReportFrame

    f.nameBox:SetText("")
    f.textBox:SetText("")
    f.nameBox:ClearFocus()
    f.textBox:ClearFocus()

    if f.nameBox:GetScript("OnEditFocusLost") then
        f.nameBox:GetScript("OnEditFocusLost")(f.nameBox)
    end
    
    if f.textBox:GetScript("OnEditFocusLost") then
        f.textBox:GetScript("OnEditFocusLost")(f.textBox)
    end

    if prefillName and type(prefillName) == "string" and prefillName ~= "" then
        prefillName = prefillName:trim()
        prefillName = BetterPosada_NormalizeName(prefillName)
        f.nameBox:SetText(prefillName)
    end

    f:Show()
end
