extends CharacterBody2D

#general aspects
@export var speed :float = 100
@export var moveDir : Vector2 = Vector2(0,0.1)
@export var faceDir = "res://Assets/Puny-Characters/"

#player specific, currently never resolves to find RemoteTransfrom2D for BadActors
@onready var remTran = $RemoteTransform2D

#Animation
@onready var animationTree = $AnimationTree
@onready var animState = animationTree.get("parameters/playback")
var currentAnimState: String = "root"

#AI specifics
@export var player:bool = true
@onready var decider :Node2D = get_node("Decider") if !player else null

var blackboard : Dictionary= {}
@onready var groupMembers = get_tree().get_nodes_in_group("targetable")



func randomModel():
	var dir = DirAccess.open(faceDir)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".png"):
				if randi_range(0,10) == 10: 
					$Sprite2D.texture = load(faceDir+file)
					break
			file = dir.get_next()

#maybe bring all of this to an external node, like the animation tree?
#but then i will have to send inputs and the likes to it
#but i would be able to deal with animations in an easier fashion
func SetAnimationState(state:String = "root"):
	currentAnimState = state
	if state == "root":
		animState = animationTree.get("parameters/playback")
	else:
		var format = "parameters/%s/playback"
		animState = animationTree.get(format % state)
func GetAnimationState():
	#var animState = animationTree.get("parameters/playback").get_current_node()
	#if animState in allAnimationStates["root"]:
	#	animState
	#return animState
	pass
var allAnimationStates = {
	"MovingState": ["Idle", "Walk"],
	"AttackingState": ["Throw", "Ranged", "Melee", "Magic"],
	"root":["Hit", "Death"]
}
func SetAnimationStateBlend():
	#var format = "parameters/%s%s/blend_position"
	for substate in allAnimationStates[currentAnimState]:
		var animPath = "/" + substate + "/blend_position"
		if currentAnimState == "root":
			# e.g. parameters/Hit/blend_position"
			animPath = "parameters" + animPath
			print(animPath)
		else:
			# e.g. parameters/MovingState/Idle/blend_position
			animPath = "parameters/" + currentAnimState + animPath
		animationTree.set(animPath,moveDir)

func _ready():
	randomModel()
	animationTree.set("parameters/MovingState/Idle/blend_position",moveDir)
	if player:
		var camera2D = get_parent().get_node("camera").get_path()
		remTran.set_remote_node(camera2D)
	#blackboard["target"] = groupMembers[0]
	
func player_process(delta):
	#take advantage of the fact that the values are clamped between [-1,1]
	var horizontal = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var vertical = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	moveDir = Vector2(horizontal,vertical)
	if Input.get_action_strength("Attack"):
		SetAnimationState()
		SetAnimationStateBlend()
		#animState.travel("Hit")
		animState.start("Hit")
		moveDir = Vector2.ZERO
func ai_process(delta):
	var debugPlayer = get_parent().get_node("Player")
	blackboard["speed"] = speed
	# xd
	#blackboard["target"] = debugPlayer
	
	decider.think(self,blackboard)
	
func no_process(delta):
	pass
	
func _physics_process(delta):
	
	if player:
		player_process(delta)
	else:
		ai_process(delta)
	
	if moveDir != Vector2.ZERO:
		SetAnimationStateBlend()
		#if currentAnimState != "MovingState":
		#	print(":(")
		SetAnimationState("MovingState")
	if currentAnimState == "MovingState":
		if velocity == Vector2.ZERO :
			animState.travel("Idle")
		else:
			animState.travel("Walk")
			
	velocity = moveDir * speed
	if velocity != Vector2.ZERO:
		move_and_slide()
