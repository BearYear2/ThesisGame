extends Node2D

enum States{Idle, Patroling, Hunting, Attacking, TakingDamage, Talk, Dead}
var currentStateNode:Node = null
var dead = false

func Init():
	TransitionTo(States.Idle)
	StateReady()

func StateReady():
	if currentStateNode:
		currentStateNode.Ready()

func StateProcess(actor,blackboard):
	if currentStateNode and !dead:
		currentStateNode.Process(actor,blackboard)
	else:
		#if we somehow forgot about what our current state
		#or something else happened, just get back into idle
		Init()

func StateExit():
	if currentStateNode:
		currentStateNode.Exit()

func TransitionTo(state:States):
	if currentStateNode:
		StateExit()
	var potentialState = null
	match state:
		States.Idle:
			potentialState = get_node("Idle")
		States.Patroling:
			potentialState = get_node("Patrol")
		States.Hunting:
			potentialState = get_node("Hunt")
		States.Attacking:
			potentialState = get_node("Attack")
		States.TakingDamage:
			potentialState = get_node("TakingDamage")
		States.Talk:
			potentialState = get_node("Talk")
		States.Dead:
			potentialState = get_node("Dead")
	if potentialState:
		currentStateNode = potentialState
		StateReady()
	else:
		currentStateNode = null
		print("current state is null, something wrong happened")
	
