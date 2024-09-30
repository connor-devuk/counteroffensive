extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 8.0

var hasGun : bool = false
var selectedGun: String
var revolver_script: Node = null
var gun_model: Node3D = null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += Vector3(0, -20, 0) * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if camera.has_node(selectedGun+"_model"):
			camera.get_node(selectedGun+"_model").visible = hasGun

	if hasGun:
		# Check if user already has a crosshair node if not lets add it
		# Otherwise we will continuisly add crosshair nodes and lag the game
		if !self.has_node("Crosshair"):
			self.add_child(ResourceLoader.load("res://addons/customizableCrosshair/crosshair/crosshair.tscn").instantiate())

		if !revolver_script:
			const PATH = "res://weapons/revolver.gd"

			revolver_script = preload(PATH).new()

			add_child(revolver_script)

			revolver_script.setup(self)
	else: 
		if self.has_node("Crosshair"):
			self.remove_child(self.get_node("Crosshair"))

		if revolver_script:
			remove_child(revolver_script)
			revolver_script = null

		# Let's add the gun to the user's hand

	
const MOUSE_SENSITIVITY = 0.0008;
@onready var camera := $Camera3D;
@onready var marker := $Camera3D/Marker3D;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -1.5, 1.5)

	if event.is_action_released("pickup"):
		pickupGun()

	if event.is_action_pressed("dropItem"):
		dropGun()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

@onready var raycast := $Camera3D/RayCast3D;	

func pickupGun() -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var gun_scenes = list_files_in_directory("res://entities/")
		
		# Check if the collider is a gun
		for scene in gun_scenes:
			if scene.get_file().get_basename() == collider.name+'_object':
				var node_path = NodePath(collider.name)
				if self.get_parent().has_node(node_path):
					if hasGun:
						dropGun()
					hasGun = true
					selectedGun = node_path
					self.get_parent().remove_child(self.get_parent().get_node(node_path))
				print("Picked up gun: ", collider.name)
				return
		
			print("Collided with non-gun object: ", collider.name)
	else:
			print("No collision detected")

func dropGun() -> void:
	if hasGun:
		hasGun = false
		var ENTITY_SCENE_PATH = "res://entities/" + selectedGun + "_object.tscn"
		if !get_parent().has_node(selectedGun):
			var scene = load(ENTITY_SCENE_PATH)
			if scene is PackedScene:
				if camera.has_node(selectedGun+"_model"):
					camera.get_node(selectedGun+"_model").visible = false
			
				var node: RigidBody3D = scene.instantiate()
				get_parent().add_child(node)
					
				# Set the initial position of the gun to be slightly in front of the camera
				var drop_pos = camera.global_transform.origin + (-camera.global_transform.basis.z * 1.5)
				node.global_transform.origin = drop_pos
					
				# Calculate the forward direction based on the camera's orientation
				var forward_dir = -camera.global_transform.basis.z
					
				# Apply an impulse in the forward direction
				node.apply_impulse(forward_dir * 5)  # Adjust the multiplier as needed
			else:
				print("Failed to load scene: ", ENTITY_SCENE_PATH)
		else:
			print("Gun node already exists")
	else:
		print("No gun to drop")
# Simple function to get a list of guns available
func list_files_in_directory(path: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files
