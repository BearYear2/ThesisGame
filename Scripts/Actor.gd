extends CharacterBody2D

#general aspects
@export var speed :float = 100
@export var moveDir : Vector2 = Vector2(0,0.1)
@export var faceDir = "res://Assets/Puny-Characters/"
@onready var itemPos = $ItemPosition
@onready var healthbar = $HealthBar
#player specific, currently never resolves to find RemoteTransfrom2D for BadActors
@onready var remTran = $RemoteTransform2D

#Animation
@onready var animationTree = $AnimationTree

#Sound
@onready var footsteps = $Sounds/Walk
@onready var attack = $Sounds/Attack

#AI specifics
@export var player:bool = true
@onready var decider :Node2D = get_node("Decider") if !player else null
@onready var groupMembers = get_tree().get_nodes_in_group("targetable")
var blackboard : Dictionary= {}

var itemGoal = ["ItemChicken","ItemBottle","ItemEdible","ItemMetal","ItemGem","ItemMaterial"]
var goal:String = itemGoal[randi()%itemGoal.size()]
#Additional mechanics
var dead = false
var lastDir = Vector2.ZERO
var attacked = false
var health:float = 100.0
var canBeAfraid = false
var afraid = false

#item pickups
var itemClose = false
var itemOldParent = null
var item:Node = null
var hasItem = false
#use timers or something like that idk xd
#var actionDelay = 0.5

func death():
	animationTree.playAnimation("Dead",moveDir)
	$HurtArea.monitorable = false
	$HurtArea.monitoring = false
	$CollisionBox.disabled = true
	$HitArea.monitorable = false
	$HitArea.monitoring = false
	dead = true
	if player:
		get_tree().reload_current_scene()
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
	blackboard["action_Pick"] = Callable(self,"itemPickUp")
	blackboard["action_Drop"] = Callable(self,"itemUnPick")
	blackboard["action_Death"] = Callable(self,"death")
	blackboard["action_ChangeModel"] = Callable(self,"randomModel")
	randomModel()
	if player:
		var camera2D = get_parent().get_node("camera").get_path()
		remTran.set_remote_node(camera2D)
	else:
		#dead = true
		if randi_range(0,10) >= 5:
			canBeAfraid = true
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
	if hasItem and item:
		print("bye")
		item.position += Vector2(randf_range(0,1.0),randf_range(0,1.0))
		item.reparent(get_parent())
		#var coll:CollisionShape2D = item.find_child("CollisionBox")
		#if coll:
		#	coll.disabled = false
		hasItem = false
		itemClose = false

func itemProcess():
	#follow direction on the horziontal :D
	pass


func player_process(_delta):
	#take advantage of the fact that the values are clamped between [-1,1]
	var horizontal = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var vertical = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	moveDir = Vector2(horizontal,vertical)
	if Input.get_action_raw_strength("Attack"):
		#you cannot attack whilst holding an item
		if !hasItem:
			animationTree.playAnimation("Melee",moveDir)
			itemPickUp()
			#need some sort of timer for PickUp and UnPick
	if Input.get_action_raw_strength("Alternative"):
		if hasItem:
			itemUnPick()


func ai_process(delta):
	#this doesn't necessarily need to happen every frame
	#but it's better than not updating them at all
	blackboard["speed"] = speed
	blackboard["delta"] = delta
	blackboard["attacked"] = attacked
	blackboard["itemClose"] = itemClose
	blackboard["hasItem"] = hasItem
	blackboard["canBeAfraid"] = canBeAfraid
	blackboard["afraid"] = afraid
	decider.think(self,blackboard)
	

#The main brains of the entire agent.
#This function deals with both the player and the NPC's movement and actions
func _physics_process(delta):
	# we died, oh no!
	if health <=0:
		death()
	# we are still alive!
	if not dead:
		# are we the player?
		if player:
			if Input.is_action_pressed("EscKey"):
				get_tree().quit()
			player_process(delta)
		# or the NPC?
		else:
			ai_process(delta)
		
		if attacked:
			animationTree.playAnimation("Hit",moveDir)
		
		#If we are moving, play the "Walk" animation in the current direction
		if moveDir != Vector2.ZERO:
			animationTree.playAnimation("Walk",moveDir)
			# play the footstep sound if it's not already playing
			if not footsteps.playing:
				footsteps.play()
			#update the lastDir, this is used for Idle
			lastDir = moveDir
		else:
			#we use lastDir in order to keep the previous orientation
			#otherwise we would default to looking down, I think?
			animationTree.playAnimation("Idle",lastDir)
		
		# 'velocity' is a variable inherited from the CharacterBody2D
		# it's used when calling 'move_and_slide()'
		velocity = moveDir * speed
		if velocity != Vector2.ZERO:
			#this wonderful function deals with movement
			#and allows sliding against solid objects (based on the Node settings)
			move_and_slide()






#General Sensors area
#These are valid for both player and enemy, so we need them in the Actor script

#When tacking damage, decrease health by a random value between 10 and 20
#Update the healthbar
#Make sure to know that we are attacked
func UponHurt(area):
	if area not in get_children() and area.name == "HitArea":
		health -= randf_range(10.0,20.0)
		print(health)
		healthbar.value = health
		attacked = true
		#This was intended as an additional mechanic
		#if canBeAfraid:
		#	afraid = true

#Phew, no more attacks
func UponSafe(area):
	if area not in get_children() and area.name == "HitArea":
		attacked = false
		#This was intended as an additional mechanic
		#if canBeAfraid:
		#	afraid = false

#This is a simple item proximity detector, though it might malfunction at times
func ItemClose(area):
	if area not in get_children() and area.name.begins_with("Item"):
		#print("We are rich ",area.name)
		#players can pick all items, npc's can only pick specific items
		if area.name == goal or player:
			itemClose = true
			#This is important, make sure we know who the item is
			item = area.get_parent()
			#and to whom it belongs
			itemOldParent = item.get_parent()

#The opposite of the above function, we "forget" about the item. Opsie!
func ItemFar(area):
	if area not in get_children() and area.name.begins_with("Item"):
		#print("We are poor ",area.name)
		if area.name == goal or player:
			itemClose = false
			item = null
			itemOldParent = null
