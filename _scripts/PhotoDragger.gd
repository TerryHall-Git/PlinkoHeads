extends Sprite2D

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
@onready var photo: Sprite2D = $photo
var mouseArea:Control 

func _ready() -> void:
	mouseArea = get_tree().current_scene.get_node("Camera2D/UI/MainMenu/MouseArea")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Check if the mouse is within the mouseArea
			var mousePos:Vector2 = get_global_mouse_position()
			if mouseArea.get_global_rect().has_point(mousePos):
				drag_offset = photo.global_position - mousePos
				is_dragging = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
			
	if event is InputEventMouseMotion and is_dragging:
		photo.global_position = get_global_mouse_position() + drag_offset
		Global.player.get_node("mask/photo").position = photo.position
