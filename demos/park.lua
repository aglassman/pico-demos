park = {
	type="park",
	id=id(), 
	weeds={},
	poops={},
	dogs={},
	bg_items={},
	items={},
	holes={},
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
		t_add(self.items, garbage_can:new({5,12}))
		t_add(self.dogs, dog:new({50, 50}))
		for i=1, 10 do
			self.weeds[i] = weed:new({flr(rnd(120)), flr(rnd(120))})
		end
		for i=1, 15 do
			self.holes[i] = hole:new({8 * i, flr(rnd(120))}, false, dog_toy)
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
		draw_all(self.holes)

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