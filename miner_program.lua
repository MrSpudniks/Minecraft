--pastebin: 5nKzryyX
--settings--
coords = {
    ["x"] = 1420,
    ["y"] = 310,
    ["z"] = 5666
}
direction = "w"
--settings--

item_coords = {
    ["copper_shard"] = 0,
    ["copper_nugget"] = 0,
    ["copper_ingot"] = 0,
    ["iron_shard"] = 0,
    ["iron_nugget"] = 0,
    ["iron_ingot"] = 0
}

direction_lookup = {
    ["n"] = {
        ["f"] = {"z", -1},
        ["l"] = {"x", 1}
    },
    ["e"] = {
        ["f"] = {"x", 1},
        ["l"] = {"z", -1}
    },
    ["s"] = {
        ["f"] = {"z", 1},
        ["l"] = {"x", -1}
    },
    ["w"] = {
        ["f"] = {"x", -1},
        ["l"] = {"z", 1}
    }
}

function stop(msg)
    if msg == nil then
        msg = "unspecified error"
    end
    --might make some stuff here idk
    error(msg)
end

function update_coords(axis, amount)
local local_axes = direction_lookup[direction]
    if axis == "y" then
        coords[axis] = coords[axis] + amount
    elseif axis == "x" then
        coords[axis] = coords[axis] + amount
    elseif axis == "z" then
        coords[axis] = coords[axis] + amount
    else
        local actual_axis, multiplier = table.unpack(local_axes[axis])
        update_coords(actual_axis, amount * multiplier)
    end
end

function select_item(name)
    for slot = 1, 16 do
        turtle.select(slot)
        if turtle.getItemCount() > 0 and turtle.getItemDetail()["name"] == name then
            return true
        end
    end
    return false
end

function move_sequence(sequence)
    local current_move_start_index = 1
    local moves = {}
    
    for letter = 2, #sequence do
        if tonumber(string.sub(sequence, letter, letter)) == nil then
            moves[#moves + 1] = string.sub(sequence, current_move_start_index, letter - 1)
            current_move_start_index = letter
        end
    end
    moves[#moves + 1] = string.sub(sequence, current_move_start_index, #sequence)
    
    for move = 1, #moves do
        current_move = string.sub(moves[move], 1, 1)
        if current_move == "u" then
            for i = 1, tonumber(string.sub(moves[move], 2)) do
                if not turtle.up() then
                    stop()
                end
                update_coords("y", 1)
            end
        elseif current_move == "d" then
            for i = 1, tonumber(string.sub(moves[move], 2)) do
                if not turtle.down() then
                    stop()
                end
                update_coords("y", -1)
            end
        elseif current_move == "f" then
            for i = 1, tonumber(string.sub(moves[move], 2)) do
                if not turtle.forward() then
                    stop()
                end
                update_coords("f", 1)
            end
        elseif current_move == "b" then
            for i = 1, tonumber(string.sub(moves[move], 2)) do
                if not turtle.back() then
                    stop()
                end
                update_coords("f", -1)
            end
        elseif current_move == "l" then
            turtle.turnLeft()
            for i = 1, tonumber(string.sub(moves[move], 2)) do
                if not turtle.forward() then
                    stop()
                end
                update_coords("l", 1)
            end
            turtle.turnRight()
        elseif current_move == "r" then
            turtle.turnRight()
            for i = 1, tonumber(string.sub(moves[move], 2)) do
                if not turtle.forward() then
                    stop()
                end
                update_coords("l", -1)
            end
            turtle.turnLeft()
        end
    end
end

while true do
    --place miner
    turtle.select(1)
    turtle.placeUp()
    
    --start miner
    while not peripheral.isPresent("top") do
        sleep(1)
    end
    miner = peripheral.wrap("top")
    miner.start()
    
    --place miner importer
    move_sequence("f3u2")
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.select(2)
    turtle.place()
    turtle.turnLeft()
    turtle.turnLeft()
    
    --place energy tanglo
    move_sequence("d2b3l2")
    turtle.select(3)
    turtle.placeUp()
    
    --place coal barrel
    move_sequence("b2u1")
    turtle.select(4)
    turtle.place()
    
    --fill coal barrel
    move_sequence("b1")
    turtle.select(5)
    turtle.place()
    sleep(3)
    turtle.dig()
    move_sequence("f1")
    
    --refuel
    if turtle.getFuelLevel() < 90000 then
        turtle.select(12)
        turtle.suck()
        turtle.refuel()
    end
    
    --place copper
    move_sequence("l1")
    turtle.select(6)
    turtle.place()
    
    --place iron
    move_sequence("l1")
    turtle.select(7)
    turtle.place()
    
    --place coords chest
    move_sequence("l1")
    turtle.select(8)
    turtle.place()
    
    --get turtle data
    move_sequence("b1")
    turtle.select(9)
    turtle.place()
    sleep(8)
    turtle.dig()
    move_sequence("f1")
    
    --suck and sort data
    turtle.select(12)
    while true do
        if not turtle.suck() then
            break
        end
        
        local name = turtle.getItemDetail()["name"]
        if name == "mekanism:shard_copper" or name == "create:copper_nugget" or name == "minecraft:copper_ingot" then
            move_sequence("r2")
            turtle.drop()
            move_sequence("l2")
        else
            move_sequence("r1")
            turtle.drop()
            move_sequence("l1")
        end
    end
    
    --calculate cooper and iron
    if coords["z"] < 0 then
        item_coords["copper_shard"] = 1
    end
    if coords["x"] < 0 then
        item_coords["iron_shard"] = 1
    end
    item_coords["copper_nugget"] = math.floor(math.abs(coords["z"]) / 1000)
    item_coords["iron_nugget"] = math.floor(math.abs(coords["x"]) / 1000)
    
    item_coords["copper_ingot"] = math.floor(math.mod(math.abs(coords["z"]), 1000) / 10)
    item_coords["iron_ingot"] = math.floor(math.mod(math.abs(coords["x"]), 1000) / 10)
    
    --suck copper
    move_sequence("r2")
    turtle.select(13)
    turtle.suck()
    turtle.select(14)
    turtle.suck()
    turtle.select(15)
    turtle.suck()
    turtle.select(16)
    turtle.suck()
    
    --put correct amount of copper in data chest
    move_sequence("l2")
    if item_coords["copper_shard"] > 0 then
        select_item("mekanism:shard_copper")
        turtle.drop()
    end
    if item_coords["copper_nugget"] > 0 then
        select_item("create:copper_nugget")
        turtle.drop(math.min(item_coords["copper_nugget"], 63))
    end
    if item_coords["copper_ingot"] > 0 then
        select_item("minecraft:copper_ingot")
        turtle.drop(math.min(item_coords["copper_ingot"], 64))
    end
    if item_coords["copper_ingot"] > 64 then
        select_item("minecraft:copper_ingot")
        turtle.drop(math.min(item_coords["copper_ingot"] - 64, 35))
    end
    
    --put back remaining copper
    move_sequence("r2")
    turtle.select(13)
    turtle.drop()
    turtle.select(14)
    turtle.drop()
    turtle.select(15)
    turtle.drop()
    turtle.select(16)
    turtle.drop()
  
    --suck iron
    move_sequence("l1")
    turtle.select(13)
    turtle.suck()
    turtle.select(14)
    turtle.suck()
    turtle.select(15)
    turtle.suck()
    turtle.select(16)
    turtle.suck()
  
    --put correct amount of iron in data chest
    move_sequence("l1")
    if item_coords["iron_shard"] > 0 then
        select_item("mekanism:shard_iron")
        turtle.drop()
    end
    if item_coords["iron_nugget"] > 0 then
        select_item("minecraft:iron_nugget")
        turtle.drop(math.min(item_coords["iron_nugget"], 63))
    end
    if item_coords["iron_ingot"] > 0 then
        select_item("minecraft:iron_ingot")
        turtle.drop(math.min(item_coords["iron_ingot"], 64))
    end
    if item_coords["iron_ingot"] > 64 then
        select_item("minecraft:iron_ingot")
        turtle.drop(math.min(item_coords["iron_ingot"] - 64, 35))
    end
  
    --put back remaining iron
    move_sequence("r1")
    turtle.select(13)
    turtle.drop()
    turtle.select(14)
    turtle.drop()
    turtle.select(15)
    turtle.drop()
    turtle.select(16)
    turtle.drop()

    --send data
    move_sequence("l1b1")
    turtle.select(10)
    turtle.place()
    sleep(8)
    turtle.dig()
    move_sequence("f1")
    
    --dig chests
    turtle.select(8)
    turtle.dig()
    move_sequence("r1")
    turtle.select(7)
    turtle.dig()
    move_sequence("r1")
    turtle.select(6)
    turtle.dig()
    move_sequence("r1")
    turtle.select(4)
    turtle.dig()

    --wait for miner to finish
    move_sequence("r2d1f2")
    miner = peripheral.wrap("top")
    while miner.getToMine() > 0 do
        sleep(3)
    end

    --dig remaining machines and move to next area
    turtle.select(1)
    turtle.digUp()
    move_sequence("f2u1")
    turtle.select(2)
    turtle.digUp()
    move_sequence("b2l1")
    turtle.turnLeft()
    turtle.select(3)
    turtle.dig()
    turtle.turnRight()
    move_sequence("r1d1f65")

    --repeat
end
