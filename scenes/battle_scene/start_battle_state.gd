extends LimboState



var _battle_scene : BattleScene

func _setup() -> void:
	_battle_scene = agent

func _enter() -> void: 
	start_battle()
	dispatch(_battle_scene.msg_start_turn)

func _update(_delta: float) -> void: 
	pass
	
func _exit() -> void:  
	pass



func start_battle():
	var units : Array[Unit] = _battle_scene.get_units()
	for child : Unit in units:
		_battle_scene.turn_manager.register_unit(child)
		
 
	
	_battle_scene.turn_manager.start_battle()


 
	
#
#func _build_inventories_for_party() -> Dictionary:
	## Esempio: 2 pozioni al primo alleato
	#if party_units.is_empty():
		#return {}
	#return { party_units[0].uid: { &"POTION": 2 } }
#
