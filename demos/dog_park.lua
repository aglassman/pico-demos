-- enable = enables devkit mode with mouse and keyboard
-- btn_emu = left,right,middle mouse buttons -> btn(❎),btn(🅾️),btn(6)
-- ptr_lock = enable pointer lock
function mkb_init(enable, btn_emu, ptr_lock)
  -- pass args as bitfield into hardware register
  poke(0x5f2d,(enable   and 1 or 0)
             |(btn_emu  and 2 or 0)
             |(ptr_lock and 4 or 0))
end

pressed=""

function handle_keypress(key)
	pressed = pressed .. key
end	


-- Globals
last_id=0
debug_draw_xy=false
move_target={}

-- Menu items
menuitem(1, "toggle debug xy", function() debug_draw_xy = not debug_draw_xy end)

debug_functions={
	q=function ()
		debug_draw_xy = not debug_draw_xy
	end,
	t=function ()
		park.items[1].is_open = not park.items[1].is_open
	end,
	b=function ()
		local new_toy = dog_toy:new({rnd_int(20, 40), rnd_int(20, 40)})
		t_add(park.bg_items, new_toy)
		park.dogs[1]:pickup_item(new_toy)
	end,
	h=function ()
		local new_hole = hole:new({rnd_int(20, 40), rnd_int(20, 40)})
		t_add(park.bg_items, new_hole)
	end
}

function debug_input()
	while stat(30) do
	    local f = debug_functions[stat(31)]
	    if (f) f()	
	end
end	

function id()
	last_id += 1
	return last_id
end	

weed = {
	sprite=0,
	new=function(self, position)
		last_id+=1
		return setmetatable({id=id(), position=position}, {__index=self})
	end,

	draw=function(self)
		--pset(self.position[1], self.position[2], 11)
		spr(self.sprite, self.position[1], self.position[2])
	end
}

garbage_can={
	lid_sprites={13, 14},
	can_sprite=29,

	new=function(self, position)
		local new_garbage_can = {
			id=id(), 
			position=position,
			is_open=true
		}
		return setmetatable(new_garbage_can, {__index=self})
	end,

	toggle=function(self)
		self.is_open = not self.is_open
	end,

	draw=function(self)
		local lid_idx = 1
		if self.is_open then
			lid_idx =  2
		end	
		spr(self.lid_sprites[lid_idx], self.position[1], self.position[2] )
		spr(self.can_sprite, self.position[1], self.position[2] + 8)
	end
}

park = {
	id=id(), 
	weeds={},
	poops={},
	dogs={},
	bg_items={},
	items={},
	back_fence={
			draw=function(self)
				for i=0, 8 do
					spr(65, (i * 16), -8, 2, 2, (i % 2) == 0)
				end	
			end
	},
	front_fence={
		draw=function(self)
			for i=0, 8 do
				spr(65, (i * 16), 128-8, 2, 2, (i % 2) == 0)
			end	
		end
	},
	init=function(self, num_weeds)
		t_add(self.items, garbage_can:new({50,50}))
		t_add(self.dogs, dog:new({50, 50}))
		for i=1, 10 do
			self.weeds[i] = weed:new({flr(rnd(120)), flr(rnd(120))})
		end
		--music(1)	
	end,
	
	draw=function(self)
		-- draw grass
		rectfill(0,0,127,127,3)
		-- draw fence
		rect(0,0,127,127,4)

		-- draw things in the park
		self.back_fence:draw()
		draw_all(self.weeds)
		draw_all(self.poops)
		draw_all(self.bg_items)
		-- draw_all(self.dogs)
		-- draw_all(self.items)
		draw_all(self.fences)

		local draw_table = {}
		--t_append_all(draw_table, self.weeds)
		--t_append_all(draw_table, self.poops)
		t_append_all(draw_table, self.dogs)
		t_append_all(draw_table, self.items)
		t_sort(draw_table, function (a, b) return a.position[2] > b.position[2] end )
		draw_all(draw_table)

		self.front_fence:draw()

		if debug_draw_xy then
			foreach(draw_table, draw_xy)
			foreach(self.bg_items, draw_xy)
		end	
	end,

	update=function(self)
		foreach(self.poops, poop.update)
		foreach(self.dogs, dog.update)
	end
}

function draw_xy(obj)
	pset(obj.position[1], obj.position[2], 8)
end	

function draw_all(t)
	for obj in all(t) do
		obj:draw()
	end	
end	

poop = {
	max_flies=4,
	sprite=9,
	flies = {},

	new=function(self,position)
		local new_poop = {
			id=id(), 
			flies = {},
			max_flies=rnd_int(3,5),
			stanky=false,
			position=position, 
			age=time(), 
			reverse=rnd_bool()
		}
		return setmetatable(new_poop, {__index=self})
	end,
	
	add_fly=function(self)
		local new_fly = fly:new({unpack(self.position)})
		local animation = {
			pipeline={
				translate(rnd_int(3, 5),rnd_int(-2,2)),
				circle(rnd_int(1,2),rnd_int(1,2)),
				sin_x(rnd_int(3,5))},
			offset=rnd_float(.1, .3),
			duration=rnd_float(1.8,2.2), 
			loop=-1, 
			reverse=self.reverse
		}
		animate(new_fly, animation)
		t_add(self.flies, new_fly)
		self.reverse = not self.reverse
	end,
	
	draw=function(self)
		if (self.stanky) pal(4,5)
		spr(9, self.position[1], self.position[2])
		pal()
		foreach(self.flies, draw_animated)
		if (debug_draw_xy) draw_xy(self)
	end,
	
	update=function(self)
		if not self.stanky and time() - self.age > 5 then
			poop.add_fly(self)
			self.age = time()
		end

		if not self.stanky and #self.flies == self.max_flies then
			self.stanky = true
		end	

	end	
}

fly = {
	new=function(self, position)
		local new_fly = {
			id=id(),
			wings=true,
			position=position,
			age=time()
		}
		return setmetatable(new_fly, {__index=self})
	end,
	draw=function(self)
		self._draw(unpack(self.position))
	end,
	_draw=function(self, x,y)
		pset(x, y, 0)
		if (self.wings) pset(x + 1, y - 1, 7)
		if (not self.wings) pset(x - 1, y - 1, 7)
		self.wings = not self.wings
		if (debug_draw_xy) pset(x, y, 8)	
	end
}

bird={
	bird_sprites={28},

	new=function(self)
		local new_bird = {
			id=id(),
			position=position
		}
		return setmetatable(new_bird, {__index=self})
	end,

	draw=function(self)
		spr(self.bird_sprites[1], self.position[1], self.position[2])
	end
}

dog_toy = {
	holder=nil,
	holding_sprite=26,
	sprites={10, 11},

	new=function(self, position)
		local new_toy = {
			id=id(),
			position=position
		}
		return setmetatable(new_toy, {__index=self})
	end,

	pickup=function(self, holder)
		self.holder=holder
		self.holder.holding = self
		self.position=holder.position
	end,

	drop=function(self, position)
		self.position=position
		self.holder.holding = nil
		self.holder=nil
	end,

	draw=function(self)
		if self.holder == nil then
			spr(self.sprites[1], self.position[1] - 4, self.position[2] - 3)
		end						
	end,

	hold_draw=function(self, position, flip_x)
		spr(self.holding_sprite, position[1] - 4, position[2] - 3, 1, 1, flip_x)
	end
}

hole = {
	sprites={68, 84, 100, 116},
	hidden=nil,
	uncovered=nil,
	new=function(self, position, flip_x)
		local new_hole = {
			id=id(),
			position=position,
			size=0,
			flip_x=flip_x or false
		}
		return setmetatable(new_hole, {__index=self})
	end,
	
	hide=function(self, item)
		self.hidden = item
		self.uncovered = nil
	end,
	
	draw=function(self)
		local i = self.size
		
		if self.size > 4 then
			i = 4
		end
		
		if self.size > 0 then
			spr(self.sprites[i], self.position[1], self.position[2], 2, 1, self.flip_x)
		end	
	end,

	increase_size=function(self)
		self.size += 1
		if self.size == 4 then
			self.uncovered = self.hidden
			self.hidden = nil
		end
	end
}

--[[
facing -> "left" or "right"
state -> standing, walking, pooping, sniffing
]]
dog = {
	facing="right",
	state="standing",

	sprite_i=0,
	walking_sprites={1,3},
	pooping_sprites={5,7},
	sniffing_sprites={33, 35},
	sniffing_standing_sprints={33, 37},
	
	digging_sprites={96, 98},
	current_hole=nil,
	
	
	poop_time=0,
	sniff_time=0,
	dig_time=0,

	new=function(self, position)
		local new_dog={
			default_speed=2,
			sniffing_speed=1,
			speed=2,
			state="standing",
			position=position,
			age=time(),
			sniff_time=0,
			bark={
				position=position,
				sfx={0, -1, 7},
				text="woof",
				text_color=1
			},
			sniff={
				sfx={1}
			}
		}
		return setmetatable(new_dog, {__index=self})
	end,

	do_bark=function(self)
		if self.facing == "left" then
			animate(self.bark, {duration=0.2, pipeline={translate(-8,-3),linear(-5,-10)}})
		else
			animate(self.bark, {duration=0.2, pipeline={translate(8,-3),linear(5,-10)}})
		end
		sfx(unpack(self.bark.sfx))
	end,

	poop=function(self)
		self.sprite_i += .05
		self:set_is("pooping")
		self.poop_time += 1
		if(self.poop_time > 100) then
			self:do_bark()
			local x, y = unpack(self.position)
			if self.facing == "left" then
				t_add(park.poops, poop:new({x + 11, y + 5}))
			else
				t_add(park.poops, poop:new({x -3, y + 5}))
			end	
			
			self.poop_time = 0
		end	
	end,

	dog_mount_position=function(self)
		local x,y = unpack(self.position)
		y+=6
		if self:is("sniffing") then
			y+=5
			if self:is_facing("left") then
				x+=1
			else
				x-=1
			end	
		end	
		
		if self:is_facing("left") then
			x+=1
		else
			x+=14
		end	
		return {x, y}
	end,

	stand=function(self)
		self:set_is("standing")
		self.speed=self.default_speed
	end,

	poop_stop=function(self)
		self:set_is("standing")
		self.poop_time = 0
	end,

	is_holding=function(self)
		return self.holding != nil
	end,

	pickup_item=function(self, item)
		self:drop_item()
		item:pickup(self)
	end,

	drop_item=function(self)
		if self.holding then
			local drop_position = self:dog_mount_position(true)
			self.holding:drop(drop_position)
		end	
	end,

	do_sniff=function(self)
		self:set_is("sniffing")
		self.sniff_time += 1
		self.speed=self.sniffing_speed

		if self.sniff_time < 2 or rnd_int(0,13) == 5 then
			sfx(unpack(self.sniff.sfx))
		end	
	end,

	do_dig=function(self)
		self:set_is("digging")
		if self.current_hole == nil then
			local x, y = unpack(self.position)
			self.current_hole = hole:new({x, y + 10}, self.facing == "left")
			self.current_hole:increase_size()
			t_add(park.bg_items, self.current_hole)
		end
		self.dig_time += 1

		if self.dig_time % 100 == 0 then
			self.current_hole:increase_size()
		end	

	end,

	dig_stop=function(self)
		self:stand()
		self.dig_time = 0;
		self.current_hole = nil;
	end,

	sniff_stop=function(self)
		self:stand()
		self.sniff_time = 0
	end,

	set_is=function(self, state)
		self.state = state
	end,

	is=function(self, state)
		return self.state == state
	end,

	is_facing=function(self, direction)
		return self.facing == direction
	end,

	draw=function(self)
		if self:is("pooping") then
			--spr(7, self.position[1], self.position[2],2,2, self.facing == "left")
			local sprite = self.pooping_sprites[(flr(self.sprite_i) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		elseif self:is("sniffing") then
			if self.moved then
				local sprite = self.sniffing_sprites[(flr(self.sprite_i) % 2) + 1]
				spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
			else
				local sprite = self.sniffing_standing_sprints[(flr(time()*2.5) % 2) + 1]
				spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
			end	
		elseif self:is("digging") then
			local sprite = self.digging_sprites[(flr(time() * 6) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		else	
			local sprite = self.walking_sprites[(flr(self.sprite_i) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		end	

		draw_animated(self.bark)

		if debug_draw_xy then
			dog_mouth = self:dog_mount_position()
			pset(dog_mouth[1], dog_mouth[2], 12)
		end	
		
		if self.holding then
			self.holding:hold_draw(self:dog_mount_position(), self:is_facing("left"))
		end	




	end,
	
	update=function(self)
		self.moved = false

		local x, y = unpack(self.position)

		if self:is("standing") or self:is("sniffing") then
			if (btn(⬅️)) then
				x -= self.speed
				self.facing = "left"
				self.moved = true
			end
			 
			if (btn(➡️)) then
				x += self.speed
				self.facing = "right"
				self.moved = true
			end
				
			if (btn(⬆️) and self:is("standing")) then
				y -= self.speed
				self.moved = true
			end
				
			if (btn(⬇️) and self:is("standing")) then
				y += self.speed
				self.moved = true
			end
		end	

		if self.moved then
			if x > 0 and x < 112 and y > -4 and y < 115 then
				self.position[1] = x
				self.position[2] = y
			end	
			self.sprite_i += .3
			self.sniff_time = 0
		end

		if (btnp(❎)) then
			if self:is_holding() then
				self:drop_item()
			else
				self:do_bark()
			end	
		end	

		if (btn(🅾️) and btn(⬇️)) then
			self:do_dig()
		elseif (btn(🅾️) and self.sniff_time > 100) then
			self:poop()
		elseif (btn(🅾️)) then
			self:do_sniff()
		else
			self:sniff_stop()
		end	


		if (not btn(🅾️)) then
			self:poop_stop()
			self:dig_stop()
		end	

	end
}


function pcord(position)
	printh("{" .. position[1] .. ", " .. position[2] .. "}", "demo_log.txt")
end	

function _init()
	mkb_init(true,false,false)
	cls()
	park:init(1)
end

function _update()
	debug_input()
	park:update()
end

function _draw()
	cls()
	park:draw()
	print(pressed, 20, 20, 7)
end