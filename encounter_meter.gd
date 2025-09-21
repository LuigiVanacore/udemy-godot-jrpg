# res://actors/player/EncounterMeter.gd
extends Node

signal encounter_triggered

@export var min_seconds: float = 10.0
@export var max_seconds: float = 25.0
@export var moving_gain_per_sec: float = 1.0     # quanto avanza al secondo in movimento
@export var idle_drain_per_sec: float = 0.15     # scarico lieve se resti fermo
@export var bonus_multiplier_run: float = 1.2    # correre aumenta il rischio? integrare dal Player se vuoi

var _threshold: float = 0.0
var _progress: float = 0.0

func _ready() -> void:
	_reset_threshold()

func tick_moving(delta: float) -> void:
	_progress += moving_gain_per_sec * delta
	if _progress >= _threshold:
		_progress = 0.0
		_reset_threshold()
		encounter_triggered.emit()

func tick_idle(delta: float) -> void:
	_progress = maxf(0.0, _progress - idle_drain_per_sec * delta)

func apply_repellent_bonus(extra_seconds: float) -> void:
	# Chiamala quando usi un item "repellente"
	_threshold += maxf(0.0, extra_seconds)

func _reset_threshold() -> void:
	_threshold = randf_range(min_seconds, max_seconds)
