# res://combat/core/action_result.gd
class_name ActionResult
extends RefCounted

var ok: bool = true
var hit: bool = false
var crit: bool = false 
var deltas: Array[ActionDelta] = []
var debug_log : String 

func _init(_ok : bool, _hit : bool, _crit : bool, _deltas : Array[ActionDelta], _debug_log : String):
	self.ok = _ok
	self.hit = _hit
	self.crit = _crit
	self.deltas = _deltas
	self.debug_log = _debug_log

static func miss(log_line: String) -> ActionResult:
	return ActionResult.new(true, false, false, [], log_line)

func is_ok()->bool:
	return ok
	
func get_deltas()->Array[ActionDelta]:
	return deltas
	
func to_dict() -> Dictionary:
	# ponte per l’ecosistema che oggi usa Dictionary
	var deltas_dict: Array = []
	for d in deltas:
		deltas_dict.append(d.to_dict())

	return {
		"ok": ok,
		"hit": hit,
		"crit": crit, 
		"deltas": deltas_dict,
		"debug_log": debug_log,
	}
