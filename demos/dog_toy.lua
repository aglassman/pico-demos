dog_toy = {
	type="dog_toy",
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

	draw_override=function(self, position, flip_x, flip_y)
		spr(self.holding_sprite, position[1] - 4, position[2] - 3, 1, 1, flip_x, flip_y)
	end
}