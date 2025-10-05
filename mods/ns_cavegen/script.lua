-- This file is executed in the mapgen environment.

-- Average size of each cave biome
local BIOME_SIZE = { x = 250, y = 250, z = 250 }

-- Average step size of connectivity params
-- Given that connectivity is mostly a horizontal feature, it mostly changes
-- on a vertical scale, and barely on a horizontal scale.
local CONNECTIVITY_BLOB = { x =  250, y =  100, z =  250 }

-- Point that is so out of the normal connectivity/verticality scope (0 - 100)
-- that it is only selected when no other items are registered.
local OUTLANDISH_POINT = -1e3

-- Several seeds for mapgen
local SEED_CONNECTIVITY   =  297948
local SEED_HEAT           =  320523
local SEED_HUMIDITY       = 9923473
local SEED_VERTICALITY    =   35644

-- Average step size of verticality params
-- Given that verticality is mostly a vertical feature, it mostly changes on a
-- horizontal scale, and barely on a vertical scale.
local VERTICALITY_BLOB = { x =  100, y =  250, z =  100 }

-- Lower bound for cave generation
local WORLD_MINP = { x = -1e6, y = -1e6, z = -1e6 }

-- Upper bound for cave generation
local WORLD_MAXP = { x =  1e6, y =  1e6, z =  1e6 }

local WORLD_DEPTH = -60

local internal = {}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------- INTERNAL API ---------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function internal.cave_vastness(pos)
    local v = ns_cavegen.cave_vastness(pos)

    if not v then
        return 0
    elseif v < 0 then
        return 0
    elseif v > 1 then
        return 1
    else
        return v
    end
end

-- Classify all nodes in the chunk into what they are
function internal.classify_nodes(used_shapes, minp, maxp)
    local sminp = vector.offset(minp,  1,  1,  1)
    local smaxp = vector.offset(maxp, -1, -1, -1)
    local sva = VoxelArea(sminp, smaxp)
    local va = VoxelArea(minp, maxp)

    local ceiling_decos = {}
    local ceilings = {}
    local contents = {}
    local floor_decos = {}
    local floors = {}
    local walls = {}
    
    for i in sva:iterp(sminp, smaxp) do
        local pos = sva:position(i)

        if used_shapes[va:index(pos.x, pos.y, pos.z)] == true then
            -- Part of cave
            if not used_shapes[va:index(pos.x, pos.y + 1, pos.z)] then
                table.insert(ceiling_decos, i)
            elseif not used_shapes[va:index(pos.x, pos.y - 1, pos.z)] then
                table.insert(floor_decos, i)
            else
                table.insert(contents, i)
            end
        else
            -- Not part of cave
            if used_shapes[va:index(pos.x, pos.y + 1, pos.z)] then
                table.insert(floors, i)
            elseif used_shapes[va:index(pos.x, pos.y - 1, pos.z)] then
                table.insert(ceilings, i)
            elseif used_shapes[va:index(pos.x - 1, pos.y, pos.z)] then
                table.insert(walls, i)
            elseif used_shapes[va:index(pos.x + 1, pos.y, pos.z)] then
                table.insert(walls, i)
            elseif used_shapes[va:index(pos.x, pos.y, pos.z - 1)] then
                table.insert(walls, i)
            elseif used_shapes[va:index(pos.x, pos.y, pos.z + 1)] then
                table.insert(walls, i)
            end
        end
    end

    return {
        ceiling_decos = ceiling_decos,
        ceilings = ceilings,
        contents = contents,
        floor_decos = floor_decos,
        floors = floors,
        walls = walls,
    }
end

function internal.clean_biome_def(def)
    assert(type(def) == "table")
    assert(type(def.name) == "string")
    assert(type(def.heat_point) == "number")
    assert(type(def.humidity_point) == "number")

    def.y_min = def.y_min or (def.min_pos and def.min_pos.y) or WORLD_MINP.y
    def.y_max = def.y_max or (def.max_pos and def.max_pos.y) or WORLD_MAXP.y

    def.min_pos = def.min_pos or { x = WORLD_MINP.x, y = def.y_min, z = WORLD_MINP.z }
    def.max_pos = def.max_pos or { x = WORLD_MAXP.x, y = def.y_max, z = WORLD_MAXP.z }

    assert(type(def.y_min) == "number")
    assert(type(def.y_max) == "number")
    assert(type(def.min_pos) == "table")
    assert(type(def.max_pos) == "table")
    assert(type(def.min_pos.x) == "number")
    assert(type(def.max_pos.x) == "number")
    assert(type(def.min_pos.y) == "number")
    assert(type(def.max_pos.y) == "number")
    assert(type(def.min_pos.z) == "number")
    assert(type(def.max_pos.z) == "number")

    def.node_air = def.node_air or "air"

    assert(def.node_dust == nil or type(def.node_dust) == "string")
    assert(def.node_floor == nil or type(def.node_floor) == "string")
    assert(def.node_wall == nil or type(def.node_wall) == "string")
    assert(def.node_roof == nil or type(def.node_roof) == "string")
    assert(type(def.node_air) == "string")

    return def
end

function internal.clean_deco_def(def)
    def.deco_type = def.deco_type or "simple"
    def.place_on = def.place_on or "floor"
    def.y_min = def.y_min or WORLD_MINP.y
    def.y_max = def.y_max or WORLD_MAXP.y

    assert(def.deco_type == "simple" or def.deco_type == "schematic")
    assert(def.place_on == "floor" or def.place_on == "ceiling")
    assert(type(def.fill_ratio) == "number")
    assert(def.biomes == nil or type(def.biomes) == "table")

    if def.deco_type == "simple" then
        def.height = def.height or 1
        def.height_max = def.height_max or def.height
        def.place_offset_y = def.place_offset_y or 0

        assert(type(def.deco_type) == "string")
        assert(type(def.height) == "number")
        assert(type(def.height_max) == "number")
        assert(type(def.place_offset_y) == "number")

    elseif def.deco_type == "schematic" then
        def.replacements = def.replacements or {}
        def.place_offset_y = def.place_offset_y or 0

        assert(type(def.schematic) == "string" or type(def.schematic) == "table")
        assert(type(def.replacements) == "table")
        
        assert(def.rotation == "0" or def.rotation == "90" or def.rotation == "180" or def.rotation == "270" or def.rotation == "random")
        assert(type(def.place_offset_y) == "number")
    end

    return def
end

function internal.clean_shape_def(def)
    assert(
        type(def) == "table",
        "Shape def is meant to be a table type"
    )
    assert(type(def.name) == "string", "Shape name is meant to be a string")
    assert(type(def.connectivity_point) == "number")
    assert(type(def.verticality_point) == "number")

    def.y_min = def.y_min or WORLD_MINP.y
    def.y_max = def.y_max or WORLD_MAXP.y

    assert(type(def.y_min) == "number")
    assert(type(def.y_max) == "number")
    assert(def.noise_params == nil or type(def.noise_params) == "table")

    return def
end

function internal.clear_registered_biomes()
    ns_cavegen.registered_biomes = {}
end

function internal.clear_registered_decorations()
    ns_cavegen.registered_decorations = {}
end

function internal.clear_registered_shapes()
    ns_cavegen.registered_shapes = {}
end

-- Get connectivity noise params
function internal.connectivity_noise_params()
    local shapes = 0
    for _, _ in pairs(ns_cavegen.registered_shapes) do
        shapes = shapes + 1
    end
    local factor = math.max(1, math.abs(shapes) ^ 0.5)

    return {
        offset = 50,
        scale = 50,
        spread = {
            x = factor * CONNECTIVITY_BLOB.x,
            y = factor * CONNECTIVITY_BLOB.y,
            z = factor * CONNECTIVITY_BLOB.z,
        },
        seed = SEED_CONNECTIVITY,
        octaves = 2,
        persistence = 0.2,
        lacunarity = 2.0,
        flags = "eased"
    }
end

-- Get a default cave biome in case no biomes are registered
function internal.default_biome()
    return internal.clean_biome_def(
        { name = "ns_cavegen:default_biome"
        , heat_point = OUTLANDISH_POINT
        , humidity_point = OUTLANDISH_POINT
        }
    )
end

-- Get a default cave shape in case no shapes are registered
function internal.default_shape()
    return internal.clean_shape_def(
        { name = "ns_cavegen:none"
        , connectivity_point = OUTLANDISH_POINT
        , verticality_point = OUTLANDISH_POINT
        }
    )
end

-- Get a (sorta) Euclidian distance. The exact distance doesn't matter,
-- it just needs to correctly determine whichever value is closer in a
-- Euclidian space. Consequently, the square root is ignored as optimization.
function internal.euclidian(x1, x2, y1, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

-- For each node, determine which cave biome they're in.
function internal.find_biome_allocations(heat, humidity, va)
    assert(#heat == #humidity)

    local allocs = {}
    local default_biome = internal.default_biome()

    for i = 1, #heat, 1 do
        local e, u = heat[i], humidity[i]
        local d = internal.euclidian(
            e, default_biome.heat_point,
            u, default_biome.humidity_point
        )
        local biome_name

        -- Find the appropriate biome
        for name, def in pairs(ns_cavegen.registered_biomes) do
            local def_d = internal.euclidian(
                e, def.heat_point, u, def.humidity_point
            )

            if def_d < d then
                local pos = va:position(i)
                local contains_x = def.min_pos.x <= pos.x and pos.x <= def.max_pos.x
                local contains_y = def.min_pos.y <= pos.y and pos.y <= def.max_pos.y
                local contains_z = def.min_pos.z <= pos.z and pos.z <= def.max_pos.z

                if contains_x and contains_y and contains_z then
                    d = def_d
                    biome_name = name
                end
            end
        end

        allocs[i] = biome_name
    end

    return allocs
end

-- For each node, determine which cave shape they follow.
function internal.find_shape_allocations(connectivity, verticality, va)
    assert(#connectivity == #verticality)

    local allocs = {}
    local default_shape = internal.default_shape()

    for i = 1, #connectivity, 1 do
        local c, v = connectivity[i], verticality[i]
        local d = internal.euclidian(
            c, default_shape.connectivity_point,
            v, default_shape.verticality_point
        )
        local shape_name

        -- Find the appropriate shape
        for name, def in pairs(ns_cavegen.registered_shapes) do
            local def_d = internal.euclidian(
                c, def.connectivity_point, v, def.verticality_point
            )

            if def_d < d then
                local y = va:position(i).y

                if def.y_min <= y and y <= def.y_max then
                    d = def_d
                    shape_name = name
                end
            end
        end

        -- Assign the chosen name
        allocs[i] = shape_name
    end

    return allocs
end

-- Once it has been figured out which node belongs to which shape,
-- get noise values from the respective shapes.
-- This function does its operations in-place.
function internal.find_shape_values(used_shapes, minp, maxp, va)
    -- Cache shapes so they don't need to be recalculated.
    local captured_shapes = {}
    local default_shape = internal.default_shape()

    for i in va:iterp(minp, maxp) do
        -- Get shape values per item
        local name = used_shapes[i]
        local shape

        if name == nil then
            shape = default_shape
        else
            shape = ns_cavegen.registered_shapes[name]
        end

        if captured_shapes[shape] == nil then
            -- minetest.debug("Generating new shape! " .. shape.name)
            captured_shapes[shape] = internal.generate_shape(shape, minp, maxp, va)
        end

        used_shapes[i] = captured_shapes[shape][i]
        if used_shapes[i] == nil then
            error(
                "Noise value ended up nil unexpectedly: i = " .. i .. ", shape = " .. shape.name
            )
        end
    end

    -- minetest.debug("Finished generating shapes.")
end

function internal.generate_connectivity_noise(minp, maxp)
    return internal.generate_perlin_noise(
        internal.connectivity_noise_params(), minp, maxp
    )
end

function internal.generate_heat_noise(minp, maxp)
    return internal.generate_perlin_noise(
        internal.heat_noise_params(), minp, maxp
    )
end

function internal.generate_humidity_noise(minp, maxp)
    return internal.generate_perlin_noise(
        internal.humidity_noise_params(), minp, maxp
    )
end

-- Generate Perlin noise within given boundaries
function internal.generate_perlin_noise(noiseparams, minp, maxp)
    local size = {
        x = 1 + maxp.x - minp.x,
        y = 1 + maxp.y - minp.y,
        z = 1 + maxp.z - minp.z,
    }

    return PerlinNoiseMap(noiseparams, size):get_3d_map_flat(minp)
end

function internal.generate_shape(def, minp, maxp, va)
    -- Get random noise if noise_params are given
    if def.noise_params then
        return internal.generate_perlin_noise(def.noise_params, minp, maxp)
    else
        local noise_flat = {}

        for i in va:iterp(minp, maxp) do
            noise_flat[i] = 0
        end

        return noise_flat
    end
end

-- Generate verticality noise within given boundaries
function internal.generate_verticality_noise(minp, maxp)
    return internal.generate_perlin_noise(
        internal.verticality_noise_params(), minp, maxp
    )
end

-- Get the noise params for the cave biome temperature.
function internal.heat_noise_params()
    return {
        offset = 50,
        scale = 50,
        spread = BIOME_SIZE,
        seed = SEED_HEAT,
        octaves = 2,
        persistence = 0.1,
        lacunarity = 2.0,
        flags = ""
    }
end

-- Get the noise params for the cave biome humidity.
function internal.humidity_noise_params()
    return { 
        offset = 50,
        scale = 50,
        spread = BIOME_SIZE,
        seed = SEED_HUMIDITY,
        octaves = 2,
        persistence = 0.1,
        lacunarity = 2.0,
        flags = ""
    }
end

function internal.log_classified_nodes(classified_nodes)
    minetest.debug("Found " .. #classified_nodes.ceiling_decos .. " ceiling decorations")
    minetest.debug("Found " .. #classified_nodes.ceilings .. " ceiling nodes")
    minetest.debug("Found " .. #classified_nodes.contents .. " content nodes")
    minetest.debug("Found " .. #classified_nodes.floors .. " floor nodes")
    minetest.debug("Found " .. #classified_nodes.floor_decos .. " floor decorations")
    minetest.debug("Found " .. #classified_nodes.walls .. " wall nodes")
end

-- Take all necessary steps to execute the mapgen
function internal.mapgen(vm, minp, maxp, blockseed)
    -- Create bordered VoxelArea.
    -- The point of this is so walls and ceilings can be determined using
    -- bordering nodes in different chunks.
    local bminp = vector.offset(minp, -1, -1, -1)
    local bmaxp = vector.offset(maxp,  1,  1,  1)

    -- Initiate VoxelArea objects
    local va = VoxelArea(vm:get_emerged_area())
    local bva = VoxelArea(bminp, bmaxp)
    local sva = VoxelArea(minp, maxp)

    -- Set seed
    math.randomseed(blockseed)

    -- Find cave shape params
    local connectivity = internal.generate_connectivity_noise(bminp, bmaxp)
    local verticality = internal.generate_verticality_noise(bminp, bmaxp)

    -- Draw cave shapes
    local used_shapes = internal.find_shape_allocations(connectivity, verticality, bva)
    internal.find_shape_values(used_shapes, bminp, bmaxp, bva)
    internal.shape_to_air(used_shapes, bminp, bmaxp, bva)

    -- Find cave biome params
    local heat = internal.generate_heat_noise(minp, maxp)
    local humidity = internal.generate_humidity_noise(minp, maxp)

    -- Classify various nodes as walls, floors, ceilings
    local classified_nodes = internal.classify_nodes(used_shapes, bminp, bmaxp)
    -- internal.log_classified_nodes(classified_nodes)

    -- Draw cave biomes
    local used_biomes = internal.find_biome_allocations(heat, humidity, sva)

    -- Manipulate `data` table by adding classified nodes based on which biome
    -- they're in.
    local data = vm:get_data()
    local ground = { [ minetest.CONTENT_AIR ] = false }

    internal.write_classified_node(
        data, va, used_biomes, classified_nodes.ceilings, sva, "node_roof",
        ground
    )
    internal.write_classified_node(
        data, va, used_biomes, classified_nodes.contents, sva, "node_air",
        ground
    )
    internal.write_classified_node(
        data, va, used_biomes, classified_nodes.floors, sva, "node_floor",
        ground
    )
    internal.write_classified_node(
        data, va, used_biomes, classified_nodes.walls, sva, "node_wall",
        ground
    )

    -- Place floor decorations
    -- In case the dust has not been defined, place air nodes first
    internal.write_classified_node(
        data, va, used_biomes, classified_nodes.floor_decos, sva, "node_air",
        ground
    )
    internal.write_classified_node(
        data, va, used_biomes, classified_nodes.floor_decos, sva, "node_dust",
        ground
    )
    local claimed_floor = internal.write_simple_floor_decorations(
        data, va, used_biomes, classified_nodes.floor_decos, sva
    )

    -- Place ceiling decorations
    internal.write_classified_node(
        data, va, used_biomes, classified_nodes.ceiling_decos, sva, "node_air",
        ground
    )
    local claimed_ceiling = internal.write_simple_ceiling_decorations(
        data, va, used_biomes, classified_nodes.ceiling_decos, sva
    )

    vm:set_data(data)

    -- Set schematic decorations
    internal.write_schematic_floor_decoration(
        vm, used_biomes, classified_nodes.floor_decos, sva, claimed_floor
    )
    internal.write_schematic_ceiling_decoration(
        vm, used_biomes, classified_nodes.ceiling_decos, sva, claimed_ceiling
    )

    -- vm:write_to_map()
end

-- Register a new biome
function internal.register_biome(biome)
    biome = internal.clean_biome_def(biome)
    ns_cavegen.registered_biomes[biome.name] = biome
end

-- Register a new decoration
function internal.register_decoration(deco)
    table.insert(
        ns_cavegen.registered_decorations,
        internal.clean_deco_def(deco)
    )
end

-- Register a new shape
function internal.register_shape(shape)
    shape = internal.clean_shape_def(shape)
    ns_cavegen.registered_shapes[shape.name] = shape
end

-- Convert all shape noise into clarifications whether a node is wall or air.
-- This function does its operations in-place.
function internal.shape_to_air(noise_values, minp, maxp, va)
    for i in va:iterp(minp, maxp) do
        local vastness = internal.cave_vastness(va:position(i))

        if noise_values[i] == nil then
            error(
                "Noise value ended up nil unexpectedly"
            )
        elseif noise_values[i] >= 1 - vastness then
            noise_values[i] = true
        else
            noise_values[i] = false
        end
    end
end

-- Get verticality noise params
function internal.verticality_noise_params()
    local shapes = 0
    for _, _ in pairs(ns_cavegen.registered_shapes) do
        shapes = shapes + 1
    end
    local factor = math.max(1, math.abs(shapes) ^ 0.5)

    return {
        offset = 50,
        scale = 50,
        spread = {
            x = factor * VERTICALITY_BLOB.x,
            y = factor * VERTICALITY_BLOB.y,
            z = factor * VERTICALITY_BLOB.z,
        },
        seed = SEED_VERTICALITY,
        octaves = 2,
        persistence = 0.2,
        lacunarity = 2.0,
        flags = "eased"
    }
end

function internal.write_classified_node(vm_data, va, used_biomes, classified_nodes, small_va, biome_key, ground_content_nodes)
    local default_biome = internal.default_biome()

    local biome_to_id = {}
    if default_biome[biome_key] == nil then
        biome_to_id[default_biome.name] = ""
    else
        biome_to_id[default_biome.name] = minetest.get_content_id(default_biome[biome_key])
    end

    for _, i in ipairs(classified_nodes) do
        local pos = small_va:position(i)
        local biome = used_biomes[i] or default_biome.name

        if biome_to_id[biome] == nil then
            local biome_def

            if biome == default_biome.name then
                biome_def = default_biome
            else
                biome_def = ns_cavegen.registered_biomes[biome] or default_biome
            end

            if biome_def[biome_key] == nil then
                biome_to_id[biome] = ""
            else
                biome_to_id[biome] = minetest.get_content_id(biome_def[biome_key]) or ""
            end
        end

        local content_id = biome_to_id[biome]

        if type(content_id) == "number" then
            local vi = va:index(pos.x, pos.y, pos.z)
            local vm_node = vm_data[vi]

            if ground_content_nodes[vm_node] == nil then
                local name = minetest.get_name_from_content_id(content_id)
                ground_content_nodes[vm_node] = minetest.registered_nodes[name].is_ground_content or true
            end

            if ground_content_nodes[vm_node] then
                vm_data[vi] = content_id
            end
        elseif content_id == "air" then
            minetest.debug("Biome " .. biome .. "||| BREAAAK")
            break
        elseif content_id ~= "" and content_id ~= nil and content_id ~= "air" then
            minetest.debug("Encountered content ID " .. content_id)
        end
    end
end

function internal.write_schematic_ceiling_decoration(vmanip, used_biomes, classified_nodes, sva, claimed_spots)
    for _, def in pairs(ns_cavegen.registered_decorations) do
        if def.deco_type == "schematic" and def.place_on == "ceiling" then
            -- Place the decoration, if they're in the appropriate biome
            for _, i in ipairs(classified_nodes) do
                local good_biome = def.biomes == nil
                local unclaimed_spot = true

                for _, ci in ipairs(claimed_spots) do
                    if ci == i then
                        unclaimed_spot = false
                        break
                    end
                end

                if unclaimed_spot and not good_biome then
                    local current_biome = used_biomes[i]
                    for _, name in ipairs(def.biomes) do
                        if name == current_biome then
                            good_biome = true
                            break
                        end
                    end
                end

                if unclaimed_spot and good_biome and math.random() < def.fill_ratio then
                    -- Automatically place the top at the top of the cave
                    local pos = sva:position(i)
                    local h = def.schematic

                    if type(def.schematic) == "string" then
                        h = minetest.read_schematic(h, {})

                        if type(h) == "nil" then
                            error("Could not find schematic! Perhaps it the filename is incorrect?")
                        end
                    end

                    h = h.size.y

                    minetest.place_schematic_on_vmanip(vmanip,
                        { x = pos.x, y = pos.y - h + 1 + def.place_offset_y, z = pos.z },
                        def.schematic, def.rotation, def.replacement, true,
                        def.flags
                    )

                    table.insert(claimed_spots, i)
                end
            end
        end
    end

    return claimed_spots
end

function internal.write_schematic_floor_decoration(vmanip, used_biomes, classified_nodes, sva, claimed_spots)
    for _, def in pairs(ns_cavegen.registered_decorations) do
        if def.deco_type == "schematic" and def.place_on == "floor" then
            -- Place the decoration, if they're in the appropriate biome
            for _, i in ipairs(classified_nodes) do
                local good_biome = def.biomes == nil
                local unclaimed_spot = true

                for _, ci in ipairs(claimed_spots) do
                    if ci == i then
                        unclaimed_spot = false
                        break
                    end
                end

                if unclaimed_spot and not good_biome then
                    local current_biome = used_biomes[i]
                    for _, name in ipairs(def.biomes) do
                        if name == current_biome then
                            good_biome = true
                            break
                        end
                    end
                end

                if unclaimed_spot and good_biome and math.random() < def.fill_ratio then
                    minetest.place_schematic_on_vmanip(
                        vmanip, sva:position(i), def.schematic, def.rotation,
                        def.replacement, true, def.flags
                    )

                    table.insert(claimed_spots, i)
                end
            end
        end
    end

    return claimed_spots
end

function internal.write_simple_ceiling_decorations(vm_data, va, used_biomes, classified_nodes, sva)
    local claimed_spots = {}

    for _, def in pairs(ns_cavegen.registered_decorations) do
        if def.deco_type == "simple" and def.place_on == "ceiling" then
            -- Place the decoration, if they're in the appropriate biome.
            for _, i in ipairs(classified_nodes) do
                local pos = sva:position(i)
                local good_biome = def.biomes == nil
                local unclaimed_spot = true

                for _, ci in ipairs(claimed_spots) do
                    if ci == i then
                        unclaimed_spot = false
                        break
                    end
                end

                if not good_biome and unclaimed_spot then
                    local current_biome = used_biomes[i]
                    for _, name in ipairs(def.biomes) do
                        if name == current_biome then
                            good_biome = true
                            break
                        end
                    end
                end

                if unclaimed_spot and good_biome and math.random() < def.fill_ratio then
                    -- Determine the height
                    local height = def.height
                    if def.height_max > height then
                        height = math.min(
                            16, math.random(def.height, def.height_max)
                        )
                    end

                    -- Place the structure!
                    for h = 1, height, 1 do
                        local y = pos.y - h + def.place_offset_y + 1

                        if sva:contains(pos.x, y, pos.z) then
                            vm_data[va:index(pos.x, y, pos.z)] = minetest.get_content_id(def.decoration)
                        end
                    end

                    table.insert(claimed_spots, i)
                end
            end
        end
    end

    return claimed_spots
end

function internal.unregister_biome(name)
    ns_cavegen.registered_biomes[name] = nil
end

function internal.unregister_shape(name)
    ns_cavegen.registerd_shapes[name] = nil
end

function internal.write_simple_floor_decorations(vm_data, va, used_biomes, classified_nodes, sva)
    local claimed_spots = {}

    for _, def in pairs(ns_cavegen.registered_decorations) do
        if def.deco_type == "simple" and def.place_on == "floor" then
            -- Place the decoration, if they're in the appropriate biome.
            for _, i in ipairs(classified_nodes) do
                local pos = sva:position(i)
                local good_biome = def.biomes == nil
                local unclaimed_spot = true

                for _, ci in ipairs(claimed_spots) do
                    if ci == i then
                        unclaimed_spot = false
                        break
                    end
                end

                if unclaimed_spot and not good_biome then
                    local current_biome = used_biomes[i]
                    for _, name in ipairs(def.biomes) do
                        if name == current_biome then
                            good_biome = true
                            break
                        end
                    end
                end

                if unclaimed_spot and good_biome and math.random() < def.fill_ratio then
                    -- Determine the height
                    local height = def.height
                    if def.height_max > height then
                        height = math.min(
                            16, math.random(def.height, def.height_max)
                        )
                    end
                    
                    -- Place the structure!
                    for h = 1, height, 1 do
                        local y = pos.y + h + def.place_offset_y - 1

                        if sva:contains(pos.x, y, pos.z) then
                            vm_data[va:index(pos.x, y, pos.z)] = minetest.get_content_id(def.decoration)
                        end
                    end

                    table.insert(claimed_spots, i)
                end
            end
        end
    end

    return claimed_spots
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--------------------------------- PUBLIC API ----------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

minetest.register_on_generated(internal.mapgen)

ns_cavegen = {
    cave_vastness = function(pos)
        if pos.y > 0 or pos.y < WORLD_DEPTH then
            return 0
        end

        local y = math.abs(pos.y)
        local d = math.abs(WORLD_DEPTH / 2)
        return 1 - (math.abs(y - d) / d)
    end,

    clear_registered_biomes = internal.clear_registered_biomes,

    clear_registered_decorations = internal.clear_registered_decorations,

    clear_registered_shapes = internal.clear_registered_shapes,

    register_biome = internal.register_biome,

    register_decoration = internal.register_decoration,

    register_shape = internal.register_shape,

    registered_biomes = {},

    registered_decorations = {},

    registered_shapes = {},

    unregister_biome = internal.unregister_biome,

    unregister_shape = internal.unregister_shape,
}

-- dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/lua/register.lua")