weed = {
	sprite=0,
	new=function(self, position)
		return {position=position}
	end,

	draw=function(self)
		--pset(self.position[1], self.position[2], 11)
		spr(0, self.position[1], self.position[2])
	end
}


park = {
	weeds={},
	poops={},
	init=function(self, num_weeds)
		for i=1, 10 do
			self.weeds[i] = weed:new({flr(rnd(120)), flr(rnd(120))})
		end	
	end,
	
	draw=function(self)
		rectfill(0,0,127,127,3)
		rect(0,0,127,127,4)
		foreach(self.weeds, weed.draw)
		foreach(self.poops, poop.draw)
	end,

	update=function(self)
		foreach(self.poops, poop.update)
	end
}

poop = {
	sprite=9,
	flies = {},
	add_fly=function(self)
		local new_fly = fly:new({unpack(self.position)})
		animate(new_fly, {pipeline={circle(2,2),sin_x(5)}, duration=2, loop=-1})
		t_add(self.flies, new_fly)
	end,
	new=function(self,position)
		return {flies={}, position=position, age=time()}
	end,
	draw=function(self)
		spr(9, self.position[1], self.position[2])
		foreach(self.flies, draw_animated)
	end,
	update=function(self)
		if time() - self.age > 5 then
			poop.add_fly(self)
			self.age = time() + 5
		end	
	end	
}

fly = {
	new=function(self, position)
		return {_draw=fly._draw, position=position}
	end,
	draw=function(self)
		self._draw(unpack(self.position))
	end,
	_draw=function(x,y)
		pset(x, y, 0)
		pset(x + 1, y - 1, 7)
		pset(x - 1, y - 1, 7)
	end
}

dog = {
	position={20,20},
	facing="right",
	speed=2,
	walking_sprites={1,3},
	sprite_i=0,
	pooping_sprites={5,7},
	running=false,
	text="WOOF",
	text_color=1,
	poop_i=0,
	pooping=false,

	bark=function(self)
		if self.facing == "left" then
			animate(self, {duration=0.2, pipeline={translate(-8,-3),linear(-5,-10)}})
		else
			animate(self, {duration=0.2, pipeline={translate(8,-3),linear(5,-10)}})
		end
		sfx(0)
	end,

	poop=function(self)
		self.sprite_i += .05
		self.pooping=true
		self.poop_i += 1
		if(self.poop_i > 100) then
			animate(self, {duration=0.2, pipeline={translate(-8,-3),linear(-5,-10)}})
			local x, y = unpack(self.position)
			if self.facing == "left" then
				t_add(park.poops, poop:new({x + 11, y + 5}))
			else
				t_add(park.poops, poop:new({x -3, y + 5}))
			end	
			
			self.poop_i = 0
		end	
	end,

	poop_stop=function(self)
		self.pooping=false
		self.poop_i = 0
	end,

	draw=function(self)
		if self.pooping then
			--spr(7, self.position[1], self.position[2],2,2, self.facing == "left")
			local sprite = self.pooping_sprites[(flr(self.sprite_i) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		else
			local sprite = self.walking_sprites[(flr(self.sprite_i) % 2) + 1]
			spr(sprite, self.position[1], self.position[2],2,2, self.facing == "left")
		end	
		draw_animated(self)
	end,
	
	update=function(self)
		local moved = false

		if not self.pooping then
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
			self.sprite_i += .2
		end

		if (btnp(❎)) then
			self:bark()
		end	

		if (btn(🅾️)) then
			self:poop()
		else
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
	--animate(fly, {pipeline={circle(2,2),sin_x(5)}, duration=2, loop=-1})
end

function _update()
	park:update()
	dog:update()
end

function _draw()
	cls()
	park:draw()
	dog:draw()
end

function t_add(table, item)
	table[#table + 1]=item
end	