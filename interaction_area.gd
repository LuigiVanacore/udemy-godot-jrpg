# res://actors/player/Interactor.gd
extends Area2D

signal interacted(target)         
signal focus_changed(target)     

@export var distance: float = 20.0
@export var box_size: Vector2 = Vector2(20, 16)
@export var use_8_directions: bool = false
@export var debug_draw: bool = false

@onready var collider: CollisionShape2D = $Shape
@onready var shape: RectangleShape2D = RectangleShape2D.new()

var _facing: Vector2 = Vector2.DOWN
var _candidates: Array[Node] = []
var _focused: Node = null

func _ready() -> void:
	monitoring = true
	monitorable = false

	# Assicura RectangleShape2D con dimensioni corrette
	if collider.shape is RectangleShape2D:
		shape = collider.shape as RectangleShape2D
	else:
		collider.shape = shape
	shape.size = box_size

	area_entered.connect(Callable(self, "_on_area_entered"))
	area_exited.connect(Callable(self, "_on_area_exited"))
	body_entered.connect(Callable(self, "_on_body_entered"))
	body_exited.connect(Callable(self, "_on_body_exited"))

func set_facing(dir: Vector2) -> void:
	var q: Vector2 = _quantize(dir)
	if q == Vector2.ZERO:
		return
	_facing = q
	position = q * distance
	if debug_draw:
		queue_redraw()

func try_interact(caller: Node) -> void:
	var target = _nearest_interactable()
	if target != null and target.has_method("interact"):
		target.interact(caller)
	emit_signal("interacted", target)

func _nearest_interactable():
	var best: Node = null
	var best_d: float = INF
	for n: Node in _candidates:
		if not is_instance_valid(n):
			continue
		if not n.is_in_group("interactable"):
			continue
		var d: float = (global_position - n.global_position).length_squared()
		if d < best_d:
			best_d = d
			best = n
	# aggiorna focus per prompt UI
	if best != _focused:
		_focused = best
		emit_signal("focus_changed", _focused)
	return best

func _quantize(v: Vector2) -> Vector2:
	if v == Vector2.ZERO:
		return _facing
	if use_8_directions:
		var angle: float = atan2(v.y, v.x)
		var step: float = PI / 4.0
		var idx: int = int(round(angle / step))
		var snapped: float = float(idx) * step
		return Vector2(cos(snapped), sin(snapped)).normalized()
	# 4 direzioni
	if absf(v.x) > absf(v.y):
		return Vector2(1, 0) if v.x >= 0.0 else Vector2(-1, 0)
	else:
		return Vector2(0, 1) if v.y >= 0.0 else Vector2(0, -1)

func _on_area_entered(a: Area2D) -> void:
	if a.is_in_group("interactable") and not _candidates.has(a):
		_candidates.append(a)

func _on_area_exited(a: Area2D) -> void:
	if _candidates.has(a):
		_candidates.erase(a)
		_nearest_interactable()

func _on_body_entered(b: Node) -> void:
	if b.is_in_group("interactable") and not _candidates.has(b):
		_candidates.append(b)

func _on_body_exited(b: Node) -> void:
	if _candidates.has(b):
		_candidates.erase(b)
		_nearest_interactable()

func _draw() -> void:
	if not debug_draw:
		return
	var r := Rect2(-box_size * 0.5, box_size)
	draw_rect(r, Color(0, 1, 0, 0.15), true)
	draw_rect(r, Color(0, 1, 0, 0.9), false, 1.0)
