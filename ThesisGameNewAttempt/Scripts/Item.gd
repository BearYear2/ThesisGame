extends Sprite2D

#the spriteSheet contains some empty frames, both because of how the artist layered them
#and because of how godot reads them in a matrix format
var emptyFrames = [10, 20, 21, 31, 32, 43, 54, 65, 84, 85, 86, 87, 106, 107, 108, 109]

#we rename the item to match the possible goals an NPC might have
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
	#select one frame at random. repeat if it's empty
	frame = randi() % 121
	while frame in emptyFrames:
		frame = randi() % 121
	#re-set the name of this item to whatever it fits from the sheet
	get_child(0).set_name(rename(frame))


