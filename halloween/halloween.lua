player=0

score={}

positions = {}

selection = {
	current=nil,
	valid_moves={},

	get_valid_move=function(self, x, y)
		for move in all(self.valid_moves) do
			if move.x == x and move.y == y then
				return move
			end	
		end	
		return false
	end,

	set_selection=function(self, x, y)
		self.current={x=x, y=y}
		self.valid_moves= valid_moves(player, x, y)
	end,

	clear_selection=function(self)
		self.current=nil
		self.valid_moves={}
	end,

	select=function(self, peice, x, y)
		local move = self:get_valid_move(x, y)

		if move then
			self:move(move)
		elseif peice and peice.player != player then
			-- Do nothing
		elseif (self.current and self.current.x == x and self.current.y == y) then
			self:clear_selection()
		elseif peice then
			self:set_selection(x, y)
		end	
	end,

	move=function(self, move)
		dp("player " .. player)
		dp("from {" .. self.current.x .. ", " .. self.current.y ..  "}")
		dp("to {" .. move.x .. ", " .. move.y ..  "}")
		local peice = get_position(self.current.x, self.current.y)
		set_position(self.current.x, self.current.y, nil)
		set_position(move.x, move.y, peice)
		self:clear_selection()

		if move.capture then
			dp("capture {" .. move.capture.x .. ", " .. move.capture.y ..  "}")
			set_position(move.capture.x, move.capture.y, nil)
			score[player] = (score[player] or 0) + 1
		end	
		dp("----")
		next_player()
	end,

	draw=function(self)
		if self.current then
			draw_rect(self.current.x, self.current.y, 8, false)
		end

		for move in all(self.valid_moves) do
			if move.capture then
				pal(0,8)
			end	
			draw_sprite(4, move.x, move.y)
			pal(0,0)
		end
	end,


}
--printh("{" .. position[1] .. ", " .. position[2] .. "}", "demo_log.txt")
function dp(string)
	printh( string, "halloween.txt")
end	

function next_player()
	player = (player + 1) % 2
end	

function draw_rect(x, y, color, fill)
	if fill then
		rectfill(x * 16, y * 16, x * 16 + 16, y * 16 + 16, color)
	else
		rect(x * 16, y * 16, x * 16 + 15, y * 16 + 15, color)
	end	
end

function draw_sprite(sprite, x, y)
	spr(sprite, x * 16, y * 16, 2, 2)
end

function get_position(x, y)
	if x < 0 or x > 7 or y < 0 or y > 7 then
		return nil
	else
		return positions[x][y]
	end	
end	

function set_position(x, y, peice)
	positions[x][y] = peice
end	

function valid_moves(player, x, y, capture)
	capture = capture or false
	local direction

	if player == 0 then
		direction = 1
	else
		direction = -1
	end

	y += direction
	
	local moves = {}
	local option_1 = get_position(x-1, y)
	local option_2 = get_position(x+1, y)


	if (capture and capture.opt == 2) then
		--nothing
	elseif option_1 == nil then
		add(moves, {x=x-1, y=y, capture=capture})
	elseif option_1.player != player then
		for move in all(valid_moves(player, x-1, y, {x=x-1, y=y, opt=1})) do
			add(moves, move)
		end	
	end	
	
	if (capture and capture.opt == 1) then
		--nothing
	elseif option_2 == nil then
		add(moves, {x=x+1, y=y, capture=capture})
	elseif option_2.player != player then
		for move in all(valid_moves(player, x+1, y, {x=x+1, y=y, opt=2})) do
			add(moves, move)
		end	
	end	

	return moves
end

piece = {
	player=0,
	sprite=0,
	king=false,
	selected=false,

	new=function(self, player, sprite)
		local new_piece={
			player=player,
			sprite=sprite,
			king=false
		}
		return setmetatable(new_piece, {__index=self})
	end,

	draw=function(self, x, y)
		draw_sprite(self.sprite, x, y)
	end,

	set_select=function(self, selected)
		self.selected = selected
	end

}

selector = {
	position={x=0,y=0},
	colors={8,7},
	draw=function(self)
		if (self.position != nil) then
			draw_rect(self.position.x, self.position.y, 7, false)
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

		if (btnp(🅾️, player)) then
			local peice = positions[self.position.x][self.position.y]
			selection:select(peice, self.position.x, self.position.y)
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
				
				draw_rect(x, y, sq_color, true)

				local peice = positions[x][y]

				if peice then
					peice:draw(x,y)
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
			if (((x + y % 2) % 2) == 0) then
				if y <= 2 then
					set_position(x, y, piece:new(0, 0))
				elseif y >= 5 then
					set_position(x, y, piece:new(1, 2))
				else
					set_position(x, y, nil)
				end			
			else 
				set_position(x, y, nil)
			end	
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
	selection:draw()
end	