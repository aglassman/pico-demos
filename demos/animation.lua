-- Always return the object's position
function a_identity(game_obj)
	return game_obj.position[1], game_obj.position[2]
end

--[[
	Returns a new quadratic bezier function with n resolution. pct=0..1
	b={{x=0,y=0},{x=40,y=80},{x=80,y=80}}
]]
function q_bezier(b)
	return function(pct)
		return qb(pct, b[1].x, b[2].x, b[3].x), qb(pct, b[1].y, b[2].y, b[3].y)
	end
end	

-- linear interpolation (start, end, percent)
function lerp(a, b, c)
	return a + (b - a) * c
end

function qb(t, p0, p1, p2)
	return lerp(lerp(p0, p1, t), lerp(p1, p2, t), t)
end

function linear(pct, point)
	return pct * point.x, pct * point.y
end	


function transpose(fn)
	return function(obj, pct)
		local dx, dy = fn(pct)
		return obj.position[1] + dx, obj.position[2] + dy
	end
end

--[[
	animate(target, args)
	target - a target table to anmiate.
	* Requires an entry of "position" of shape {x=number, y=number}
	
	Animate stores the following attributes on the target:
	* st: number (start time)
	* et: number (end time)
	* loop_count: number (to track iterations)
	* reverse: boolean (to track direction)
	* animation_complete: boolean (to track if iteration is complete)
	* transpose_fn: Function that returns an x/y coordinate for where the sprite should be drawn.
	* draw_path_fn: Function that can draw the full animation path.

	Animate Args
	* duration: in seconds, the length of the animation (default 1.0)
	* loop:  Number of iterations (default 1)
	* direction:  "forward" or "reverse" (default "forward")
	* mirror: boolean (default false) Will mirror animation after each iteration.
	* smooth: If animate is called for the target object before a previous animation
		is complete, it will not reset reverse, loop_count, or st attributes. It will
		only recalcuate the end time, and replace the transpose_fn, and path attributes.
]]
function animate(target, args)
	local duration = args.duration or 1
	local loop = args.loop or 1
	local direction = args.direction or "forward"
	local mirror = args.mirror or false


	if (not target.animation_complete) and args.transition == "smooth" then
		target.et = target.st + duration
	else
		if direction == "forward" then
			target.reverse = false
		else
			target.reverse = true
		end	
		
		target.st = time()
		target.et = time() + duration
		target.loop_count = 0

	end
	
	target.animation_complete = false
	target.draw_path_fn = args.draw_path_fn

	target.transpose_fn = function (self)
		local pct
		if self.reverse then
			pct = 1 - (( time() - self.st) / duration)
		else
			pct = ( time() - self.st) / duration
		end	

		local x, y = args.transpose_fn(self, pct)

		if time() > self.et then
			if self.loop_count == loop - 1 then
				local x, y = args.transpose_fn(self, 1)
				self.position = {x, y}
				self.transpose_fn = a_identity
				self.animation_complete = true
				return x, y
			else
				if mirror then
					self.reverse = not self.reverse
				end	
				self.st = time()
				self.et = time() + duration
				self.loop_count += 1
			end	
		end	

		return x, y
	end
end

