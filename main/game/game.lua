require "main.game.grid"

Game = {}
Game.__index = Game

-- players
local PLAYERS = {"human", "computer"}

-- (left, right), (up, down), (one diagonal), (second diagonal)
local DIRECTIONS = {{{-1, 0}, {1, 0}}, {{0, 1}, {0, -1}}, {{-1, 1}, {1, -1}}, {{1, 1}, {-1, -1}}}

function Game:create(last_turn, size, field_size, required_to_win)
	local game = {}
	setmetatable(game, Game)

	game.last_turn = last_turn
	game.grid = Grid:create(size, field_size)
	game.required_to_win = required_to_win

	game.winner = nil
	game.simulation = false
	game.moves_left = size * size
	game.last_mark = nil
	
	return game
end

function Game:get_next_turn() 
	if self.last_turn == "human" then
		return "computer"
	else
		return "human"
	end
end

function Game:get_copy()	
	local copy = Game:create(self.last_turn, self.grid.size, self.grid.field_size, self.required_to_win)
	
	copy.simulation = true
	copy.winner = self.winner
	copy.moves_left = self.moves_left

	copy.grid = self.grid:get_copy()

	return copy
end

function Game:is_end()
	return self.moves_left == 0 or self.winner
end

function Game:check_tie()
	if self.moves_left == 0 and not self.winner then
		self.winner = "tie"
	end
	
	return self.winner == "tie"
end

function Game:check_winner(position, turn)	
	for i = 1, 4 do
		local count = 1

		for j = 1, 2 do
			local direction = DIRECTIONS[i][j]

			local x = direction[1]
			local y = direction[2]

			local field = {x = position.x, y = position.y}

			while (true) do
				field.x = field.x + x
				field.y = field.y + y

				if self.grid:is_valid_coord(field) and self.grid[field.x][field.y] == turn then
					count = count + 1

					if count == self.required_to_win then
						self.winner = turn
						return true
					end
				else
					break
				end
			end
		end		
	end

	return false
end

function Game:put_mark(coord, turn)	
	if self.grid[coord.x][coord.y] == "empty" then
		self.moves_left = self.moves_left - 1
		self.grid[coord.x][coord.y] = turn

		if not self.simulation then
			local component = "#" .. turn
			local centered_position = self.grid:get_centered_position(coord)
			
			factory.create(component, centered_position)
		end

		self.last_mark = coord
		self.last_turn = turn
		self:check_winner(coord, turn)
		self:check_tie()

		return true
	else
		return false
	end
end
