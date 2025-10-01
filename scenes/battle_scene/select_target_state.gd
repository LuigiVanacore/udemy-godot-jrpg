class_name SelectTargetState
extends LimboState



signal target_changed(unit )
signal target_selected(unit )

# ——— CONFIG ———


@export var marker_name: StringName = &"TargetMarker"        # Nome del Marker2D dentro all'unit


@export_range(0.0, 1.0, 0.01) var tween_time: float = 0.12   # Velocità movimento cursore
@export var wrap_around: bool = true                         # Se true, da ultimo torna al primo

var msg_cencel_action : StringName = &"cancel"

var _battle_scene : BattleScene  

var _units: Array[Unit] = []            # lasciato non tipizzato per tollerare istanze liberate
var _target_cursor : TargetCursor                     # Node2D atteso, ma non tipizzato (vedi doc blackboard)
var _index: int = 0
var _is_target_multiple = false


var target_cursor_scene : PackedScene = preload("uid://dcqfjgitjcvdb")

# ----------------- LIMBO LIFECYCLE -----------------

func _setup() -> void:
	_battle_scene = agent

func _enter() -> void:
	# Recupero dati da blackboard
	
	_units = _battle_scene._units       
	_target_cursor = target_cursor_scene.instantiate()
	add_child(_target_cursor)

 

	# Pulisce unità invalide
	_units = _units.filter(func(u): return is_instance_valid(u))

	#if _units.is_empty():
		#push_warning("SelectTargetState: nessuna unit disponibile in %s" % [str(units_var)])
		#dispatch(EVENT_CANCEL)
		#return

	# Seleziona il primo elemento e posiziona il cursore senza tween
	_index = clampi(_index, 0, _units.size() - 1)
	_snap_cursor_to_current_unit()
	emit_signal("target_changed", _units[_index], _index)

func _update(_delta: float) -> void:
	# Navigazione
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
		_step(-1)
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up"):
		_step(+1)

	# Conferma/Annulla
	if Input.is_action_just_pressed("ui_accept"):
		var selected : Unit = _units[_index]
		blackboard.set_var(_battle_scene.bb_target_unit, selected)
		target_selected.emit(selected)
		dispatch(_battle_scene.msg_target_selected)  # transizione “ok, finito”
	elif Input.is_action_just_pressed("ui_cancel"):
		dispatch(msg_cencel_action)

func _exit() -> void:
	_target_cursor.queue_free()

# ----------------- HELPERS -----------------

func _step(dir: int) -> void:
	# Rimuove eventuali istanze non valide runtime
	_units = _units.filter(func(u): return is_instance_valid(u))
	if _units.is_empty():
		dispatch(msg_cencel_action)
		return

	_index += dir
	if wrap_around:
		_index = (_index % _units.size() + _units.size()) % _units.size()
	else:
		_index = clampi(_index, 0, _units.size() - 1)

	_snap_cursor_to_current_unit()
	emit_signal("target_changed", _units[_index], _index)

func _get_marker_on(unit: Node) -> Marker2D:
	if unit == null or not is_instance_valid(unit):
		return null
	for c in unit.get_children():
		if c is Marker2D and c.name == marker_name:
			return c
	return null

func _current_target_global_pos() -> Vector2:
	var unit : Unit = _units[_index]
	var marker : Marker2D = unit.get_target_marker()
	if marker != null:
		return marker.global_position
	return Vector2.ZERO

func _snap_cursor_to_current_unit() -> void:
	if _target_cursor == null or not is_instance_valid(_target_cursor):
		return
	var target_position : Vector2 = _current_target_global_pos()
	_target_cursor.global_position = target_position
	var cursor_orientation := TargetCursor.PointedOrientation.RIGHT
	if _units[_index].is_party_member():
		cursor_orientation = TargetCursor.PointedOrientation.LEFT
	_target_cursor.set_pointed_orientation(cursor_orientation)
