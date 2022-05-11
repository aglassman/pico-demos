points={p0={x=0,y=0}, p1={x=40,y=80}, p2={x=80,y=80}}

function _init()

end	

function _update()
	if (btn(⬅️)) points.p1.x -= 1
	if (btn(➡️)) points.p1.x += 1
	if (btn(⬆️)) points.p1.y -= 1
	if (btn(⬇️)) points.p1.y += 1	
end

function _draw()
	cls()
	for k, point in pairs(points) do
		draw_point(point)
	end	
	draw_bezier(points)
end	

function draw_point(point)
	pset(point.x, point.y, 3)
end	

function draw_bezier(points)
	n = abs(points.p2.x - points.p0.x)
	for i=0, n, 1 do
		t= i/n
		lx = quad_bezier(t, points.p0.x, points.p1.x, points.p2.x)
		ly = quad_bezier(t, points.p0.y, points.p1.y, points.p2.y)
		pset(lx, ly, 4)
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