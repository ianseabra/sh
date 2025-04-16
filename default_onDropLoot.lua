local ec = EventCallback

ec.onDropLoot = function(self, corpse)
    local mType = self:getType()
    local player = Player(corpse:getCorpseOwner())

    if not player or player:getStamina() > 840 then
        local monsterLoot = mType:getLoot()
        local lootMultiplier = 1
        local monsterLevel = self:getMonsterLevel()
        
		--- Extra Loot for Monster Levels ---
        if monsterLevel >= 0 and monsterLevel < 4 then
			-- No Multiplier loot check below how monsterLevel increments loot any question ask me  --
        elseif monsterLevel >= 5 and monsterLevel < 50 then
            lootMultiplier = 1.15
        elseif monsterLevel >= 51 and monsterLevel < 100 then
            lootMultiplier = 1.35
        elseif monsterLevel >= 101 and monsterLevel < 200 then
            lootMultiplier = 1.65
        elseif monsterLevel >= 201 and monsterLevel < 300 then
            lootMultiplier = 1.95
        elseif monsterLevel >= 301 and monsterLevel < 500 then
            lootMultiplier = 2.25
        elseif monsterLevel >= 501 and monsterLevel < 10000 then
            lootMultiplier = 2.70
        end

		--- Extra Loot For Storage of player, so if player kills a monster with level it does an addition example level 501 is 2.70 if storage is 1 then 2.70 + 1.15 = 3.85 ---
        if player:getStorageValue(76855) == 1 then
            lootMultiplier = lootMultiplier + 1.15
		elseif player:getStorageValue(76855) == 2 then
			lootMultiplier = lootMultiplier + 1.35
		elseif player:getStorageValue(76855) == 3 then
			lootMultiplier = lootMultiplier + 1.65
		elseif player:getStorageValue(76855) == 4 then
			lootMultiplier = lootMultiplier + 1.95
		elseif player:getStorageValue(76855) == 5 then
			lootMultiplier = lootMultiplier + 2.25
		elseif player:getStorageValue(76855) == 6 then
			lootMultiplier = lootMultiplier + 2.70
        end


        for i = 1, #monsterLoot do
            for _ = 1, lootMultiplier do
                local additionalItem = corpse:createLootItem(monsterLoot[i])
                if not additionalItem then
                    Spdlog.warn(string.format("[3][Monster:onDropLoot] - Could not add additional loot item to monster: %s, from corpse id: %d.", self:getName(), corpse:getId()))
                end
            end
        end
		--- Add Sliver & Dusts globally to all monsters with 3% chance to appear on any monster ---
        if math.random(1, 100) <= 3 then
            local quantity28343 = math.random(1, 5)
            local specialItem1 = corpse:addItem(28343, quantity28343)
            if not specialItem1 then
                Spdlog.warn(string.format("[3][Monster:onDropLoot] - Could not add special loot item 28343 to monster: %s, from corpse id: %d.", self:getName(), corpse:getId()))
            end

            local quantity28344 = math.random(1, 3)
            local specialItem2 = corpse:addItem(28344, quantity28344)
            if not specialItem2 then
                Spdlog.warn(string.format("[3][Monster:onDropLoot] - Could not add special loot item 28344 to monster: %s, from corpse id: %d.", self:getName(), corpse:getId()))
            end
        end

        local text = ("Loot of %s: %s"):format(mType:getNameDescription(), corpse:getContentDescription())
        local party = player:getParty()
        if party then
            party:broadcastPartyLoot(text)
        else
            player:sendTextMessage(MESSAGE_LOOT, text)
        end
    else
        local text = ("Loot of %s: nothing (due to low stamina)"):format(mType:getNameDescription())
        local party = player:getParty()
        if party then
            party:broadcastPartyLoot(text)
        else
            player:sendTextMessage(MESSAGE_LOOT, text)
        end
    end
end

ec:register()
