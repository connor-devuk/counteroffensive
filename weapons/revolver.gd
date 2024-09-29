extends Node

var player: CharacterBody3D  # Reference to the player node

func setup(player_node: CharacterBody3D) -> void:
	player = player_node
	# Any other setup you need to do

func _process(_delta: float) -> void:
	# Handle shooting logic here
	if Input.is_action_just_pressed("fire"):
		shoot()

func shoot() -> void:
	# Implement your shooting logic here
	print("Bang!", player.hasGun)
