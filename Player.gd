extends CharacterBody3D

@onready var head = $head
@onready var animation_player = $AnimationPlayer
@onready var camera = $head/camera
@onready var ray_cast_3d = $head/camera/RayCast3D

var playerColor:Color = Color(0,0,0)
var is_ready = false
var current_speed = 5.0
var health = 3
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

const JUMP_VELOCITY = 4.5
const mouse_sens = 0.1
var lerp_speed = 10.0
var direction = Vector3.ZERO
var crouching_depth = -0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	is_ready = true
func _input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89),deg_to_rad(89))
	if Input.is_action_just_pressed("shoot") and animation_player.current_animation != "shoot":
		print("hm")
		#shoot.rpc()
		if ray_cast_3d.is_colliding():
			var hit_player = ray_cast_3d.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
	else:
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
		else:
			current_speed = walking_speed
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()
	
@rpc("call_local")
func shoot():
	
	animation_player.stop()
	animation_player.play("shoot")

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		#position = Vector3(0,10,0)
	print("Hit")
func setName(player_name):
	$Name.text = player_name

func setColor(color:Color):
	var material:StandardMaterial3D = $MeshInstance3D.get_active_material(0).duplicate()
	material.albedo_color = color
	$MeshInstance3D.set_surface_override_material(0, material)
