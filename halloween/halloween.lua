winner = nil

player=0

score={}

positions = {}


pumpkin = {
	unselected=0,
	selected={0, 2, 0, 4},
	speed=1.2
}

ghost = {
	unselected=32,
	selected={32, 34, 32, 36},
	speed=3
}

spider = {
	sprite=64
}

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

	set_selection=function(self, piece, x, y)
		piece:set_select(true)
		self.current={x=x, y=y}
		self.valid_moves= valid_moves(player, x, y, piece.king)
	end,

	clear_selection=function(self, piece)
		piece:set_select(false)
		self.current=nil
		self.valid_moves={}
	end,

	select=function(self, piece, x, y)
		local move = self:get_valid_move(x, y)

		if move then
			self:move(move)
		elseif piece and piece.player != player then
			-- Do nothing
		elseif (self.current and self.current.x == x and self.current.y == y) then
			self:clear_selection(piece)
		elseif piece then
			self:set_selection(piece, x, y)
		end	
	end,

	move=function(self, move)
		dp("player " .. player)
		dp("from {" .. self.current.x .. ", " .. self.current.y ..  "}")
		dp("to {" .. move.x .. ", " .. move.y ..  "}")
		
		local piece = get_position(self.current.x, self.current.y)
		set_position(self.current.x, self.current.y, nil)
		set_position(move.x, move.y, piece)
		self:clear_selection(piece)

		if move.capture then
			dp("capture {" .. move.capture.x .. ", " .. move.capture.y ..  "}")
		
			set_position(move.capture.x, move.capture.y, nil)
			score[player] = (score[player] or 0) + 1
		
			dp("----")
		end
		
		if (player == 0 and move.y == 7) or (player == 1 and move.y == 0) then
			piece.king = true
		end	

		dp("----")
		
		next_player(piece, move)
			
	end,

	draw=function(self)
		if self.current then
			draw_rect(self.current.x, self.current.y, 8, false)
		end

		for move in all(self.valid_moves) do
			if move.capture then
				pal(0,8)
			end	
			draw_sprite(spider.sprite, move.x, move.y)
			pal(0,0)
		end
	end,


}

piece = {
	player=0,
	sprite=nil,
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
		if self.king then
			pal(0, 8)
		end	

		if self.selected then
			local offset = flr(time() * self.sprite.speed % #self.sprite.selected) + 1
			local selected_sprite = self.sprite.selected[offset]
			draw_sprite(selected_sprite, x, y)
		else
			draw_sprite(self.sprite.unselected, x, y)
		end	

		if self.king then
			pal(0, 0)
		end	
	end,

	set_select=function(self, selected)
		self.selected = selected
	end

}

selector = {
	position={x=0,y=0},
	colors={8,7},
	draw=function(self)
		local color

		if player == 0 then
			color = 10
		elseif player == 1 then
			color = 7
		end	

		if (self.position != nil) then
			draw_rect(self.position.x, self.position.y, color, false)
		end
	end,

	update=function(self)
		if (btnp(⬅️, player)) and in_bounds(self.position.x - 1) then
			self.position.x -= 1
		end
		 
		if (btnp(➡️, player)) and in_bounds(self.position.x + 1) then
			self.position.x += 1
		end
			
		if (btnp(⬆️, player)) and in_bounds(self.position.y - 1) then
			self.position.y -= 1
		end
			
		if (btnp(⬇️, player)) and in_bounds(self.position.y + 1) then
			self.position.y += 1
		end

		if (btnp(🅾️, player)) then
			local piece = positions[self.position.x][self.position.y]
			selection:select(piece, self.position.x, self.position.y)
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

				local piece = positions[x][y]

				if piece then
					piece:draw(x,y)
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
					set_position(x, y, piece:new(0, pumpkin))
				elseif y >= 5 then
					set_position(x, y, piece:new(1, ghost))
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
	if not winner then
		selector:update()
		check_win()
	end		
end

function _draw()
	
	if winner then
		cls()
		board:draw()
		draw_winner()
	else
		cls()
		board:draw()
		selector:draw()
		selection:draw()
	end	
end	

function draw_winner()
	rectfill(8, 40, 120, 75, 0)
	local winner_sprite
	if winner == "pumpkins" then
		winner_sprite = piece:new(0, pumpkin)
	else
		winner_sprite = piece:new(0, ghost)
	end	
		
	winner_sprite.selected = true
	winner_sprite:draw(1, 3)
	winner_sprite:draw(6, 3)

	print(winner .. " win!", 40, 55, 7)
end	

function check_win()
	if (score[0] or 0) == 12 then
		winner = "pumpkins"
	end
	
	if (score[1] or 0) == 12 then
		winner = "ghosts"
	end
end	

function dp(string)
	printh( string, "halloween.txt")
end	

function next_player(piece, move)
	if piece and move.capture then
		for next_move in all(valid_moves(player, move.x, move.y, piece.king)) do
			if next_move.capture then
				dp("double_jump_possible {" .. next_move.capture.x .. ", " .. next_move.capture.y ..  "}")
				return false
			end	
		end	
	end
	dp("next player")
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

function in_bounds(a)
	return a >= 0 and a <= 7
end	

function get_position(x, y)
	if in_bounds(x) and in_bounds(y) then
		return positions[x][y]
	else
		return nil
	end	
end	

function set_position(x, y, piece)
	positions[x][y] = piece
end	

function valid_moves(player, x, y, is_king)
	local directions

	if is_king then
		directions = {-1, 1}
	else
		if player == 0 then
			directions = {1}
		else
			directions = {-1}
		end
	end

	x_options = {-1, 1}

	local moves = {}

	for direction in all(directions) do
		local y += direction
		for x_option in all(x_options) do
			local potential_move = get_position(x + x_option, y)
			if potential_move == nil and in_bounds(x + x_option) and in_bounds(y) then
				add(moves, {x=x + x_option, y=y})
			elseif potential_move != nil and potential_move.player != player then
				potential_move = get_position(x + (x_option * 2), (y + direction))
				if potential_move == nil and in_bounds(x + (x_option * 2)) and in_bounds(y + direction) then
					add(moves, {x=x + (x_option * 2), y=(y + direction), capture={x=x + x_option, y=y}})
				end	
			end	
		end
	end		

	return moves
end