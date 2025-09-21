# res://combat/core/IAction.gd
@abstract
class_name AbstractAction
extends RefCounted

@abstract func id() -> StringName
@abstract func label() -> String
@abstract func target_mode() -> int
@abstract func execute(state_before: Dictionary, payload: Dictionary, rng: RandomNumberGenerator) -> Dictionary

# Facoltativi/concreti (non astratti): forniscono default
func validate(state_before: Dictionary, payload: Dictionary) -> Array:
	return []

func preview(state_before: Dictionary, payload: Dictionary) -> Dictionary:
	return {}

func is_usable(state_before: Dictionary, payload: Dictionary) -> bool:
	return validate(state_before, payload).is_empty()
