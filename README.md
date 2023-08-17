# Tic-Tac-Toe with MCTS opponent

Playable at [http://jung.ninja/game/](http://jung.ninja/game/). Simple game made with [Defold](https://www.defold.com/). Computation time represents time given for computer to make a decision.

## Monte Carlo Tree Search

Computer finds his move based on Monte Carlo tree search algorithm with Upper Confidence Bound to maintain balance between exploration and exploitation.

## MCTS parameters

In `main/mcts/config.lua` we can play with the parameters, especially UCTK and REWARDs. 

## Possible improvements

This is my first project with [Defold](https://www.defold.com/) and even in [LUA](https://www.lua.org/) language, but it demonstrate MCTS quite good. A lot of things could be optimized and then MCTS would be capable of computing better strategies in given time.

