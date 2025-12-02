local channelName = "posada"
local function BP_JoinPosada()
    if not channelName or channelName == "" then
        channelName = "posada"
    end
    local id = GetChannelName(channelName)
    if not id or id == 0 then
        JoinChannelByName(channelName)
    end
end

local function BP_RecheckPosada()
    local id = GetChannelName(channelName)
    if not id or id == 0 then
        JoinChannelByName(channelName)
    end
end

local PosadaJoiner = CreateFrame("Frame")
PosadaJoiner:RegisterEvent("PLAYER_LOGIN")
PosadaJoiner:RegisterEvent("PLAYER_ENTERING_WORLD")
PosadaJoiner:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")

PosadaJoiner:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        BP_JoinPosada()

    elseif event == "PLAYER_ENTERING_WORLD" then
        BP_JoinPosada()

    elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
        local msg, _, _, _, _, _, _, _, chanName = ...
        if strlower(chanName or "") == strlower(channelName) then
            BP_RecheckPosada()
        end
    end
end)

local playerMessages = {}
local maxMessages = 500
local messageHeight = 125
local messageContainer
local filterText = ""
local rightPaneWidth = 220
if not BetterPosadaDB then BetterPosadaDB = {} end
if not BetterPosadaDB.reports then BetterPosadaDB.reports = {} end
BetterPosada_IconCounts = {}
BetterPosada_ActiveIconFilter = nil

BetterPosada_IconOrder = {
    "Interface\\Icons\\inv_shirt_guildtabard_01",                       -- Guild
    "Interface\\LFGFrame\\LFGIcon-IcecrownCitadel",                     -- ICC
    "Interface\\Icons\\achievement_reputation_argentcrusader",          -- TOC
    "Interface\\Icons\\spell_fire_moltenblood",                         -- RS
    "Interface\\Icons\\inv_essenceofwintergrasp",                       -- VOA
    "Interface\\Icons\\INV_Misc_Coin_01",                               -- Comercio
    "Interface\\Icons\\inv_misc_frostemblem_01",                        -- Semanal
    "Interface\\LFGFrame\\LFGIcon-Naxxramas",                           -- Naxx
    "Interface\\Icons\\achievement_dungeon_ulduarraid_misc_03",         -- Ulduar
    "Interface\\Icons\\spell_holy_borrowedtime",                        -- Timewalking
    "Interface\\Icons\\achievement_boss_illidan",                       -- Illidan
    "Interface\\Icons\\Inv_misc_summerfest_brazierorange",              -- Fenix
    "Interface\\Icons\\achievement_boss_forgemaster",                   -- Forja
    "Interface\\Icons\\achievement_dungeon_icecrown_hallsofreflection", -- Camara de reflexion
    "Interface\\Icons\\achievement_dungeon_icecrown_forgeofsouls",      -- Default
    "Interface\\Icons\\INV_Misc_QuestionMark"                           -- Default
}

BetterPosada_IconNames = {
    ["Interface\\Icons\\inv_shirt_guildtabard_01"]                       = "Guild",
    ["Interface\\LFGFrame\\LFGIcon-IcecrownCitadel"]                     = "ICC",
    ["Interface\\Icons\\achievement_reputation_argentcrusader"]          = "TOC",
    ["Interface\\Icons\\spell_fire_moltenblood"]                         = "SR (Sagrario rubí)",
    ["Interface\\LFGFrame\\LFGIcon-Naxxramas"]                           = "Naxx",
    ["Interface\\Icons\\achievement_dungeon_ulduarraid_misc_03"]         = "Ulduar",
    ["Interface\\Icons\\inv_essenceofwintergrasp"]                       = "Archavon (VOA)",
    ["Interface\\Icons\\INV_Misc_Coin_01"]                               = "Comercio",
    ["Interface\\Icons\\inv_misc_frostemblem_01"]                        = "Semanal o diaria",
    ["Interface\\Icons\\spell_holy_borrowedtime"]                        = "Viajeros del tiempo",
    ["Interface\\Icons\\achievement_boss_illidan"]                       = "Illidan",
    ["Interface\\Icons\\Inv_misc_summerfest_brazierorange"]              = "Fénix",
    ["Interface\\Icons\\achievement_boss_forgemaster"]                   = "Foso de Saron",
    ["Interface\\Icons\\achievement_dungeon_icecrown_hallsofreflection"] = "Cámaras de Reflexión",
    ["Interface\\Icons\\achievement_dungeon_icecrown_forgeofsouls"]      = "Forja de Almas",
    ["Interface\\Icons\\INV_Misc_QuestionMark"]                          = "Otros"
}


----------------------------------------------------------
-- TEMAS VISUALES
----------------------------------------------------------
BetterPosadaThemes = {
    dark = {
        name   = "Minimal",
        bg1    = {0.10, 0.10, 0.14, 0.90},
        bg2    = {0.14, 0.14, 0.18, 0.90},
        author = {1.00, 0.95, 0.80},
        msg    = {0.90, 0.90, 0.96},
        timer  = "default",
        border = false,
    },

    warm = {
        name   = "Atardecer",
        bg1    = {0.26, 0.16, 0.06, 0.95},
        bg2    = {0.30, 0.18, 0.07, 0.95},
        author = {1.00, 0.88, 0.50},
        msg    = {1.00, 0.95, 0.85},
        timer  = "warm",
        border = false,
    },

    ice = {
        name   = "Azul hielo",
        bg1    = {0.05, 0.11, 0.20, 0.92},
        bg2    = {0.07, 0.15, 0.26, 0.92},
        author = {0.70, 0.92, 1.00},
        msg    = {0.86, 0.96, 1.00},
        timer  = "ice",
        border = true,
    },

    noir = {
        name   = "Noir",
        bg1    = {0.02, 0.02, 0.02, 0.96},
        bg2    = {0.05, 0.05, 0.05, 0.96},
        author = {0.90, 0.90, 0.90},
        msg    = {0.96, 0.96, 0.96},
        timer  = "gray",
        border = false,
    },
}

--------------------------------------------------------
-- Canal de comunicacion para reportes
--------------------------------------------------------

BetterPosada_ChannelName = "BETTERPOSADA_REP"
BetterPosada_ChannelID = nil

function string.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function BP_FindChannelID()
    for i = 1, 20 do
        local id, name = GetChannelName(i)
        if name == BetterPosada_ChannelName then
            return id
        end
    end
    return nil
end

local function BP_JoinChannel()
    local id = BP_FindChannelID()
    if not id or id == 0 then
        JoinChannelByName(BetterPosada_ChannelName, nil, nil, true)
    end
end

local function BP_UpdateChannelID()
    local id = BP_FindChannelID()
    if id and id ~= 0 then
        BetterPosada_ChannelID = id
    end
end

local BP_ChannelFrame = CreateFrame("Frame")
BP_ChannelFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
BP_ChannelFrame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
BP_ChannelFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        BP_JoinChannel()
        BP_UpdateChannelID()
    elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
        BP_UpdateChannelID()
    end
end)

function BetterPosada_NormalizeName(name)
    if not name then return "" end
    name = (name or ""):trim()

    if name == "" then
        return ""
    end

    name = name:lower()
    name = name:gsub("^%l", string.upper)

    return name
end

local function FindMessageIndex(author, msg)
    for i, entry in ipairs(playerMessages) do
        if entry.msg == msg and entry.author == author then
            return i
        end
    end
    return nil
end

--------------------------------------------------------
-- Clear focus
--------------------------------------------------------

BetterPosada_ClickFrames = {}

function BetterPosada_TryClearFocus()
    -- Mensaje
    if BetterPosadaMessageInput and BetterPosadaMessageInput.HasFocus and BetterPosadaMessageInput:HasFocus() then
        BetterPosadaMessageInput:ClearFocus()
        if BetterPosadaMessageInput.RefreshPlaceholder then
            BetterPosadaMessageInput:RefreshPlaceholder()
        end
    end

    -- Filtro
    if BetterPosadaFilterBox and BetterPosadaFilterBox.HasFocus and BetterPosadaFilterBox:HasFocus() then
        BetterPosadaFilterBox:ClearFocus()
        if BetterPosadaFilterBox.RefreshPlaceholder then
            BetterPosadaFilterBox:RefreshPlaceholder()
        end
    end
end

function RegisterClickFrame(f)
    if f and f.EnableMouse then
        table.insert(BetterPosada_ClickFrames, f)
        f:EnableMouse(true)
        f:HookScript("OnMouseDown", function()
            BetterPosada_TryClearFocus()
        end)
    end
end

----------------------------------------------------------
-- VENTANA DE CONFIGURACIÓN
----------------------------------------------------------
local function CreateConfigWindow()
    if BetterPosadaConfigFrame then
        BetterPosadaConfigFrame:Show()
        return
    end

    local f = CreateFrame("Frame", "BetterPosadaConfigFrame", UIParent)
    BetterPosadaConfigFrame = f

    f:SetSize(400, 300)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(100)
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })

    f:SetBackdropColor(0, 0, 0, 1)
    table.insert(UISpecialFrames, "BetterPosadaConfigFrame")

    ---------------------------------------------------------
    -- Botón cerrar (X)
    ---------------------------------------------------------
    f.closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeBtn:SetPoint("TOPRIGHT", -5, -5)
    f.closeBtn:SetSize(32, 32)
    f.closeBtn:SetScript("OnClick", function() f:Hide() end)

    ---------------------------------------------------------
    -- Título
    ---------------------------------------------------------
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("|cffFFD700BetterPosada – Configuración|r")

    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetTexture(1, 0.82, 0, 0.4)
    line:SetHeight(2)
    line:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
    line:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -35)

    ---------------------------------------------------------
    -- ANIMACIÓN DE MENSAJES
    ---------------------------------------------------------
    local animLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    animLabel:SetPoint("TOPLEFT", 20, -55)
    animLabel:SetText("Animación de mensajes:")

    local animDrop = CreateFrame("Frame", "BetterPosadaAnimationDropdown", f, "UIDropDownMenuTemplate")
    animDrop:SetPoint("TOPLEFT", animLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(animDrop, 150)

    local animationOptions = {
        { value = "fade",  text = "Fade (suave)" },
        { value = "glow",  text = "Glow (brillo)" },
        { value = "grow",  text = "Grow (zoom)" },
        { value = "shine", text = "Shine (destello)" },
    }

    local currentAnim = BetterPosadaDB.settings.animation
    local valid = { fade = true, glow = true, grow = true, shine = true }
    if not valid[currentAnim] then
        currentAnim = "fade"
        BetterPosadaDB.settings.animation = "fade"
    end

    local function AnimTextFromValue(v)
        for _, opt in ipairs(animationOptions) do
            if opt.value == v then
                return opt.text
            end
        end
        return "Fade (suave)"
    end

    UIDropDownMenu_SetText(animDrop, AnimTextFromValue(currentAnim))

    UIDropDownMenu_Initialize(animDrop, function(self, level)
        for _, opt in ipairs(animationOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.text
            info.func = function()
                BetterPosadaDB.settings.animation = opt.value
                UIDropDownMenu_SetText(animDrop, opt.text)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    ---------------------------------------------------------
    -- TEMA VISUAL (dropdown)
    ---------------------------------------------------------
    local themeLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    themeLabel:SetPoint("TOPLEFT", animDrop, "BOTTOMLEFT", 15, -20)
    themeLabel:SetText("Tema visual:")

    local themeDrop = CreateFrame("Frame", "BetterPosadaThemeDropdown", f, "UIDropDownMenuTemplate")
    themeDrop:SetPoint("TOPLEFT", themeLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(themeDrop, 160)

    local themeKey = BetterPosadaDB.settings.theme or "dark"
    local themeDef = BetterPosadaThemes[themeKey] or BetterPosadaThemes.dark
    UIDropDownMenu_SetText(themeDrop, themeDef.name or "dark")

    local themeOrder = { "dark", "warm", "ice", "noir" }

    UIDropDownMenu_Initialize(themeDrop, function(self, level)
        for _, key in ipairs(themeOrder) do
            local data = BetterPosadaThemes[key]
            if data then
                local info = UIDropDownMenu_CreateInfo()
                info.text = data.name or key
                info.func = function()
                    BetterPosadaDB.settings.theme = key
                    UIDropDownMenu_SetText(themeDrop, data.name or key)
                    if UpdateChatDisplay then
                        UpdateChatDisplay()
                    end
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    ---------------------------------------------------------
    -- TIEMPO DE EXPIRACIÓN
    ---------------------------------------------------------
    local expLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expLabel:SetPoint("TOPLEFT", themeDrop, "BOTTOMLEFT", 15, -25)
    expLabel:SetText("Tiempo para borrar mensajes:")

    local options = {
        { text = "60 segundos",  value = 60  },
        { text = "90 segundos",  value = 90  },
        { text = "120 segundos", value = 120 },
    }

    local radioButtons = {}
    local lastBtn = nil
    local currentExpire = BetterPosadaDB.settings.expireTime or 60

    for i, opt in ipairs(options) do
        local btn = CreateFrame("CheckButton", nil, f, "UIRadioButtonTemplate")
        btn:SetChecked(currentExpire == opt.value)

        if not lastBtn then
            btn:SetPoint("TOPLEFT", expLabel, "BOTTOMLEFT", 0, -10)
        else
            btn:SetPoint("TOPLEFT", lastBtn, "BOTTOMLEFT", 0, -5)
        end

        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", btn, "RIGHT", 4, 0)
        label:SetText(opt.text)

        btn:SetScript("OnClick", function()
            for _, b in ipairs(radioButtons) do
                b:SetChecked(false)
            end
            btn:SetChecked(true)
            BetterPosadaDB.settings.expireTime = opt.value
        end)

        table.insert(radioButtons, btn)
        lastBtn = btn
    end

    ---------------------------------------------------------
    -- BOTÓN GUARDAR
    ---------------------------------------------------------
    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(100, 22)
    saveBtn:SetPoint("BOTTOMRIGHT", -15, 15)
    saveBtn:SetText("Guardar")

    saveBtn:SetScript("OnClick", function()
        print("|cff00ff00BetterPosada:|r Configuración guardada.")
        if UpdateChatDisplay then
            UpdateChatDisplay()
        end
        f:Hide()
    end)
end


-- Evento al recibir mensaje
function OnChatMessage(self, event, msg, author, _, _, _, _, _, _, channelNameArg, _, guid)
    if strlower(channelNameArg or "") ~= strlower(channelName) then return end

    local index = FindMessageIndex(author, msg)
    local isRepeat = false

    if index then
        -- Mensaje repetido del mismo autor
        isRepeat = true
        playerMessages[index].timestamp = GetTime()
        playerMessages[index].guid = guid or playerMessages[index].guid
    else
        table.insert(playerMessages, {
            author = author,
            msg = msg,
            timestamp = GetTime(),
            guid = guid,
            icon = BetterPosada_GetIndicatorIcon(msg)
        })

        if #playerMessages > maxMessages then
            table.remove(playerMessages, 1)
        end

        index = #playerMessages
    end

    UpdateChatDisplay(index, isRepeat)
end

local function FormatElapsed(t)
    local elapsed = GetTime() - t
    elapsed = math.floor(elapsed)

    if elapsed < 60 then
        return string.format("hace %ds", elapsed)
    else
        local m = math.floor(elapsed / 60)
        local s = elapsed % 60
        return string.format("hace %dm %ds", m, s)
    end
end

function FlashMessageFrame(frame)
    local mode = BetterPosadaDB.settings.animation or "fade"

    if mode == "fade" then
        Flash_Fade(frame)
    elseif mode == "glow" then
        Flash_Glow(frame)
    elseif mode == "grow" then
        Flash_Grow(frame)
    elseif mode == "shine" then
        Flash_Shine(frame)
    else
        Flash_Fade(frame)
    end
end

function Flash_Fade(frame)
    frame.animAlpha = 0
    frame:SetAlpha(0)

    frame:SetScript("OnUpdate", function(self, elapsed)
        self.animAlpha = self.animAlpha + elapsed * 2
        if self.animAlpha >= 1 then
            self:SetAlpha(1)
            self:SetScript("OnUpdate", nil)
        else
            self:SetAlpha(self.animAlpha)
        end
    end)
end

function Flash_Glow(frame)
    local glow = frame.glow
    if not glow then
        glow = frame:CreateTexture(nil, "OVERLAY")
        frame.glow = glow
        glow:SetTexture("Interface\\Buttons\\WHITE8x8")
        glow:SetBlendMode("ADD")
        glow:SetAllPoints(frame)
    end

    local t = 0
    local duration = 0.6
    local pulses = 2

    glow:SetAlpha(0)

    frame:SetScript("OnUpdate", function(self, elapsed)
        t = t + elapsed

        if t >= duration then
            glow:SetAlpha(0)
            self:SetScript("OnUpdate", nil)
            return
        end

        local p = t / duration
        local phase = p * pulses * math.pi * 2
        local osc = (math.sin(phase) + 1) * 0.5
        local intensity = osc * 0.35

        glow:SetAlpha(intensity)
    end)
end



function Flash_Grow(frame)
    local scaleStart = 1.04
    local scaleEnd   = 1.00
    local duration   = 0.15
    local timer      = 0

    frame:SetScale(scaleStart)

    frame:SetScript("OnUpdate", function(self, elapsed)
        timer = timer + elapsed
        local p = math.min(timer / duration, 1)
        local s = scaleStart + (scaleEnd - scaleStart) * p

        self:SetScale(s)

        if p >= 1 then
            self:SetScale(1)
            self:SetScript("OnUpdate", nil)
        end
    end)
end

function Flash_Shine(frame)
    local shine = frame.shine
    if not shine then
        shine = frame:CreateTexture(nil, "OVERLAY")
        frame.shine = shine
        shine:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
        shine:SetBlendMode("ADD")
        shine:SetWidth(frame:GetWidth() * 0.5)
        shine:SetHeight(frame:GetHeight() * 1.3)
    end

    local t = 0
    shine:SetAlpha(0.8)
    shine:ClearAllPoints()
    shine:SetPoint("LEFT", frame, "LEFT", -shine:GetWidth(), 0)

    frame:SetScript("OnUpdate", function(self, elapsed)
        t = t + elapsed
        local p = t / 0.35

        shine:SetPoint("LEFT", frame, "LEFT",
            (p * (frame:GetWidth() + shine:GetWidth())) - shine:GetWidth(),
            0
        )

        if p >= 1 then
            shine:SetAlpha(0)
            self:SetScript("OnUpdate", nil)
        end
    end)
end

function DestroyAllMessageFrames()
    if not messageContainer then return end

    local children = { messageContainer:GetChildren() }
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end

    for _, entry in ipairs(playerMessages) do
        local f = entry.frame
        if f then
            -- Remover scripts
            f:SetScript("OnUpdate", nil)
            if f.holder then f.holder:SetScript("OnUpdate", nil) end
            if f.sf then 
                f.sf:SetScript("OnUpdate", nil)
                f.sf:Clear()
            end

            -- Remover texturas
            if f.glow then f.glow:SetTexture(nil) end
            if f.shine then f.shine:SetTexture(nil) end

            -- Ocultar hijos del holder
            if f.holder then
                local c = { f.holder:GetChildren() }
                for _, k in ipairs(c) do
                    k:Hide()
                    k:SetParent(nil)
                end
            end

            f:Hide()
            f:SetParent(nil)
            entry.frame = nil
        end
    end

    messageContainer:SetHeight(BetterPosadaScrollFrame:GetHeight())
end

function UpdateChatDisplay(targetIndex, isRepeat)
    if not messageContainer then return end

    local now = GetTime()

    -- RECONTAR ICONOS
    BetterPosada_IconCounts = {}

    for _, entry in ipairs(playerMessages) do
        local icon = entry.icon or "none"
        BetterPosada_IconCounts[icon] = (BetterPosada_IconCounts[icon] or 0) + 1
    end

    for i = #playerMessages, 1, -1 do
        local entry = playerMessages[i]
        local expireTime = BetterPosadaDB.settings.expireTime or 60

        if now - entry.timestamp >= expireTime then
            if entry.frame then
                entry.frame:Hide()
                entry.frame:SetParent(nil)
                entry.frame = nil
            end

            table.remove(playerMessages, i)
            if targetIndex and i < targetIndex then
                targetIndex = targetIndex - 1
            end
        end
    end

    for _, entry in ipairs(playerMessages) do
        if entry.frame then entry.frame:Hide() end
    end

    local filteredMessages = {}
    for _, entry in ipairs(playerMessages) do
        local textPass = (filterText == "" or strfind(strlower(entry.msg), strlower(filterText), 1, true))

        local iconPass = true
        if BetterPosada_ActiveIconFilter then
            iconPass = (entry.icon == BetterPosada_ActiveIconFilter)
        end

        if textPass and iconPass then
            table.insert(filteredMessages, entry)
        end
    end

    local count = #filteredMessages
    local visualIndex = 0

    for _, entry in ipairs(filteredMessages) do
        visualIndex = visualIndex + 1

        local msgFrame = entry.frame
        if not msgFrame then
            msgFrame = CreateFrame("Frame", nil, messageContainer)

            msgFrame:EnableMouse(true)

            entry.frame = msgFrame

            msgFrame.bg = msgFrame:CreateTexture(nil, "BACKGROUND")
            msgFrame.bg:SetAllPoints()

            msgFrame.authorLabel = msgFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")

            msgFrame.indicator = msgFrame:CreateTexture(nil, "ARTWORK")
            msgFrame.indicator:SetSize(20, 20)
            msgFrame.indicator:SetPoint("TOPLEFT", msgFrame.authorLabel, "BOTTOMLEFT", 0, -3)

            local holder = CreateFrame("Frame", nil, msgFrame)
            msgFrame.holder = holder

            local sf = CreateFrame("ScrollingMessageFrame", nil, holder)
            msgFrame.sf = sf

            sf:SetFontObject(GameFontHighlight)
            sf:SetJustifyH("LEFT")
            sf:SetJustifyV("TOP")
            sf:SetFading(false)
            sf:SetMaxLines(3)
            sf:SetHyperlinksEnabled(true)
            sf:EnableMouse(true)
            sf:SetInsertMode("TOP")

            sf:HookScript("OnMouseDown", function()
                BetterPosada_TryClearFocus()
            end)

            sf:SetScript("OnMouseUp", function()
                BetterPosada_TryClearFocus()

                BetterPosadaSelectedAuthor:SetText(entry.author)
                BetterPosadaSelectedAuthor.targetName = entry.author
                BetterPosada_UpdateActionButtons()
            end)

            sf:SetScript("OnHyperlinkClick", function(self, link, text, button)
                ChatFrame_OnHyperlinkShow(self, link, text, button)
            end)

            sf:SetScript("OnHyperlinkEnter", function(self, linkData)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:SetHyperlink(linkData)
                GameTooltip:Show()
            end)

            sf:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

            sf:AddMessage(entry.msg)

            msgFrame.timerAnchor = CreateFrame("Frame", nil, msgFrame)
            msgFrame.timerLabel = msgFrame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
            msgFrame.timerLabel:SetJustifyH("RIGHT")

            msgFrame:EnableMouse(true)
            msgFrame:SetScript("OnMouseDown", function()
                BetterPosada_TryClearFocus()

                BetterPosadaSelectedAuthor:SetText(entry.author)
                BetterPosadaSelectedAuthor.targetName = entry.author

                if BetterPosada_UpdateActionButtons then
                    BetterPosada_UpdateActionButtons()
                end
            end)
        end

        msgFrame:SetParent(messageContainer)
        msgFrame:Show()

        msgFrame:SetSize(messageContainer:GetWidth(), messageHeight)
        msgFrame:ClearAllPoints()
        msgFrame:SetPoint("TOPLEFT", 0, -((visualIndex - 1) * messageHeight))

        local theme = BetterPosadaThemes[ BetterPosadaDB.settings.theme or "minimal" ]

        local bg = (visualIndex % 2 == 0) and theme.bg2 or theme.bg1
        msgFrame.bg:SetTexture(bg[1], bg[2], bg[3], bg[4])
        local finalAlpha = math.min((bg[4] or 1) * 0.65, 1)
        msgFrame.bg:SetAlpha(finalAlpha)

        msgFrame.sf:SetTextColor(unpack(theme.msg))

        local authorLabel = msgFrame.authorLabel
        authorLabel:ClearAllPoints()
        authorLabel:SetPoint("TOPLEFT", 5, -5)

        if msgFrame.indicator then
            local iconTexture = BetterPosada_GetIndicatorIcon(entry.msg or "")
            msgFrame.indicator:SetTexture(iconTexture)
            msgFrame.indicator:ClearAllPoints()
            msgFrame.indicator:SetPoint("TOPLEFT", authorLabel, "BOTTOMLEFT", 0, -3)
        end
        authorLabel:SetWidth(100)
        authorLabel:SetJustifyH("LEFT")
        msgFrame.authorLabel:SetText(entry.author .. ":")

        local timerReservedWidth = 40
        local availableWidth = msgFrame:GetWidth() - authorLabel:GetWidth() - timerReservedWidth - 20
        if availableWidth < 50 then availableWidth = 50 end

        local holder = msgFrame.holder
        holder:ClearAllPoints()
        holder:SetPoint("TOPLEFT", authorLabel, "TOPRIGHT", 5, -2)
        holder:SetSize(availableWidth, messageHeight - 10)

        local sf = msgFrame.sf
        sf:ClearAllPoints()
        sf:SetPoint("TOPLEFT", msgFrame.indicator, "TOPRIGHT", 6, 0)
        sf:SetSize(availableWidth, messageHeight - 10)

        local timerAnchor = msgFrame.timerAnchor
        local timerLabel = msgFrame.timerLabel

        timerAnchor:ClearAllPoints()
        timerAnchor:SetSize(timerReservedWidth, messageHeight)
        timerAnchor:SetPoint("TOPRIGHT", msgFrame, -5, 0)

        timerLabel:ClearAllPoints()
        timerLabel:SetPoint("TOPRIGHT", timerAnchor, "TOPRIGHT", 0, -5)

        local themeObj = BetterPosadaThemes[ BetterPosadaDB.settings.theme or "dark" ] or BetterPosadaThemes.dark

        local elapsed = now - entry.timestamp
        local r, g, b
        local scheme = themeObj.timer or "default"
        local expireTime = BetterPosadaDB.settings.expireTime or 60

        if elapsed < 0 then elapsed = 0 end

        -- Dinámica de umbrales
        local T1 = 20
        local T2 = math.floor(expireTime * 0.66)
        local T3 = math.floor(expireTime * 0.83)

        if scheme == "default" then
            if elapsed < T1 then
                r,g,b = 0.00, 1.00, 0.10
            elseif elapsed < T2 then
                r,g,b = 1.00, 1.00, 0.10
            elseif elapsed < T3 then
                r,g,b = 1.00, 0.50, 0.00
            else
                r,g,b = 1.00, 0.05, 0.05
            end

        elseif scheme == "warm" then
            if elapsed < T1 then
                r,g,b = 1.00, 0.80, 0.40
            elseif elapsed < T2 then
                r,g,b = 1.00, 0.65, 0.25
            elseif elapsed < T3 then
                r,g,b = 1.00, 0.45, 0.10
            else
                r,g,b = 0.90, 0.20, 0.05
            end

        elseif scheme == "ice" then
            if elapsed < T1 then
                r,g,b = 0.70, 0.95, 1.00
            elseif elapsed < T2 then
                r,g,b = 0.40, 0.75, 1.00
            elseif elapsed < T3 then
                r,g,b = 0.20, 0.55, 1.00
            else
                r,g,b = 0.05, 0.25, 0.65
            end

        elseif scheme == "gray" then
            if elapsed < T1 then
                r,g,b = 0.90, 0.90, 0.90
            elseif elapsed < T2 then
                r,g,b = 0.70, 0.70, 0.70
            elseif elapsed < T3 then
                r,g,b = 1.00, 0.55, 0.20
            else
                r,g,b = 1.00, 0.10, 0.10
            end
        else
            r,g,b = 0.8, 0.8, 0.8
        end


        timerLabel:SetText(FormatElapsed(entry.timestamp))
        timerLabel:SetTextColor(r, g, b)


        if targetIndex and playerMessages[targetIndex] == entry then
            FlashMessageFrame(msgFrame)
        end
    end

    local totalHeight = math.max(count * messageHeight, BetterPosadaScrollFrame:GetHeight())
    messageContainer:SetHeight(totalHeight)

    BetterPosada_UpdateIconBar()
end

function InitializeFrame()
    ------------------------------------------------
    -- BACKDROP DE LA VENTANA PRINCIPAL
    ------------------------------------------------
    BetterPosadaFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    BetterPosadaFrame:SetBackdropColor(0, 0, 0, 0.8)

    ------------------------------------------------
    -- TÍTULO
    ------------------------------------------------
    local header = BetterPosadaFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    header:SetPoint("TOP", 0, -10)
    header:SetText("|cffFFD700BetterPosada|r")

    local line = BetterPosadaFrame:CreateTexture(nil, "ARTWORK")
    line:SetTexture(1, 0.82, 0, 0.4)
    line:SetHeight(2)
    line:SetPoint("TOPLEFT", BetterPosadaFrame, "TOPLEFT", 10, -35)
    line:SetPoint("TOPRIGHT", BetterPosadaFrame, "TOPRIGHT", -10, -35)

    tinsert(UISpecialFrames, "BetterPosadaFrame")

    local currentW, currentH = BetterPosadaFrame:GetWidth(), BetterPosadaFrame:GetHeight()
    if currentW < 450 then currentW = 450 end
    if currentH < 600 then currentH = 600 end
    BetterPosadaFrame:SetSize(currentW, currentH)

    BetterPosadaFrame:SetMovable(true)
    BetterPosadaFrame:EnableMouse(true)
    BetterPosadaFrame:RegisterForDrag("LeftButton")
    BetterPosadaFrame:SetClampedToScreen(true)
    BetterPosadaFrame:SetScript("OnDragStart", BetterPosadaFrame.StartMoving)
    BetterPosadaFrame:SetScript("OnDragStop", BetterPosadaFrame.StopMovingOrSizing)

    ------------------------------------------------
    -- FILTRO + PLACEHOLDER
    ------------------------------------------------
    local filterBox = CreateFrame("EditBox", nil, BetterPosadaFrame, "InputBoxTemplate")
    filterBox:SetFrameLevel(BetterPosadaFrame:GetFrameLevel() + 10)
    filterBox:SetSize(200, 20)
    filterBox:ClearAllPoints()
    filterBox:SetPoint("TOPLEFT", BetterPosadaFrame, "TOPLEFT", 15, -40)
    filterBox:SetAutoFocus(false)

    BetterPosadaFilterBox = filterBox

    local placeholder = filterBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    placeholder:SetPoint("LEFT", filterBox, "LEFT", 5, 0)
    placeholder:SetText("Buscar:")
    placeholder:SetTextColor(0.7, 0.7, 0.7)

    local function RefreshFilterPlaceholder()
        if filterBox:GetText() == "" and not filterBox:HasFocus() then
            placeholder:Show()
        else
            placeholder:Hide()
        end
    end

    filterBox.RefreshPlaceholder = RefreshFilterPlaceholder

    filterBox:SetScript("OnTextChanged", function(self)
        filterText = self:GetText() or ""
        RefreshFilterPlaceholder()
        UpdateChatDisplay()
    end)

    filterBox:SetScript("OnEditFocusGained", RefreshFilterPlaceholder)
    filterBox:SetScript("OnEditFocusLost", RefreshFilterPlaceholder)
    filterBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    filterBox:SetScript("OnMouseDown", function(self) self:SetFocus() end)

    WorldFrame:HookScript("OnMouseDown", function()
        if filterBox:HasFocus() then filterBox:ClearFocus() end
    end)
    RegisterClickFrame(filterBox)

    ------------------------------------------------
    -- SCROLLFRAME
    ------------------------------------------------
    local scrollFrame = BetterPosadaScrollFrame
    if not scrollFrame then
        return
    end

    scrollFrame:ClearAllPoints()
    scrollFrame:SetPoint("TOPLEFT", filterBox, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", BetterPosadaFrame, "BOTTOMRIGHT", -(rightPaneWidth + 20), 20)

    messageContainer = CreateFrame("Frame", nil, scrollFrame)
    messageContainer:SetWidth(scrollFrame:GetWidth() - 20)
    messageContainer:SetHeight(scrollFrame:GetHeight())
    scrollFrame:SetScrollChild(messageContainer)

    messageContainer:EnableMouse(true)
    messageContainer:RegisterForDrag("LeftButton")

    messageContainer:SetScript("OnDragStart", function()
        BetterPosadaFrame:StartMoving()
    end)

    messageContainer:SetScript("OnDragStop", function()
        BetterPosadaFrame:StopMovingOrSizing()
    end)

    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -20, -16)
        scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -20, 16)
    end

    ------------------------------------------------
    -- PANEL DERECHO
    ------------------------------------------------
    local rightPane = CreateFrame("Frame", "BetterPosadaRightPane", BetterPosadaFrame)
    rightPane:SetPoint("TOPRIGHT", BetterPosadaFrame, "TOPRIGHT", -10, -40)
    rightPane:SetPoint("BOTTOMRIGHT", BetterPosadaFrame, "BOTTOMRIGHT", -10, 10)
    rightPane:SetWidth(rightPaneWidth)
    rightPane:EnableMouse(true)
    rightPane:EnableMouse(true)
    rightPane:RegisterForDrag("LeftButton")

    rightPane:SetScript("OnDragStart", function()
        BetterPosadaFrame:StartMoving()
    end)

    rightPane:SetScript("OnDragStop", function()
        BetterPosadaFrame:StopMovingOrSizing()
    end)

    local rpBg = rightPane:CreateTexture(nil, "BACKGROUND")
    rpBg:SetTexture(0, 0, 0, 0)

    function BetterPosada_AddNetworkReport(player, text, time, sender)
        local box = BetterPosada_RightPaneReportsBox
        if not box then return end

        local msg = string.format("|cffFFD700%s|r: %s\n|cFFAAAAAA(%s)|r", sender, text, time)
        box:AddMessage(msg)
    end

    ------------------------------------------------
    -- "Enviar mensaje a:"
    ------------------------------------------------
    local title1 = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title1:SetPoint("TOPLEFT", 5, -10)
    title1:SetWidth(rightPaneWidth - 10)
    title1:SetText("|cFFFFFFFFEnviar mensaje a:|r")

    BetterPosadaSelectedAuthor = rightPane:CreateFontString("BetterPosadaSelectedAuthor", "OVERLAY", "GameFontHighlightLarge")
    BetterPosadaSelectedAuthor:SetPoint("TOPLEFT", title1, "BOTTOMLEFT", 0, -4)
    BetterPosadaSelectedAuthor:SetWidth(rightPaneWidth - 10)
    BetterPosadaSelectedAuthor:SetJustifyH("LEFT")
    BetterPosadaSelectedAuthor:SetText(" ")
    BetterPosadaSelectedAuthor.targetName = nil

    function BetterPosada_UpdateActionButtons()
        local hasTarget = BetterPosadaSelectedAuthor.targetName ~= nil 
                        and BetterPosadaSelectedAuthor.targetName ~= ""

        if BetterPosadaSendBtn then
            if hasTarget then
                BetterPosadaSendBtn:Enable()
            else
                BetterPosadaSendBtn:Disable()
            end
            BetterPosadaSendBtn:GetFontString():SetTextColor(
                hasTarget and 1 or 0.5, 
                hasTarget and 1 or 0.5, 
                hasTarget and 0 or 0.5
            )
        end

        if BetterPosadaReportLoadingBtn then
            if hasTarget then
                BetterPosadaReportLoadingBtn:Enable()
            else
                BetterPosadaReportLoadingBtn:Disable()
            end
            BetterPosadaReportLoadingBtn:GetFontString():SetTextColor(
                hasTarget and 1 or 0.5, 
                hasTarget and 1 or 0.5, 
                hasTarget and 1 or 0.5
            )
        end

        if BetterPosadaInviteBtn then
            if hasTarget then
                BetterPosadaInviteBtn:Enable()
            else
                BetterPosadaInviteBtn:Disable()
            end
            BetterPosadaInviteBtn:GetFontString():SetTextColor(
                hasTarget and 1 or 0.5,
                hasTarget and 1 or 0.5,
                hasTarget and 0 or 0.5
            )
        end
    end

    ------------------------------------------------
    -- CAJA DEL MENSAJE
    ------------------------------------------------
    local msgBox = CreateFrame("Frame", nil, rightPane)
    msgBox:SetPoint("TOPLEFT", BetterPosadaSelectedAuthor, "BOTTOMLEFT", 0, -10)
    msgBox:SetSize(rightPaneWidth - 10, 125)
    msgBox:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=12,
        insets={left=4,right=4,top=4,bottom=4},
    })
    msgBox:SetBackdropColor(0,0,0,0.85)

    ------------------------------------------------
    -- EDITBOX
    ------------------------------------------------
    local msgInput = CreateFrame("EditBox","BetterPosadaMessageInput",msgBox)
    BetterPosadaMessageInput = msgInput
    msgInput:SetMultiLine(true)
    msgInput:SetAutoFocus(false)
    msgInput:SetMaxLetters(255)
    msgInput:SetFontObject(GameFontHighlight)
    msgInput:SetPoint("TOPLEFT", msgBox, "TOPLEFT", 6, -6)
    msgInput:SetPoint("BOTTOMRIGHT", msgBox, "BOTTOMRIGHT", -6, 6)
    msgInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    ------------------------------------------------
    -- PLACEHOLDER
    ------------------------------------------------
    local msgPlaceholder = msgInput:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
    msgPlaceholder:SetFont(msgPlaceholder:GetFont(), 9)
    msgPlaceholder:SetPoint("TOPLEFT", msgBox, "TOPLEFT", 10, -8)
    msgPlaceholder:SetText("Escribe un mensaje... (máx 255 caracteres)")
    msgPlaceholder:SetTextColor(0.7,0.7,0.7)

    local function RefreshMsgPlaceholder()
        if msgInput:GetText()=="" and not msgInput:HasFocus() then
            msgPlaceholder:Show()
        else
            msgPlaceholder:Hide()
        end
    end
    msgInput.RefreshPlaceholder = RefreshMsgPlaceholder

    msgInput:HookScript("OnTextChanged", RefreshMsgPlaceholder)
    msgInput:HookScript("OnEditFocusGained", RefreshMsgPlaceholder)
    msgInput:HookScript("OnEditFocusLost", RefreshMsgPlaceholder)

    BetterPosadaHistoryBox = CreateFrame("Frame", nil, rightPane)
    local historyBox = BetterPosadaHistoryBox

    ------------------------------------------------
    -- ENTER PARA ENVIAR MENSAJE
    ------------------------------------------------
    msgInput:SetScript("OnEnterPressed",function(self)
        local text = self:GetText()
        local target = BetterPosadaSelectedAuthor.targetName

        if target and text~="" then
            SendChatMessage(text,"WHISPER",nil,target)
            self:SetText("")
            RefreshMsgPlaceholder()
            self:ClearFocus()
        end
    end)

    ------------------------------------------------
    -- BOTÓN ENVIAR
    ------------------------------------------------
    BetterPosadaSendBtn = CreateFrame("Button", "BetterPosadaSendBtn", rightPane, "UIPanelButtonTemplate2")
    BetterPosadaSendBtn:SetSize(rightPaneWidth - 10, 26)
    BetterPosadaSendBtn:SetText("|cFFFFEE00Enviar (Enter)|r")
    BetterPosadaSendBtn:SetPoint("TOPLEFT", msgBox, "BOTTOMLEFT", 0, -10)


    BetterPosadaSendBtn:SetScript("OnClick", function()
        local text = msgInput:GetText() or ""
        local target = BetterPosadaSelectedAuthor.targetName

        if target and text~="" then
            SendChatMessage(text,"WHISPER",nil,target)
            msgInput:SetText("")
            RefreshMsgPlaceholder()
        end
    end)

    local consultBtn = CreateFrame("Button", "BetterPosadaReportLoadingBtn", rightPane, "UIPanelButtonTemplate2")
    consultBtn:SetSize(rightPaneWidth - 10, 26)
    consultBtn:SetText("|cFFFFEE00Consultar reportes|r")
    consultBtn:SetPoint("TOPLEFT", BetterPosadaSendBtn, "BOTTOMLEFT", 0, 0)

    consultBtn:SetScript("OnClick", function()
        local target = BetterPosadaSelectedAuthor.targetName
        if not target or target == "" then
            print("|cffff0000BetterPosada: Debes seleccionar un jugador.|r")
            return
        end

        BetterPosada_OpenFullReportFor(target)
    end)

    ------------------------------------------------
    -- BOTÓN INVITAR
    ------------------------------------------------
    local inviteBtn = CreateFrame("Button", "BetterPosadaInviteBtn", rightPane, "UIPanelButtonTemplate2")
    inviteBtn:SetSize(rightPaneWidth - 10, 26)
    inviteBtn:SetText("|cFFFFEE00Invitar|r")
    inviteBtn:SetPoint("TOPLEFT", consultBtn, "BOTTOMLEFT", 0, 0)

    inviteBtn:SetScript("OnClick", function()
        local target = BetterPosadaSelectedAuthor.targetName
        if not target or target == "" then
            print("|cffff0000BetterPosada: Debes seleccionar un jugador.|r")
            return
        end

        InviteUnit(target)
    end)

    ------------------------------------------------
    -- LABEL: FILTROS
    ------------------------------------------------
    local filterLabel = BetterPosadaFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    filterLabel:SetText("|cffFFD700Filtros|r")
    filterLabel:SetPoint("TOPLEFT", consultBtn, "BOTTOMLEFT", 0, -35)

    local filterLine = BetterPosadaFrame:CreateTexture(nil, "ARTWORK")
    filterLine:SetTexture(1, 0.82, 0, 0.35)
    filterLine:SetHeight(1.5)
    filterLine:SetPoint("TOPLEFT", filterLabel, "BOTTOMLEFT", 0, -3)
    filterLine:SetPoint("TOPRIGHT", filterLabel, "BOTTOMRIGHT", 0, -3)

    ------------------------------------------------
    -- contador de íconos
    ------------------------------------------------
    local iconBar = CreateFrame("Frame", "BetterPosadaIconBar", BetterPosadaFrame)
    iconBar:SetSize(rightPaneWidth - 10, 24)
    iconBar:SetPoint("TOPLEFT", filterLine, "BOTTOMLEFT", 0, -10)
    iconBar.icons = {}
    iconBar:SetFrameLevel(consultBtn:GetFrameLevel() + 2)

    ------------------------------------------------
    -- INFORMACIÓN
    ------------------------------------------------
    local helpBtn = CreateFrame("Button", "BetterPosadaHelpBtn", rightPane)
    helpBtn:SetSize(18, 18)
    helpBtn:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -4, 4)

    local tx = helpBtn:CreateTexture(nil, "ARTWORK")
    tx:SetAllPoints()
    tx:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    helpBtn.tex = tx

    helpBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Ayuda de BetterPosada", 1, 0.82, 0)
        GameTooltip:AddLine("Click para ver comandos disponibles.", 1, 1, 1)
        GameTooltip:Show()
    end)

    helpBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    helpBtn:SetScript("OnClick", function()
        BetterPosada_OpenHelpWindow()
    end)

    ------------------------------------------------
    -- BOTÓN CERRAR
    ------------------------------------------------
    local closeBtn = CreateFrame("Button", nil, BetterPosadaFrame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("TOPRIGHT", -10, -10)
    closeBtn:SetText("Cerrar")
    closeBtn:SetScript("OnClick", function()
        BetterPosadaFrame:Hide()
    end)

    ------------------------------------------------
    -- BOTÓN LIMPIAR
    ------------------------------------------------
    local resetBtn = CreateFrame("Button", nil, BetterPosadaFrame, "UIPanelButtonTemplate")
    resetBtn:SetSize(80, 22)
    resetBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -5, 0)
    resetBtn:SetText("Limpiar")
    resetBtn:SetScript("OnClick", function()
        for _, entry in ipairs(playerMessages) do
            if entry.frame then
                entry.frame:Hide()
                entry.frame:SetParent(nil)
                entry.frame = nil
            end
        end

        wipe(playerMessages)

        if messageContainer then
            messageContainer:SetHeight(BetterPosadaScrollFrame:GetHeight())
        end
        UpdateChatDisplay()

        if BetterPosada_ExternalReports then
            wipe(BetterPosada_ExternalReports)
        end

        BetterPosadaSelectedAuthor:SetText(" ")
        BetterPosadaSelectedAuthor.targetName = nil

        if BetterPosadaMessageInput then
            BetterPosadaMessageInput:SetText("")
            BetterPosadaMessageInput:RefreshPlaceholder()
        end
        if BetterPosada_UpdateActionButtons then
            BetterPosada_UpdateActionButtons()
        end
    end)

    ------------------------------------------------
    -- BOTÓN REPORTAR
    ------------------------------------------------
    local reportBtn = CreateFrame("Button", nil, BetterPosadaFrame, "UIPanelButtonTemplate")
    reportBtn:SetSize(80, 22)
    reportBtn:SetPoint("TOPRIGHT", resetBtn, "TOPLEFT", -5, 0)
    reportBtn:SetText("Reportar")

    reportBtn:SetNormalTexture(nil)
    reportBtn:SetHighlightTexture(nil)
    reportBtn:SetPushedTexture(nil)
    reportBtn:SetDisabledTexture(nil)

    reportBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    reportBtn:SetBackdropBorderColor(1, 0.85, 0, 1)
    reportBtn:SetBackdropColor(0.4, 0, 0, 0.9)

    reportBtn:SetScript("OnClick", BetterPosada_OpenReportWindow)

    ------------------------------------------------
    -- BOTÓN CONFIG
    ------------------------------------------------
    local configBtn = CreateFrame("Button", nil, BetterPosadaFrame, "UIPanelButtonTemplate")
    configBtn:SetSize(100, 22)
    configBtn:ClearAllPoints()
    configBtn:SetPoint("TOPLEFT", BetterPosadaFrame, "TOPLEFT", 10, -10)    
    configBtn:SetText("Opciones")
    configBtn:SetScript("OnClick", function()
        CreateConfigWindow()
        BetterPosadaConfigFrame:Show()
    end)
    configBtn:SetFrameLevel(resetBtn:GetFrameLevel() + 5)
    local scrollWidth = BetterPosadaScrollFrame:GetWidth()
    local rightWidth = rightPane:GetWidth()
    local extraPadding = 40

    local totalWidth = scrollWidth + rightWidth + extraPadding
    if totalWidth < 600 then totalWidth = 600 end

    BetterPosadaFrame:SetWidth(totalWidth)

    ------------------------------------------------
    -- REGISTRAR FRAMES EN EL SISTEMA DE CLICK
    ------------------------------------------------
    RegisterClickFrame(BetterPosadaFrame)
    RegisterClickFrame(BetterPosadaScrollFrame)
    RegisterClickFrame(rightPane)
    RegisterClickFrame(BetterPosadaSendBtn)
    RegisterClickFrame(BetterPosadaSelectedAuthor)

    RefreshMsgPlaceholder()
    RefreshFilterPlaceholder()

    BetterPosadaFrame:HookScript("OnMouseDown", function()
        if BetterPosadaMessageInput and BetterPosadaMessageInput.RefreshPlaceholder then
            BetterPosadaMessageInput:RefreshPlaceholder()
        end
        if BetterPosadaFilterBox and BetterPosadaFilterBox.RefreshPlaceholder then
            BetterPosadaFilterBox:RefreshPlaceholder()
        end
    end)

    if BetterPosada_UpdateActionButtons then
        BetterPosada_UpdateActionButtons()
    end
end

function BetterPosada_UpdateIconBar()
    local bar = BetterPosadaIconBar
    if not bar then return end

    for _, b in ipairs(bar.icons or {}) do
        b:Hide()
        b:SetParent(nil)
    end
    bar.icons = {}

    ---------------------------------------------------------
    -- PARÁMETROS DE LA GRILLA
    ---------------------------------------------------------
    local ICON_SIZE = 12
    local CELL_W = 43
    local CELL_H = 36
    local PER_ROW = 5

    local row = 0
    local col = 0

    for _, icon in ipairs(BetterPosada_IconOrder) do
        local count = BetterPosada_IconCounts[icon] or 0

        -----------------------------------------------------
        -- FRAME DEL ICONO
        -----------------------------------------------------
        local btn = CreateFrame("Button", nil, bar)
        btn:SetSize(ICON_SIZE + 8, ICON_SIZE + 8)
        btn:SetPoint("TOPLEFT", bar, "TOPLEFT", col * CELL_W, -row * CELL_H)

        -----------------------------------------------------
        -- TEXTURA DEL ICONO
        -----------------------------------------------------
        local tx = btn:CreateTexture(nil, "ARTWORK")
        tx:SetAllPoints(btn)
        tx:SetTexture(icon)
        btn.tex = tx

        -----------------------------------------------------
        -- CONTADOR
        -----------------------------------------------------
        local n = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        n:ClearAllPoints()
        n:SetPoint("LEFT", btn, "RIGHT", 4, 0)
        n:SetJustifyH("LEFT")
        n:SetFontObject(GameFontNormalSmall)
        n:SetTextColor(1, 0.82, 0)
        n:SetText(count)
        btn.countText = n

        -----------------------------------------------------
        -- BORDE SELECCIONADO
        -----------------------------------------------------
        local border = CreateFrame("Frame", nil, btn)
        border:SetPoint("TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", 2, -2)

        border:SetBackdrop({
            bgFile = nil,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 13,
        })

        border:SetBackdropBorderColor(1, 0.85, 0, 1)

        btn.border = border
        if BetterPosada_ActiveIconFilter == icon then
            border:Show()
        else
            border:Hide()
        end

        -----------------------------------------------------
        -- CLICK: alternar filtro
        -----------------------------------------------------
        btn:SetScript("OnClick", function()
            if BetterPosada_ActiveIconFilter == icon then
                BetterPosada_ActiveIconFilter = nil
            else
                BetterPosada_ActiveIconFilter = icon
            end

            UpdateChatDisplay()
        end)

        table.insert(bar.icons, btn)

        -----------------------------------------------------
        -- TOOLTIP AL PASAR EL MOUSE
        -----------------------------------------------------
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

            local label = BetterPosada_IconNames[icon] or "Icono"
            local count = BetterPosada_IconCounts[icon] or 0

            GameTooltip:AddLine(label, 1, 0.82, 0)
            GameTooltip:AddLine("Mensajes: " .. count, 1, 1, 1)

            if BetterPosada_ActiveIconFilter == icon then
                GameTooltip:AddLine("(Filtrando solo este ícono)", 0, 1, 0)
            else
                GameTooltip:AddLine("Click para filtrar", 0.7, 0.7, 0.7)
            end

            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -----------------------------------------------------
        -- AVANZAR EN GRILLA
        -----------------------------------------------------
        col = col + 1
        if col >= PER_ROW then
            col = 0
            row = row + 1
        end
    end

    local totalRows = row + 1
    local barHeight = totalRows * CELL_H
    bar:SetHeight(barHeight)
end

function ToggleBetterPosadaFrame(msg)
    if msg and msg ~= "" then
        channelName = msg
    else
        if BetterPosadaFrame:IsShown() then
            BetterPosadaFrame:Hide()
        else
            BetterPosadaFrame:Show()
            UpdateChatDisplay()
        end
    end
end

-- Eventos
BetterPosadaFrame:RegisterEvent("CHAT_MSG_CHANNEL")
BetterPosadaFrame:RegisterEvent("PLAYER_LOGIN")
BetterPosadaFrame:RegisterEvent("ADDON_LOADED")
BetterPosadaFrame:RegisterEvent("CHAT_MSG_ADDON")


BetterPosadaFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_CHANNEL" then
        local msg, sender, _, _, _, _, _, chanID, chanName = ...

        -- Mensajes del canal de posada
        if strlower(chanName or "") == strlower(channelName) then
            OnChatMessage(self, event, ...)
        end

        -- Mensajes del canal oculto SOLO PARA ASK
        if chanName == BetterPosada_ChannelName then
            local askTarget = msg:match("^BP_ASK:(.+)")
            if askTarget then
                BetterPosada_HandleAsk(askTarget, sender)
                return
            end
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, payload, channel, sender = ...


        if prefix == "BP_ANSWER" then
            BetterPosada_HandleAnswer(payload, sender)
            return
        end
    elseif event == "PLAYER_LOGIN" then
        if not BetterPosadaDB then
            BetterPosadaDB = {
                settings = { expireTime = 60 },
                reports = {},
            }
        else
            BetterPosadaDB.settings = BetterPosadaDB.settings or { expireTime = 60 }
            BetterPosadaDB.reports  = BetterPosadaDB.reports or {}
        end

        if not BetterPosadaDB.settings.animation then
            BetterPosadaDB.settings.animation = "fade"
        end
        if not BetterPosadaDB.settings.theme then
            BetterPosadaDB.settings.theme = "dark"
        end
    elseif event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "BetterPosada" then
            InitializeFrame()
        end
    end
end)


SLASH_BETTERPOSADA1 = "/betterposada"
SLASH_BETTERPOSADA2 = "/bp"
SlashCmdList["BETTERPOSADA"] = ToggleBetterPosadaFrame

BetterPosadaFrame:Hide()

local ldb = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

BetterPosadaLDB = ldb:NewDataObject("BetterPosada", {
    type = "launcher",
    icon = "Interface\\AddOns\\BetterPosada\\Media\\betterposada_icon.tga",
    OnClick = function(_, button)
        if BetterPosadaFrame:IsShown() then
            BetterPosadaFrame:Hide()
        else
            BetterPosadaFrame:Show()
            UpdateChatDisplay()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cffFFD700BetterPosada|r")
        tooltip:AddLine("Click para abrir/cerrar.")
    end,
})

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if not BetterPosadaDB then BetterPosadaDB = {} end
    icon:Register("BetterPosada", BetterPosadaLDB, BetterPosadaDB)
end)

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_, _, msg, _, _, _, _, _, _, chanName)
    if chanName == BetterPosada_ChannelName then
        return true
    end

    if msg:find("^BP_") then
        return true
    end
end)

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", function(_, _, _, _, _, _, _, _, chanName)
    if chanName == BetterPosada_ChannelName then
        return true
    end
end)


-------------------------------------------------------------
-- /bpreport
-------------------------------------------------------------
SLASH_BPREPORT1 = "/bpreport"

SlashCmdList["BPREPORT"] = function(msg)
    msg = msg and msg:trim() or ""
    if msg == "" then
        local t = UnitName("target")
        if t and UnitIsPlayer("target") then
            BetterPosada_OpenReportWindow(BetterPosada_NormalizeName(t))
        else
            BetterPosada_OpenReportWindow("")
        end
        return
    end
    local who, text = msg:match("^(%S+)%s+(.+)$")
    if not who or not text then
        print("|cffffd700BetterPosada:|r Uso: /bpreport jugador mensaje")
        return
    end

    who = BetterPosada_NormalizeName(who)

    BetterPosada_SaveReport(who, text)

    print("|cff00ff00BetterPosada:|r Reporte guardado para " .. who)
    return
end


-------------------------------------------------------------
-- /bpshowreports
-------------------------------------------------------------
SLASH_BPSHOWREPORTS1 = "/bpshowreports"

SlashCmdList["BPSHOWREPORTS"] = function(msg)
    msg = msg:trim()

    if msg == "" then
        local target = UnitName("target")

        if target and UnitIsPlayer("target") then
            msg = target
        else
            print("|cffffd700BetterPosada:|r Uso: /bpshowreports jugador (o selecciona un TARGET jugador)")
            return
        end
    end

    msg = BetterPosada_NormalizeName(msg)

    BetterPosada_OpenFullReportFor(msg)
end

-------------------------------------------------------------
-- /bpclear
-------------------------------------------------------------
SLASH_BPCLEAR1 = "/bpclearreports"

SlashCmdList["BPCLEAR"] = function(msg)
    if not msg or msg:trim() == "" then
        print("|cffffd700BetterPosada:|r Uso: /bpclearreports jugador")
        return
    end

    local target = msg:match("^(%S+)$")
    if not target then
        print("|cffffd700Uso correcto:|r /bpclearreports jugador")
        return
    end

    target = BetterPosada_NormalizeName(target)

    if not BetterPosadaDB or not BetterPosadaDB.reports or not BetterPosadaDB.reports[target] then
        return
    end

    BetterPosadaDB.reports[target] = nil

    print("|cff00ff00BetterPosada:|r Reportes de " .. target .. " fueron eliminados.")
end

hooksecurefunc("ChatEdit_InsertLink", function(text)
    -- si tu editbox NO existe, salir
    if not BetterPosadaMessageInput then return end

    -- si tu editbox NO tiene foco, salir
    if not BetterPosadaMessageInput:HasFocus() then return end

    -- insertar link en tu editbox
    BetterPosadaMessageInput:Insert(text)
end)