

-- Sneakster 

mobs:register_mob("otcr_mobs:sneakster", {
	type = "monster",
	passive = false,
	pathfinding = true,
	hp_min = 20,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_creeper.b3d",
	textures = {
		{"mobs_mc_creeper.png"}
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
--	sounds = {random = "mobs_oerkki"},
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 16,
	jump = true,
	drops = {
		{name = "tnt:gunpower", chance = 1, min = 0, max = 3} -- Gunpowder droprate is slightly inaccurate by design
	},
	lava_damage = 4,
	light_damage = 0,
	fear_height = 8, -- Allow Sneakster to jump from cave cielings to kamikaze
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	attack_type = "explode",
	
	explosion_radius = 3,
	reach = 4,
	explosion_damage_radius = 7,
	explosion_timer = 1.5,
	allow_fuse_reset = true,
	stop_to_explode = true,

	do_custom = function(self, dtime)
		if self._forced_explosion_countdown_timer ~= nil then
			self._forced_explosion_countdown_timer = self._forced_explosion_countdown_timer - dtime
			if self._forced_explosion_countdown_timer <= 0 then
				mobs:explosion(self.object:getpos(), self.explosion_radius, 0, 1, self.sounds.explode)
				self.object:remove()
			end
		end
	end,
})

-- where to spawn

mobs:spawn({
	name = "otcr_mobs:sneakster",
	nodes = {"group:cracky", "group:crumbly", "group:choppy"},
	max_light = 7,
	chance = 3000,
        max_height = 256,
	min_height = -31000
})

-- spawn egg

mobs:register_egg("otcr_mobs:sneakster", ("Spawn Sneakster"), "default_grass.png", 1)
