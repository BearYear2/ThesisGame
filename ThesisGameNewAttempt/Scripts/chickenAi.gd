extends CharacterBody2D

#the location of the chicken spritesheets
@export var faceDir = "res://Assets/Chickens/"
@onready var animationTree = $AnimationTree
#a reference to the animation state machine, look in Actor.gd as well
@onready var animState:AnimationNodeStateMachinePlayback = animationTree.get("parameters/playback")

#same implementation as in Actor.gd
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
			

var nextPoint = Vector2.ZERO
func _ready():
	randomModel()
	#artificial delay when the chickens will sit to give a bit of randomness
	await get_tree().create_timer(randf_range(0.1,10)).timeout
	animState.travel("IdleSit")
	$Move.wait_time = randf_range(0.5,3)
	nextPoint = position
	$CollisionBox.disabled = true
	$ItemChicken.monitorable = false
	$ItemChicken.monitoring = false
	$ItemChicken/CollisionShape2D.disabled = true

var moveDir = Vector2.ZERO
var lastDir = Vector2.ZERO
var speed = 50
func _process(delta):
	moveDir = position.direction_to(nextPoint)
	#If we are moving, play the "Walk" animation in the current direction
	if moveDir >= Vector2.ONE/3:
		animState.travel("Walk")
		#animationTree.playAnimation("Walk",moveDir)
		#update the lastDir, this is used for Idle
		lastDir = moveDir
	else:
		#we use lastDir in order to keep the previous orientation
		#otherwise we would default to looking down, I think?
		animState.travel("IdleSit")
		moveDir=Vector2.ZERO
		#animationTree.playAnimation("Idle",lastDir)
	
	# 'velocity' is a variable inherited from the CharacterBody2D
	# it's used when calling 'move_and_slide()'
	velocity = moveDir * speed
	if velocity != Vector2.ZERO:
		#this wonderful function deals with movement
		#and allows sliding against solid objects (based on the Node settings)
		move_and_slide()

#const Bounds_TopLeft = Vector2(-10,-10)
#const Bounds_BotRight = Vector2(10,10)
#var moveDir = Vector2.ZERO
#var point = Vector2.ZERO
#var speed = 10
#func _process(delta):
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
#	pass


func OnTimerFinish():
	#chickens should move randomly
	var x = randf_range(-10,10)
	var y = randf_range(-10,10)
	nextPoint = Vector2i(x,y) + Vector2i(position)
	$Move.wait_time = randf_range(5,10)
