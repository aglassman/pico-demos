-- [[ Table Helpers ]]
function t_add(table, item)
	table[#table + 1]=item
end	

function t_append_all(ta, tb)
	local ta_len = #ta
	local i = 1
	for b_item in all(tb) do
		ta[ta_len + i] = b_item
		i+=1
	end	
end

function t_sort(a,cmp)
  for i=1,#a do
    local j = i
    while j > 1 and cmp(a[j-1],a[j]) do
        a[j],a[j-1] = a[j-1],a[j]
    j = j - 1
    end
  end
end	

--[[ Generate a random integer between min and max, inclusive. ]]
function rnd_int(min, max)
	return min + flr(rnd(max - min + 1))
end

function rnd_float(min, max)
	return min + rnd(max - min + 1)
end	

function rnd_bool()
	return rnd_int(0,1) == 1
end	

--[[ Position Helpers.  Expects positions where format is {x, y}. ]]
function distance(p1, p2)

end

-- Rect is defined as 
function point_in_rect(p1, rect)

end	