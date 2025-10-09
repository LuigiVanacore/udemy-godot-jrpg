class_name UI_ActionMenu
extends Control


signal select_battle_action
signal battle_action_selected(action_type : ActionTypes.BattleAction)

@onready var sub_menu_control : Control = %SubMenuControl
@onready var sub_menu : ItemList = %SubMenu
@onready var command_list : CommandList = %CommandList


func _ready() -> void:
	select_battle_action.connect(_on_select_battle_action)
	

func _on_select_battle_action():
	command_list.set_cursor_visible(true)

func _on_btn_attack_pressed() -> void:
	command_list.set_cursor_visible(false)
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
	command_list.set_cursor_visible(false)
	battle_action_selected.emit(ActionTypes.BattleAction.DEFEND)


func _on_btn_escape_pressed() -> void:
	command_list.set_cursor_visible(false)
	battle_action_selected.emit(ActionTypes.BattleAction.ESCAPE)
