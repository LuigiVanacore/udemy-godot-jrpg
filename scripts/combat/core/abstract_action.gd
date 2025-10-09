# res://combat/core/IAction.gd
@abstract
class_name AbstractAction
extends RefCounted

var payload : Dictionary

func _init(_payload : Dictionary):
	self.payload = _payload

func get_payload()->Dictionary:
	return payload

@abstract func id() -> StringName
@abstract func label() -> String
@abstract func target_mode() -> int
@abstract func validate() -> String
@abstract func execute(rng: RandomNumberGenerator) -> ActionResult

 
 

