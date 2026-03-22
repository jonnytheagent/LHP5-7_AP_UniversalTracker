require("scripts/autotracking/location_mapping")

CUR_INDEX = -1
COLLECTED_LOCATION_IDS = {}

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
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then return end
    CUR_INDEX = index
    -- Items will be handled later
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