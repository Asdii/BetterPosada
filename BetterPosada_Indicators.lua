----------------------------------------------------------
-- Indicadores de Contenido
----------------------------------------------------------

function BetterPosada_GetIndicatorIcon(msg)
    local m = strlower(msg or "")

    -- Guild
    if m:find("guild") or m:find("recluta") or m:find("hermandad") then
        return "Interface\\Icons\\inv_shirt_guildtabard_01"
    end

    -- ICC
    if m:find("icc") or m:find("farmeable") or m:find("caída del rey") or m:find("sindra") or m:find(" lk") then
        return "Interface\\LFGFrame\\LFGIcon-IcecrownCitadel"
    end

    -- TOC / TOGC
    if m:find("toc ") or m:find("toc25") then
        return "Interface\\Icons\\achievement_reputation_argentcrusader"
    end

    -- RS / SR / Ruby Sanctum
    if m:find("sr ") or m:find("ruby") or m:find("halion")
        or m:find("sr25") or m:find("sr10") then
        return "Interface\\Icons\\spell_fire_moltenblood"
    end

    -- Naxxramas
    if m:find("naxx") then
        return "Interface\\LFGFrame\\LFGIcon-Naxxramas"
    end

    -- Ulduar
    if m:find("ulduar") then
        return "Interface\\Icons\\achievement_dungeon_ulduarraid_misc_03"
    end

    -- VOA
    if (not m:find("escarcha")) and (m:find("voa") or m:find("archavon") or m:find("archa ") or m:find("archa10") or m:find("archa25")
        or m:find("archa 10") or m:find("archa 25")) then
        return "Interface\\Icons\\inv_essenceofwintergrasp"
    end

    -- Comercio (vendo, compro, wts, wtb, etc.)
    if m:find("vendo") or m:find("compro") or m:find("wts ") or m:find("wtb ")
        or m:find("busco ") or m:find("trade ") or m:find("gold ") or m:find("oro ") or m:find("v ") or m:find("c ")
        or m:find(" vende")
        or m:find("vende ") or m:find("compra ") or m:find("encantamiento") or m:find("joyero") or m:find("joyeria")
        or m:find("alquimia") or m:find("sastreria") or m:find("alquimista") or m:find("encantador") or m:find("sastre")
         or m:find("peletero") or m:find("enchant")
    then
        return "Interface\\Icons\\INV_Misc_Coin_01"
    end

    -- Semanal
    if m:find("semanal") or m:find("must die!") or m:find("debe morir!") or m:find("diaria") or m:find(" ojo") or m:find("rdf") then
        return "Interface\\Icons\\inv_misc_frostemblem_01"
    end

    -- Viajeros del tiempo
    if m:find("viajeros del tiempo") then
        return "Interface\\Icons\\spell_holy_borrowedtime"
    end

    -- Templo oscuro
    if m:find("templo oscuro") or m:find("black temple") then
        return "Interface\\Icons\\achievement_boss_illidan"
    end

    -- Fenix
    if m:find("fenix") or m:find("tempestad") then
        return "Interface\\Icons\\Inv_misc_summerfest_brazierorange"
    end

    -- Forja
    if m:find("forja") then
        return "Interface\\Icons\\achievement_boss_forgemaster"
    end

    -- Foso
    if m:find("foso") then
        return "Interface\\Icons\\achievement_dungeon_icecrown_forgeofsouls"
    end

    -- Camara de reflexion
    if m:find("camara") then
        return "Interface\\Icons\\achievement_dungeon_icecrown_hallsofreflection"
    end

    -- Default
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end
