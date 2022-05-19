--[[
Pico Animation

A 2D animation library


First, define an animation.
Animations are declarative, and are stored as tables.  You can reuse them, or clone them. They don't hold any
animation state.

You can start simple, and expand on it.

This example will animate the object in a circle, once, over one second.

```
small_circle = {
	pipeline={circle(20,20)}
}
```

This will loop the animatio 10 times, each iteration will take 3 seconds.

```
small_circle_inf = {
	pipeline={circle(20,20)},
	duration=3,
	loop=100
}
```

You can declare multiple functions to effect transform pipeline.
You can also infinitely loop

```
small_circle_inf = {
	pipeline={circle(20,20), linear(20, 0)},
	duration=3,
	loop=-1
}

```

You can animate any object that is represented as a table, it only needs a `position` entry, which stores {x, y} coordinates.

```
target = {
	position={64, 64}
}

animate(target, small_circle_inf)

```

The animation will then attach transpose functions, and state to the target.
See animate function documentation for details.

When the animation is complete, target.animation_complete will be true.

You can halt an animation using:

```
halt_animation(target)
```

This will set target.animation_complete == true, and change the transpose function back to the identiy function.


]]


--[[
Pipeline Transpose Functions

These functions can be composed to combine any number of individual transpose functions into one
function.
]]

--[[
	Returns a new quadratic bezier function with n resolution. pct=0..1
	b={{x=0,y=0},{x=40,y=80},{x=80,y=80}}
]]
function q_bezier(b)
	return function(pct)
		return qb(pct, b[1].x, b[2].x, b[3].x), qb(pct, b[1].y, b[2].y, b[3].y)
	end
end	

function translate(x, y)
	return function(pct)
		return x, y
	end
end	

function linear(x, y)
	return function(pct)
		return pct * x, pct * y
	end	
end	


function sin_x(multiplier)
	return function(pct)
		return sin(pct) * multiplier, 0
	end 
end

function sin_y(multiplier)
	return function(pct)
		return 0, sin(pct) * multiplier
	end 
end	


function sin_xy(x_multiplier, y_multiplier)
	return function(pct)
		return sin(pct) * x_multiplier, sin(pct) * y_multiplier
	end
end

function circle(x_multiplier, y_multiplier)
return function(pct)
		return sin(pct) * x_multiplier, cos(pct) * y_multiplier
	end
end	


function create_pipeline(pipeline)
	return function(self, pct)
		local x = self.position[1]
		local y = self.position[2]
		for fn in all(pipeline) do
			local dx, dy = fn(pct)
			printh("d: " .. dx .. ", " .. dy, "demo_log.txt")
			x += dx
			y += dy
		end
		printh("new: " .. x .. ", " .. y, "demo_log.txt")
		return x, y	
	end
end	


-- Always return the object's position
function a_identity(game_obj)
	return game_obj.position[1], game_obj.position[2]
end


--[[
	animate(target, args)
	target - a target table to anmiate.
	* Requires an entry of "position" of shape {x, y} where x and y are of type number.
	
	Animate stores the following attributes on the target:
	* animation_st: number (start time)
	* animation_et: number (end time)
	* animation_loop_count: number (to track iterations)
	* animation_reverse: boolean (to track direction)
	* animation_complete: boolean (to track if iteration is complete)
	* animation_transpose_fn: Function that returns an x/y coordinate for where the sprite should be drawn.
	* animation_draw_path_fn: Function that can draw the full animation path.

	Animate Args
	* duration: in seconds, the length of the animation (default 1.0)
	* loop:  Number of iterations (default 1)
	* direction:  "forward" or "reverse" (default "forward")
	* mirror: boolean (default false) Will mirror animation after each iteration.
	* transition: string (default nil). Effects the way an in-progress animation will be handled if a new
		animation is applied to the same target.
	   * "smooth" - If animate is called for the target object before a previous animation
		is complete, it will not reset reverse, loop_count, or st attributes. It will
		only recalcuate the end time, and replace the transpose_fn, and path attributes.
	* offset: offset the animation (+/- 0..1)
]]
function animate(target, args)
	local duration = args.duration or 1
	local loop = args.loop or 1
	local direction = args.direction or "forward"
	local mirror = args.mirror or false
	local offset = args.offset or 0


	if (not target.animation_complete) and args.transition == "smooth" then
		target.animation_et = target.animation_st + duration
	else
		if direction == "forward" then
			target.animation_reverse = false
		else
			target.animation_reverse = true
		end	
		
		target.animation_st = time()
		target.animation_et = time() + duration
		target.animation_loop_count = 0

	end
	
	target.animation_complete = false
	target.animation_draw_path_fn = args.draw_path_fn

	local pipelin_fn = create_pipeline(args.pipeline)

	target.animation_transpose_fn = function (self)
		local pct
		local t = time() + offset
		if self.reverse then
			pct = 1 - (( t - self.animation_st) / duration)
		else
			pct = ( t - self.animation_st) / duration
		end	

		local x, y = pipelin_fn(self, pct)

		if time() > self.animation_et then
			if self.animation_loop_count == loop - 1 then
				halt_animation(self)
				return x, y
			else
				if mirror then
					self.animation_reverse = not self.animation_reverse
				end	
				self.animation_st = time()
				self.animation_et = time() + duration
				self.animation_loop_count += 1
			end	
		end	

		return x, y
	end
end

function halt_animation(target)
	target.animation_transpose_fn = a_identity
	target.animation_complete = true
end	

-- Supporting Functions
-- linear interpolation (start, end, percent)
function lerp(a, b, c)
	return a + (b - a) * c
end

-- quadratic bezier
function qb(t, p0, p1, p2)
	return lerp(lerp(p0, p1, t), lerp(p1, p2, t), t)
end
