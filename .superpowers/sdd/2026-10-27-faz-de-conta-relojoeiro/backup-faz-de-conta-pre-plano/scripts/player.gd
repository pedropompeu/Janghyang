extends CharacterBody3D
## First-person blockout controller. No HUD, no combat, no fail state.

@export var speed := 2.6
@export var mouse_sensitivity := 0.0022

var camera: Camera3D
var ray: RayCast3D
var flashlight: SpotLight3D
var _bob_time := 0.0

func _ready() -> void:
	camera = $Camera3D
	ray = $Camera3D/RayCast3D
	flashlight = $Camera3D/SpotLight3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensitivity
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * mouse_sensitivity, -1.45, 1.45)
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			KEY_E:
				_interact()
			KEY_F:
				flashlight.visible = not flashlight.visible
			KEY_R:
				get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		input_dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		input_dir.y += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		input_dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		input_dir.x += 1.0
	input_dir = input_dir.normalized()

	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction.length() > 0.01:
		velocity.x = move_toward(velocity.x, direction.x * speed, 10.0 * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)

	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= 9.8 * delta

	move_and_slide()

	var horizontal := Vector2(velocity.x, velocity.z).length()
	if horizontal > 0.1 and is_on_floor():
		_bob_time += delta * horizontal * 4.0
		camera.position.y = 1.62 + sin(_bob_time) * 0.018
	else:
		camera.position.y = lerpf(camera.position.y, 1.62, 8.0 * delta)

	if position.y < -5.0:
		position = Vector3(2.0, 0.25, 11.2)
		velocity = Vector3.ZERO

func _interact() -> void:
	if ray == null or not ray.is_colliding():
		return
	var collider := ray.get_collider()
	if collider != null and collider.has_method("interact"):
		collider.interact()

func get_look_ray() -> RayCast3D:
	return ray
