extends TileMap

@export var AStarLayer = 0
@export var NavLayer = 0
#docs article on the heuristic
#https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html#enum-astargrid2d-heuristic
#although it's a short enum, it still provides enough for most game devs
@export var costHeuristic: AStarGrid2D.Heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
@export var estimateHeuristic: AStarGrid2D.Heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN

# quite an important variable we got here
var grid : AStarGrid2D = AStarGrid2D.new()


#this function displays the current rectange that represens the entire world
func debug(rect):
	var poly:Polygon2D = get_node("../Debug")
	var polies = poly.get_polygon()
	polies.append(rect.position*16)
	polies.append(Vector2(rect.position.x, rect.end.y)*16)
	polies.append(rect.end*16)
	polies.append(Vector2(rect.end.x, rect.position.y)*16)
	poly.set_polygon(polies)

#call this function when defining the grid
#it creates a white 2D polygon at the specified position
func draw_poly(cell:Vector2):
	var poly: Polygon2D = Polygon2D.new()
	var polies = poly.get_polygon()
	var cellM = cell
	polies.append(Vector2(0,0))
	polies.append(Vector2(0,14))
	polies.append(Vector2(14,14))
	polies.append(Vector2(14,0))
	poly.set_polygon(polies)
	poly.position = cellM
	poly.offset = Vector2(-7,-7)
	print(poly.position)
	add_child(poly)
	poly.z_index = 3
	
#function used to draw a dark tile for debug purposes
func debug_cell(coords:Vector2i):
	var cellToDraw = coords
	#this corresponds to a darker tile, which helps with boundary visiblity
	var atlasCoords = Vector2i(5,8)
	set_cell(0,cellToDraw,0,atlasCoords)
	print(map_to_local(cellToDraw))
	print(local_to_map(cellToDraw))
	print(get_cell_atlas_coords(0,cellToDraw))
	draw_poly(map_to_local(cellToDraw))
	
	
func _ready():
	var rect = get_used_rect().end
	#debug(get_used_rect())
	grid.cell_size = Vector2i(get_quadrant_size(),get_quadrant_size())
	grid.size = rect
	grid.offset = grid.cell_size*0.5
	grid.default_compute_heuristic = costHeuristic
	grid.default_estimate_heuristic = estimateHeuristic
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	
	for x in rect.x:
		for y in rect.y:
			var pos = Vector2i(x,y)
			var cellData = get_cell_tile_data(0,pos)
			if not cellData.get_navigation_polygon(0):
				#print(pos*8.5)
				grid.set_point_solid(pos)
				#keep in mind that it's not very efficient 
				#as we just colour all solid cells
				#draw_poly(map_to_local(pos))
