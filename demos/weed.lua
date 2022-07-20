weed = {
	sprite=0,
	new=function(self, position)
		last_id+=1
		return setmetatable({id=id(), position=position}, {__index=self})
	end,

	draw=function(self)
		--pset(self.position[1], self.position[2], 11)
		spr(self.sprite, self.position[1], self.position[2])
	end
}