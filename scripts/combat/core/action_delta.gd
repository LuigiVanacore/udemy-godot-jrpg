# ActionDelta.gd
class_name ActionDelta
extends RefCounted

# Tipi di delta che il core può capire
enum Kind { HP, MP, STATUS_ADD, STATUS_REMOVE, CONSUME_ITEM, GIVE_ITEM, CUSTOM }
 
var unit : Unit
var kind: Kind = Kind.CUSTOM
var value: Variant = null      # es.: -15 per HP, &"POISON" per STATUS_ADD, &"POTION" per CONSUME/GIVE
var meta: Dictionary = {}      # es.: {stacks=2, duration=3, source="Hero", overwrite=true, amount=1}


func execute():
	 
	if unit == null:
		return 

	match kind:
		Kind.HP:
			unit.change_hp(value)
		Kind.MP:
			unit.change_mp(value)

		#Kind.STATUS_ADD:
			#var mods_add: Array = ad.meta.get("mods", [])
			#_apply_temp_mods(si, ad.value, mods_add)  # source = nome status
			#_reclamp_hp_mp_if_caps_changed(si)
#
		#Kind.STATUS_REMOVE:
			#_clear_temp_mods_by_source(si, ad.value)  # source = nome status
			#_reclamp_hp_mp_if_caps_changed(si)

		_:
			pass
			
			
# --------- Factory methods ---------
static func hp(_unit : Unit, amount: int) -> ActionDelta:
	var d := ActionDelta.new()
	d.unit = _unit
	d.kind = Kind.HP
	d.value = amount
	return d

static func mp(amount: int) -> ActionDelta:
	var d := ActionDelta.new()
	d.kind = Kind.MP
	d.value = amount
	return d

static func status_add(status_key: StringName, stacks: int = 1, duration_turns: int = -1, source: Variant = null, overwrite: bool = false) -> ActionDelta:
	var d := ActionDelta.new()
	d.kind = Kind.STATUS_ADD
	d.value = status_key
	d.meta = {"stacks": stacks, "duration": duration_turns, "source": source, "overwrite": overwrite}
	return d

static func status_remove(status_key: StringName) -> ActionDelta:
	var d := ActionDelta.new()
	d.kind = Kind.STATUS_REMOVE
	d.value = status_key
	return d

static func consume_item(item_id: StringName, amount: int = 1) -> ActionDelta:
	var d := ActionDelta.new()
	d.kind = Kind.CONSUME_ITEM
	d.value = item_id
	d.meta = {"amount": amount}
	return d

static func give_item(item_id: StringName, amount: int = 1) -> ActionDelta:
	var d := ActionDelta.new()
	d.kind = Kind.GIVE_ITEM
	d.value = item_id
	d.meta = {"amount": amount}
	return d

# --------- Serializzazione (per compat col vecchio core) ---------
#func to_dict() -> Dictionary:
	#match kind:
		#Kind.HP:
			#return {"unit": id, "hp": int(value)}
		#Kind.MP:
			#return {"unit": id, "mp": int(value)}
		#Kind.STATUS_ADD:
			## rappresento lo status come dizionario semplice
			#var out := {"unit": id, "status_add": value}
			#for k in meta.keys():
				#out[k] = meta[k]
			#return out
		#Kind.STATUS_REMOVE:
			#return {"unit": id, "status_remove": value}
		#Kind.CONSUME_ITEM:
			#return {"unit": id, "consume_item": value, "amount": int(meta.get("amount", 1))}
		#Kind.GIVE_ITEM:
			#return {"unit": id, "give_item": value, "amount": int(meta.get("amount", 1))}
		#_:
			#return {"unit": id, "kind": kind, "value": value, "meta": meta}
#
#static func from_dict(d: Dictionary) -> ActionDelta:
	#var ad := ActionDelta.new()
	#ad.id = d.get("id")
	#if d.has("hp"):
		#ad.kind = Kind.HP
		#ad.value = int(d["hp"])
	#elif d.has("mp"):
		#ad.kind = Kind.MP
		#ad.value = int(d["mp"])
	#elif d.has("status_add"):
		#ad.kind = Kind.STATUS_ADD
		#ad.value = d["status_add"]
		#ad.meta = {
			#"stacks": int(d.get("stacks", 1)),
			#"duration": int(d.get("duration", -1)),
			#"source": d.get("source"),
			#"overwrite": bool(d.get("overwrite", false))
		#}
	#elif d.has("status_remove"):
		#ad.kind = Kind.STATUS_REMOVE
		#ad.value = d["status_remove"]
	#elif d.has("consume_item"):
		#ad.kind = Kind.CONSUME_ITEM
		#ad.value = d["consume_item"]
		#ad.meta = {"amount": int(d.get("amount", 1))}
	#elif d.has("give_item"):
		#ad.kind = Kind.GIVE_ITEM
		#ad.value = d["give_item"]
		#ad.meta = {"amount": int(d.get("amount", 1))}
	#else:
		#ad.kind = int(d.get("kind", Kind.CUSTOM))
		#ad.value = d.get("value")
		#ad.meta = d.get("meta", {})
	#return ad
#
## Utility
#func is_shell_only() -> bool:
	#return kind == Kind.CONSUME_ITEM or kind == Kind.GIVE_ITEM
#
## Unisci delta compatibili (utile per ridurre spam log/applicazioni ripetute)
#func can_merge(other: ActionDelta) -> bool:
	#if id != other.id or kind != other.kind:
		#return false
	#if kind == Kind.HP or kind == Kind.MP:
		#return true
	#if kind == Kind.STATUS_ADD and value == other.value:
		## mergiamo solo se non c'è overwrite
		#return not bool(meta.get("overwrite", false)) and not bool(other.meta.get("overwrite", false))
	#if kind in [Kind.CONSUME_ITEM, Kind.GIVE_ITEM] and value == other.value:
		#return true
	#return false
#
#func merge_in_place(other: ActionDelta) -> void:
	#match kind:
		#Kind.HP, Kind.MP:
			#value = int(value) + int(other.value)
		#Kind.STATUS_ADD:
			#meta["stacks"] = int(meta.get("stacks", 1)) + int(other.meta.get("stacks", 1))
			## durata: tieni la max (o min se preferisci)
			#meta["duration"] = max(int(meta.get("duration", -1)), int(other.meta.get("duration", -1)))
		#Kind.CONSUME_ITEM, Kind.GIVE_ITEM:
			#meta["amount"] = int(meta.get("amount", 1)) + int(other.meta.get("amount", 1))
		#_:
			#pass
