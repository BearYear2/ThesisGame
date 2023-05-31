extends Node

@onready var actor : Node = get_parent()
@onready var actorVec2i : Vector2i = actor.position
#I don't really like these hardcoded values, but i want to be able to use @onready
@onready var tilemap: TileMap = actor.get_node("../NavigationRegion2D/TileMap")
@onready var debugTile: Node2D = actor.get_node("../NavigationRegion2D/TileMap/TestTile")
var targetPosition : Vector2 = Vector2.ZERO
var path = null

func get_target_position() -> Vector2:
	return targetPosition

func set_target_position(pos: Vector2):
	
	if actor:
		#check if we can walk to that position
		var tilePos = tilemap.local_to_map(Vector2i(pos))
		var cellData = tilemap.get_cell_tile_data(0,tilePos)
		if cellData and cellData.get_navigation_polygon(0):
			targetPosition = Vector2(Vector2i(pos))
			actorVec2i = Vector2i(actor.position)
			var _start = tilemap.local_to_map(actorVec2i)
			var _end = tilemap.local_to_map(targetPosition)
			#print("start,end",_start,_end)
			path = tilemap.grid.get_id_path (_start,_end)
			#print("path",path)

@onready var previousPoint = Vector2((actor.position))
func get_next_path_position() -> Vector2:
	#we might lose some precision with this, but hopefully it's not too much
	var localActor = Vector2(tilemap.local_to_map(actor.position))
	var next_point = tilemap.local_to_map(previousPoint)
	#currently the actor is spasing, maybe if i make all movement snapier, this might be alleviated
	if (path && path.size() >= 2) and localActor.distance_to(Vector2(next_point)) < 0.1:
		path.remove_at(0)
		next_point = path[0]
	previousPoint = tilemap.map_to_local(next_point)
	#debugTile.position = previousPoint
	return previousPoint
