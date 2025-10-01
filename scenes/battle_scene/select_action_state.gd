extends LimboState




var _battle_scene : BattleScene

func _setup() -> void:
	_battle_scene = agent
	_battle_scene.battle_hud.battle_action_selected.connect(_on_battle_hud_battle_action_selected)

func _enter() -> void: 
	pass

func _update(_delta: float) -> void: 
	pass
	
func _exit() -> void:  
	pass


func _on_battle_hud_battle_action_selected(action_type: ActionTypes.BattleAction) -> void:
	if action_type == ActionTypes.BattleAction.ATTACK:
		_battle_scene._current_action_selected = action_type
		blackboard.set_var(_battle_scene.bb_action_to_execute, _battle_scene._current_action_selected)
		dispatch(_battle_scene.msg_action_selected)
