extends LimboState


var _unit : Unit

func _setup() -> void:
	_unit = agent

func _enter() -> void: 
	_unit.animation_manager.play(AnimationTypes.Types.IDLE)

func _update(_delta: float) -> void: 
	pass
	
func _exit() -> void:  
	pass
