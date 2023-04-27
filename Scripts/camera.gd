extends Camera2D

@onready var list = $entityList

var lastEntity = null
var zoomStep = Vector2(0.2,0.2)

func _unhandled_input(event):
	if event.get_action_strength("MouseWheelUp") and zoom + zoomStep != Vector2.ZERO:
		zoom += zoomStep
	elif event.get_action_strength("MouseWheelDown") and zoom - zoomStep != Vector2.ZERO:
		zoom -= zoomStep
	
func _ready():
	for i in get_tree().get_nodes_in_group("targetable"):
		list.add_item(i.name)


func OnItemClicked(index, at_position, mouse_button_index):
	pass
	#var entity = get_parent().get_node(list.get_item_text(index))
	#print(entity.name)
	#if entity != lastEntity and lastEntity:
	#	lastEntity.remTram.set_update_position (false)
	#	lastEntity.remTram.force_update_cache()
	#	lastEntity = entity
	#entity.remTran.set_remote_node(self.get_path())
