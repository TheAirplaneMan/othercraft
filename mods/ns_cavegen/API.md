# Noordstar caves API

This mod is built in a way to be easy to change the underground world.
The API is written in a way to be very similar to the Minetest API.

## Shapes

Underground caves have varying shapes, and the variable
`noordstar.registered_shapes` contains all those definitions.

For shapes, the following functions are available:

- `ns_cavegen.register_shape(shape def)` Define a new cave shape
- `ns_cavegen.unregister_shape(name)` Remove a defined cave shape
- `ns_cavegen.clear_registered_shapes()` Remove all known cave shapes

Generally, it is recommended to keep the number of cave shapes below 100.
A good number of shapes is 10 for diversity but performance.

The shapes are defined as follows:

```lua
{
    name = "ns_cavegen:bubbles",
    -- Unique name identifying the shape
    -- Namespacing is not required but recommended
    
    noise_params = {
        offset = 0.4,
        scale = 0.6,
        spread = { x = 100, y = 100, z = 100 },
        seed = 248039,
        octaves = 2,
        persistence = 0.6,
        lacunarity = 2.0,
        flags = "eased"
    },
    -- NoiseParams structure describing the perlin noise of the shape
    -- Values below 0 are always wall, values above 1 will always be part of a
    -- cave.
    -- Values in-between are either cave or non-cave depending on the
    -- cave size: lower values are only included in larger caves:
    --
    --     -0.25 -----  0  ---- 0.25 ----- 0.5 ----- 0.75 ----- 1 ----- 1.25
    --             ^         ^         ^          ^        ^          ^
    --             |         |         |          |        |          |
    --       always a wall   |   larger caves     |   most caves      |
    --                       |                    |                   |
    --            massive caves only       smaller caves         always cave

    y_min = -31000,
    y_max = 31000,
    -- Lower and upper limits for cave shapes.
    -- Optional. If absent, the shape is allowed at all heights.

    connectivity_point = 10,
    verticality_point = 40,
    -- Characteristic verticality and connectivity  for the cave shape.
    -- Similar to how biomes are created, these values create 'shape points' on
    -- a voronoi diagram with verticality and connectivity as axes. However,
    -- in contrast with biomes, the voronoi cells aren't strict shape borders:
    -- they slightly overlap, creating smoother changes between cave shapes.
    --
    -- Although the variables can be interpreted differently, the variables
    -- stand for the following:
    --
    --     - Verticality: high vertical caves have large gaps, massive holes
    --                      and great paths leading downwards
    --                    low vertical caves have mostly horizontal corridors
    --                      with relatively little vertical changes
    --
    --     - Connectivity: highly connected caves generally are one massive
    --                      connected cave system, where you can generally
    --                      navigate to other parts of the cave without breaking
    --                      blocks
    --                     lowly connected caves are usually very separate
    --                      pieces, single domes, bubbles or standard shapes
    --
    --
    -- For example:
    --
    --                       |   low verticality   |   high verticality   |
    --    -------------------|---------------------|----------------------|
    --     low connectivity  | a single large dome | a deep sinkhole      |
    --    -------------------|---------------------|----------------------|
    --     high connectivity | abandoned mineshaft | spaghetti tunnels    |
    --    -------------------|---------------------|----------------------|
}
```

## Biomes

Just like the surface world, the underground world uses biomes to decorate their
caves. The cave biomes are independent of the cave shapes.

For shapes, the following functions are available:

- `ns_cavegen.register_biome(biome def)` Define a new cave biome
- `ns_cavegen.unregister_biome(name)` Remove a defined cave biome
- `ns_cavegen.clear_registered_biomes()` Remove all known cave biomes

The biomes are defined as follows:

```lua
{
    name = "ns_cavegen:tundra",
    -- Unique name identifying the biome
    -- Namespacing is not required but recommended

    node_dust = "foo:snow",
    -- Node dropped onto floor after all else is generated

    node_floor = "foo:dirt_with_snow",
    -- Node forming the floor that the player walks on

    node_wall = "foo:ice",
    -- Node forming the side walls of the cave

    node_roof = "foo:bluestone",
    -- Node forming the ceiling of the cave

    node_air = "foo:air",
    -- Nodes filling the inside of the cave. By default, this is air.
    -- You can replace it with e.g. water to make the entire cave a water cave.
    -- Keep in mind that cave biomes can blend, so it might not always look
    -- very smooth.

    y_max = -100,
    y_min = -31000,
    -- Upper and lower limits of the cave biome.
    -- Alternatively you can use xyz limits as shown below.

    max_pos = { x =  31000, y = -100, z =  31000 }
    min_pos = { x = -31000, y = -500, z = -31000 }
    -- xyz limits for biome, an alternative to using `y_min` and `y_max`.
    -- Cave biome is limited to a cuboid defined by these positions.
    -- Any x, y or z field left undefined defaults to -31000 in `min_pos` or
    -- 31000 in `max_pos`.

    heat_point = 0,
    humidity_point = 50,
    -- Characteristic temperature and humidity for the biome.
    -- Just like the Minetest Lua API for biomes, these values create
    -- 'biome points' on a voronoi diagram with heat and humidity as axes.
    -- The resulting voronoi cells determine the distribution of the biomes.
    -- Heat and humidity have an average of 50, vary mostly between 0 and 100
    -- but can exceed these values.
}
```

## Decorations

As a final part of generating the caves, decorations can be added to add unique
structures to cave biomes.

For decorations, the following functions are defined:

- `ns_cavegen.register_decoration(decoration def)` Define a new cave decoration
- `ns_cavegen.clear_registered_decorations()` Remove all known cave decorations

The decorations are defined as follows:

```lua
{
    deco_type = "simple",
    -- Type. "simple" or "schematic" supported

    place_on = "floor",
    -- Side of the cave to place the decoration on. "floor" or "ceiling" supported

    fill_ratio = 0.02,
    -- Percentage of surface nodes on which this decoration will spawn

    biomes = { "ns_cavegen:tundra", "foo:desert" },
    -- List of (cave!) biomes that this decoration will spawn in. Occurs in all
    -- biomes if this is omitted.

    y_min = -31000,
    y_max =  31000,
    -- Lower and upper limits for decoration (inclusive).
    -- These parameters refer to the Y-coordinate of the node where it is
    -- originally chosen to be placed.

    ----- Simple-type parameters

    decoration = "foo:grass",
    -- The node name used as the decoration.
    -- If instead a list of strings, a randomly selected node from the list
    -- is placed as the decoration.

    height = 1,
    -- Decoration height in nodes.
    -- If height_max is not 0, this is the lower limit of a randomly selected
    -- height.
    -- Height can not be over 16.

    height_max = 0,
    -- Upper limit of the randomly selected height.
    -- If absent, the parameter `height` is used as a constant.
    -- Max height will be capped at 16.

    place_offset_y = 0,
    -- Y offset of the decoration base node relative to the standard base node
    -- position.
    -- Can be positive or negative. Default is 0.

    ----- Schematic-type parameters

    schematic = "foobar.mts",
    -- If schematic is a string, it is the filepath relative to the correct
    -- working directory of the specified Minetest schematic file.
    -- Could also be the ID of a previously registered schematic.

    schematic = {
        size = {x = 4, y = 6, z = 4},
        data = {
            {name = "default:cobble", param1 = 255, param2 = 0},
            {name = "default:dirt_with_grass", param1 = 255, param2 = 0},
            {name = "air", param1 = 255, param2 = 0},
              ...
        },
        yslice_prob = {
            {ypos = 2, prob = 128},
            {ypos = 5, prob = 64},
              ...
        },
    },
    -- Alternative schematic specification by supplying a table. The fields
    -- size and data are mandatory whereas yslice_prob is optional.
    -- See 'schematic specifier' in the Minetest Lua API documentation.


    replacements = {["oldname"] = "convert_to", ...},
    -- Map of node names to replace in the schematic after reading it.

    flags = "place_center_x, place_center_y, place_center_z",
    -- Flags for schematic decorations. See 'Schematic attributes'.

    rotation = "90",
    -- Rotation can be "0", "90", "180", "270", or "random"

    place_offset_y = 0,
    -- Y offset of the schematic base node layer relative to the 'place_on'
    -- node.
    -- Can be positive or negative. Default is 0.
    -- Effect is NOT inverted for decorations on the ceiling.
    -- Ignored by 'y_min' and 'y_max' checks, which always refer to the
    -- 'place_on' node.
}
```

## Ores

This mod does not support adding ores to the caves, as this is a feature that
is already well-supported by the Minetest Lua API and doesn't need a mod like
this.
