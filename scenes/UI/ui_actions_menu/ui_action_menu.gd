extends Control



@onready var sub_menu_control : Control = %SubMenuControl
@onready var sub_menu : ItemList = %SubMenu


func bind_unit(unit : Unit):
	pass

func _on_btn_attack_pressed() -> void:
	pass # Replace with function body.


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
	pass # Replace with function body.


func _on_btn_escape_pressed() -> void:
	pass # Replace with function body.
