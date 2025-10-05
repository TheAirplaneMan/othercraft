otcr_under.cave_params = {
	{"cave_1", "-256", "-1750"},
	{"cave_2", "-3501", "-5251"},
	{"cave_3", "-7001", "-8751"},
	{"cave_4", "-10501", "-12251"},
	{"cave_5", "-14001", "-15751"},
	{"cave_6", "-17501", "-19251"},
	{"cave_7", "-21001", "-22751"},
	{"cave_8", "-24501", "-26251"},
	{"cave_9", "-28001", "-29751"},

}

local cave_params = otcr_under.cave_params

for i = 1, #cave_params do
	local name, max, min = unpack(cave_params[i])

	minetest.register_biome({
		name = name,
		node_stone = "default:stone",
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossy_cobble",
		node_dungeon_stair = "stairs:cobble",
		y_max = max,
		y_min = min,
		heat_point = 50,
		humidity_point = 50,
	})
end