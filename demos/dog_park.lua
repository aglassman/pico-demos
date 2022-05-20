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
		foreach(park.poops, poop.draw)
	end
}

poop = {
	sprite=9,
	new=function(self,position)
		return {position=position}
	end,
	draw=function(self)
		spr(9, self.position[1], self.position[2])
	end	
}

dog = {
	position={20,20},
	facing="right",
	speed=2,
	walking_sprites={1,3},
	sprite_i=0,
	pooping_sprite=7,
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
		self.pooping=true
		self.poop_i += 1
		if(self.poop_i > 100) then
			animate(self, {duration=0.2, pipeline={translate(-8,-3),linear(-5,-10)}})

			if self.facing == "left" then
				park.poops[#park.poops + 1] = poop:new({self.position[1] + 11, self.position[2] + 5})
			else
				park.poops[#park.poops + 1] = poop:new({self.position[1] - 3, self.position[2] + 5})
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
			spr(7, self.position[1], self.position[2],2,2, self.facing == "left")
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
end

function _update()
	dog:update()
end

function _draw()
	cls()
	park:draw()
	dog:draw()
	spr(9, 30,30)
end