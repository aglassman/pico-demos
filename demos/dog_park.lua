-- enable = enables devkit mode with mouse and keyboard
-- btn_emu = left,right,middle mouse buttons -> btn(❎),btn(🅾️),btn(6)
-- ptr_lock = enable pointer lock
function mkb_init(enable, btn_emu, ptr_lock)
  -- pass args as bitfield into hardware register
  poke(0x5f2d,(enable   and 1 or 0)
             |(btn_emu  and 2 or 0)
             |(ptr_lock and 4 or 0))
end

pressed=""

function handle_keypress(key)
	pressed = pressed .. key
end	


-- Globals
last_id=0
debug_draw_xy=false
move_target={}

-- Menu items
menuitem(1, "toggle debug xy", function() debug_draw_xy = not debug_draw_xy end)

debug_functions={
	q=function ()
		debug_draw_xy = not debug_draw_xy
	end,
	t=function ()
		park.items[1].is_open = not park.items[1].is_open
	end,
	b=function ()
		local new_toy = dog_toy:new({rnd_int(20, 40), rnd_int(20, 40)})
		t_add(park.bg_items, new_toy)
		park.dogs[1]:pickup_item(new_toy)
	end,
	h=function ()
		local new_hole = hole:new({rnd_int(20, 40), rnd_int(20, 40)})
		t_add(park.bg_items, new_hole)
	end
}

function debug_input()
	while stat(30) do
	    local f = debug_functions[stat(31)]
	    if (f) f()	
	end
end

function dp(string)
	printh( string, "dog_park_debug.txt", true)
end	

function id()
	last_id += 1
	return last_id
end	

function draw_xy(obj)
	pset(obj.position[1], obj.position[2], 8)
end	

function draw_all(t)
	for obj in all(t) do
		obj:draw()
	end	
end	


function pcord(position)
	printh("{" .. position[1] .. ", " .. position[2] .. "}", "demo_log.txt")
end	

function _init()
	mkb_init(true,false,false)
	cls()
	park:init(1)
end

function _update()
	debug_input()
	park:update()
end

function _draw()
	cls()
	park:draw()
	print(pressed, 20, 20, 7)
end

-- position_1 is the point to check if it exists in the rect
-- position_2 is the rect center
-- rect_dimensions is the x/y offset from center in either direction
function inside_rect(position_1, position_2, rect_dimensions)
	local px, py = unpack(position_1)
	local rx, ry = unpack(position_2)
	local rw, rh = unpack(rect_dimensions)
	return 
		px >= (rx - rw) and
		px <= (rx + rw) and
		py >= (ry - rh) and  
		py <= (ry + rh)
end	
