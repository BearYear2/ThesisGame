extends State


func Ready():
	#nothing to set here
	pass
	
func Process(actor,blackboard):
	blackboard["target"] = actor
	await get_tree().create_timer(randf_range(1,10)).timeout
	
func Exit():
	#nothing to unset here
	pass
