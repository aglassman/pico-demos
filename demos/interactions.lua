function dog_interact(dog, item)
	local in_rect = false

	if item.check_intersection then
		in_rect = inside_rect(dog:dog_mouth_position(), item.position, item.rect_dimensions)
	end	

	if in_rect and item.type == "hole" and item.size < 1 and dog:is("sniffing") and dog.current_hole == nil then
		dog:do_bark()
	end

	if in_rect and item.type == "hole" and item.size >= item.hole_depth and dog:is("sniffing") and item.uncovered != nil then
		dog:pickup_item(item.uncovered)
		item.uncovered = nil
	end

	if in_rect and item.type == "dog_toy" and dog:is("sniffing") then
		dp("pick it up!")
		dog:pickup_item(item)
	end	


end

function find_existing_hole(dog, holes)
	if dog.current_hole == nil then
		for hole in all(holes) do
			local rx, ry = unpack(hole.rect_dimensions)
			if inside_rect(dog:dog_mouth_position(), hole.position, {rx + 2, ry + 2}) then
				dog.current_hole = hole
				if hole.size < hole.hole_depth then
					hole.flip_x = dog.facing == "left"
				end	
				break
			end	
		end		
	end
end	