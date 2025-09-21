extends Control

@onready var panel: Panel = $Panel
@onready var icon: TextureRect = $Panel/TextureRect
@onready var label: Label = $Panel/Label

@export var color_player: Color = Color(0.15, 0.6, 1.0, 0.9)
@export var color_enemy: Color = Color(1.0, 0.35, 0.2, 0.9)

func show_turn(actor) -> void:
	if actor == null or not is_instance_valid(actor):
		hide()
		return
	show()
	#var name_text : String = actor.has_method("get_display_name") ? String(actor.call("get_display_name")) : String(actor.get("display_name") if actor.has_method("get") else "Actor")
	#label.text = "Tocca a: %s" % name_text

	var is_player : bool= false
	if actor.has_method("get_side"):
		is_player = int(actor.call("get_side")) == 0
	# Colora il pannello per lato
	var sb := StyleBoxFlat.new()
	if is_player:
		sb.bg_color = color_player
	else:
		sb.bg_color = color_enemy
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", sb)

	# piccolo pop
	modulate = Color(1,1,1,1)
	scale = Vector2(0.95, 0.95)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)
