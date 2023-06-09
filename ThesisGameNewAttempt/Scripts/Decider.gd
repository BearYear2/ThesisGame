#it would be best to see this as the brain overall
#NavMode is an internal process, not always conscious
#AiMode is the cognitive part, the active thinking making use of all resources



extends Node2D

#navigation related variables
@onready var navigator = get_node("../Navigator")
@onready var navAgent = get_node("../NavAgent2D")
@onready var astarAgent = get_node("../AStarAgent2D")
@export var navigationSpeed = 50
enum NavMode {NavAgent,AStar}
@export var NavigationMode:NavMode = NavMode.NavAgent


enum AiMode {Simple,FSM}
@export var ThinkingMode: AiMode = AiMode.Simple

#we need to know where we can go
@onready var PatrolPoints = get_tree().get_nodes_in_group("points")
@onready var DeliveryPoints = get_tree().get_nodes_in_group("delivery")

#the blackboard from Actor.gd is saved into this variable
#since we only have temporary access to it during specific calls
#and Decider has additional sensors that depend on the actor and it's state
var worldState: Dictionary = Dictionary()

#what if i put these functions into some sort of action list?
#i could just decide when to use them based on what technique i am currently using
#though i am a bit disheartened that there won't be enough of a difference
#since i am running the most optimized example


func InGroup(node:Node2D,groupName:String):
	var result = false
	if get_owner() and get_tree() and node in get_tree().get_nodes_in_group(groupName):
		result = true
	return result
	
##########################
####Finished functions####
##########################
##look into the demo with astargrid2d, adapt code from there
func PursueTarget(actor:Node2D, target:Node2D, speed:float):
	var targetGlobal = navigator.GetGlobalPosition(target)
	navigationSpeed = speed
	
	var Agent = navAgent if NavMode.NavAgent == NavigationMode else astarAgent
	if Agent.get_target_position() != targetGlobal:
		Agent.set_target_position(targetGlobal)
		
	var arrived = navigator.Navigate(actor,navigationSpeed,NavigationMode)
	if arrived == 0:
		actor.moveDir = Vector2.ZERO
	return arrived
#func Patrol(actor:Node2D,speed:float,point:Node2D = null):
#	var patrolPoint = point
#	if not point and PatrolPoints:
#		var pointCount = PatrolPoints.size()
#		patrolPoint = PatrolPoints[randi()%pointCount]
#		print(patrolPoint.name)

func Die(actor:Node2D):
	actor.death()


##########################
###UnFinished functions###
##########################
#enum AttackType{Melee,Ranged,Magic}
#add some delay to attacks
func Attack(actor:Node2D,_target:Node2D):#,type:AttackType = AttackType.Melee):
	actor.animationTree.playAnimation("Melee",actor.moveDir)

func Alert(actor:Node2D, groupName:String = "targetable"):
	#we alert everyone of our current target
	for node in get_tree().get_nodes_in_group(groupName):
		node.worldState["target"] = worldState["target"]
#use the actor function, much more easier to use for the time being
#func PickUp(actor:Node2D,item:Node2D):
	#actor.animState.travel("")
	#functionality already existend in Actor.gd
#	pass
############################
###Optional Functionality###
############################
#func Sleep(actor:Node2D,time:float):
#	actor.animState.travel("Sleep")
#func Forget(actor:Node2D):
#	actor.animState.travel("Sleep")
#	Spin(actor,15.0)
#func Spin(actor:Node2D,time:float):
#	pass
#func DissapearIntoTheGround(actor:Node2D):
#	actor.animState.travel("Dead")
#	#actor.position.zinded
#func Ascend(actor:Node2D,time:float):
#	pass
#func TalkTo(actor:Node2D,target:Node2D):
#	actor.animState.travel("Hit")
#func Trade(actor:Node2D,item:Node2D):
#	pass


#simple Ai is done internally
#we could also say that this is a simple form of decision trees

#TemporaryHelperFunctions
#TakingDamage and Dead are handled by the actor on it's own
#Call it a sort of reflexive action, so I don't need to switch into it
func Talk(actor,blackboard):
	pass
func Deliver(actor,blackboard):
	actor.itemPickUp()
	if DeliveryPoints:
		var deliveryPoint = DeliveryPoints[0]
		var dist = actor.position.distance_to(deliveryPoint.position)
		for devPts in DeliveryPoints:
			if actor.position.distance_to(devPts.position) < dist:
				deliveryPoint = devPts
				dist = actor.position.distance_to(deliveryPoint.position)
		blackboard["target"]= deliveryPoint
		currentState = States.Patrol
func Idle(actor,blackboard):
	blackboard["target"] = actor
	actor.moveDir = Vector2.ZERO
	await get_tree().create_timer(randf_range(1,10)).timeout
	currentState = States.Patrol
	#blackboard["target"] = null

func Pat(actor,blackboard):
	if blackboard.get("itemClose") and not blackboard.get("hasItem"):
		currentState = States.DeliverItem
	if blackboard.get("target"):
		if InGroup(blackboard["target"],"targetable"):
			currentState = States.Hunt
		if PursueTarget(actor,blackboard["target"], blackboard["speed"]) == 0:
			currentState = States.Idle
			blackboard["target"] = null
	else:
		#Patrol
		if PatrolPoints:
			var pointCount = PatrolPoints.size()
			var patrolPoint = PatrolPoints[randi()%pointCount]
			blackboard["target"]= patrolPoint

func Hunt(actor,blackboard):
	if blackboard.get("itemClose") and not blackboard.get("hasItem"):
		currentState = States.DeliverItem
	if blackboard.get("target"):
		#have we arrived close enough to our target?
		#Patorl/Hunt
		if PursueTarget(actor,blackboard["target"], blackboard["speed"]) == 0:
			#is thihs target 'targetable'?
			if blackboard.get("hasItem") and InGroup(blackboard["target"],"delivery"):
				actor.itemUnPick()
			if InGroup(blackboard["target"],"targetable") and not blackboard.get("hasItem"):
				#is it a player?
				currentState = States.Attack
			else:
				currentState = States.Patrol

func Attk(actor,blackboard):
	if InGroup(actor,"targetable") and blackboard["target"].player:
		#Attack
		Attack(actor,blackboard["target"])
	else:
		currentState = States.Patrol
	if blackboard["target"].health <=0:
		blackboard["target"] = null
	else:
		currentState = States.Hunt


#add a sort of goal system, so that npc's can do more than just hunt the player
#while patroling, if you find an item, pick it up, and deliver it to the closest tower
#if you encounter another npc, you have to play a game of chicken, and the loser has to turn back
#if you encounter something hostile, you have to run away, you can only drop items near the tower
#if you have a chicken on you, you can still attack, but at a slower pace? but it is more valuable


func simple(actor,blackboard):
	if blackboard.get("itemClose") and not blackboard.get("hasItem"):
		actor.itemPickUp()
		if DeliveryPoints:
			var deliveryPoint = DeliveryPoints[0]
			var dist = actor.position.distance_to(deliveryPoint.position)
			for devPts in DeliveryPoints:
				if actor.position.distance_to(devPts.position) < dist:
					deliveryPoint = devPts
					dist = actor.position.distance_to(deliveryPoint.position)
			blackboard["target"]= deliveryPoint
	#Idk what to do with this
	#maybe avoid the player when you have an item
	#if blackboard.get("hasItem") and :
	#	pass 
	if blackboard.get("target"):
		#have we arrived close enough to our target?
		#Patorl/Hunt
		if PursueTarget(actor,blackboard["target"], blackboard["speed"]) == 0:
			#is this target a delivery point?
			if blackboard.get("hasItem") and InGroup(blackboard["target"],"delivery"):
				actor.itemUnPick()
				#Idle
				blackboard["target"] = actor
				await get_tree().create_timer(randf_range(1,10)).timeout
				blackboard["target"] = null
			#is this something we can attack?
			elif InGroup(blackboard["target"],"targetable"):
				#is it a player?
				if blackboard["target"].player and not blackboard.get("hasItem"):
					#Attack
					Attack(actor,blackboard["target"])
				#target's dead
				if blackboard["target"].health <=0:
					blackboard["target"] = null
	else:
		#Patrol
		if PatrolPoints:
			var pointCount = PatrolPoints.size()
			var patrolPoint = PatrolPoints[randi()%pointCount]
			blackboard["target"]= patrolPoint

enum States {Idle,Patrol,Hunt,Attack,Talk,DeliverItem}
var currentState:States = States.Idle
func finite(actor,blackboard):
	match currentState:
		States.Idle:		Idle(actor,blackboard)
		States.Patrol:		Pat(actor,blackboard)
		States.Hunt:		Hunt(actor,blackboard)
		States.Attack:		Attk(actor,blackboard)
		States.DeliverItem:	Deliver(actor,blackboard)

func think(actor,blackboard):
	#both point to the same reference
	blackboard["actor"]=actor
	worldState = blackboard
	
	match ThinkingMode:
		AiMode.Simple:
			simple(actor,blackboard)
		AiMode.FSM:
			finite(actor,blackboard)

#oh, this also works for touch, but we are not telling you which
var runningAway = false
func UponSeeingSomething(body : Node2D):
	if InGroup(body,"targetable"):
		if not worldState.get("hasItem"):
		#we'll pick a fight with the player, or with anyone not on
		#the godess' of luck side 
			if body.player or randi() % 1000 >= 999:
				#since blackboard is a dictionary, and dictionaries are passed around
				#by reference, then this means that this change would be reflected
				#everywhere else
				worldState["target"] = body
		else:
			if body.player and not runningAway: #or RequiresMyItem(body)
				var deliveryPoint = DeliveryPoints[randi()%DeliveryPoints.size()]
				worldState["target"]= deliveryPoint
				runningAway = true
	
		

func UponHearingSomething(body : Node2D):
	#we will pass this body to the UponSeeingSomething function, except
	#we shall make it so that the targets location is estimated
	#however, doing this might break a few things, as we need to keep into account
	#both local coordinates as well as map coordinates
	pass

func UponLosingSight(body:Node2D):
	#sometimes, in debug, an error would be fired when stopping
	if get_owner() and get_tree():
		if body in get_tree().get_nodes_in_group("targetable"):
			if body.player and not worldState.get("hasItem"):# and not hostile:
				worldState["target"] = null


func UponTouchingSomething(body):
	if InGroup(body,"targetable") and not body.player:
		#print("we meet again")
		#await get_tree().create_timer(randf_range(0,5)).timeout
		if PatrolPoints and worldState.has("actor"):
			var pointCount = PatrolPoints.size()
			var patrolPoint = PatrolPoints[randi()%pointCount]
			var pointPosition = patrolPoint.position
			
			worldState["actor"].position += Vector2(randf_range(-2,2), randf_range(-2,2))
			if body.position.x < worldState["actor"].position.x:
				worldState["actor"].position += Vector2(randf_range(0,5), randf_range(0,5))
				#pointPosition = worldState["actor"].position + Vector2(300,0)
			else:
				worldState["actor"].position += Vector2(randf_range(-5,0), randf_range(-5,0))
				#pointPosition = worldState["actor"].position - Vector2(300,0)
				
			
			#if body.position.y < worldState["actor"].position.y:
				#pointPosition = worldState["actor"].position - Vector2(0,300)
			#	worldState["actor"].moveDir += Vector2(randf_range(0,5), randf_range(0,5))
			#else:
			#	worldState["actor"].moveDir += Vector2(randf_range(-5,0), randf_range(-5,0))
				#pointPosition = worldState["actor"].position + Vector2(0,300)
				
			#print(worldState["actor"].name)
			#print(pointPosition,worldState["actor"].position)
			#for patPo in PatrolPoints:
					#if patPo.position.distance_to(pointPosition) < patrolPoint.position.distance_to(pointPosition):
						#patrolPoint = patPo
			#worldState["target"] = patrolPoint
			runningAway = true


func UponNoLongerTouching(body):
	if InGroup(body,"targetable") and not body.player:
		runningAway = false
	else:
		if  not runningAway: #or RequiresMyItem(body)
				var deliveryPoint = DeliveryPoints[randi()%DeliveryPoints.size()]
				worldState["target"]= deliveryPoint
				runningAway = true
		
