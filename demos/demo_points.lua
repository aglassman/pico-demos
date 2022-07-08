points = {}

bg_color = 1
shadow_color = 0
n = 6
d = 2
x = -30
y = -2

point={
	_draw=function(self, x, y)
		--pset(x, y, self.color)
		--circfill(x, y, y - 40, self.color)
		self.last={x,y}
		--pset(x + 8, y + 50, shadow_color)
		ovalfill(x, y + 20, x + 16, y + 25, shadow_color )
		spr(4, x, y, 2, 2)
		
	end
}

function reset()
	for i=1, n do
		local new_point = setmetatable({color=i + 6, position={64, 50}}, {__index=point})		
		points[i] = new_point
		animate(new_point, {
			offset= (i / n) * d, 
			pipeline={
				translate(-10,0), 
				circle(x, y)},
			--reverse=rnd_bool(),	
			duration=d, 
			loop=-1,
			transition="smooth"
		})
	end	
end	

function _init()
	reset()
end

function _draw()
	cls()
	rectfill(0, 0, 128, 128,bg_color )
	t_sort(points, function (a, b) if (a.last) then return a.last[2] > b.last[2] else return true end  end )
	foreach(points, draw_animated)
end

function _update()
	if (btnp(❎)) then
		bg_color+=1
	end

	if (btnp(🅾️)) then
		shadow_color += 1
	end	

	if (btnp(⬅️)) then
		x-=1
		reset()
	end
	 
	if (btnp(➡️)) then
		x+=1
		reset()
	end
		
	if (btnp(⬆️)) then
		y+=1
		reset()
	end
		
	if (btnp(⬇️)) then
		y-=1
		reset()
	end
end	