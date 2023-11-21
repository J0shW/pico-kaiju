pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--this is a prototype to test spawning buildings
--and scrolling the map
--it should be noted that the map is not actually
--scrolling, but rather the player and buildings
--are moving relative to the map
--this prototype should spawn buildings as the player moves to new areas
--and despawn buildings as the player moves away from them (~100 tiles away)
function _init()
	init_player()

	--buildings array
	buildings={
		-- {spr=4,x=-30,y=-30},
		-- {spr=5,x=30,y=30},
	}
	--building variables
	despawn_distance=640
	
	--map functions
	map_x,map_y=0,0
end

function _update()
	update_player()
	-- despawn_buildings()
	-- spawn_buildings()
end

function _draw()
	cls(3)
	draw_camera()
	draw_terrain()

	draw_buildings()
	despawn_buildings()
	spawn_buildings()
	draw_player()
	--debug
	-- print('b'..#buildings, p_x, p_y-6, 7)
	print(''..p_x..','..p_y, p_x, p_y-6, 7)
	--print x and y for each building
	for i=1,#buildings do
		local b=buildings[i]
		if (b == nil) return
		print('b'..i, cx+2, cy+(i*6), 7)
		print('x '..b.x, cx+12, cy+(i*6), 7)
		print('y '..b.y, cx+40, cy+(i*6), 7)
		-- if (i > 1) then
		-- 	print('l'..tostring(doRectsOverlap(buildings[i].x,buildings[i].y,72,48,buildings[i-1].x,buildings[i-1].y,72,48)), cx+40, cy+(i*6), 7)
		-- end
	end
	if (false) then
		print('cx '..cx, cx+10, cy+10, 7)
		print('cy '..cy, cx+10, cy+16)
		print('p_x '..p_x, cx+10, cy+22)
		print('p_y '..p_y, cx+10, cy+28)
		print('mod '..(-60%128), cx+10, cy+34)
		print('mod '..(-120%128), cx+10, cy+40)
	end
end

function draw_camera()
	cx=p_x-60
	cy=p_y-60
	camera(cx, cy)
end

function init_player()
	--player variables
	p_x,p_y=0,0

	--direction
	p_dx,p_dy=0,0
	--animation variable
	p_flip=false	
	p_spr=2
end

function draw_player()
	if not p_flip then
		if(p_dx<0)p_flip=true
	else
		if(p_dx>0)p_flip=false
	end
 	--draw player
  	spr(p_spr,p_x,p_y,1,1,p_flip)
end

function draw_buildings()
	for i=1,#buildings do
		if (buildings[i].x == 0) return
		map(16,0,
		buildings[i].x,
		buildings[i].y,
		9,6)
	end
end

function despawn_buildings()
	--delete buildings that are too far away
	for i=1,#buildings do
		local b=buildings[i]
		if (b == nil) return
		if (abs(b.x-p_x)>despawn_distance) or (abs(b.y-p_y)>despawn_distance) then
			--remove building
			deli(buildings,i)
		end
	end
end

function rndGrid(startPos)
	local mini, maxi = 128, despawn_distance-128  -- The range of the random number
	local adjustedMin = ceil(mini / 8) * 8  -- Round up min to the nearest multiple of 8
    local adjustedMax = flr(maxi / 8) * 8  -- Round down max to the nearest multiple of 8
    
    local range = (adjustedMax - adjustedMin) / 8  -- Calculate the adjusted range

	local offset = mini / 8  -- Calculate the minimum distance from the player in multiples of 8

    local minBound = (startPos / 8) - offset + adjustedMin  -- Calculate the minimum boundary
    local maxBound = (startPos / 8) + offset + adjustedMin  -- Calculate the maximum boundary

    local randomNumber = flr(rnd(range + 1)) * 8 + adjustedMin  -- Generate a random multiple of 8
    return min(maxi, max(mini, randomNumber)) -- Return the random number, clamped to the min and max
	-- return flr(rnd(range))*8+min
end

function getBSpawn()
	--get an x position that is at least 128 pixels from the player
	local x,y=rndGrid(p_x),rndGrid(p_y)
	while (abs(x-p_x)<128) do 
		x=rndGrid(p_x)
	end
	while (abs(y-p_y)<128) do
		y=rndGrid(p_y)
	end
	if rnd(1)>0.5 then x*=-1 end
	if rnd(1)>0.5 then y*=-1 end
	return {x=x,y=y}
end

function spawn_buildings()
	--spawn new buildings if the building count if below 10
	if #buildings<8 then
		local width = 8*9
		local height = 8*6

		local bspawn = getBSpawn()

		--If there's an overlap, generate a new position until there's no overlap
		local overlaps = true
		while overlaps do
			bspawn = getBSpawn()
			overlaps = false
	
			for i=1, #buildings do
				if (doRectsOverlap(buildings[i].x,buildings[i].y,width,height,bspawn.x,bspawn.y,width,height)) then
					overlaps = true
					break
				end
			end
		end

		--spawn a building
		add(buildings,{spr=4,x=bspawn.x,y=bspawn.y})
	end
	
end

function draw_terrain()
	local map_offset_x = 128 - (cx % 128)
	local map_offset_y = 128 - (cy % 128)

	-- Render the map based on the camera's position
	for i = -1, 1 do
		for j = -1, 1 do
			map(0, 0,
				map_offset_x + 128 * i + cx,
				map_offset_y + 128 * j + cy,
				16, 16)
		end
	end
end

function update_player()
	p_dx,p_dy=0,0
	if btn(⬅️) then
		p_dx=-1
	end
	if btn(➡️) then
		p_dx=1
	end
 	if btn(⬆️) then
		p_dy=-1
	end
 	if btn(⬇️) then
		p_dy=1
	end
	--update player position
	p_x+=p_dx
	p_y+=p_dy
end

-- Function to check if two rectangles overlap
function doRectsOverlap(rect1_x, rect1_y, rect1_width, rect1_height, rect2_x, rect2_y, rect2_width, rect2_height)
    return rect1_x < rect2_x + rect2_width and
           rect1_x + rect1_width > rect2_x and
           rect1_y < rect2_y + rect2_height and
           rect1_y + rect1_height > rect2_y
end
__gfx__
00000000000000000000099000000000ddddddd0111111100755a557777777777755555700000000000000000000000000000000000000000000000000000000
0000000000000000000a989900000000dadadad01a1a1a100755a557555555555555555500000000000000000000000000000000000000000000000000000000
007007000000000000a99777000c8000dadadad01a1a1a1007555557555555555555555500000000000000000000000000000000000000000000000000000000
000770000000000000999999066c8660ddddddd01111111007555557aa5555aa5555555500000000000000000000000000000000000000000000000000000000
00077000000000000a99990006777760dadadad01a1a1a1007555557555555555555555500000000000000000000000000000000000000000000000000000000
00700700000006600999909967777776dadadad01a1a1a1007555557555555555555555500000000000000000000000000000000000000000000000000000000
00000000000056669995990065577556ddddddd0111111100755a557777777777755555700000000000000000000000000000000000000000000000000000000
00000000000555550999599065566556dd444dd0114441100755a557000000000755555700000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000006000000060504050600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000100000000000008070707080707070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000006040504060000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000008070707080707070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000001000006050405060000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000008070707080707070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
