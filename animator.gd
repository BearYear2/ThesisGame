extends AnimationTree
@onready var animState:AnimationNodeStateMachinePlayback = get("parameters/playback")
var currentAnimState: String = ""
var started:bool = false
var finished: bool = true
var disabled: bool = false

# Transform them into enums could also work
# This would allow me to enforce the types, but it would be harder to get the values out
var allAnimationStates = [\
	"Idle", "Walk", #interruptable
	"Throw", "Ranged", "Melee", "Magic", #non-interruptable
	"Hit", "Death"] #non-interruptable
var interruptableAnimations = ["Idle", "Walk"]
func playAnimation(animName:String,animDir:Vector2):
	if !disabled:
		var animationName = ""
		for animation in allAnimationStates:
				animationName = animName
				break
		if animationName != "":
			if !started  and currentAnimState != animName:
					animState.stop()
					animState.travel(animName)
					animState.start(animName)
					currentAnimState =  animName
					set("parameters/" + animName + "/blend_position",animDir)
					if animName not in interruptableAnimations: #same as a simple else
						started = true
			if finished:
				set("parameters/" + currentAnimState + "/blend_position",animDir)
	if animName == "Dead":
		disabled = true
func _ready():
	playAnimation("Idle",Vector2.UP)


func AnimationFinished(anim_name):
	started = false
	finished = true
	#print("FINISHED",anim_name)


func AnimationStarted(anim_name):
	started = true
	finished = false
	#print("STARTED",anim_name)
