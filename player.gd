# res://actors/player/Player.gd
class_name Player
extends CharacterBody2D

@export var walk_speed: float = 120.0
@export var run_multiplier: float = 1.35
@export var acceleration: float = 900.0
@export var deceleration: float = 1200.0

@onready var animator: Node = $Sprite
@onready var interactor: Area2D = $InteractionArea
@onready var encounter_meter: Node = $EncounterMeter

var _move_input: Vector2 = Vector2.ZERO
var _last_dir: Vector2 = Vector2.DOWN

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	# Input direzione (normalizzato)
	_move_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var is_running := Input.is_action_pressed("run")
	var target_speed := (walk_speed * (run_multiplier if is_running else 1.0))
	var target_vel := _move_input * target_speed

	# Accelerazione / Decelerazione
	if _move_input.length() > 0.0:
		velocity = velocity.move_toward(target_vel, acceleration * delta)
		_last_dir = _move_input
		if interactor and interactor.has_method("set_facing"):
			interactor.set_facing(_last_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()

	# Anima in base alla velocità
	#if animator and "set_motion" in animator:
		#animator.set_motion(velocity, _last_dir)

	# Avanza il contatore incontri solo quando ti muovi
	if encounter_meter and _move_input.length() > 0.0:
		if "tick_moving" in encounter_meter:
			encounter_meter.tick_moving(delta)
	else:
		if encounter_meter and "tick_idle" in encounter_meter:
			encounter_meter.tick_idle(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if interactor and "try_interact" in interactor:
			interactor.try_interact(self)
