class_name FloatingText2D
extends Node2D

signal finished(node: FloatingText2D)

enum MESSAGE_TYPE { DAMAGE, HEAL, NEUTRAL }

@onready var label: Label = $Label

# --- Parametri animazione ---
@export var rise_pixels: float = 40.0      # quanto sale in alto
@export var duration: float = 1.2          # durata salita (s)
@export var fade_time: float = 0.35        # quanto dura la dissolvenza finale (s)
@export var y_spawn_offset: float = -50.0   # offset iniziale sopra il punto
@export var horizontal_jitter: float = 8.0 # leggera casualità orizzontale

# --- Aspetto ---
@export var damage_color := Color(1.0, 0.27, 0.27)  # rosso
@export var heal_color   := Color(0.2, 1.0, 0.2)    # verde
@export var neutral_color := Color.WHITE
@export var critical_scale: float = 1.3             # scala del testo in critico
@export var outline_color := Color(0, 0, 0, 0.85)
@export var outline_size: int = 2
@export var custom_font: Font = null                # opzionale
@export var font_size : int = 24


func _ready() -> void:
	visible = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	if custom_font:
		label.add_theme_font_override("font", custom_font)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)

# Popup rapido per valori numerici (danno/heal)
func popup_amount(amount: int, world_pos: Vector2,
	kind: MESSAGE_TYPE = MESSAGE_TYPE.DAMAGE, crit: bool = false) -> void:
	var color := damage_color
	if kind == MESSAGE_TYPE.HEAL:
		color = heal_color
	elif kind == MESSAGE_TYPE.NEUTRAL:
		color = neutral_color
	popup_text(str(amount), world_pos, color, crit)

# Popup generico con testo
func popup_text(text: String, world_pos: Vector2,
	color: Color = Color.WHITE, crit: bool = false) -> void:
	# Posizionamento in coordinate globali con lieve jitter e offset verso l'alto
	var jitter_x := randf_range(-horizontal_jitter, horizontal_jitter)
	global_position = world_pos + Vector2(jitter_x, y_spawn_offset)

	label.text = text
	label.modulate = color
	label.scale = Vector2.ONE * (critical_scale if crit else 1.0)

	# Reset/Mostra
	modulate.a = 1.0
	visible = true

	# Avvia animazione (salita + fade finale in parallelo, con delay)
	_run_tween()

func _run_tween() -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Salita
	t.tween_property(self, "position:y", position.y - rise_pixels, duration)
	# Dissolvenza in parallelo, iniziata verso la fine della salita
	t.parallel().tween_property(self, "modulate:a", 0.0, fade_time)\
		.set_delay(max(0.0, duration - fade_time))
	t.finished.connect(_on_finished)

func _on_finished() -> void:
	emit_signal("finished", self)
	queue_free()  # se vuoi usare un pool, commenta questo e riusa l'istanza
