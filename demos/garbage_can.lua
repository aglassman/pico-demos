garbage_can={
	lid_sprites={13, 14},
	can_sprite=29,

	new=function(self, position)
		local new_garbage_can = {
			id=id(), 
			position=position,
			is_open=true
		}
		return setmetatable(new_garbage_can, {__index=self})
	end,

	toggle=function(self)
		self.is_open = not self.is_open
	end,

	draw=function(self)
		local lid_idx = 1
		if self.is_open then
			lid_idx =  2
		end	
		spr(self.lid_sprites[lid_idx], self.position[1], self.position[2] )
		spr(self.can_sprite, self.position[1], self.position[2] + 8)
	end
}