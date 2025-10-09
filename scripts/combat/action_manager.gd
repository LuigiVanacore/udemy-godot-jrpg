# ActionQueue.gd
class_name ActionManager
extends Node
 
signal action_started( caster : Unit, action_id : StringName, payload : Dictionary)


@export var _rng_seed: int = 0

var rng : RandomNumberGenerator
 



func _ready() -> void:
	rng = RandomNumberGenerator.new()
	if _rng_seed != 0:
		rng.seed = _rng_seed

func set_seed(_seed: int) -> void:
	_rng_seed = _seed 
 

  
func execute_action(action: AbstractAction)->ActionResult:
	var payload : Dictionary = action.get_payload()
	action_started.emit(payload.get("caster"), action.id(), payload)

	var errors: String = action.validate()
	if not errors.is_empty():
		return null
		
	return action.execute(rng)
 
 
 
func execute_attack_action(caster: Unit, target: Unit) -> ActionResult:
	
	var payload := {
		"caster": caster,
		"target": [target],
	}
	
	return execute_action(AttackAction.new(payload))



#func apply_deltas(deltas: Array[ActionDelta]):
	#if deltas.is_empty():
		#return  
#
	#for ad in deltas:
		#if ad == null: 
			#continue
		#
		#ad.unit.apply_delta()
		#
		#match ad.kind:
			#ActionDelta.Kind.HP:
				#var new_hp := unit.get_stat(StatsIds.Stat.HP) + int(ad.value)
				#var hp_max := unit.get_stat(StatsIds.Stat.HP_MAX)
				#
#
			#ActionDelta.Kind.MP:
				#var new_mp := unit.get_stat(StatsIds.Stat.MP) + int(ad.value)
				#var mp_max := unit.get_stat(StatsIds.Stat.MP_MAX) 
#
			#ActionDelta.Kind.STATUS_ADD:
				#var key: StringName = ad.value
				#var st: Dictionary = us.statuses_state
				#var stacks := int(ad.meta.get("stacks", 1))
				#var duration := int(ad.meta.get("duration", -1))
				#var overwrite := bool(ad.meta.get("overwrite", false))
				#if overwrite or not st.has(key):
					#st[key] = {"stacks": max(1, stacks), "duration": duration, "active": true}
				#else:
					#var cur: Dictionary = st[key]
					#cur["stacks"] = max(1, int(cur.get("stacks", 1)) + stacks)
					#cur["duration"] = max(int(cur.get("duration", -1)), duration)
					#cur["active"] = true
					#st[key] = cur
				#us.statuses_state = st
#
			#ActionDelta.Kind.STATUS_REMOVE:
				#var key_rm: StringName = ad.value
				#var st2: Dictionary = us.statuses_state
				#if st2.has(key_rm):
					#st2.erase(key_rm)
				#us.statuses_state = st2
#
			## altri tipi (CONSUME_ITEM/GIVE_ITEM/CUSTOM) ignorati dal core:
			#_:
				#pass
 




	 #
 #
	#emit_signal("action_started", payload.get("caster"), action.id(), payload)
#
	#var res : ActionResult = ActionResolver.run(action, payload, _rng_seed)
#
	## normalizza: accetta sia ActionResult che Dictionary
	#var ok := false
	#var deltas_arr: Array = []
	#var res_dict: Dictionary
 #
	#ok = res.is_ok()
 #
	#if ok:
		## 1) applica i delta allo stato PERSISTITO nel BSM
		#state_after = battle_state_manager.reduce(deltas_arr)
		#
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
		## 2) side-effects di shell (inventario, ecc.) → delega al BSM (o gestiscili qui se preferisci)
		##battle_state_manager.apply_shell_side_effects(deltas_arr)
#
	## aggiungo state_after nel result per comodità di UI/debug
	#res_dict["state_after"] = state_after
#
	#emit_signal("action_resolved", res_dict)
	#await get_tree().process_frame
 #
 #
	#
	
#
#func commit_skill(caster: Unit, targets: Array[Unit], data: SkillData) -> void:
	#var action := SkillAction.new(data)
	#var tids: Array[StringName] = []
	#for t: Unit in targets: tids.append(t.uid)
	#var payload := {"caster_id": caster.uid, "target_ids": tids}
	#var meta := {"caster_id": caster.uid, "target_ids": tids}
	#action_queue.enqueue(action, payload, meta)
#
#func commit_item(caster: Unit, targets: Array[Unit], data: ItemData) -> void:
	#var action := ItemAction.new(data)
	#var tids: Array[StringName] = []
	#for t: Unit in targets: tids.append(t.uid)
	#var payload := {"caster_id": caster.uid, "target_ids": tids}
	#var meta := {"caster_id": caster.uid, "target_ids": tids}
	#action_queue.enqueue(action, payload, meta)
#
#
#
#
#
#
#
#
#func enqueue(action: AbstractAction, payload: Dictionary, meta := {}) -> void:
	#var errs := action.validate(state, payload)
	#if not errs.is_empty():
		#push_error("ActionQueue.enqueue(): invalid payload: %s" % str(errs))
		#return
	#_queue.append({"action": action, "payload": payload, "meta": meta})
	#action_enqueued.emit(action.id(), payload)
	#if _queue.size() == 1:
		#_process_next()
#
#func _process_next() -> void:
	#if _queue.is_empty():
		#queue_empty.emit()
		#return
#
	#var item: Dictionary = _queue[0]
	#var action: AbstractAction = item["action"]
	#var payload: Dictionary = item["payload"]
	#var meta: Dictionary = item.get("meta", {})
#
	#action_started.emit(action.id(), payload)
#
	#var res: Dictionary = ActionResolver.run(action, state, payload, _rng_seed)
	#if not res.get("ok", false):
		#push_error("Action failed: %s" % str(res.get("errors", [])))
		#_queue.pop_front()
		#_process_next()
		#return
#
	## 1) aggiorna lo stato funzionale
	#state = res["state_after"]
#
	## 2) aziona la shell (animazioni + HUD + consumo item)
	#await _play_and_apply_shell(action.id(), res, meta)
#
	#action_resolved.emit(res)
#
	## 3) continua con la prossima
	#_queue.pop_front()
	#_process_next()
#
## --- Shell driver: animazioni, HUD e consumi ---
#func _play_and_apply_shell(action_id: StringName, result: Dictionary, meta: Dictionary) -> void:
	## (opzionale) anim dell'incantatore
	#var caster_id: Variant = meta.get("caster_id")
	#if caster_id and _id_to_unit.has(caster_id):
		#var caster = _id_to_unit[caster_id]
		#if caster.has_method("play_action_anim"):
			## Se hai una coroutine sul caster, la aspetti:
			#await caster.play_action_anim(action_id, meta.get("target_ids", []))
		#elif caster.has_method("play_attack"):
			#await caster.play_attack(_ids_to_nodes(meta.get("target_ids", [])))
#
	## Applica i delta ai nodi (HUD/anim per-hit) e gestisci marker inventario
	#for d in result.get("deltas", []):
		## Consumo item (marker funzionale → effetto shell)
		#if d.has("consume_item"):
			#var cid: StringName = d.get("id")
			#var item_id: StringName = d.get("consume_item")
			#_consume_item_in_shell(cid, item_id)
			#continue
#
		#var uid: Variant = d.get("id")
		#if uid and _id_to_unit.has(uid):
			#var u: Node = _id_to_unit[uid]
			#var after_unit: Dictionary = state.get("units", {}).get(uid, {})
			#if u.has_method("apply_delta"):
				#u.apply_delta(d, after_unit) # aggiorna HP/MP/Barre/Popup numeri ecc.
			#action_effect_applied.emit(action_id, d, u)
#
		## Piccola pausa facoltativa per pop-up numeri, ecc.
		#var pause_ms: int = int(meta.get("per_hit_pause_ms", 0))
		#if pause_ms > 0:
			#await get_tree().create_timer(float(pause_ms) / 1000.0).timeout
#
## Helper
#func _ids_to_nodes(ids: Array) -> Array:
	#var out := []
	#for idv in ids:
		#if _id_to_unit.has(idv):
			#out.append(_id_to_unit[idv])
	#return out
#
## --- Inventari: consumo item in shell (mantieni il tuo marker) ---
#func _consume_item_in_shell(caster_id: StringName, item_id: StringName) -> void:
	#if not state.has("inventories"):
		#return
	#var invs = state["inventories"]
	#var inv = invs.get(caster_id, {})
	#if inv.has(item_id):
		#inv[item_id] = max(0, int(inv[item_id]) - 1)
