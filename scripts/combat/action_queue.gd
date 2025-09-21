# ActionQueue.gd
class_name ActionQueue
extends Node

signal action_resolved(result: Dictionary)

# Stato FUNZIONALE della battaglia: snapshot puro (niente riferimenti a nodi)
# Esempio:
# {
#   "units": {
#       &"u_ally_1": {"id":&"u_ally_1","team":0,"name":"Hero","hp":30,"hp_max":30,"mp":10,"mp_max":10,"atk":8,"def":3},
#       &"u_enemy_1": {"id":&"u_enemy_1","team":1,"name":"Slime","hp":20,"hp_max":20,"mp":0,"mp_max":0,"atk":5,"def":1}
#   },
#   "inventories": { &"u_ally_1": { &"POTION": 2 } }
# }
var state: Dictionary = {}

# Mappa id unit -> Node (per applicare i delta ai nodi e giocare animazioni)
var unit_nodes: Dictionary = {}

func register_unit_node(unit_id: StringName, node: Node) -> void:
	unit_nodes[unit_id] = node

func set_state(new_state: Dictionary) -> void:
	state = new_state

func enqueue_and_resolve(action: AbstractAction, payload: Dictionary, rng_seed: int = 0) -> Dictionary:
	var result := ActionResolver.run(action, state, payload, rng_seed)
	if result.get("ok", false):
		# 1) Aggiorna lo stato funzionale
		state = result["state_after"]
		# 2) Applica i deltas ai nodi + side-effects (animazioni, inventari, suoni)
		_apply_deltas_to_nodes(result.get("deltas", []))
	emit_signal("action_resolved", result)
	return result

func _apply_deltas_to_nodes(deltas: Array) -> void:
	for d in deltas:
		var uid = d.get("id", null)
		if uid != null and unit_nodes.has(uid):
			var u: Node = unit_nodes[uid]
			if "apply_delta" in u:
				u.apply_delta(d)

		# Marker per inventari (shell): consumi/ricariche item
		if d.has("consume_item"):
			var caster_id: StringName = d.get("id")
			var item_id: StringName = d.get("consume_item")
			_consume_item_in_shell(caster_id, item_id)

func _consume_item_in_shell(caster_id: StringName, item_id: StringName) -> void:
	if not state.has("inventories"):
		return
	var invs = state["inventories"]
	var inv = invs.get(caster_id, {})
	if inv.has(item_id):
		inv[item_id] = max(0, int(inv[item_id]) - 1)
