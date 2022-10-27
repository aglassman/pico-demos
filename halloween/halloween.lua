positions = {}

selector = {
	player=0,
	position={x=0,y=0},
	colors={8,7},
	draw=function(self)
		if (self.position != nil) then
			rect(
				self.position.x * 16,
				self.position.y * 16,
				self.position.x * 16 + 15,
				self.position.y * 16 + 15,
				7)
		end
	end,

	update=function(self)
		if (btnp(⬅️, player)) then
			self.position.x -= 1
		end
		 
		if (btnp(➡️, player)) then
			self.position.x += 1
		end
			
		if (btnp(⬆️, player)) then
			self.position.y -= 1
		end
			
		if (btnp(⬇️, player)) then
			self.position.y += 1
		end

		if(btnp(❎, player)) then
			positions[self.position.x][self.position.y] = "pumpkin"
		end	

		if(btnp(🅾️, player)) then
			positions[self.position.x][self.position.y] = "ghost"
		end	
	end
}

board = {
	draw=function(self)
		for x=0, 7 do
			for y=0, 7 do
				local sq_color = 8

				if (((x + y % 2) % 2) == 0) then
					sq_color = 1
				else
					sq_color = 2
				end	
				
				rectfill(
					x * 16,
					y * 16,
					x * 16 + 16,
					y * 16 + 16,
					sq_color)

				local obj = positions[x][y]

				if (obj == "pumpkin") then
					spr(0, x * 16, y * 16, 2, 2)
				end

				if (obj == "ghost") then
					spr(2, x * 16, y * 16, 2, 2)
				end		
			end				
		end	
	end
}


function _init()
	palt(11, true)
	palt(0, false)
	for x=0, 7 do
		positions[x] = {}
		for y=0, 7 do
			positions[x][y] = "empty"
		end
	end		
end	

function _update()
	selector:update()
end

function _draw()
	cls()
	board:draw()
	selector:draw()
end	