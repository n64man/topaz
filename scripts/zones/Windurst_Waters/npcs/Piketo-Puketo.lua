-----------------------------------
-- Area: Windurst Waters
--  NPC: Piketo-Puketo
-- Type: Cooking Guild Master
-- !pos -124.012 -2.999 59.998 238
-----------------------------------
local ID = require("scripts/zones/Windurst_Waters/IDs")
require("scripts/globals/crafting")
require("scripts/globals/status")
-----------------------------------

function onTrade(player, npc, trade)
    local signed = player:signedByTrader(player,0)
    local newRank = tradeTestItem(player, npc, trade, tpz.skill.COOKING)

    if
        newRank > 9 and
        player:getCharVar("CookingExpertQuest") == 1 and
        player:hasKeyItem(getRankKeyItem(player,56))
    then
        if signed ~=0 then
            player:setSkillRank(tpz.skill.COOKING, newRank)
            player:startEvent(10014, 0, 0, 0, 0, newRank, 1)
            player:setCharVar("CookingExpertQuest",2)
        else
            player:startEvent(10014, 0, 0, 0, 0, newRank, 0)
        end
    elseif newRank ~= 0 and newRank <=9 then
        player:setSkillRank(tpz.skill.COOKING, newRank)
        player:startEvent(10014, 0, 0, 0, 0, newRank)
    end
end

function onTrigger(player, npc)
    local craftSkill = player:getSkillLevel(tpz.skill.COOKING)
    local testItem = getTestItem(player, npc, tpz.skill.COOKING)
    local guildMember = isGuildMember(player, 4)
    local rankCap = getCraftSkillCap(player, 56)
    local expertQuestStatus = 0
    local Rank = player:getSkillRank(56)
    local realSkill = (craftSkill - Rank) / 32
    if (guildMember == 1) then guildMember = 150995375; end
    if player:getCharVar("CookingExpertQuest") == 1 then
        if player:hasKeyItem(getRankKeyItem(player,56)) then
            expertQuestStatus = 550
        else
            expertQuestStatus = 600
        end
    end

    if expertQuestStatus == 550 then
        --[[  Feeding the proper parameter currently hangs the client in cutscene. This may
              possibly be due to an unimplemented packet or function (display recipe?) Work
              around to present dialog to player to let them know the trade is ready to be
              received by triggering with lower rank up parameters.  ]]--
        player:showText(npc, 7260)
        player:showText(npc, 7262)
        player:startEvent(10013, testItem, realSkill, 44, guildMember, 0, 0, 0, 0)
    else
        player:startEvent(10013, testItem, realSkill, rankCap, guildMember, expertQuestStatus, 0, 0, 0)
    end
end

-- 978  983  980  981  10013  10014
function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    local guildMember = isGuildMember(player, 4)

    if (csid == 10013 and option == 2) then
        if guildMember == 1 then
            player:setCharVar("CookingExpertQuest",1)
        end
    elseif (csid == 10013 and option == 1) then
        local crystal = 4096 -- fire crystal
        if (player:getFreeSlotsCount() == 0) then
            player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, crystal)
        else
            player:addItem(crystal)
            player:messageSpecial(ID.text.ITEM_OBTAINED, crystal)
            signupGuild(player, guild.cooking)
        end
    end
end
