# ActionQueue.gd (imperative shell)
class_name ActionQueue
extends Node

signal action_started(caster_id: Variant, action_id: StringName)
signal action_resolved(result: Dictionary)
signal queue_empty
 

# Internal queue of {action: AbstractAction, payload: Dictionary, seed: int}
#var _queue: Array = []
#var _running: bool = false
#
#@onready var battle_state_manager : BattleStateManager = %BattleStateManager
#
#func enqueue(action: AbstractAction, payload: Dictionary, rng_seed: int = 0) -> void:
	#_queue.push_back({"action": action, "payload": payload, "seed": rng_seed})
	#if not _running:
		#_running = true
		#_process_queue()
#
#func _process_queue() -> void:
	#while not _queue.is_empty():
		#var item: Dictionary = _queue.pop_front()
		#var action: AbstractAction = item["action"]
		#var payload: Dictionary = item["payload"]
		#var seed: int = int(item.get("seed", 0))
#
		## snapshot prima dell'azione (non modifichiamo l'originale)
		#var state_before: Dictionary = battle_state_manager.snapshot()
#
		#emit_signal("action_started", payload.get("caster_id"), action.id(), payload)
#
		#var res = ActionResolver.run(action, state_before, payload, seed)
#
		## normalizza: accetta sia ActionResult che Dictionary
		#var ok := false
		#var deltas_arr: Array = []
		#var res_dict: Dictionary
#
#
		#ok = res.is_ok()
		#deltas_arr = res.get_deltas()
		#res_dict = res.to_dict()
		#
#
		#var state_after := state_before
		#if ok:
			## 1) applica i delta allo stato PERSISTITO nel BSM
			#state_after = battle_state_manager.reduce(deltas_arr)
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
	#_running = false
	#emit_signal("queue_empty")
#
#
## Converte un Array di ActionDelta (o misto) in Array di Dictionary
#func _to_dict_deltas(deltas: Array) -> Array:
	#var out: Array = []
	#for d in deltas:
		#if typeof(d) == TYPE_DICTIONARY:
			#out.push_back(d)
		#elif is_instance_of(d, ActionDelta):
			#out.push_back(d.to_dict())
	#return out
#
#
## Ora prende direttamente l'array di deltas (in formato Dictionary)
#func _apply_shell_side_effects(deltas_arr: Array[ActionDelta]) -> void:
	#for dd in deltas_arr:
		#if typeof(dd) != TYPE_DICTIONARY:
			#continue
		#if dd.has("consume_item"):
			#_consume_item_in_shell(dd.get("id"), dd.get("consume_item"))
		## Update functional state immediately so all consumers see the new snapshot
		#if res.is_ok():
			#_apply_shell_side_effects(res)
#
		#emit_signal("action_resolved", res)
		#await get_tree().process_frame # yields one frame for UI/animations to react
#
	#_running = false
	#emit_signal("queue_empty")
#
#
#func _apply_shell_side_effects(res: ActionResult) -> void:
	#var deltas: Array[ActionDelta] = res.get_deltas()
	#for d in deltas:
		#if not is_instance_of(d, ActionDelta): continue
		#if d.has("consume_item"):
			#_consume_item_in_shell(d.get("id"), d.get("consume_item"))
#
#func _consume_item_in_shell(caster_id: Variant, item_id: StringName) -> void:
	#if not state.has("inventories"): return
	#var invs: Dictionary = state["inventories"]
	#var inv: Dictionary = invs.get(caster_id, {})
	#if inv.has(item_id):
		#inv[item_id] = max(0, int(inv[item_id]) - 1)

# --- Optional helpers to bridge Units <-> state ---
# Build/refresh the functional state from an array of Unit nodes
#func rebuild_state_from_units(units_nodes: Array) -> void:
	#var units: Dictionary = {}
	#for u in units_nodes:
		#if u == null: continue
		#var idv: Variant = u.name # or a custom exported ID
		#units[idv] = {
			#"id": idv,
			#"team": int(u.get("team", 0)),
			#"name": String(u.get("display_name", String(idv))),
			#"hp": int(u.stats_instance.current_hp),
			#"hp_max": int(u.stats_instance.base.HP_MAX),
			#"mp": int(u.stats_instance.current_mp),
			#"mp_max": int(u.stats_instance.base.MP_MAX),
			#"atk": int(u.stats_instance.base.ATK),
			#"def": int(u.stats_instance.base.DEF),
			#"matk": int(u.stats_instance.base.MATK),
			#"mdef": int(u.stats_instance.base.MDEF),
			#"acc": float(u.stats_instance.base.ACC),
			#"eva": float(u.stats_instance.base.EVA),
			#"crit_rate": float(u.stats_instance.base.CRIT_RATE),
			#"crit_dmg": float(u.stats_instance.base.CRIT_DMG),
			#"speed": float(u.stats_instance.base.SPEED)
		#}
	#state["units"] = units
#
## Push HP/MP changes from state back to Unit nodes after actions (if desired)
#func apply_state_to_units(units_nodes: Array) -> void:
	#if not state.has("units"): return
	#var us: Dictionary = state["units"]
	#for u in units_nodes:
		#if u == null: continue
		#var idv: Variant = u.name
		#if not us.has(idv): continue
		#var snap: Dictionary = us[idv]
		## Apply using the Resource API so other systems receive signals
		#var curr_hp: float = float(u.stats_instance.current_hp)
		#var new_hp: float = float(snap.get("hp", curr_hp))
		#if new_hp < curr_hp:
			#u.stats_instance.apply_damage(curr_hp - new_hp)
		#elif new_hp > curr_hp:
			#u.stats_instance.heal(new_hp - curr_hp)
		## MP sync (simplified)
		#var curr_mp: float = float(u.stats_instance.current_mp)
		#var new_mp: float = float(snap.get("mp", curr_mp))
		#if new_mp < curr_mp:
			#u.stats_instance.spend_mp(curr_mp - new_mp)
		#elif new_mp > curr_mp:
			#u.stats_instance.recover_mp(new_mp - curr_mp)
