class_name TargetCursor
extends Node2D

enum PointedOrientation { RIGHT, LEFT }

@export var position_right_side: Vector2 = Vector2.ZERO
@export var position_left_side: Vector2 = Vector2.ZERO
@export var  pointed_orientation : PointedOrientation = PointedOrientation.RIGHT


@onready var pivot : Marker2D = $Pivot
@onready var animated_sprite : AnimatedSprite2D = $Pivot/AnimatedSprite



func _ready() -> void:
	set_pointed_orientation(pointed_orientation)

func set_pointed_orientation(orientation : PointedOrientation):
	pointed_orientation = orientation
	if pointed_orientation == PointedOrientation.RIGHT:
		animated_sprite.position = position_right_side
		animated_sprite.flip_h = false
	else:
		animated_sprite.position = position_left_side
		animated_sprite.flip_h = true


 #
## Coordinate (in pixel) della punta dell’indice dentro la texture, quando la mano punta a DESTRA.
## Origine (0,0) in alto-sinistra dell'immagine, come da convenzione.
#
#
## Offset di posizionamento rispetto a un asse verticale, quando punta a DESTRA.
## dx > 0 significa "a destra dell'asse". dy è lo scarto verticale.
#@export var offset_from_axis_right: Vector2 = Vector2(16, 0)
#
#@export var debug_draw_origin := true
#
#@onready var spr: Sprite2D = $Sprite2D
#
#func _ready() -> void:
	#assert(spr != null, "HandPointer richiede un Sprite2D figlio")
	#if texture:
		#spr.texture = texture
	#spr.centered = true
	#_apply_tip_offset()
#
## --- Allinea l’origine del nodo alla punta del dito ---
#func _apply_tip_offset() -> void:
	#if spr == null or spr.texture == null:
		#return
	#var size: Vector2 = spr.texture.get_size()
	#var center: Vector2 = size * 0.5
#
	## Se flip_h è attivo, la punta va “specchiata” rispetto al centro
	#var tip := tip_px_right
	#if spr.flip_h:
		#tip.x = size.x - tip_px_right.x
		## tip.y resta uguale: flip orizzontale non cambia la y
#
	## Con Sprite2D.centered = true, l'immagine è centrata sull'origine del nodo;
	## spostiamo l'immagine di (center - tip) così che il pixel "tip" coincida con (0,0).
	#spr.offset = center - tip
#
## --- API di posizionamento: imposta direzione e coord globali simmetriche rispetto a un asse X ---
## axis_x: ascissa della retta verticale di simmetria (per esempio, la x del bersaglio)
## anchor_y: ordinata di allineamento (per esempio, la y del bersaglio)
## offset_right: spostamento quando punta a DESTRA (a SINISTRA sarà specchiato sull'asse)
#func set_side_right(is_right: bool, axis_x: float, anchor_y: float, offset_right: Vector2 = offset_from_axis_right) -> void:
	#spr.flip_h = not is_right
	#_apply_tip_offset()
#
	#var dx := offset_right.x
	#var dy := offset_right.y
#
	## Posizione speculare rispetto all’asse verticale x = axis_x
	## Destra:  axis_x + dx
	## Sinistra: axis_x - dx    (simmetria orizzontale)
	#var x := axis_x + (is_right ? +dx : -dx)
	#global_position = Vector2(x, anchor_y + dy)
#
## Variante: se conosci la posizione "a destra", ricava automaticamente quella “a sinistra”
#func set_from_right_position(right_pos: Vector2, axis_x: float, is_right: bool) -> void:
	#spr.flip_h = not is_right
	#_apply_tip_offset()
	#if is_right:
		#global_position = right_pos
	#else:
		## Specchio di right_pos rispetto a x = axis_x
		#global_position = Vector2(2.0 * axis_x - right_pos.x, right_pos.y)
 
