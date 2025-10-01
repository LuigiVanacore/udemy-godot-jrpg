extends LimboState
 




var _battle_scene : BattleScene

func _setup() -> void:
	_battle_scene = agent
	_battle_scene.turn_manager.turn_started.connect(_on_turn_started)

func _enter() -> void: 
	_battle_scene.turn_manager.start_turn()

func _update(_delta: float) -> void: 
	pass
	
func _exit() -> void:  
	pass



func _on_turn_started(unit : Unit, round_index: int, turn_index: int):
	_battle_scene.turn_indicator.follow_unit(unit)
	blackboard.set_var(_battle_scene.bb_caster_unit, unit) 
	dispatch(_battle_scene.msg_select_action)
