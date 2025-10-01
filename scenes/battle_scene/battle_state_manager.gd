class_name BattleStateManager
extends Node

signal state_changed(after: Dictionary[StringName, int], deltas: Array)

class UnitState:
	var unit_name : StringName
	var unit_uid : int
	var stats_state : Dictionary[StringName, int]
	var inventory_staet : Dictionary[StringName, int]
	func _init(unit_name : StringName, unit_uid : int, stats_state : Dictionary[StringName, int], inventory_state : Dictionary[StringName, int]) -> void:
		self.unit_name = unit_name
		self.unit_uid = unit_uid
		self.stats_state = stats_state
		self.inventory_staet = inventory_state
		
		
var _battle_state: Dictionary[int, UnitState] = {}

 
func snapshot() -> Dictionary: return _battle_state.duplicate(true)

#func reset_from_units(units: Array) -> void:
	#var u := {}
	#for unit in units:
		#u[unit.uid] = unit.as_snapshot_dict(unit.team)
	#_state = {"units": u, "inventories": {}}
	#state_changed.emit(snapshot(), [])

func reduce(deltas: Array) -> Dictionary[int, UnitState]:
	_battle_state = ActionResolver.apply_deltas_to_state(_battle_state, deltas)
	state_changed.emit(snapshot(), deltas)
	return _battle_state



func register_state(units : Array[Unit]):
	_register_units_stats_state(units)
	
func _register_units_stats_state(units : Array[Unit]):
	for unit in units:
		var unit_name : StringName = unit.get_unit_name()
		var unit_uid : int = unit.get_instance_id()
		var stats_state : Dictionary[StringName, int] = unit.get_stats_state()
		var inventory_state : Dictionary[StringName, int] = unit.get_inventory_state()
		var unit_state : UnitState = UnitState.new(unit_name, unit_uid, stats_state, inventory_state)
		_battle_state[unit_uid] = unit_state
		
		
