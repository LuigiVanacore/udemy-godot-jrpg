# res://combat/core/ActionResolver.gd
class_name ActionResolver
extends RefCounted

static func run(action: AbstractAction, state_before: Dictionary, payload: Dictionary, rng_seed: int = 0) -> ActionResult:
	var errors: String = action.validate(state_before, payload)
	if not errors.is_empty():
		return ActionResult.new(false, false, false, [], errors )
		
	var rng := RandomNumberGenerator.new()
	if rng_seed != 0:
		rng.seed = rng_seed

	var res: ActionResult = action.execute(state_before, payload, rng)
	if res.is_ok():
		return res
	return ActionResult.new(false, false, false, [], "Action failed or returned invalid result") 


static func apply_deltas_to_state(state_before: Dictionary, deltas: Array[ActionDelta]) -> Dictionary:
	var state_after := state_before.duplicate(true)
	if deltas.is_empty():
		return state_after
	if not state_after.has("units"):
		return state_after

	var units: Dictionary = state_after["units"] as Dictionary

	for ad in deltas:
		if ad == null:
			continue
		var uid := ad.id
		if not units.has(uid):
			continue
		var u: Dictionary = units[uid] as Dictionary

		match ad.kind:
			ActionDelta.Kind.HP:
				var new_hp: int = int(u.get("hp", 0)) + int(ad.value)
				var hp_max: int = int(u.get("hp_max", max(new_hp, 0)))
				u["hp"] = clamp(new_hp, 0, hp_max)

			ActionDelta.Kind.MP:
				var new_mp: int = int(u.get("mp", 0)) + int(ad.value)
				var mp_max: int = int(u.get("mp_max", max(new_mp, 0)))
				u["mp"] = clamp(new_mp, 0, mp_max)

			ActionDelta.Kind.STATUS_ADD:
				var key: StringName = ad.value
				var st: Dictionary = u.get("statuses", {})
				var stacks := int(ad.meta.get("stacks", 1))
				var duration := int(ad.meta.get("duration", -1)) # -1 = infinito
				var overwrite := bool(ad.meta.get("overwrite", false))
				if overwrite or not st.has(key):
					st[key] = {"stacks": max(1, stacks), "duration": duration, "active": true}
				else:
					var cur: Dictionary = st[key]
					cur["stacks"] = max(1, int(cur.get("stacks", 1)) + stacks)
					cur["duration"] = max(int(cur.get("duration", -1)), duration)
					cur["active"] = true
					st[key] = cur
				u["statuses"] = st

			ActionDelta.Kind.STATUS_REMOVE:
				var key_rm: StringName = ad.value
				var st2: Dictionary = u.get("statuses", {})
				if st2.has(key_rm):
					st2.erase(key_rm)
				u["statuses"] = st2

			# Shell-only: inventario ecc. NON toccare lo state qui
			ActionDelta.Kind.CONSUME_ITEM, ActionDelta.Kind.GIVE_ITEM, ActionDelta.Kind.CUSTOM:
				pass

	return state_after
 


