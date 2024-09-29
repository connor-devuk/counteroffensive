extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 8.0

var hasGun : bool = false
var revolver_script: Node = null
var gun_model: Node3D = null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += Vector3(0, -24, 0) * delta

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

	if camera.has_node("revolver_model"):
			camera.get_node("revolver_model").visible = hasGun

	if hasGun:
		# Check if user already has a crosshair node if not lets add it
		# Otherwise we will continuisly add crosshair nodes and lag the game
		if !self.has_node("Crosshair"):
			self.add_child(ResourceLoader.load("res://addons/customizableCrosshair/crosshair/crosshair.tscn").instantiate())

		if !revolver_script:

			revolver_script = preload("res://weapons/revolver.gd").new()

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

	if event.is_action("pickup"):
		pickupGun()

	if event.is_action_pressed("dropItem"):
		if hasGun:
			hasGun = false
			if !get_parent().has_node("gun"):
				var node: RigidBody3D = preload("res://gun_object.tscn").instantiate()
				get_parent().add_child(node)
                
                # Set the initial position of the gun to be slightly in front of the camera
				var drop_pos = camera.global_transform.origin + (-camera.global_transform.basis.z * 1.5)
				node.global_transform.origin = drop_pos
                
                # Calculate the forward direction based on the camera's orientation
				var forward_dir = -camera.global_transform.basis.z
                
                # Apply an impulse in the forward direction
				node.apply_impulse(forward_dir * 5)  # Adjust the mu
		
			if self.has_node("revolver_model"):
				self.remove_child(self.get_node("revolver_model"))
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

@onready var raycast := $Camera3D/RayCast3D;

func pickupGun() -> void:
	print('is pickup signal', raycast.get_collider())
	if raycast.is_colliding() and raycast.get_collider().name == "gun":
		hasGun = true
		# print('picked up gun', self.get_parent().get_children())
		if self.get_parent().has_node("gun"):
			self.get_parent().remove_child(self.get_parent().get_node("gun"))