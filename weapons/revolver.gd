extends Node

var player: CharacterBody3D

func setup(player_node: CharacterBody3D) -> void:
	player = player_node
	# Any other setup you need to do

func _process(_delta: float) -> void:
	
	# Handle shooting logic here
	if Input.is_action_just_pressed("fire"):
		shoot()

func shoot() -> void:
	var raycast = player.raycast
	var space_state = get_world_3d().direct_space_state
    
    # Get the global transform of the raycast
	var ray_start = raycast.global_transform.origin
	var ray_end = ray_start + raycast.global_transform.basis.z * 1000  # Extend the ray to 1000 units
    
    # Create physics ray query
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
    
    # Perform the raycast
	var result = space_state.intersect_ray(query)
    
	if result:
		print(result.collider.name)
		if result.collider.name == "hitbox":
			print("Hit!")
		else:
			print("Miss!")
	else:
		print("Nothing in trajectory")
    
	print("Bang!")
