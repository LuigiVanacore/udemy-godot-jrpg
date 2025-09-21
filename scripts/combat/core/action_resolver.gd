# res://combat/core/ActionResolver.gd
class_name ActionResolver
extends RefCounted

static func run(action: AbstractAction, state_before: Dictionary, payload: Dictionary, rng_seed: int = 0) -> Dictionary:
	var errors: Array = action.validate(state_before, payload)
	if not errors.is_empty():
		return {"ok": false, "errors": errors}

	var rng := RandomNumberGenerator.new()
	if rng_seed != 0:
		rng.seed = rng_seed

	var res: Dictionary = action.execute(state_before, payload, rng)
	if res.has("ok") and bool(res["ok"]) == true:
		return res
	return {"ok": false, "errors": ["Action failed or returned invalid result"]}

static func copy_state(state: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in state.keys():
		var v: Variant = state[k]
		out[k] = ((v as Dictionary).duplicate(true)) if (v is Dictionary) else v
	return out

static func apply_deltas_to_state(state_before: Dictionary, deltas: Array) -> Dictionary:
	var state_after: Dictionary = copy_state(state_before)
	if not state_after.has("units"):
		return state_before

	var units: Dictionary = state_after["units"] as Dictionary
	for d_ in deltas:
		var d: Dictionary = d_ as Dictionary
		if d.is_empty(): continue
		if not d.has("id"): continue
		var uid = d["id"]
		if not units.has(uid): continue
		var u: Dictionary = units[uid] as Dictionary

		if d.has("hp"):
			var new_hp: int = int(u.get("hp", 0)) + int(d["hp"])
			var hp_max: int = int(u.get("hp_max", new_hp))
			u["hp"] = clamp(new_hp, 0, hp_max)

		if d.has("mp"):
			var new_mp: int = int(u.get("mp", 0)) + int(d["mp"])
			var mp_max: int = int(u.get("mp_max", new_mp))
			u["mp"] = clamp(new_mp, 0, mp_max)

	return state_after
