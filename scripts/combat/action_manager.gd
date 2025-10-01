# ActionQueue.gd
class_name ActionManager
extends Node

signal action_enqueued(action_id: StringName, payload: Dictionary) 
signal action_effect_applied(action_id: StringName, delta: Dictionary, unit: Node) 


 

@export var _rng_seed: int = 0

@onready var action_queue : ActionQueue = $ActionQueue

func set_seed(seed: int) -> void:
	_rng_seed = seed 
 

  
 
 



func commit_attack(caster: Unit, target: Unit) -> void:
	var action := AttackAction.new()
	var payload := {
		"caster_id": caster.get_instance_id(),
		"target_ids": [target.get_instance_id()],
	}
	action_queue.enqueue(action, payload, _rng_seed)
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
