dofile(minetest.get_modpath("player_api") .. "/api.lua")
dofile(minetest.get_modpath("player_api") .. "/hand.lua")

-- Default player appearance
player_api.register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png"},
	animations = {
		-- Standard animations.
		stand     = {x = 0,   y = 79},
		lay       = {x = 162, y = 166, eye_height = 0.3, override_local = true,
			collisionbox = {-0.6, 0.0, -0.6, 0.6, 0.3, 0.6}},
		walk      = {x = 168, y = 187},
		mine      = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit       = {x = 81,  y = 160, eye_height = 0.8, override_local = true,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.0, 0.3}}
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	stepheight = 0.6,
	eye_height = 1.47,
})

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	player_api.set_model(player, "character.b3d")
        player:set_sky({
		base_color = "#3064c4",
		type = "regular",
		sky_color = {
			day_sky = "#3064c4",
			day_horizon = "#6ab8e1",

			dawn_sky = "2a3fff",
			dawn_horizon = "2a3fff",

			night_sky = "2a3fff",
			night_horizon = "2a3fff",

			indoors = "#0d3e55",
		}
	})

end)
