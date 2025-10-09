extends LimboState





var _unit : Unit
var _result : ActionResult
var animPlayer : AnimationPlayer

func _setup() -> void:
	_unit = agent
	animPlayer = _unit.animPlayer

func _enter() -> void:
	_unit.action_started.emit()
	_result = blackboard.get_var(_unit.bb_action_result)
	if _unit.is_party_member():
		_unit.animation_manager.play(AnimationTypes.Types.ATTACK_SLASH)
	else:
		_unit.animation_manager.play(AnimationTypes.Types.ATTACK)
	await animPlayer.animation_finished
	dispatch(_unit.msg_idle)

func _update(_delta: float) -> void: 
	pass
	
func _exit() -> void:  
	_unit.action_ended.emit()


func execute_attack():
	if not _result.is_ok():
		return
	
	if _result.is_missed():
		miss_attack()
		return
		
	success_attack(_result)

func success_attack(result : ActionResult):
	for actionDelta in result.get_deltas():
		actionDelta.execute()
	
	
	
func miss_attack():
	var floating_text : FloatingText2D = _unit.floating_text_scene.instantiate()
	_unit.add_child(floating_text)
	floating_text.popup_text("Miss", _unit.global_position )
