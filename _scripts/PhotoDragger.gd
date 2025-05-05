extends Sprite2D

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
@onready var photo: Sprite2D = $photo

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			drag_offset = photo.global_position - get_global_mouse_position()
			is_dragging = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
			
	if event is InputEventMouseMotion and is_dragging:
		photo.global_position = get_global_mouse_position() + drag_offset
		Global.player.get_node("mask/photo").position = photo.position
