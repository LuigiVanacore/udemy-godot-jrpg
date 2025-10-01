class_name UI_ActionMenu
extends Control



signal battle_action_selected(action_type : ActionTypes.BattleAction)

@onready var sub_menu_control : Control = %SubMenuControl
@onready var sub_menu : ItemList = %SubMenu


func bind_unit(unit : Unit):
	pass

func _on_btn_attack_pressed() -> void:
	battle_action_selected.emit(ActionTypes.BattleAction.ATTACK)


func _on_btn_skills_pressed() -> void:
	if sub_menu_control.visible:
		sub_menu_control.visible = false
	else:
		sub_menu_control.visible = true


func _on_btn_items_pressed() -> void:
	if sub_menu_control.visible:
		sub_menu_control.visible = false
	else:
		sub_menu_control.visible = true



func _on_btn_defend_pressed() -> void:
	battle_action_selected.emit(ActionTypes.BattleAction.DEFEND)


func _on_btn_escape_pressed() -> void:
	battle_action_selected.emit(ActionTypes.BattleAction.ESCAPE)
