poop = {
	type="poop",
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