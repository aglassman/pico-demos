-- 128 x 128
points={{x=0,y=0},{x=40,y=80},{x=80,y=80}}

sel = 0

coin = 1

pf = function (self)
	return self.position
end

obj = {
	sprite=coin,
	position={x=-4, y=-4},
	pos=pf
}

speed=5

function _init()
	animate({
		target=obj, 
		transpose_fn=transpose(q_bezier(points)),
		path=q_bezier_draw(points),
		duration=speed, 
		loop="mirror"})
end	

function _update()
	if (btnp(❎)) sel +=1
	if (btnp(❎)) sel %=3
	if (btn(⬅️)) points[sel + 1].x -= 2
	if (btn(➡️)) points[sel + 1].x += 2
	if (btn(⬆️)) points[sel + 1].y -= 2
	if (btn(⬇️)) points[sel + 1].y += 2

	if (btnp(🅾️)) then
	 speed -=.2
	 printh(speed, "demo_log.txt")
	 animate({
		target=obj, 
		transpose_fn=transpose(q_bezier(points)),
		path=q_bezier_draw(points),
		duration=speed, 
		loop="mirror",
		transition="smooth"})
	end 
	--if (btnp(❎)) speed +=.02; printh(speed, "demo_log.txt");
	--if (btnp(⬅️)) animate(obj, {fn=linear, args={x= -30, y= 30}}, speed)
	--if (btnp(➡️)) animate(obj, {fn=linear, args={x= 30, y= 30}}, speed, "mirror")
	--if (btnp(⬆️)) animate(obj, {fn=linear, args={x= 0, y= -30}}, speed, "mirror")
	--if (btnp(⬇️)) animate(obj, {fn=quad_bezier, args=q_bezier(points)}, speed, "mirror")

end

function _draw()
	cls()
	draw_obj(obj)
	--pset(obj.position.x, obj.position.y,11)
end	

-- returns a new quadratic bezier function with n resolution. pct=0..1
function q_bezier(b)
	return function(pct)
		return qb(pct, b[1].x, b[2].x, b[3].x), qb(pct, b[1].y, b[2].y, b[3].y)
	end
end	

function linear(pct, point)
	return pct * point.x, pct * point.y
end	


function transpose(fn)
	return function(obj, pct)
		dx, dy = fn(pct)
		return {x=obj.position.x + dx, y=obj.position.y + dy}
	end
end	

--[[
	animate({
	    target=obj, 
		transpose_fn=transpose(self, pct), 
		duration=3, 
		loop="mirror"
		})
]]
function animate(args)
	local target = args.target
	local duration = args.duration
	local loop = args.loop or "once"
	
	if args.transition == "smooth" then
		target.et = target.st + duration
	else
		target.st = time()
		target.et = time() + duration
		target.reverse = nil
	end	


	target.pos = function (self)
		if time() > self.et then
			if loop == "once" then
				target.pos = pf
				return pf(self)
			elseif loop == "mirror" then
				self.st = time()
				self.et = time() + duration
				self.reverse = not self.reverse
			else	
				self.st = time()
				self.et = time() + duration
			end	
		end	

		local pct

		if target.reverse then
			pct = 1 - (( time() - self.st) / duration)
		else
			pct = ( time() - self.st) / duration
		end	

		return args.transpose_fn(self, pct)
	end

	target.path = args.path
end	

function update_obj(obj)

end	

function draw_obj(obj)
	p = obj:pos()
	spr(obj.sprite, p.x, p.y)

	obj:path()
end	


function q_bezier_draw(points)
	local q_bz = q_bezier(points)
	return function()
		n = 200
		for i=0, n, 1 do
			t = i / n
			x, y = q_bz(t)
			pset(x, y, 7)
		end	

		foreach(points, draw_point)
		draw_point(points[sel + 1], 11)
	end	
end


function draw_point(p, c)
	c = c or 8
	pset(p.x, p.y, c)
end


-- linear interpolation (start, end, percent)
function lerp(a, b, c)
	return a + (b - a) * c
end

function qb(t, p0, p1, p2)
	return lerp(lerp(p0, p1, t), lerp(p1, p2, t), t)
end
