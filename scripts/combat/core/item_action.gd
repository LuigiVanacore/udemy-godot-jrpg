class_name ItemAction
extends AbstractAction

const ActionResolver = preload("uid://b6ekywox8mdeo")
const ActionTypes    = preload("uid://4i0na2itm2ix")

var _data: ItemData

func _init(data: ItemData) -> void:
	_data = data

func id() -> StringName: return _data.id
func label() -> String: return _data.label
func target_mode() -> int: return _data.target_mode

func validate(state_before: Dictionary, payload: Dictionary) -> Array:
	var errs: Array = []
	if _data == null:
		errs.append("ItemData missing")
	if not payload.has("caster_id"):
		errs.append("Missing caster_id")
	if not payload.has("target_ids"):
		errs.append("Missing target_ids")
	if not errs.is_empty():
		return errs

	# --- TIPI ESPLICITI QUI ---
	var inv_all: Dictionary = state_before.get("inventories", {}) as Dictionary
	var caster_id: StringName = payload["caster_id"] as StringName
	var inv: Dictionary = inv_all.get(caster_id, {}) as Dictionary

	if int(inv.get(_data.id, 0)) <= 0:
		errs.append("Item not available")

	# (Opzionale: validare target_mode/allies/enemies)
	return errs

func execute(state_before: Dictionary, payload: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var deltas: Array = []
	var log: Array = []

	# --- TIPI ESPLICITI QUI ---
	var caster_id: StringName = payload["caster_id"] as StringName
	deltas.append({"id": caster_id, "consume_item": _data.id}) # usa direttamente StringName

	# target_ids può contenere StringName o String → trattalo come Variant e basta
	var tids_any: Array = payload["target_ids"] as Array
	for tid_any in tids_any:
		var tid: Variant = tid_any
		deltas.append({"id": tid, "hp": int(_data.heal_amount)})
		log.append("%s usa %s su %s (+%d HP)" % [
			String(caster_id), _data.label, String(tid), int(_data.heal_amount)
		])

	var state_after: Dictionary = ActionResolver.apply_deltas_to_state(state_before, deltas)
	return {"ok": true, "deltas": deltas, "log": log, "state_after": state_after}

