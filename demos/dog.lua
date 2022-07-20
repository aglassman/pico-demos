--[[
facing -> "left" or "right"
state -> standing, walking, pooping, sniffing, digging
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

	dog_mouth_position=function(self)
		local x,y = unpack(self.position)
		y+=6
		if self:is("sniffing") or self:is("digging") then
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
			local drop_position = self:dog_mouth_position(true)
			self.holding:drop(drop_position)
		end	
	end,

	do_sniff=function(self)
		self:set_is("sniffing")
		self.sniff_time += 1
		self.speed=self.sniffing_speed

		if rnd_int(0,13) == 5 then
			sfx(unpack(self.sniff.sfx))
		end	
	end,

	do_dig=function(self)
		self:set_is("digging")
		if self.current_hole == nil then
			local x, y = unpack(self.position)
			self.current_hole = hole:new(self:dog_mouth_position(), self.facing == "left")
			self.current_hole:increase_size()
			t_add(park.bg_items, self.current_hole)
		end
		self.dig_time += 1

		if self.dig_time % 10 == 0 then
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
			dog_mouth = self:dog_mouth_position()
			pset(dog_mouth[1], dog_mouth[2], 12)
		end	
		
		if self.holding then
			self.holding:draw_override(self:dog_mouth_position(), self:is_facing("left"), false)
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
			self:dig_stop()
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