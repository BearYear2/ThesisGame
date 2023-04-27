extends Node2D
@onready var navAgent = get_node("../NavAgent2D")
@export var searchRadius = 2
enum Mode {NavAgent,AStar}
#A* specific variables
@onready var AStarAgent :Node = get_node("../AStarAgent2D")
#no character can have negative location, at least those that move on the grid

func GetDistance(a:Node2D, b:Node2D) -> float:
	var aGlobal = GetGlobalPosition(a)
	var bGlobal = GetGlobalPosition(b)
	return aGlobal.distance_to(bGlobal)

func GetGlobalPosition(a:Node2D) -> Vector2:
	var temp : Vector2 = Vector2.ZERO
	if a.is_inside_tree():
		temp = a.global_position
	else:
		temp = a.position
	return temp

func Navigate(actor:CharacterBody2D,speed:float,mode=Mode.NavAgent) ->int:
	var result = -1
	var currentLocation = GetGlobalPosition(actor)
	var nextLocation = currentLocation
	var Agent = navAgent if mode == Mode.NavAgent else AStarAgent
	#code adapted from here
	#https://www.youtube.com/watch?v=-juhGgA076E
	#use else for now, since we only have two modes
	nextLocation = Agent.get_next_path_position()
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
