extends AnimationTree
@onready var animState:AnimationNodeStateMachinePlayback = get("parameters/playback")
var currentAnimState: String = ""
var started:bool = false
var finished: bool = true

# Transform them into enums could also work
# This would allow me to enforce the types, but it would be harder to get the values out
var allAnimationStates = [\
	"Idle", "Walk", #interruptable
	"Throw", "Ranged", "Melee", "Magic", #non-interruptable
	"Hit", "Death"] #non-interruptable
var interruptableAnimations = ["Idle", "Walk"]
func playAnimation(animName:String,animDir:Vector2):
	var animationName = ""
	for animation in allAnimationStates:
			animationName = animName
			break
	if animationName != "":
		#if animName can be interrupted
		#i can choose any other animation
		#this also means that i should not replay this animation
		#also, i need to make sure something else did not start
		if animName in interruptableAnimations and currentAnimState != animName and !started:
			animState.stop()
			animState.travel(animName)
			animState.start(animName)
			currentAnimState =  animName
			set("parameters/" + animName + "/blend_position",animDir)
		#if animName cannot be interrupted
		#i can only change when it finished
		if animName not in interruptableAnimations and finished:
			animState.stop()
			animState.travel(animName)
			animState.start(animName)
			currentAnimState =  animName
			set("parameters/" + animName + "/blend_position",animDir)
			started = true
		else:
			set("parameters/" + currentAnimState + "/blend_position",animDir)
				
			#var root:AnimationNodeStateMachine = tree_root
			#print(root.has_transition("Idle","Walk"))
func _ready():
	playAnimation("Idle",Vector2.UP)
	#SetAnimationStateBlend()


func AnimationFinished(anim_name):
	started = false
	finished = true
	print("FINISHED",anim_name)


func AnimationStarted(anim_name):
	started = true
	finished = false
	print("STARTED",anim_name)
