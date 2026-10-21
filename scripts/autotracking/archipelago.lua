require("scripts/autotracking/location_mapping")

CUR_INDEX = -1
COLLECTED_LOCATION_IDS = {}

-- AP Item ID -> ability codes granted by that item
local ABILITY_ITEM_MAPPING = {
    [400008] = {"ability_key"},
    [400010] = {"ability_key"},
    [400021] = {"ability_dark_magic"},
    [400029] = {"ability_dark_magic"},
    [400030] = {"ability_dark_magic"},
    [400040] = {"ability_wrench"},
    [400049] = {"ability_dark_magic"},
    [400069] = {"ability_dark_magic"},
    [400070] = {"ability_dark_magic"},
    [400079] = {"ability_dark_magic"},
    [400082] = {"ability_dark_magic"},
    [400083] = {"ability_dark_magic"},
    [400084] = {"ability_dark_magic"},
    [400105] = {"ability_key"},
    [400107] = {"ability_wrench"},
    [400124] = {"ability_dark_magic"},
    [400127] = {"ability_dark_magic"},
    [400130] = {"ability_wrench"},
    [400153] = {"ability_key"},
    [400155] = {"ability_wrench"},
    [400163] = {"ability_dark_magic"},
    [400166] = {"ability_dark_magic"},
    [400174] = {"ability_dark_magic"},
    [400178] = {"ability_dark_magic"},
    [400180] = {"ability_dark_magic"},
    [400183] = {"ability_dark_magic"},
    [400189] = {"ability_dark_magic"},
    [400195] = {"ability_dark_magic"},
    [400208] = {"ability_dark_magic"},
    [400954] = {"ability_super_strength"},
    [400995] = {"ability_pets"},
    [400996] = {"ability_invisibility_cloak"},
    [400998] = {"ability_diffindo"},
    [400999] = {"ability_lumos"},
    [401000] = {"ability_polyjuice_potion"},
    [401001] = {"ability_deluminator"},
    [401002] = {"ability_aguamenti"},
    [401003] = {"ability_focus"},
    [401004] = {"ability_expecto_patronum"},
    [401005] = {"ability_reducto"},
    [401020] = {"ability_apparition"},
    [401024] = {"ability_www_boxes"},
    [401025] = {"ability_spectrespecs"},
    [401026] = {"ability_hermiones_bag"},
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

    -- Reset all abilities granted by Archipelago items
    for _, ability_codes in pairs(ABILITY_ITEM_MAPPING) do
        for _, ability_code in ipairs(ability_codes) do
            local obj = Tracker:FindObjectForCode(ability_code)
            if obj then obj.Active = false end
        end
    end
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

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)