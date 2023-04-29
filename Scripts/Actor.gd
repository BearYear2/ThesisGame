extends CharacterBody2D

#general aspects
@export var speed :float = 100
@export var moveDir : Vector2 = Vector2(0,0.1)
@export var faceDir = "res://Assets/Puny-Characters/"
@onready var itemPos = $ItemPosition

#player specific, currently never resolves to find RemoteTransfrom2D for BadActors
@onready var remTran = $RemoteTransform2D

#Animation
@onready var animationTree = $AnimationTree


#AI specifics
@export var player:bool = true
@onready var decider :Node2D = get_node("Decider") if !player else null
@onready var groupMembers = get_tree().get_nodes_in_group("targetable")
var blackboard : Dictionary= {}

#Additional mechanics
var dead = false
var lastDir = Vector2.ZERO
var attacked = false
#item pickups
var itemClose = false
var itemOldParent = null
var item:Node = null
var hasItem = false
#use timers or something like that idk xd
#var actionDelay = 0.5

func death():
	animationTree.playAnimation("Dead",moveDir)
	dead = true
func randomModel():
	var dir = DirAccess.open(faceDir)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".png"):
				if randi_range(0,10) == 10: 
					$Model.texture = load(faceDir+file)
					break
			file = dir.get_next()
func _ready():
	randomModel()
	if player:
		var camera2D = get_parent().get_node("camera").get_path()
		remTran.set_remote_node(camera2D)
	#blackboard["target"] = groupMembers[0]



func itemPickUp():
	if itemClose:
		item.reparent(self)
		item.position = itemPos.position 
		#item.scale = item.scale
		var coll:CollisionShape2D = item.find_child("CollisionBox")
		if coll:
			coll.disabled = true
		hasItem = true
func itemUnPick():
	if hasItem:
		print("bye")
		item.reparent(get_parent())
		var coll:CollisionShape2D = item.find_child("CollisionBox")
		if coll:
			coll.disabled = false
		hasItem = false
		itemClose = false
		
func itemProcess():
	#follow direction on the horziontal :D
	pass
func player_process(delta):
	#take advantage of the fact that the values are clamped between [-1,1]
	var horizontal = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var vertical = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	moveDir = Vector2(horizontal,vertical)
	if Input.get_action_raw_strength("Attack"):
		animationTree.playAnimation("Melee",moveDir)
		#need some sort of timer for PickUp and UnPick
		if !hasItem:
			itemPickUp()
		#else:
		#	itemPickUp()
func ai_process(delta):
	blackboard["speed"] = speed
	# xd
	#var debugPlayer = get_parent().get_node("Player")
	#blackboard["target"] = debugPlayer
	
	decider.think(self,blackboard)
	
func no_process(delta):
	pass
	
func _physics_process(delta):
	if not dead:
		if player:
			player_process(delta)
		else:
			ai_process(delta)
		if attacked:
			animationTree.playAnimation("Hit",moveDir)
		if moveDir != Vector2.ZERO:
			animationTree.playAnimation("Walk",moveDir)
			lastDir = moveDir
		else:
			animationTree.playAnimation("Idle",lastDir)
				
		velocity = moveDir * speed
		if velocity != Vector2.ZERO:
			move_and_slide()



#extend the hitbox through animation :D
func UponHurt(area):
	if area not in get_children() and area.name == "HitArea":
		attacked = true


func UponSafe(area):
	if area not in get_children() and area.name == "HitArea":
		attacked = false


func ItemClose(area):
	if area not in get_children() and area.name.begins_with("Item"):
		print("We are rich ",area.name)
		itemClose = true
		item = area.get_parent()
		itemOldParent = item.get_parent()


func ItemFar(area):
	if area not in get_children() and area.name.begins_with("Item"):
		print("We are poor ",area.name)
		itemClose = false
		item = null
		itemOldParent = null
