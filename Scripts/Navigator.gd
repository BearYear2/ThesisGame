extends Node2D

#get a reference to the navigation agent and a* agent
@onready var navAgent = get_node("../NavAgent2D")
@onready var AStarAgent :Node = get_node("../AStarAgent2D")
@export var searchRadius = 2
enum Mode {NavAgent,AStar}

#no character can have negative location, at least those that move on the grid
#this is very important, there were a lot of issues with A*
#and the tilemap containing tiles on negative positions


func GetDistance(a:Node2D, b:Node2D) -> float:
	var aGlobal = GetGlobalPosition(a)
	var bGlobal = GetGlobalPosition(b)
	return aGlobal.distance_to(bGlobal)

#shortcut function to get the proper global_position
func GetGlobalPosition(a:Node2D) -> Vector2:
	var temp : Vector2 = Vector2.ZERO
	if a.is_inside_tree():
		temp = a.global_position
	else:
		temp = a.position
	return temp

#Call this function to deal with calculating and advancing through the map
func Navigate(actor:CharacterBody2D,speed:float,mode=Mode.NavAgent) ->int:
	var result = -1
	
	#simple shorthand to use the appropiate node when computing navigation
	var Agent = navAgent if mode == Mode.NavAgent else AStarAgent
	#code adapted from here
	#https://www.youtube.com/watch?v=-juhGgA076E
	var currentLocation = GetGlobalPosition(actor)
	#this is why we need to have identical calls to the navigation agent
	#otherwise we would need a switch (match) structure in order to call functions
	var nextLocation = Agent.get_next_path_position()
	var newVelo = currentLocation.direction_to(nextLocation)
	#this is crucial, we need to set our actors moveDir
	actor.moveDir = newVelo
	#euclidean distance to the target
	var distance = currentLocation.distance_to(Agent.get_target_position())
	#var distance = currentLocation.distance_to(nextLocation)
	#this might also cause issues with AStar?
	if  distance >= searchRadius:
		result = 1 # running
	else:
		result = 0 #stopped
	return result
