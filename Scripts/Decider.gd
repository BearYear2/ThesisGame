#it would be best to see this as the brain overall
#NavMode is an internal process, not always conscious
#AiMode is the cognitive part, the active thinking making use of all resources

extends Node2D
#navigation related variables
@onready var navigator = get_node("../Navigator")
@onready var navAgent = get_node("../NavAgent2D")
#another cheeky code duplication
@onready var astarAgent :Node = get_node("../AStarAgent2D")
@export var navigationSpeed = 50
enum NavMode {NavAgent,AStar}
@export var NavigationMode:NavMode = NavMode.NavAgent

#a little cheeky code duplication
@onready var simpleAI = get_node("SimpleAi")
@onready var finiteAI = get_node("FiniteStateMachine")
@onready var behaveAI = get_node("BehaviourTree")
enum AiMode {Simple,FSM,BT}
@export var ThinkingMode: AiMode = AiMode.Simple

@onready var PatrolPoints = get_tree().get_nodes_in_group("points")

var worldState: Dictionary = Dictionary()

#what if i put these functions into some sort of action list?
#i could just decide when to use them based on what technique i am currently using
#though i am a bit disheartened that there won't be enough of a difference
#since i am running the most optimized example
func InGroup(node:Node2D,groupName:String):
	var result = false
	if node in get_tree().get_nodes_in_group(groupName):
		result = true
	return result
	
##########################
####Finished functions####
##########################
func PursueTarget(actor:Node2D, target:Node2D, speed:float):
	var targetGlobal = navigator.GetGlobalPosition(target)
	navigationSpeed = speed
	var Agent = navAgent if NavMode.NavAgent == NavigationMode else astarAgent
	
	#################################
	### look into the demo with astargrid2d, adapt code from there
	#################################
	if Agent.get_target_position() != targetGlobal:
		Agent.set_target_position(targetGlobal)
		
	var arrived = navigator.Navigate(actor,navigationSpeed,NavigationMode)
	if arrived == 0:
		actor.moveDir = Vector2.ZERO
	return arrived
func Patrol(actor:Node2D,speed:float,point:Node2D = null):
	var patrolPoint = point
	if not point and PatrolPoints:
		var pointCount = PatrolPoints.size()
		patrolPoint = PatrolPoints[randi()%pointCount]
		print(patrolPoint.name)
func Die(actor:Node2D):
	actor.death()


##########################
###UnFinished functions###
##########################
#enum AttackType{Melee,Ranged,Magic}
func Attack(actor:Node2D,target:Node2D):#,type:AttackType = AttackType.Melee):
	actor.animationTree.playAnimation("Melee",actor.moveDir)

func PickUp(actor:Node2D,item:Node2D):
	#actor.animState.travel("")
	pass
func GetHit(actor:Node2D):
	actor.animState.travel("Hit")
	
func PickUpChicken(actor:Node2D,chicken:Node2D):
	pass
############################
###Optional Functionality###
############################
func Sleep(actor:Node2D,time:float):
	actor.animState.travel("Sleep")
func Forget(actor:Node2D):
	actor.animState.travel("Sleep")
	Spin(actor,15.0)
func Spin(actor:Node2D,time:float):
	pass
func DissapearIntoTheGround(actor:Node2D):
	actor.animState.travel("Dead")
	#actor.position.zinded
func Ascend(actor:Node2D,time:float):
	pass
func TalkTo(actor:Node2D,target:Node2D):
	actor.animState.travel("Hit")
func Trade(actor:Node2D,item:Node2D):
	pass


#simple Ai is done internally
func simple(actor,blackboard):
	if blackboard.get("target"):
		#have we arrived close enough to our target?
		if PursueTarget(actor,blackboard["target"], blackboard["speed"]) == 0:
			#is thihs target 'targetable'?
			if InGroup(blackboard["target"],"targetable"):
				#is it a player?
				if blackboard["target"].player:
					Attack(actor,blackboard["target"])
			else:
				blackboard["target"] = null
	else:
		if PatrolPoints:
			var pointCount = PatrolPoints.size()
			var patrolPoint = PatrolPoints[randi()%pointCount]
			blackboard["target"]= patrolPoint

#finite state machine related activities are delegated to
#the FiniteStateMachineNode
func finite(actor,blackboard):
	pass

#finite state machine related activities are delegated to
#the BehaviourTreeNode
func behave(actor,blackboard):
	pass

func think(actor,blackboard):
	var speed = blackboard["speed"]
	var target = blackboard.get("target")
	worldState["blackboard"] = blackboard
	match ThinkingMode:
		AiMode.Simple:
			simple(actor,blackboard)
		AiMode.FSM:
			finite(actor,blackboard)
		AiMode.BT:
			behave(actor,blackboard)
	#if target != null:
	#	PursueTarget(actor,target,speed)

#oh, this also works for touch, but we are not telling you which
func UponSeeingSomething(body : Node2D):
	if InGroup(body,"targetable"):
		#we'll pick a fight with the player, or with anyone not on
		#the godess' of luck side 
		if body.player or randi() % 1000 >= 999:
			#since blackboard is a dictionary, and dictionaries are passed around
			#by reference, then this means that this change would be reflected
			#everywhere else
			worldState["blackboard"]["target"] = body

func UponHearingSomething(body : Node2D):
	#we will pass this body to the UponSeeingSomething function, except
	#we shall make it so that the targets location is estimated
	#however, doing this might break a few things, as we need to keep into account
	#both local coordinates as well as map coordinates
	pass

func UponLosingSight(body:Node2D):
	#sometimes, in debug, an error would be fired when stopping
	if get_tree():
		if body in get_tree().get_nodes_in_group("targetable") and body.player:
			worldState["blackboard"]["target"] = null
