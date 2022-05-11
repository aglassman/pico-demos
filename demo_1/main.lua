points={{x=0,y=0},{x=40,y=80},{x=80,y=80}}

sel = 0

function _init()

end	

function _update()
	if (btnp(❎)) sel +=1
	if (btnp(❎)) sel %=3
	if (btn(⬅️)) points[sel + 1].x -= 1
	if (btn(➡️)) points[sel + 1].x += 1
	if (btn(⬆️)) points[sel + 1].y -= 1
	if (btn(⬇️)) points[sel + 1].y += 1	
end

function _draw()
	cls()
	draw_bezier(points)
	foreach(points, draw_point)
	draw_point(points[sel + 1], 3)
end	

function draw_point(p, c)
	c = c or 2
	pset(p.x, p.y, c)
end

function draw_bezier(b)
	n = max(abs(b[3].x - b[1].x),50)
	for i=0, n, 1 do
		t= i/n
		lx = quad_bezier(t, b[1].x, b[2].x, b[3].x)
		ly = quad_bezier(t, b[1].y, b[2].y, b[3].y)
		pset(lx, ly, 6)
	end	
end	

function lerp(a, b, c)
	return a + (b - a) * c
end
 
function quad_bezier(t, p0, p1, p2)
	local l1 = lerp(p0, p1, t)
	local l2 = lerp(p1, p2, t)
	local quad = lerp(l1, l2, t)
	return quad
end