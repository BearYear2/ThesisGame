extends AnimationTree
@onready var animState = get("parameters/playback")
var currentAnimState: String = "MovingStateIdle"



# Transform them into enums could also work
# This would allow me to enforce the types, but it would be harder to get the values out

var allAnimationStates = \
{
	"MovingState": ["Idle", "Walk"], #interruptable
	"AttackingState": ["Throw", "Ranged", "Melee", "Magic"], #non-interruptable
	"DamagedState":["Hit", "Death"] #non-interruptable
}
func playAnimation(animName:String,animDir:Vector2):
	var animationState = ""
	var animationName = ""
	for key in allAnimationStates:
		if animName in allAnimationStates[key]:
			animationState = key
			animationName = animName
			break
	if animationState != "":
		print(currentAnimState," ", animationState + animName)
		if currentAnimState != animationState + animName:
			currentAnimState = animationState + animName
			#var stateRoot = "parameters/"+ animationState
			#animState = get(stateRoot+"/playback")
			#set(stateRoot + "/blend_position",animDir)
	
func _ready():
	playAnimation("Idle",Vector2.UP)
	#SetAnimationStateBlend()


func AnimationFinished(anim_name):
	print("DEBUG",anim_name)


func AnimationStarted(anim_name):
	print("DEBUG",anim_name)
