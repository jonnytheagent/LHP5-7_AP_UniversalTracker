require("scripts/autotracking/location_mapping")

CUR_INDEX = -1
COLLECTED_LOCATION_IDS = {}

-- category A: AP Item ID -> Ability Code
local ABILITY_ITEM_MAPPING = {
    [401005] = {"ability_reducto"},
    [401020] = {"ability_apparition"},
    [401002] = {"ability_aguamenti"},
    [401001] = {"ability_deluminator", "ability_polyjuice_potion"},
    [400998] = {"ability_diffindo"},
    [401004] = {"ability_expecto_patronum"},
    [401003] = {"ability_focus"},
    [401026] = {"ability_hermiones_bag"},
    [401025] = {"ability_spectrespecs"},
    [401024] = {"ability_www_boxes"},
}

-- category B: Ability Code -> list of Char Codes that can unlock it
local ABILITY_CHAR_MAPPING = {
    ability_wrench = {
        "Arthur Weasley Playable",
        "Arthur (Torn Suit) Playable",
        "Arthur (Cardigan) Playable",
        "Arthur (Suit) Playable",
    },
    ability_dark_magic = {
        "Alecto Carrow Playable",
        "Amycus Carrow Playable",
        "Antonin Dolohov Playable",
        "Bellatrix Lestrange Playable",
        "Bellatrix (Azkaban) Playable",
        "Death Eater Playable",
        "Dolohov (Workman) Playable",
        "Fenrir Greyback Playable",
        "Grindelwald (Young) Playable",
        "Grindelwald (Old) Playable",
        "Lord Voldemort Playable",
        "Lucius (Death Eater) Playable",
        "Lucius Malfoy Playable",
        "Mrs Black Playable",
        "Pius Thicknesse Playable",
        "Scabior Playable",
        "Snatcher Playable",
        "Thorfinn Rowle Playable",
        "Tom Riddle Playable",
        "Wormtail Playable",
        "Yaxley Playable",
    },
    ability_key = {
        "Bogrod Playable",
        "Mrs Cole Playable",
        "Griphook Playable",
    },
}

function onClear(slot_data)
    COLLECTED_LOCATION_IDS = {}
    CUR_INDEX = -1

    -- Reset all locations
    for _, section_id in pairs(LOCATION_MAPPING) do
        local obj = Tracker:FindObjectForCode(section_id)
        if obj then
            obj.AvailableChestCount = obj.ChestCount
        end
    end

    -- Reset category A abilities
    for ability_code, _ in pairs(ABILITY_ITEM_MAPPING) do
        local obj = Tracker:FindObjectForCode(ability_code)
        if obj then obj.Active = false end
    end

    -- Reset category B abilities
    for ability_code, _ in pairs(ABILITY_CHAR_MAPPING) do
        local obj = Tracker:FindObjectForCode(ability_code)
        if obj then obj.Active = false end
    end

    -- recalculate char abilities if chars already unlocked
    update_char_abilities()
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then return end
    CUR_INDEX = index

    local ability_codes = ABILITY_ITEM_MAPPING[item_id]
    if ability_codes then
        for _, ability_code in ipairs(ability_codes) do
            local obj = Tracker:FindObjectForCode(ability_code)
            if obj then obj.Active = true end
        end
    end
end

function onLocation(location_id, location_name)
    COLLECTED_LOCATION_IDS[location_id] = true
    local section_id = LOCATION_MAPPING[location_id]
    if not section_id then
        print(string.format("onLocation: no mapping for id %s (%s)", location_id, location_name))
        return
    end
    local obj = Tracker:FindObjectForCode(section_id)
    if obj then
        obj.AvailableChestCount = obj.AvailableChestCount - 1
    else
        print(string.format("onLocation: could not find object for %s", section_id))
    end
end

local function update_char_abilities()
    for ability_code, char_codes in pairs(ABILITY_CHAR_MAPPING) do
        local ability = Tracker:FindObjectForCode(ability_code)
        if ability then
            local unlocked = false
            for _, char_code in ipairs(char_codes) do
                local char = Tracker:FindObjectForCode(char_code)
                if char and char.Active then
                    unlocked = true
                    break
                end
            end
            ability.Active = unlocked
        end
    end
end

ScriptHost:AddWatchForCode("char_ability_updater", "*", update_char_abilities)
Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)