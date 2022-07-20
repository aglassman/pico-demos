bird={
	bird_sprites={28},

	new=function(self)
		local new_bird = {
			id=id(),
			position=position
		}
		return setmetatable(new_bird, {__index=self})
	end,

	draw=function(self)
		spr(self.bird_sprites[1], self.position[1], self.position[2])
	end
}