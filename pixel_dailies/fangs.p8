pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
function _draw()
	cls()
	rectfill(0,0,128,128, 15)
	
	local x = 55 
	local y = 60
	
	palt(0, false)
	palt(11,true)
	
 local	speed = 4
	
	
	
	spr(9,
		cos((time() - 1.6 ) / speed) * 10 * 4 + x, 
		sin((time() - 1.6 )/ speed) * 10 * 2 + y, 
		2, 2)
	
	spr(7,
		cos((time() - 1.2 ) / speed) * 10 * 4 + x, 
		sin((time() - 1.2 )/ speed) * 10 * 2 + y, 
		2, 2)
	
	spr(5,
		cos((time() - .8 ) / speed) * 10 * 4 + x, 
		sin((time() - .8 )/ speed) * 10 * 2 + y, 
		2, 2)
	
	spr(3,
		cos((time() - .4 ) / speed) * 10 * 4 + x, 
		sin((time() - .4 )/ speed) * 10 * 2 + y, 
		2, 2)
	
	spr(3,
		cos((time() - .4 ) / speed) * 10 * 4 + x, 
		sin((time() - .4 )/ speed) * 10 * 2 + y, 
		2, 2)
	
	spr(1,
		cos((time() + 0 ) / speed) * 10 * 4 + x, 
		sin((time() + 0)/ speed) * 10 * 2 + y, 
		2, 2)
	
	
				 
	
	
end


__gfx__
00000000bbbbbccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb888888bbbbb0000000000000000000000000000000000000000
00000000bbbccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbb8888888888bbb0000000000000000000000000000000000000000
00700700bbccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbb0bbbbbbbbbb888bbb222bbbbbb888888888888bb0000000000000000000000000000000000000000
00077000bccccccc7777cccbbbbbb00000bbbbbbbbbb000bb0000bbbbbb888bbb222bbbbb888888bbb8888bb0000000000000000000000000000000000000000
00077000bcccccc77777cccbbbbb0000000bbbbbbbb00000000000bbbbb2888bb222bbbbb9888bbbbbb88bbb0000000000000000000000000000000000000000
00700700ccccccc77cccccccbbbb00bbb00bbbbbbb000000000000bbbbb2888bb222bbbb9999bbbbbbbbbbbb0000000000000000000000000000000000000000
00000000ccccccc77cccccccbbbbbbbbb00bbbbbbb00000000000bbbbbb22888b222bbbb9999bbbbbbbbbbbb0000000000000000000000000000000000000000
00000000ccccccc77cccccccbbbbbb00000bbbbbbb0000000000bbbbbbb22888b222bbbb9999bbbbbcccccbb0000000000000000000000000000000000000000
00000000ccccc777777cccccbbbbb000000bbbbbbb0000000000bbbbbbb222888222bbbb9999bbbbbccccccb0000000000000000000000000000000000000000
00000000ccccc77777ccccccbbbb00bbb000bbbbbb0000000000bbbbbbb222888222bbbb9999bbbbbbbbcccb0000000000000000000000000000000000000000
00000000ccccccc77cccccccbbbb000000000bbbbb00000000000bbbbbb222b88822bbbb9999bbbbbbbbcccb0000000000000000000000000000000000000000
00000000bcccccc77ccccccbb9bbb00000b00999bbb00000000000bbbbb222b88822bbbbb99933bbbbb3cccb0000000000000000000000000000000000000000
00000000bcccccc77ccccccbbb9bbbbbbbbbbb99bbb00000000000bbbbb222bb8882bbbbb993333333333cbb0000000000000000000000000000000000000000
00000000bbccccc77cccccbbbbb99999999999b9bbbb000000000bbbbbb222bb8882bbbbbb333333333333bb0000000000000000000000000000000000000000
00000000bbbcccc77ccccbbbbbbb999999999bbbbbbbb00bb000bbbbbbb222bbb888bbbbbbb3333333333bbb0000000000000000000000000000000000000000
00000000bbbbbcc77ccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bbbbb0000000000000000000000000000000000000000
