mobs:register_mob("otcr_mobs:pig", {
	type = "animal",
	passive = true,
	hp_min = 10,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 0.865, 0.45},
	visual_size = {x=2.5, y=2.5},
	visual = "mesh",
	mesh = "mobs_mc_pig.b3d",
	textures = {
		{"mobs_mc_pig.png"}
	},
	makes_footstep_sound = true,
--	sounds = {
--		random = "mobs_pig",
--	},
	walk_velocity = 2,
	jump = true,
	jump_height = 6,
	pushable = true,
	drops = {
		{name = "otcr_mobs:pork_raw", chance = 1, min = 1, max = 3},
		{name = "mobs:leather", chance = 1, min = 0, max = 2}
	},
	water_damage = 0.01,
	lava_damage = 4,
	light_damage = 0,
	animation = {
		stand_speed = 40,
		walk_speed = 40,
		run_speed = 50,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
	},
	follow = {
		"farming:wheat"
	},
	view_range = 8
})

-- where to spawn

if not mobs.custom_spawn_animal then

	mobs:spawn({
		name = "otcr_mobs:pig",
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

mobs:register_egg("otcr_mobs:pig", ("Pig"), "otcr_mobs_pork_raw.png")

-- porkchop

minetest.register_craftitem("otcr_mobs:pork_raw", {
	description = ("Raw Porkchop"),
	inventory_image = "mobs_pork_raw.png",
	stack_max = 1,
	on_use = minetest.item_eat(0, "bucket:bucket_empty"),
	groups = {food_milk = 1, drink = 1}
})