-- The hand

--Create an initial hand tool
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=1},
})

-- This is a fake node that should never be placed in the world
local def = minetest.registered_items[""]
minetest.register_node("player_api:player", {
	description = "",
	tiles = {"character.png"},
	visual_scale = 1,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
		},
		damage_groups = {damage=1},
	},
	wield_scale = {x=1,y=1,z=1},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "hand.b3d",
	-- Prevent construction
	node_placement_prediction = "",
	on_construct = function(pos)
		minetest.log("error", "Tried to place hand at "..minetest.pos_to_string(pos))
		minetest.remove_node(pos)
	end,
	drop = "",
	on_drop = function()
		return ""
	end,
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	range = def.range,
})

minetest.register_node("player_api:creative", {
	description = "",
	tiles = {"player.png"},
	visual_scale = 1,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {		
			stone = {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			dirt =  {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			snow =  {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			grass = {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			sand =  {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			wood =  {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			leaves ={times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			wool =  {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			glass = {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}, uses=0, maxlevel=1},
			netherrack = {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0},uses=0, maxlevel=1},
			unbreakable = {times={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0},uses=0, maxlevel=1},
			dig_immediate = {times={[2]=0,[3]=0,[1]=0,},uses=0, maxlevel=1},
		},
		damage_groups = {damage=1},
	},
	wield_scale = {x=1,y=1,z=1},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "hand.b3d",
	-- Prevent construction
	node_placement_prediction = "",
	on_construct = function(pos)
		minetest.log("error", "Tried to place hand at "..minetest.pos_to_string(pos))
		minetest.remove_node(pos)
	end,
	drop = "",
	on_drop = function()
		return ""
	end,
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	range = def.range,
})


--Create a hand list and then enable the hand node
minetest.register_on_joinplayer(function(player)
	player:get_inventory():set_size("hand", 1)
	player:get_inventory():set_stack("hand", 1, "player_api:player")
end)