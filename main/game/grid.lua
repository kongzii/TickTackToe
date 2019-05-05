Grid = {}
Grid.__index = Grid

-- left, right, up, down, one diagonal), (second diagonal)
local AROUND_DIRECTIONS = {{-1, 0}, {1, 0}, {0, 1}, {0, -1}, {-1, 1}, {1, -1}, {1, 1}, {-1, -1}}

function Grid:create(size, field_size)
	local grid = {}
	setmetatable(grid, Grid)

	for i = 1, size do
		grid[i] = {}

		for j = 1, size do
			grid[i][j] = "empty"
		end
	end

	grid.size = size
	grid.field_size = field_size

	return grid
end

function Grid:get_copy()
	local copy = Grid:create(self.size, self.field_size)
	
	for i = 1, self.size do
		for j = 1, self.size do
			copy[i][j] = self[i][j]
		end
	end
	
	return copy
end

function Grid:is_valid_coord(coord) 
	return coord.x >= 1 and coord.y >= 1 and coord.x <= self.size and coord.y <= self.size
end

function Grid:get_coords(position)
	local x = math.floor(position.x / self.field_size) + 1
	local y = math.floor(position.y / self.field_size) + 1

	return vmath.vector3(x, y, 0)
end

function Grid:get_centered_position(coords)
	local x = coords.x * self.field_size - self.field_size / 2
	local y = coords.y * self.field_size - self.field_size / 2

	return vmath.vector3(x, y, 0)
end

function Grid:paint()
	for i = 0, self.size - 1 do
		local x = vmath.vector3(i * self.field_size, 0, 0)
		local y = vmath.vector3(0, i * self.field_size, 0)

		local line = "#line"

		factory.create(line, x)
		factory.create(line, y, vmath.quat_rotation_z(- math.pi / 2))
	end 
end

function Grid:print(offset)
	for y = self.size, 1, -1 do
		if offset then
			io.write(offset)
		end
		
		for x = 1, self.size do
			if self[x][y] == "human" then
				io.write("X ")
			elseif self[x][y] == "computer" then
				io.write("O ")
			else
				io.write("_ ")
			end
			
		end

		io.write("\n")
	end

	io.flush()
end

function Grid:get_random_free_coord()
	local set = self:get_free_coords()

	if #set == 0 then
		return nil
	end

	return set[math.random(#set)]
end

function Grid:get_occupied_coords()
	local set = {}

	for y = 1, self.size do
		for x = 1, self.size do
			if self[x][y] ~= "empty" then
				table.insert(set, vmath.vector3(x, y, 0))
			end
		end
	end

	return set
end

function Grid:get_free_coords()
	local set = {}

	for y = 1, self.size do
		for x = 1, self.size do
			if self[x][y] == "empty" then
				table.insert(set, vmath.vector3(x, y, 0))
			end
		end
	end

	return set
end

function Grid:get_near_occupied_free_coords()
	local occupied_coords = self:get_occupied_coords()

	local visited = {}
	local near_occupied_free_coords = {}

	for _, occ_coord in pairs(occupied_coords) do
		for _, direction in pairs(AROUND_DIRECTIONS) do
			local x = occ_coord.x + direction[1]
			local y = occ_coord.y + direction[2]

			local coord = vmath.vector3(x, y, 0)
			
			if self:is_valid_coord(coord) and self[x][y] == "empty" and (not visited[x] or not visited[x][y]) then
				if not visited[x] then
					visited[x] = {}
				end

				visited[x][y] = true
				table.insert(near_occupied_free_coords, coord)
			end
		end
	end

	return near_occupied_free_coords
end