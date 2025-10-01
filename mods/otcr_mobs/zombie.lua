

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
	armor = 90,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	textures = {
		{"mobs_mc_zombie.png"}
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
--	sounds = {random = "mobs_oerkki"},
	walk_velocity = 0.8,
	run_velocity = 1.6,
	view_range = 16,
	jump = true,
	drops = {
		{name = "default:obsidian", chance = 3, min = 0, max = 2},
		{name = "default:gold_lump", chance = 2, min = 0, max = 2}
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
	min_height = -60
})

-- spawn egg

mobs:register_egg("otcr_mobs:zombie", ("Spawn Zombie"), "default_mossycobble.png", 1)
