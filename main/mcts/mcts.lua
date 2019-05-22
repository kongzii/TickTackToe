require "main.mcts.config"
require "main.mcts.node"

MCTS = {}
MCTS.__index = MCTS

function MCTS:create(root, game, time_limit_seconds)
	local mcts = {}
	setmetatable(mcts, MCTS)

	mcts.start_time = os.time()

	if root == nil then
		mcts.root = Node:create(game)
	else
		mcts.root = root
		mcts.root.depth = 0
	end

	mcts.time_limit_seconds = time_limit_seconds
	
	return mcts
end

function MCTS:get_action()
	while self:time_lefts() > 0 do
		local node = self.root
		local game = self.root.game
		
		-- Selection
		while node:is_fully_expanded() and not node:is_terminal() do
			if game:get_next_turn() == "computer" then
				-- node = node:get_min_visits_child("computer")
				node = node:get_max_utc_child("computer")
			else
				-- node = node:get_min_visits_child("human")
				node = node:get_max_utc_child("human")
			end

			game = node.game
		end

		-- Expansion
		if not node:is_fully_expanded() and not node:is_terminal() then
			game = game:get_copy()

			local coord = node:get_random_untried_coord()
			game:put_mark(coord, game:get_next_turn())
			
			node = node:add_child(coord, game)
		end

		game = game:get_copy()

		-- Rollout
		while not game:is_end() do
			game:put_mark(game.grid:get_random_free_coord(), game:get_next_turn())
		end

		-- Backpropagation
		while node do
			node:update(game.winner)
			node = node.parent
		end
	end

	return self.root:get_max_q_coord("computer")
end

function MCTS:time_lefts()
	return self.time_limit_seconds - os.difftime(os.time(), self.start_time)
end