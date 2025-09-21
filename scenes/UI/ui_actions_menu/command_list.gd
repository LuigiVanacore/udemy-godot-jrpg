extends VBoxContainer


signal action_selected(action)

var is_disabled := false
var _buttons: Array[TextureButton] = []

# === CONFIG ESPORTABILE ===
@export var cursor_offset_x := 0
@export var wrap_navigation := true


var _cursor_scene : PackedScene = preload("uid://c7joc7ff5e04c")
# riferimento runtime al cursore creato
var _cursor: TextureRect

func _ready() -> void:
	_cursor = _cursor_scene.instantiate()
	add_child(_cursor)
	_cursor.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_cursor.top_level = true   
	# raccogli bottoni
	for c in get_children():
		if c is TextureButton:
			_buttons.append(c)



	# focus & listener
	for i in _buttons.size():
		_buttons[i].focus_mode = Control.FOCUS_ALL
		_buttons[i].mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Defer: aspetta il layout prima di muovere il cursore
		_buttons[i].focus_entered.connect(func(): call_deferred("move_cursor_to_button", _buttons[i]))

	# focus iniziale
	if _buttons.size() > 0:
		_buttons[0].grab_focus()
		move_cursor_to_button(_buttons[0])


# ---------- CURSORE ----------


func move_cursor_to_button(button: TextureButton) -> void:
	if !_cursor or button == null: return

	var r: Rect2 = button.get_global_rect()
	# punto target: bordo destro + offset, centrato
	var target: Vector2 = r.position + Vector2(r.size.x + cursor_offset_x, r.size.y * 0.5)

	# allinea il pivot del cursore al target
	_cursor.position = target - _cursor.pivot_offset


	
func _on_UIActionButton_focus_entered(button: TextureButton, _name: String, _cost: int) -> void:
	move_cursor_to_button(button)
