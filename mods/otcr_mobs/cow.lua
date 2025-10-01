mobs:register_mob("otcr_mobs:cow", {
	type = "animal",
	passive = true,
	hp_min = 10,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.39, 0.45},
	visual_size = {x=2.8, y=2.8},
	visual = "mesh",
	mesh = "mobs_mc_cow.b3d",
	textures = { {
		"mobs_mc_cow.png",
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
		{name = "otcr_mobs:beef_raw", chance = 1, min = 1, max = 3},
		{name = "mobs:leather", chance = 1, min = 0, max = 2}
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
		"farming:wheat"
	},
	view_range = 8
})

-- where to spawn

if not mobs.custom_spawn_animal then

	mobs:spawn({
		name = "otcr_mobs:cow",
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

mobs:register_egg("otcr_mobs:cow", ("Cow"), "mobs_leather.png")

-- bucket of milk

minetest.register_craftitem(":mobs:bucket_milk", {
	description = ("Bucket of Milk"),
	inventory_image = "mobs_bucket_milk.png",
	stack_max = 1,
	on_use = minetest.item_eat(0, "bucket:bucket_empty"),
	groups = {food_milk = 1, drink = 1}
})


-- Beef

minetest.register_craftitem("otcr_mobs:beef_raw", {
	description = ("Raw Beef"),
	inventory_image = "otcr_mobs_beef_raw.png",
	on_use = minetest.item_eat(2),
	groups = {food_beef = 1}
})

minetest.register_craft({
	type = "cooking",
	output = "otcr_mobs:beef_cooked",
	recipe = "otcr_mobs:beef_raw",
})

minetest.register_craftitem("otcr_mobs:beef_cooked", {
	description = ("Steak"),
	inventory_image = "otcr_mobs_beef_cooked.png",
	on_use = minetest.item_eat(8),
	groups = {food_beef = 1}
})