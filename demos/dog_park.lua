weed = {
	sprite=0,
	
	new=function(self, position)
		return setmetatable({position=position}, {__index=self})
	end,

	draw=function(self)
		--pset(self.position[1], self.position[2], 11)
		spr(0, self.position[1], self.position[2])
	end
}


park = {
	weeds={},
	poops={},
	dogs={},
	init=function(self, num_weeds)
		t_add(self.dogs, dog:new({50, 50}))
		for i=1, 10 do
			self.weeds[i] = weed:new({flr(rnd(120)), flr(rnd(120))})
		end
		--music(1)	
	end,
	
	draw=function(self)
		rectfill(0,0,127,127,3)
		rect(0,0,127,127,4)
		foreach(self.weeds, weed.draw)
		foreach(self.poops, poop.draw)
		foreach(self.dogs, dog.draw)
	end,

	update=function(self)
		foreach(self.poops, poop.update)
		foreach(self.dogs, dog.update)
	end
}

poop = {
	max_flies=4,
	sprite=9,
	flies = {},

	new=function(self,position)
		local new_poop = {
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
		return setmetatable({wings=true, position=position, age=time()}, {__index=self})
	end,
	draw=function(self)
		self._draw(unpack(self.position))
	end,
	_draw=function(self, x,y)
		pset(x, y, 0)
		if (self.wings) pset(x + 1, y - 1, 7)
		if (not self.wings) pset(x - 1, y - 1, 7)
		self.wings = not self.wings	
	end
}

--[[
facing -> "left" or "right"
state -> standing, walking, pooping, sniffing
]]
dog = {
	position={20,20},
	facing="right",
	speed=2,

	state="standing",

	sprite_i=0,
	walking_sprites={1,3},
	pooping_sprites={5,7},
	sniffing_sprites={33, 35},
	
	sfx_sniff=1,

	
	poop_time=0,
	sniff_time=0,

	woof={
		sfx_woof={0, -1, 7},
		text="WOOF",
		text_color=1
	},
	

	new=function(self, position)
		local new_dog={
			speed=2,
			state="standing",
			position=position,
			age=time(),
			sniff_time=0,
		}
		return setmetatable(new_dog, {__index=self})
	end,

	bark=function(self)
		if self.facing == "left" then
			animate(self, {reverse=true, duration=0.2, pipeline={translate(-8,-3),linear(-5,-10)}})
		else
			animate(self, {reverse=true, duration=0.2, pipeline={translate(8,-3),linear(5,-10)}})
		end
		sfx(unpack(self.woof.sfx_woof))
	end,

	poop=function(self)
		self.sprite_i += .05
		self:set_is("pooping")
		self.poop_time += 1
		if(self.poop_time > 100) then
			self:bark()
			local x, y = unpack(self.position)
			if self.facing == "left" then
				t_add(park.poops, poop:new({x + 11, y + 5}))
			else
				t_add(park.poops, poop:new({x -3, y + 5}))
			end	
			
			self.poop_time = 0
		end	
	end,

	stand=function(self)
		self:set_is("standing")
		self.speed=2
	end,

	poop_stop=function(self)
		self:set_is("standing")
		self.poop_time = 0
	end,

	sniff=function(self)
		self:set_is("sniffing")
		self.sniff_time += 1
		self.speed=1

		if self.sniff_time < 5 or rnd_int(0,6) == 5 then
			sfx(self.sfx_sniff)
		end	
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

	draw=function(self)
		if self:is("pooping") then
			--spr(7, self.position[1], self.position[2],2,2, self.facing == "left")
			local sprite = self.pooping_sprites[(flr(self.sprite_i) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		elseif self:is("sniffing") then
			local sprite = self.sniffing_sprites[(flr(self.sprite_i) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		else	
			local sprite = self.walking_sprites[(flr(self.sprite_i) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		end	
		draw_animated(self)
	end,
	
	update=function(self)
		local moved = false

		if not self:is("pooping") then
			if (btn(⬅️)) then
				self.position[1] -= self.speed
				self.facing = "left"
				moved = true
			end
			 
			if (btn(➡️)) then
				self.position[1] += self.speed
				self.facing = "right"
				moved = true
			end
				
			if (btn(⬆️)) then
				self.position[2] -= self.speed
				moved = true
			end
				
			if (btn(⬇️)) then
				self.position[2] += self.speed
				moved = true
			end
		end	

		if moved then
			self.sprite_i += .3
		end

		if (btnp(❎)) then
			self:bark()
		end	

		if (btn(🅾️) and self.sniff_time > 100) then
			self:poop()
		elseif (btn(🅾️)) then
			self:sniff()
		else
			self:sniff_stop()
		end	

		if (not btn(🅾️)) then
			self:poop_stop()
		end	

	end
}


function pcord(position)
	printh("{" .. position[1] .. ", " .. position[2] .. "}", "demo_log.txt")
end	

function _init()
	cls()
	park:init(1)
end

function _update()
	park:update()
end

function _draw()
	cls()
	park:draw()
end

function t_add(table, item)
	table[#table + 1]=item
end	

--[[ Generate a random integer between min and max, inclusive. ]]
function rnd_int(min, max)
	return min + flr(rnd(max - min + 1))
end

function rnd_float(min, max)
	return min + rnd(max - min + 1)
end	

function rnd_bool()
	return rnd_int(0,1) == 1
end	