target = {
	sprite=1,
	position={64, 64}
}

objs = {}

duration=1

index = -1


function multi_offset_example()
	local str="hello world"
	local objs = {}
	for i = 1, #str do
    	local c = sub(str, i,i)
    	local new_obj = {
				text=c,
				text_color=11,
				position={64, 64}
			}
		local new_animation = {
	    		offset=.3*i,
				pipeline={circle(20,20)},
				duration=5,
				mirror=false,
				loop=-1}	
    	objs[i]={obj=new_obj, animation=new_animation}
	end
	return objs
end	

function q_bezier_draw(points)
	local q_bz = q_bezier(points)
	return function()
		n = 200
		for i=0, n, 1 do
			local t = i / n
			local x, y = q_bz(t)
			pset(x, y, 7)
		end	

		for p in all(points) do
			pset(p.x, p.y, 8)
		end
	end	
end

examples = {
		{
			description="linear - x only, 3 times",
			obj=target,
			animation={
				pipeline={linear(50, 0)},
				duration=duration,
				loop=3
			}
		},
		{
			description="linear - y only, 3 times",
			obj=target,
			animation={
				pipeline={linear(0, 50)},
				duration=duration,
				loop=3
			}
		},
		{
			description="linear - x and y, 3 times",
			obj=target,
			animation={
				pipeline={linear(50, 50)},
				duration=duration,
				loop=3
			}
		},
		{
			description="linear - x only, reverse, 3 times",
			obj=target,
			animation={
				pipeline={linear(0, 50)},
				duration=duration,
				reverse=true,
				loop=3
			}
		},
		{
			description="linear - x only, mirror, 3 times",
			obj=target,
			animation={
				pipeline={linear(0, 50)},
				duration=duration,
				mirror=true,
				loop=3
			}
		},
		{
			description="circle",
			obj=target,
			animation={
				pipeline={circle(20, 20)},
				duration=duration,
				loop=-1
			}
		},
		{
			description="oval",
			obj=target,
			animation={
				pipeline={circle(50, 20)},
				duration=duration,
				loop=-1
			}
		},
		{
			description="smooth transition (try change spped)",
			obj=target,
			animation={
				pipeline={linear(30, 0)},
				duration=duration,
				transition="smooth",
				mirror= true,
				loop=-1
			}
		},
		{
			description="sin_x",
			obj=target,
			animation={
				pipeline={sin_x(30)},
				duration=duration,
				loop=-1
			}
		},
		{
			description="sin_y",
			obj=target,
			animation={
				pipeline={sin_y(30)},
				duration=duration,
				loop=-1
			}
		},
		{
			description="sin_x -> sin_y",
			obj=target,
			animation={
				pipeline={sin_x(15), sin_y(30)},
				duration=duration,
				loop=-1
			}
		},
		{
			description="quad bezier - 1",
			obj=target,
			animation = {
				pipeline={translate(-64, -64),q_bezier({{x=0,y=64},{x=64,y=10},{x=128,y=64}})},
				draw_path_fn=q_bezier_draw({{x=0,y=64},{x=64,y=10},{x=128,y=64}}),
				duration=duration,
				loop=-1
			}
		},
		{
			description="quad bezier - 2",
			obj=target,
			animation = {
				pipeline={translate(-64, -64),q_bezier({{x=30,y=100},{x=100,y=10},{x=100,y=100}})},
				draw_path_fn=q_bezier_draw({{x=30,y=100},{x=100,y=10},{x=100,y=100}}),
				duration=duration,
				loop=-1
			}
		},
		{
			description="quad bezier - mirror",
			obj=target,
			animation = {
				pipeline={translate(-64, -64),q_bezier({{x=30,y=100},{x=100,y=10},{x=100,y=100}})},
				draw_path_fn=q_bezier_draw({{x=30,y=100},{x=100,y=10},{x=100,y=100}}),
				duration=duration,
				mirror=true,
				loop=-1
			}
		},
		{
			description="quad bezier - no path",
			obj=target,
			animation = {
				pipeline={translate(-64, -64),q_bezier({{x=30,y=100},{x=100,y=10},{x=100,y=100}})},
				duration=duration,
				mirror=true,
				loop=-1
			}
		},
		{
			description="text",
			obj={
				text="hello world",
				text_color=11,
				position={64, 64}
			},
			animation={
				pipeline={circle(20,20)},
				duration=duration,
				mirror=false,
				loop=-1}
		},
		{
			description="offset",
			multi=multi_offset_example()
		}						
}

for i=1, #examples do
	examples[i].index = i
end	


function get_example()
	return examples[(index % #examples) + 1]
end	

function reset_example()
	local example = get_example()

	if example.multi then
		halt_animation(target)
		target.hide = true
		for e in all(example.multi) do
			e.animation.duration = 3.6
			animate(e.obj, e.animation)
		end
	else
		target.hide = false
		example.animation.duration = duration
		animate(example.obj, example.animation)
	end	
end	

function next_example()
	index += 1
	reset_example()
end

function previous_example()
	index -= 1
	reset_example()
end		

function _init()
	next_example()
end	

function _update()
	if (btnp(❎)) sel +=1
	if (btnp(❎)) sel %=3
	if (btnp(⬅️)) previous_example()
	if (btnp(➡️)) next_example()
	if (btnp(⬆️)) duration += 0.2; reset_example()
	if (btnp(⬇️)) duration -= 0.2; reset_example()	
end

function _draw()
	cls()
	example = get_example()
	print(example.index .. ": " .. example.description, 10, 10, 7)
	print("duration: " .. duration, 10, 20, 7)
	if example.multi then
		for e in all(example.multi) do
			draw_obj(e.obj)
		end
	else
		draw_obj(example.obj)
	end	
end	


function draw_obj(obj)
	local x, y = obj:animation_transpose_fn()

	if not obj.hide then

		if obj.sprite then
			spr(obj.sprite, x, y)
		end	

		if obj.text then
			print(obj.text, x, y, obj.text_color)
		end	
		
		if obj.animation_draw_path_fn then
			obj:animation_draw_path_fn()
		end
	end		
end	
