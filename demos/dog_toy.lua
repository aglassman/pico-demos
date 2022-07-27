dog_toy = {
	type="dog_toy",
	check_intersection=true,
	rect_dimensions={4,4},
	holder=nil,
	toy_types={"bone", "ball", "kong", "stick"},
	get_sprites=function(self)
		if self.toy_type == "bone" then
			return {10, 11, 26}
		end
		
		if self.toy_type == "ball" then
			return {25, 25, 41}
		end

		if self.toy_type == "kong" then
			return {42, 43, 43}
		end

		if self.toy_type == "stick" then
			return {44, 44, 45}
		end 	
	end,

	new=function(self, position, toy_type)
		local new_toy = {
			id=id(),
			position=position,
			flip_x=false,
			toy_type=toy_type
		}
		return setmetatable(new_toy, {__index=self})
	end,

	pickup=function(self, holder)
		self.holder=holder
		self.holder.holding = self
		self.position=holder.position
	end,

	drop=function(self, position, flip_x)
		self.position=position
		self.holder.holding = nil
		self.holder=nil
		self.flip_x = flip_x
	end,

	draw=function(self)
		local sprites = self:get_sprites()
		if self.holder == nil then
			spr(sprites[1], self.position[1] - 4, self.position[2] - 3, 1, 1, self.flip_x, false)
		end						
	end,

	draw_override=function(self, position, flip_x, flip_y)
		local sprites = self:get_sprites()
		spr(sprites[3], position[1] - 4, position[2] - 3, 1, 1, flip_x, flip_y)
	end
}