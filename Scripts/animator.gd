extends AnimationTree
#A reference to the animation state machine. 
#We need this in order to trigger the animations in the direction we want
@onready var animState:AnimationNodeStateMachinePlayback = get("parameters/playback")
var currentAnimState: String = ""
var started:bool = false
var finished: bool = true
var disabled: bool = false

#All currently available animation states
#NOTE: not all are implemented (like Throw, Ranged and Magic)
var allAnimationStates = [\
	"Idle", "Walk", #interruptable
	"Throw", "Ranged", "Melee", "Magic", #non-interruptable
	"Hit", "Dead"] #non-interruptable

#An additional list, we need this one to know what animations are cancellable
#NOTE:	This was implemented in order to allow the Melee, Hit and Dead animations
#		to finish before another animation can be played 
var interruptableAnimations = ["Idle", "Walk"]

#An easy to access interface, the user should only provide the name of an animation
#and the direction in which the animation should be played.
#NOTE: At some later point the 'animName' could be changed to an enum
func playAnimation(animName:String,animDir:Vector2):
	if !disabled: #we can only play animations if we are not dead!
		var animationName = ""
		for animation in allAnimationStates:
				animationName = animName
				break
		# we died x.x, no more animations
		if animationName == "Dead":
			animState.stop()
			started = false
		
		if animationName != "":
			#are we trying to play a different animation?
			#are we playing another animation?
			if !started  and currentAnimState != animName:
					animState.stop()
					animState.travel(animName)
					animState.start(animName)
					currentAnimState =  animName
					#This funny looking value tells the animation state machine
					#which animation to play, and it's direction
					set("parameters/" + animName + "/blend_position",animDir)
					#if the animation is interruptable (Walk or Idle)
					#then we don't care if they started. 
					#Otherwise, make sure to not interrupt the current animation
					if animName not in interruptableAnimations: 
						started = true
			#if the animation finished, make sure we face the previous direction
			if finished:
				set("parameters/" + currentAnimState + "/blend_position",animDir)
	# make sure to disable the character
	# maybe this could be moved to the previous statement?
	if animName == "Dead":
		disabled = true
		
#On ready, be Idle
func _ready():
	playAnimation("Idle",Vector2.UP)


#This function is triggered whenever an animation has finished playing
func AnimationFinished(_anim_name):
	started = false
	finished = true
	#print("FINISHED",anim_name)

#This function is triggered whenever an animation has started playing
func AnimationStarted(_anim_name):
	started = true
	finished = false
	#print("STARTED",anim_name)
