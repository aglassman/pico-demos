hole = {
	type="hole",
	check_intersection=true,
	rect_dimensions={4,4},
	hole_depth=4,
	sprites={68, 84, 100, 116},
	filled_sprite=70,
	hidden=nil,
	uncovered=nil,
	new=function(self, position, flip_x, to_hide)
		local hidden = nil
		
		if to_hide != nil then
			hidden = to_hide:new(position)
		end

		local new_hole = {
			id=id(),
			position=position,
			size=-1,
			flip_x=flip_x or false,
			hidden=hidden,
			uncovered=nil,
			filled=false,
			found={
				position=position,
				text="!!",
				text_color=10
			}
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
			local x_offset = 3
			
			if  not self.flip_x then
				x_offset += 9
			end	

			local sprite = self.sprites[i]

			if self.filled then
				sprite = self.filled_sprite
			end

			spr(sprite, self.position[1] - x_offset, self.position[2] - 4, 2, 1, self.flip_x)
		end	

		if self.uncovered != nil then
			self.uncovered:draw_override({self.position[1] + 1, self.position[2] - 2}, self.flip_x, true)
		end

		if debug_draw_xy then
			rect(self.position[1] - 4, self.position[2] - 4, self.position[1] + 4, self.position[2] + 4, 8)
		end

	end,

	increase_size=function(self)
		sfx(4, -1, 8 + self.size, 1)
		self.size += 1
		if self.size == self.hole_depth then
			if self.hidden != nil then
				sfx(4, -1, 0, 6)
			else
				sfx(5, -1, 0, 3)
			end	
			self.uncovered = self.hidden
			self.hidden = nil
		end
		if self.size == self.hole_depth + 3 then
			self.filled = true
		end	
	end
}