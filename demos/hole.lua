hole = {
	hole_depth=4,
	sprites={68, 84, 100, 116},
	hidden=nil,
	uncovered=nil,
	new=function(self, position, flip_x)
		local new_hole = {
			id=id(),
			position=position,
			size=-1,
			flip_x=flip_x or false,
			hidden=dog_toy:new(position)
		}
		return setmetatable(new_hole, {__index=self})
	end,
	
	hide=function(self, item)
		self.hidden = item
		self.uncovered = nil
	end,

	draw=function(self)
		local i = self.size
		
		if self.size > self.hole_depth then
			i = self.hole_depth
		end
		
		if self.size > 0 then
			spr(self.sprites[i], self.position[1], self.position[2], 2, 1, self.flip_x)
		end	

		if self.uncovered != nil then
			self.uncovered:hold_draw(self.position, self.flip_x)
		end	
	end,

	increase_size=function(self)
		self.size += 1
		if self.size == self.hole_depth then
			self.uncovered = self.hidden
			self.hidden = nil
		end
	end
}