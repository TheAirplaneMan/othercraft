otcr_under.nether_params = {
	{"nether_1", "-1751", "-3500"},
	{"nether_2", "-5252", "-7000"},
	{"nether_3", "-8752", "-10500"},
	{"nether_4", "-12252", "-14000"},
	{"nether_5", "-14002", "-17500"},
	{"nether_6", "-19252", "-21000"},
	{"nether_7", "-22752", "-24500"},
	{"nether_8", "-26252", "-28000"},
	{"nether_9", "-29752", "-31000"},

}

local nether_params = otcr_under.nether_params

for i = 1, #nether_params do
	local name, max, min = unpack(nether_params[i])

	minetest.register_biome({
		name = name,
		node_stone = "default:netherrock",
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossy_cobble",
		node_dungeon_stair = "stairs:cobble",
		y_max = max,
		y_min = min,
		heat_point = 50,
		humidity_point = 50,
	})
end