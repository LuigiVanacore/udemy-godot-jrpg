class_name BattleStateManager
extends Node

signal state_changed(after: Dictionary, deltas: Array)

const Kind = ActionDelta.Kind
#
#class UnitState:
	#var unit_name : StringName
	#var unit_uid : int
	#var stats_state : Dictionary[StringName, int]
	#var inventory_state : Dictionary[StringName, int]
	#var statuses_state : Dictionary
	#func _init(
		#unit_name : StringName,
		#unit_uid : int,
		#stats_state : Dictionary[StringName, int],
		#inventory_state : Dictionary[StringName, int],
		#statuses_state : Dictionary = {}
	#) -> void:
		#self.unit_name = unit_name
		#self.unit_uid = unit_uid
		#self.stats_state = stats_state
		#self.inventory_state = inventory_state
		#self.statuses_state = statuses_state
#
#var _battle_state: Dictionary[int, UnitState] = {}
#var _stats_by_uid: Dictionary[int, StatsInstance] = {}
#
#func snapshot() -> Dictionary:
	#return _battle_state
#
#func register_state(units : Array[Unit]) -> void: # Array[Unit]
	#_battle_state.clear()
	#_stats_by_uid.clear()
	#for unit in units:
		#if unit == null:
			#continue
		#var uid : int = unit.get_instance_id()
#
		## --- prendi gli status dalla Unit SOLO se esiste il metodo ---
		#var statuses_state: Dictionary = {}
		#if unit.has_method("get_statuses_state"):
			#statuses_state = unit.get_statuses_state()
#
		#_battle_state[uid] = UnitState.new(
			#unit.get_unit_name(),
			#uid,
			#unit.get_stats_state(),
			#unit.get_inventory_state(),
			#statuses_state
		#)
#
		## --- prendi la StatsInstance SOLO se esiste il getter ---
		#var si: StatsInstance = null
		#si = unit.get_stats_instance()
		#
		#if si != null:
			#_stats_by_uid[uid] = si
#
#func reduce(deltas: Array) -> Dictionary[int, UnitState]:
	#ActionResolver.apply_deltas_to_state(_battle_state, deltas) # muta in place
	#_sync_runtime(deltas)
	#state_changed.emit(snapshot(), deltas)
	#return _battle_state
#
#func _sync_runtime(deltas: Array) -> void:
	#for ad in deltas:
		#if ad == null:
			#continue
		#var uid: int = ad.id
		#var si: StatsInstance = _stats_by_uid.get(uid, null)
		#var us: UnitState = _battle_state.get(uid, null)
		#if si == null or us == null:
			#continue
#
		#match ad.kind:
			#Kind.HP:
				#si.set_current_hp(int(us.stats_state.get(&"HP", si.current_hp)))
			#Kind.MP:
				#si.set_current_mp(int(us.stats_state.get(&"MP", si.current_mp)))
#
			#Kind.STATUS_ADD:
				#var mods_add: Array = ad.meta.get("mods", [])
				#_apply_temp_mods(si, ad.value, mods_add)  # source = nome status
				#_reclamp_hp_mp_if_caps_changed(si)
#
			#Kind.STATUS_REMOVE:
				#_clear_temp_mods_by_source(si, ad.value)  # source = nome status
				#_reclamp_hp_mp_if_caps_changed(si)
#
			#_:
				#pass
#
#
#func _reclamp_hp_mp_if_caps_changed(si: StatsInstance) -> void:
	## niente "_ = ...": basta chiamare, il valore di ritorno viene ignorato
	#si.total(StatsIds.Stat.HP_MAX)
	#si.total(StatsIds.Stat.MP_MAX)
	#si.set_current_hp(si.current_hp)
	#si.set_current_hp(si.current_mp)
#
#func _apply_temp_mods(si: StatsInstance, source: StringName, mods: Array) -> void:
	#if si.has_method("add_temp_modifier"):
		#for m in mods:
			#var stat := int(m.get("stat"))
			#var flat := int(m.get("flat", 0))
			#var pct  := float(m.get("pct", 0.0))
			#si.add_temp_modifier(source, stat, flat, pct)
	#else:
		#push_warning("StatsInstance.add_temp_modifier mancante.")
	## forza eventuale recalc lazy senza usare '_ ='
	#si.total(StatsIds.Stat.HP_MAX)
#
#func _clear_temp_mods_by_source(si: StatsInstance, source: StringName) -> void:
	#if si.has_method("clear_modifiers_from_source"):
		#si.clear_modifiers_from_source(source)
	#else:
		#push_warning("StatsInstance.clear_modifiers_from_source mancante.")
	#si.total(StatsIds.Stat.HP_MAX)
