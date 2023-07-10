extends Camera2D

var zoomStep = Vector2(0.2,0.2)
func _unhandled_input(event):
	#be aware, zoom will trigger an error if it is exactly 0
	if event.get_action_strength("MouseWheelUp") and zoom + zoomStep != Vector2.ZERO:
		zoom += zoomStep
	elif event.get_action_strength("MouseWheelDown") and zoom - zoomStep != Vector2.ZERO:
		zoom -= zoomStep
	
var thinking = null
var navigation = null
var brain = null #used as a reference for variables
var targetables = null
func _ready():
	targetables = get_tree().get_nodes_in_group("targetable")
	if targetables:
		for body in targetables:
			if not body.player:
				brain = body.get_node("Decider")
				thinking = brain.ThinkingMode
				navigation = brain.NavigationMode
				break
		triggerUpdate = false
		match thinking:
			brain.AiMode.Simple:
				$Back2/Decision/DT.button_pressed = true
				$Back2/Decision/FSM.button_pressed = false
			brain.AiMode.FSM:
				$Back2/Decision/DT.button_pressed = false
				$Back2/Decision/FSM.button_pressed = true
		match navigation:
			brain.NavMode.NavAgent:
				$Back/PathFinding/Godot.button_pressed = true
				$"Back/PathFinding/A*".button_pressed = false
			brain.NavMode.AStar:
				$Back/PathFinding/Godot.button_pressed = false
				$"Back/PathFinding/A*".button_pressed = true

func updateNPC():
	if targetables:
		for body in targetables:
			if not body.player:
				brain = body.get_node("Decider")
				brain.NavigationMode = navigation
				brain.ThinkingMode = thinking

var triggerUpdate = false
func _process(_delta):
	if triggerUpdate:
		triggerUpdate = false
		updateNPC()
	
#TODO
#@onready var list = $entityList
#func _ready():
	#for i in get_tree().get_nodes_in_group("targetable"):
	#	list.add_item(i.name)
#var lastEntity = null
#func OnItemClicked(index, at_position, mouse_button_index):
	#pass
	#var entity = get_parent().get_node(list.get_item_text(index))
	#print(entity.name)
	#if entity != lastEntity and lastEntity:
	#	lastEntity.remTram.set_update_position (false)
	#	lastEntity.remTram.force_update_cache()
	#	lastEntity = entity
	#entity.remTran.set_remote_node(self.get_path())


func GodotNavToggled(button_pressed):
	if triggerUpdate == false:
		$Back/PathFinding/Godot.button_pressed = button_pressed
		$"Back/PathFinding/A*".button_pressed = !button_pressed
		navigation = brain.NavMode.NavAgent
		triggerUpdate = true

func AStarNavToggled(button_pressed):
	if triggerUpdate == false:
		$Back/PathFinding/Godot.button_pressed = !button_pressed
		$"Back/PathFinding/A*".button_pressed = button_pressed
		navigation = brain.NavMode.AStar
		triggerUpdate = true

func DTToggled(button_pressed):
	if triggerUpdate == false:
		$Back2/Decision/DT.button_pressed = button_pressed
		$Back2/Decision/FSM.button_pressed = !button_pressed
		thinking = brain.AiMode.Simple
		triggerUpdate = true

func FSMToggled(button_pressed):
	if triggerUpdate == false:
		$Back2/Decision/DT.button_pressed = !button_pressed
		$Back2/Decision/FSM.button_pressed = button_pressed
		thinking = brain.AiMode.FSM
		triggerUpdate = true
