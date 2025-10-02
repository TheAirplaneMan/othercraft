mobs:register_mob("otcr_mobs:chicken", {
	type = "animal",
	passive = true,
	hp_min = 4,
	hp_max = 4,
	armor = 100,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.69, 0.2},
	visual_size = {x=2.2, y=2.2},
	visual = "mesh",
	mesh = "mobs_mc_chicken.b3d",
	textures = { {
		"mobs_mc_chicken.png",
		"blank.png",
	}, },
	makes_footstep_sound = true,
--	sounds = {
--		random = "mobs_cow",
--	},
	walk_velocity = 2,
	jump = true,
	jump_height = 6,
	pushable = true,
	drops = {
		{name = "otcr_mobs:chicken_raw", chance = 1, min = 1, max = 3},
		{name = "otcr_mobs:feather", chance = 1, min = 0, max = 2}
	},
	water_damage = 0.01,
	lava_damage = 4,
	light_damage = 0,
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = {
		"farming:wheat_seed"
	},
	view_range = 8
})

-- where to spawn

if not mobs.custom_spawn_animal then

	mobs:spawn({
		name = "otcr_mobs:chicken",
		nodes = {"default:dirt_with_grass"},
		min_light = 14,
		interval = 60,
		chance = 4000,
		min_height = 1,
		max_height = 256,
		day_toggle = true
	})
end

-- spawn egg

mobs:register_egg("otcr_mobs:chicken", ("Spawn Chicken"), "default_red_dirt.png", 1)




minetest.register_craftitem("otcr_mobs:feather", {
	description = ("Feather"),
	inventory_image = "mobs_feather.png"
})


-- Chicken Meat

minetest.register_craftitem("otcr_mobs:chicken_raw", {
	description = ("Raw Chicken"),
	inventory_image = "otcr_mobs_chicken_raw.png",
	on_use = minetest.item_eat(-2),
	groups = {food_chicken = 1}
})

minetest.register_craft({
	type = "cooking",
	output = "otcr_mobs:chicken_cooked",
	recipe = "otcr_mobs:chicken_raw",
})

minetest.register_craftitem("otcr_mobs:chicken_cooked", {
	description = ("Cooked Chicken"),
	inventory_image = "otcr_mobs_chicken_cooked.png",
	on_use = minetest.item_eat(6),
	groups = {food_chicken = 1}
})