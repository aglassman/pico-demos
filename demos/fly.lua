fly = {
	new=function(self, position)
		local new_fly = {
			id=id(),
			wings=true,
			position=position,
			age=time()
		}
		return setmetatable(new_fly, {__index=self})
	end,
	draw=function(self)
		self._draw(unpack(self.position))
	end,
	_draw=function(self, x,y)
		pset(x, y, 0)
		if (self.wings) pset(x + 1, y - 1, 7)
		if (not self.wings) pset(x - 1, y - 1, 7)
		self.wings = not self.wings
		if (debug_draw_xy) pset(x, y, 8)	
	end
}