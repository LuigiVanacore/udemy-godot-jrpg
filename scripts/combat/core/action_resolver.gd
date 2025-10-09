class_name ActionResolver
extends RefCounted




 
	
static func apply_deltas(deltas: Array[ActionDelta]):
	if deltas.is_empty():
		return  

	for ad in deltas:
		if ad == null: 
			continue
		var us = ad.
		if us == null:
			continue
		var stats: Dictionary = us.stats_state

		match ad.kind:
			ActionDelta.Kind.HP:
				var new_hp := int(stats.get(&"HP", 0)) + int(ad.value)
				var hp_max := int(stats.get(&"HP_MAX", max(new_hp, 0)))
				stats[&"HP"] = clamp(new_hp, 0, hp_max)

			ActionDelta.Kind.MP:
				var new_mp := int(stats.get(&"MP", 0)) + int(ad.value)
				var mp_max := int(stats.get(&"MP_MAX", max(new_mp, 0)))
				stats[&"MP"] = clamp(new_mp, 0, mp_max)

			ActionDelta.Kind.STATUS_ADD:
				var key: StringName = ad.value
				var st: Dictionary = us.statuses_state
				var stacks := int(ad.meta.get("stacks", 1))
				var duration := int(ad.meta.get("duration", -1))
				var overwrite := bool(ad.meta.get("overwrite", false))
				if overwrite or not st.has(key):
					st[key] = {"stacks": max(1, stacks), "duration": duration, "active": true}
				else:
					var cur: Dictionary = st[key]
					cur["stacks"] = max(1, int(cur.get("stacks", 1)) + stacks)
					cur["duration"] = max(int(cur.get("duration", -1)), duration)
					cur["active"] = true
					st[key] = cur
				us.statuses_state = st

			ActionDelta.Kind.STATUS_REMOVE:
				var key_rm: StringName = ad.value
				var st2: Dictionary = us.statuses_state
				if st2.has(key_rm):
					st2.erase(key_rm)
				us.statuses_state = st2

			# altri tipi (CONSUME_ITEM/GIVE_ITEM/CUSTOM) ignorati dal core:
			_:
				pass
 


static func _clone_unit_state(us: BattleStateManager.UnitState) -> BattleStateManager.UnitState:
	return BattleStateManager.UnitState.new(
		us.unit_name,
		us.unit_uid,
		us.stats_state.duplicate(true),
		us.inventory_state.duplicate(true)
	)
