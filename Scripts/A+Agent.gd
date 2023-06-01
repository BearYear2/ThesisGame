extends Node
#get a reference to our parent, the actor/agent
@onready var actor : Node = get_parent()
@onready var actorVec2i : Vector2i = actor.position
#I don't really like these hardcoded values, but i want to be able to use @onready
#we need the tilemap in order to have access to all necessary functions
@onready var tilemap: TileMap = actor.get_node("../NavigationRegion2D/TileMap")

#this debug tile only works when there's one NPC
#good for checking where an NPC is going
@onready var debugTile: Node2D = actor.get_node("../NavigationRegion2D/TileMap/TestTile")

#where are we going?
var targetPosition : Vector2 = Vector2.ZERO
#the path we are currently following
var path = null
@onready var previousPoint = Vector2((actor.position))

#get_target_position, set_target_position and get_next_path_position
#are all modelled after the NavigationAgent2D interface
#so that we don't have implementation specific calls 
func get_target_position() -> Vector2:
	return targetPosition

func set_target_position(pos: Vector2):
	#this was not fun to code at all
	if actor:
		#check if we can walk to that position
		#local_to_map, and map_to_local will be explained in the A+Grid.gd script
		#but in short, they quickly convert between tilemap and local coordinates
		var tilePos = tilemap.local_to_map(Vector2i(pos))
		var cellData = tilemap.get_cell_tile_data(0,tilePos)
		#since the NavigationAgent2D only uses navigation polygons for pathfinding
		#we also check if our target happens to be stadning on such a polygon
		if cellData and cellData.get_navigation_polygon(0):
			#this trick was stolen from an official Godot example for navigation
			#specifically the demo project for A*
			#it gets rid of the fractional part, since we only work with ints
			targetPosition = Vector2(Vector2i(pos))
			actorVec2i = Vector2i(actor.position)
			var _start = tilemap.local_to_map(actorVec2i)
			var _end = tilemap.local_to_map(targetPosition)
			#print("start,end",_start,_end)
			#generate the path from our current position, to the target position
			path = tilemap.grid.get_id_path (_start,_end)
			#print("path",path)

func get_next_path_position() -> Vector2:
	#we might lose some precision with this, but hopefully it's not too much
	var localActor = Vector2(tilemap.local_to_map(actor.position))
	var next_point = tilemap.local_to_map(previousPoint)
	#currently the actor is spasing, maybe if i make all movement snapier, this might be alleviated
	#are there at least two nodes in our path, and are we really close to the next one?
	if (path && path.size() >= 2) and localActor.distance_to(Vector2(next_point)) < 0.1:
		#get rid of the first node in the path
		path.remove_at(0)
		#set the 'next" element as our new target
		next_point = path[0]
	#keep track of the previous point we visited
	previousPoint = tilemap.map_to_local(next_point)
	#use this only when there's one NPC, this allows the visualisation of the path
	#to some extent
	#debugTile.position = previousPoint
	return previousPoint
