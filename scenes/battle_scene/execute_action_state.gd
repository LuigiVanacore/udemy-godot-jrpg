extends LimboState



var _battle_scene : BattleScene  

var _target : Unit
var _caster : Unit
var _action_to_execute : ActionTypes.BattleAction

func _setup() -> void:
	_battle_scene = agent

func _enter() -> void:
	_target = blackboard.get_var(_battle_scene.bb_target_unit)
	_caster = blackboard.get_var(_battle_scene.bb_caster_unit)
	_action_to_execute = blackboard.get_var(_battle_scene.bb_action_to_execute)
	_battle_scene.action_manager.commit_attack(_caster, _target)
	dispatch(_battle_scene.msg_end_turn)
 

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	# Se vuoi nascondere il cursore al termine, fallo qui.
	# _cursor.visible = false
	pass


 
			
			#
			#
#func _on_action_resolved(result: Dictionary) -> void:
	#if not bool(result.get("ok", false)):
		#print("Action error: ", result.get("errors"))
		## torna a selezione (o fallisce il turno)
		#%SelectActionState.enter_for_actor(_active_unit_id)
		#return
#
	## 1) Applica DELTAS ai Node2D (shell)
	#var deltas: Array = result.get("deltas", [])
	#_apply_deltas_to_nodes(deltas)
#
	## 2) Log a schermo
	#for line in result.get("log", []):
		#print(line)
#
	## 3) Prossimo turno
	#_active_unit_id = _pick_next_actor_id()
	#%SelectActionState.enter_for_actor(_active_unit_id)
#
#func _apply_deltas_to_nodes(deltas: Array) -> void:
	#for d in deltas:
		#var uid: int = d.get("id")
		#if not _id_to_unit_node.has(uid):
			#continue
		#var unit: Unit = _id_to_unit_node[uid]
		#if d.has("hp"):
			#var hp_delta := int(d["hp"])
			#var si := unit.stats_instance
			#var old_hp := si.current_hp
			#var new_hp : int = clamp(old_hp + hp_delta, 0, si.total(StatsIds.Stat.HP_MAX))
			#si.current_hp = new_hp
			## Qui puoi triggerare animazioni/hitflash/aggiornare barre
#
#func _compute_allowed_targets(mode: int, caster_id: StringName) -> Array[StringName]:
	#var out: Array[StringName] = []
	#var caster_team := int(action_queue.state["units"][caster_id]["team"])
	#for uid in action_queue.state["units"].keys():
		#var u = action_queue.state["units"][uid]
		#if int(u["hp"]) <= 0:
			#continue
		#match mode:
			#ActionTypes.TargetMode.SINGLE_ENEMY:
				#if int(u["team"]) != caster_team:
					#out.append(uid)
			#ActionTypes.TargetMode.SINGLE_ALLY:
				#if int(u["team"]) == caster_team:
					#out.append(uid)
			#ActionTypes.TargetMode.SELF:
				#if uid == caster_id:
					#out.append(uid)
			#_:
				## Estendi per ALL_ENEMIES/ALL_ALLIES/EVERYONE
				#out.append(uid)
	#return out
