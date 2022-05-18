-- 128 x 128
quad_bezier_points={{x=0,y=0},{x=40,y=80},{x=40,y=80}}

sel = 0

obj = {
	text="funky butt lovin",
	sprite=1,
	position={x=-4, y=-4}
}

objs = {}

speed=1

function _init()
	-- animate(obj, {
	-- 	transpose_fn=transpose(q_bezier(quad_bezier_points)),
	-- 	draw_path_fn=q_bezier_draw(quad_bezier_points),
	-- 	duration=speed, 
	-- 	direction="reverse",
	-- 	mirror=true,
	-- 	loop=3})

	local str = "hello world"

	for i = 1, #str do
    	local c = sub(str, i,i)
    	objs[i] = {
				text=c,
				position={i * 5,-4}
			}
    	animate(
			objs[i],
	    	{
				transpose_fn=transpose(q_bezier(quad_bezier_points)),
				draw_path_fn=q_bezier_draw(quad_bezier_points),
				--duration=speed/(i*.8),
				mirror=true,
				loop=1})
	end

	-- animate(obj, {transpose_fn=transpose(q_bezier(quad_bezier_points))})
end	

function _update()
	if (btnp(❎)) sel +=1
	if (btnp(❎)) sel %=3
	if (btn(⬅️)) quad_bezier_points[sel + 1].x -= 2
	if (btn(➡️)) quad_bezier_points[sel + 1].x += 2
	if (btn(⬆️)) quad_bezier_points[sel + 1].y -= 2
	if (btn(⬇️)) quad_bezier_points[sel + 1].y += 2

	if (btnp(🅾️)) then

	local str = "hello world"

	for i = 1, #str do
    	local c = sub(str, i,i)
    	objs[i] = {
				text=c,
				position={i * 5,-4}
			}
    	animate(
			objs[i],
	    	{
				transpose_fn=transpose(q_bezier(quad_bezier_points)),
				draw_path_fn=q_bezier_draw(quad_bezier_points),
				duration=speed*(i*.2),
				mirror=true,
				loop=1})
	end

	end 

	--if (btnp(❎)) speed +=.02; printh(speed, "demo_log.txt");
	--if (btnp(⬅️)) animate(obj, {fn=linear, args={x= -30, y= 30}}, speed)
	--if (btnp(➡️)) animate(obj, {fn=linear, args={x= 30, y= 30}}, speed, "mirror")
	--if (btnp(⬆️)) animate(obj, {fn=linear, args={x= 0, y= -30}}, speed, "mirror")
	--if (btnp(⬇️)) animate(obj, {fn=quad_bezier, args=q_bezier(points)}, speed, "mirror")

end

function _draw()
	cls()
	foreach(objs,draw_obj)
	--pset(obj.position.x, obj.position.y,11)
end	


function draw_obj(obj)
	local x, y = obj:transpose_fn()

	if obj.sprite then
		spr(obj.sprite, x, y)
	end	

	if obj.text then
		print(obj.text, x, y, 11)
	end	
	
	if obj.draw_path_fn then
		obj:draw_path_fn()
	end	
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

