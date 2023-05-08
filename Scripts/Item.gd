extends Sprite2D

# Called when the node enters the scene tree for the first time.
var emptyFrames = [10, 20, 21, 31, 32, 43, 54, 65, 84, 85, 86, 87, 106, 107, 108, 109]
func rename(frameIndex:int) -> String:
	var result = ""
	if frameIndex >= 110:
		result = "ItemBottle"
	elif frameIndex >= 66:
		result = "ItemEdible"
	elif frameIndex >= 33:
		result = "ItemMetal"
	elif frameIndex >= 22:
		result = "ItemGem"
	else:
		result = "ItemMaterial"
	return result
func _ready():
	frame = randi() % 121
	while frame in emptyFrames:
		frame = randi() % 121
	get_child(0).set_name(rename(frame))


