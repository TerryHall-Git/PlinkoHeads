extends Node2D

@export var target: NodePath  # The target node to follow

@onready var pupil: Node2D = $Pupil

func _process(_delta: float) -> void:
	if not has_node(target):
		return  # Exit if the target node doesn't exist

	var target_node = get_node(target)
	if target_node and target_node is Node2D:
		# Calculate the direction to the target
		var direction = (target_node.global_position - global_position).normalized()
		# Set the rotation to point toward the target
		rotation = direction.angle()
		pupil.rotation = -rotation
