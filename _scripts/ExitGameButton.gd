extends TextureRect


func _on_mouse_entered() -> void:
	# Change the modulate color to pure white
	modulate = Color(1, 1, 1)

func _on_mouse_exited() -> void:
	# Change the modulate color to (200, 200, 200)
	modulate = Color(200 / 255.0, 200 / 255.0, 200 / 255.0)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Exit the game
		get_tree().quit()
