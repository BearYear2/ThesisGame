extends CharacterBody2D

@export var faceDir = "res://Assets/Chickens/"
@onready var animationTree = $AnimationTree
@onready var animState:AnimationNodeStateMachinePlayback = animationTree.get("parameters/playback")
func randomModel():
	var dir = DirAccess.open(faceDir)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".png"):
				if randi_range(0,10) >= 5: 
					$Model.texture = load(faceDir+file)
					break
			file = dir.get_next()

func _ready():
	randomModel()
	animState.travel("IdleSit")

const Bounds_TopLeft = Vector2(-10,-10)
const Bounds_BotRight = Vector2(10,10)
var moveDir = Vector2.ZERO
var point = Vector2.ZERO
var speed = 10
func _process(delta):
	#if randi() % 100 >= 70:
	#	animState.travel("Rise")
	#	var pointX = randf_range(Bounds_TopLeft.x,Bounds_BotRight.x)
	#	var pointY = randf_range(Bounds_TopLeft.y,Bounds_BotRight.y)
	#	point = Vector2(pointX,pointY)
	#	var newVelo = position.direction_to(point)
	#	#this is crucial, we need to set our actors moveDir
	#	velocity = newVelo * speed
	#else:
	#	velocity = Vector2.ZERO
	#move_and_slide()
	pass
