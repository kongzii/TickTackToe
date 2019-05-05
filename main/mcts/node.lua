Node = {}
Node.__index = Node

function Node:create(game, depth)
	local node = {}
	setmetatable(node, Node)

	node.uctk = config.UCTK_CONSTANT
	node.depth_limit = config.TREE_DEPTH_LIMIT

	node.positive_reward = config.POSITIVE_REWARD
	node.negative_reward = config.NEGATIVE_REWARD
	node.neutral_reward = config.NEUTRAL_REWARD

	node.score = {human = 0, computer = 0}
	node.visits = {human = 0, computer = 0}
	
	node.depth = depth or 0
	node.parent = nil
	node.children = {}
	node.coord = nil

	node.game = game:get_copy()
	node.untried_coords = node.game.grid:get_near_occupied_free_coords()
	
	return node
end

function Node:is_fully_expanded()
	return #self.untried_coords == 0
end

function Node:is_terminal()
	return self.game:is_end() or self.depth >= self.depth_limit
end

function Node:get_random_untried_coord()
	if #self.untried_coords == 0 then
		return nil
	end
	
	return self.untried_coords[math.random(#self.untried_coords)]
end

function Node:get_max_q_coord(player)
	return self:get_max_q_child(player).coord
end

function Node:q_value(player)
	return self.score[player] / self.visits[player]
end

function Node:child_utc_value(child, player)
	if child.visits[player] == 0 then
		return math.huge
	end
	
	return child:q_value(player) + self.uctk * math.sqrt(2 * math.log(self.visits[player]) / child.visits[player])
end

function Node:get_max_q_child(player)
	local max_q_child = self.children[1]
	local maximum = self.children[1]:q_value(player)

	for index, child in pairs(self.children) do
		local child_q_value = child:q_value(player)

		if child_q_value > maximum then
			maximum = child_q_value
			max_q_child = child
		end
	end

	return max_q_child
end

function Node:get_max_utc_child(player)
	local max_utc_child = self.children[1]
	local maximum = self:child_utc_value(max_utc_child, player)
	
	for index, child in pairs(self.children) do
		local childs_utc_value = self:child_utc_value(child, player)

		if childs_utc_value > maximum then
			maximum = childs_utc_value
			max_utc_child = child
		end
	end
	
	return max_utc_child
end

function Node:get_min_visits_child(player)
	local min_visits_child = self.children[1]
	local minimum = self.children[1].visits[player]

	for index, child in pairs(self.children) do 
		if child.visits[player] < minimum then
			minimum = child.visits[player]
			min_visits_child = child
		end
	end

	return min_visits_child
end

function Node:erase_untried_coord(coord)
	for index, untried_coord in pairs(self.untried_coords) do
		if untried_coord.x == coord.x and untried_coord.y == coord.y then
			table.remove(self.untried_coords, index)
			return true
		end
	end

	return false
end

function Node:add_child(coord, game)
	self:erase_untried_coord(coord)
	
	local child = Node:create(game, self.depth + 1)

	child.coord = coord
	child.parent = self

	table.insert(self.children, child)
	
	return child
end

function Node:update(winner) 
	self.visits["human"] = self.visits["human"] + 1
	self.visits["computer"] = self.visits["computer"] + 1
	
	if winner == "human" then
		self.score["human"] = self.score["human"] + self.positive_reward
		self.score["computer"] = self.score["computer"] + self.negative_reward
	end

	if winner == "computer" then
		self.score["computer"] = self.score["computer"] + self.positive_reward
		self.score["human"] = self.score["human"] + self.negative_reward
	end

	if winner == "tie" then
		self.score["human"] = self.score["human"] + self.neutral_reward
		self.score["computer"] = self.score["computer"] + self.neutral_reward
	end
end

function Node:print(max_depth, offset_n, depth)
	local depth = depth or 0
	local max_depth = max_depth or math.huge

	local offset = ""
	local offset_n = offset_n or 0
	
	for i = 1, offset_n do
		offset = offset .. " "
	end
	
	io.write(offset .. "Score human: ", self.score.human, "\n")
	io.write(offset .. "Score computer: ", self.score.computer, "\n")
	io.write(offset .. "Visits human: ", self.visits.human, "\n")
	io.write(offset .. "Visits computer: ", self.visits.computer, "\n")
	io.write(offset .. "Q Value human: ", self:q_value("human"), "\n")
	io.write(offset .. "Q Value computer: ", self:q_value("computer"), "\n")
	io.write(offset .. "Untried coords: ", #self.game.grid:get_free_coords(), "\n")
	io.write(offset .. "Next turn: ", self.game:get_next_turn(), "\n")

	if self.coord then
		io.write(offset .. "Coord: ", self.coord.x, " ", self.coord.y, "\n")
	end

	io.write(offset .. "Map:", "\n")
	self.game.grid:print(offset)

	io.write(offset .. "Childs: ", #self.children, "\n")

	if depth + 1 <= max_depth then
		for index, child in pairs(self.children) do
			io.write(offset .. "  ", index, ")", "\n")
			io.write(offset .. "  UTC human: ", self:child_utc_value(child, "human"), "\n")
			io.write(offset .. "  UTC computer: ", self:child_utc_value(child, "computer"), "\n")
			child:print(max_depth, offset_n + 2, depth + 1)
		end
	end

	io.write("\n")
end