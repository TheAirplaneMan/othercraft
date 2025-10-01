

-- Zombie 

mobs:register_mob("otcr_mobs:zombie", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 3,
	hp_min = 20,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	textures = {
		{"mobs_mc_zombie.png"}
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
--	sounds = {random = "mobs_oerkki"},
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 16,
	jump = true,
	drops = {
		{name = "otcr_mobs:rotten_flesh", chance = 1, min = 0, max = 2}
	},
	lava_damage = 4,
	light_damage = 2,
	fear_height = 4,
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
})

-- where to spawn

mobs:spawn({
	name = "otcr_mobs:zombie",
	nodes = {"group:cracky", "group:crumbly", "group:choppy"},
	max_light = 7,
	chance = 6000,
	max_height = 256,
	min_height = -31000
})

-- spawn egg

mobs:register_egg("otcr_mobs:zombie", ("Spawn Zombie"), "default_mossycobble.png", 1)




-- Rotten Flesh

minetest.register_craftitem("otcr_mobs:rotten_flesh", {
	description = ("Rotten Flesh"),
	inventory_image = "otcr_mobs_rotten_flesh.png",
	on_use = minetest.item_eat(-2),
	groups = {food_rotten_flesh = 1}
})
