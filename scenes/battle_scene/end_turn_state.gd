extends LimboState




var _battle_scene : BattleScene

func _setup() -> void:
	_battle_scene = agent

func _enter() -> void: 
	_battle_scene.turn_manager.end_turn()
	dispatch(_battle_scene.msg_start_turn)

func _update(_delta: float) -> void: 
	pass
	
func _exit() -> void:  
	pass
