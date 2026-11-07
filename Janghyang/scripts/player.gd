extends CharacterBody3D
## First-person controller: walk, run until the breath gives out, hop,
## crouch, climb ladders, and close the eyes to pretend. No HUD.

const Mobility = preload("res://scripts/mobility_model.gd")

@export var mouse_sensitivity := 0.0022
## Options (settings_ui.gd): mouse up looks down.
var invert_y := false

const STAND_EYE := 1.62
const CROUCH_EYE := 0.92

signal catalog_requested(target: Area3D)
signal notebook_requested
## M: the plan spread of the notebook (lots and map).
signal map_requested
## Once per footfall, at the low point of the head bob.
signal stepped
## Every use of the hands, for the house's recording.
signal acted(verb: StringName, collider: Node)
## The stick leaves the shoulder, whether or not it will meet anything.
signal swung
## Feet back on the ground after a fall; `impact` in m/s.
signal landed(impact: float)
## One rung of a ladder, up or down.
signal climbed
## Eyes closed (pretending) or open again.
signal pretend_changed(on: bool)

const VERBS := {&"Ball": &"rolar", &"Doll": &"boneco", &"MusicBox": &"musica", &"Figure": &"vela", &"EntryClock": &"corda"}

const EXAMINE_FOV := 45.0
const KNOCK_REACH := 1.5
const CLIMB_SPEED := 1.7
const RUNG := 0.32
## Falls below this are taken back to the respawn point.
const FALL_LIMIT := -9.0

var camera: Camera3D
var ray: RayCast3D
var catalog_ray: RayCast3D
var flashlight: SpotLight3D
## Elias's hands and his stick; optional, built by main as child "Hands".
var hands: Node
var crouched := false
var mobility = Mobility.new()
var sprinting := false
## Eyes closed, remembering the house as it was (V or the right button held).
var pretending := false
## Ladder volumes the body is inside; ladder.gd keeps the count.
var ladders := 0
## While true (notebook open, ending) only Tab is read.
var input_locked := false
## Where a fall or a restart puts the player back; set by main.
var respawn_point := Vector3(1.8, 0.2, 8.3)
var _bob_time := 0.0
var _eye := STAND_EYE
var _stand_query: CapsuleShape3D
var _base_fov := 70.0
var _examine_tween: Tween
var _want_jump := false
var _pretend_held := false
var _fall_speed := 0.0
var _climb_acc := 0.0

func _ready() -> void:
	camera = $Camera3D
	ray = $Camera3D/RayCast3D
	flashlight = $Camera3D/SpotLight3D
	catalog_ray = get_node_or_null("Camera3D/CatalogRay")
	hands = get_node_or_null("Hands")
	if hands != null:
		hands.struck.connect(_land_knock)
	_base_fov = camera.fov
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## The resting field of view (options); running and examining lean on it.
func set_base_fov(fov: float) -> void:
	_base_fov = fov
	camera.fov = fov

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		notebook_requested.emit()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		map_requested.emit()
		get_viewport().set_input_as_handled()
		return
	# R works even while locked: after the ending, too. Esc is the options
	# sheet (settings_ui.gd).
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		# A-017: log which event reloads the scene (diagnostic only, no behaviour change).
		print("[reload] R via %s" % event)
		get_tree().reload_current_scene()
		return
	if input_locked:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensitivity
		var pitch_sign := -1.0 if invert_y else 1.0
		camera.rotation.x = clampf(camera.rotation.x - pitch_sign * event.relative.y * mouse_sensitivity, -1.45, 1.45)
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_E:
				_interact()
			KEY_Q:
				var target := catalog_target_in_view()
				if target != null:
					catalog_requested.emit(target)
			KEY_B:
				_knock()
			KEY_C, KEY_CTRL:
				set_crouched(not crouched)
			KEY_SPACE:
				_want_jump = true
			KEY_F:
				flashlight.visible = not flashlight.visible

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
	input_dir = Vector2.ZERO if input_locked else input_dir.normalized()

	var held := not input_locked and (Input.is_physical_key_pressed(KEY_V) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))
	if held != _pretend_held:
		_pretend_held = held
		set_pretending(held)
	var wants_run := not input_locked and Input.is_physical_key_pressed(KEY_SHIFT) and input_dir.y < 0.0 and not crouched and not pretending
	sprinting = mobility.update(delta, wants_run, input_dir.length() > 0.1)

	var climbing := ladders > 0 and not input_locked
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var top := _speed() * (0.5 if climbing else 1.0)
	if direction.length() > 0.01:
		velocity.x = move_toward(velocity.x, direction.x * top, 10.0 * delta)
		velocity.z = move_toward(velocity.z, direction.z * top, 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)

	var was_on_floor := is_on_floor()
	if climbing:
		velocity.y = -input_dir.y * CLIMB_SPEED
		_climb_acc += absf(velocity.y) * delta
		if _climb_acc >= RUNG:
			_climb_acc = 0.0
			climbed.emit()
	elif is_on_floor():
		velocity.y = -0.1
		if _want_jump and not crouched and not input_locked:
			velocity.y = Mobility.JUMP_VELOCITY
	else:
		velocity.y -= Mobility.GRAVITY * delta
	_want_jump = false
	if not was_on_floor:
		_fall_speed = minf(_fall_speed, velocity.y)

	move_and_slide()

	if is_on_floor() and not was_on_floor:
		if _fall_speed < -3.0:
			landed.emit(-_fall_speed)
		_fall_speed = 0.0

	var horizontal := Vector2(velocity.x, velocity.z).length()
	if horizontal > 0.1 and is_on_floor():
		var before := floori(_bob_time / PI)
		_bob_time += delta * horizontal * 4.0
		if floori(_bob_time / PI) != before:
			stepped.emit()
		camera.position.y = _eye + sin(_bob_time) * 0.018
	else:
		camera.position.y = lerpf(camera.position.y, _eye, 8.0 * delta)

	if _examine_tween == null or not _examine_tween.is_running():
		camera.fov = lerpf(camera.fov, Mobility.fov_for(_base_fov, horizontal), minf(1.0, 5.0 * delta))

	if position.y < FALL_LIMIT:
		position = respawn_point
		velocity = Vector3.ZERO

func _speed() -> float:
	return Mobility.speed_for(sprinting, crouched, pretending)

## Close or open the eyes. Closing them lowers the stick and slows the step.
func set_pretending(on: bool) -> void:
	if on == pretending:
		return
	pretending = on
	pretend_changed.emit(on)

## 0 rested, 1 gasping: how hard the last run was.
func strain() -> float:
	return mobility.strain()

## Crouch or stand. Standing up is refused when a standing capsule would hit
## the world (under the folded F1, for example). Returns the resulting state
## as requested: true when the request was honoured.
func set_crouched(on: bool) -> bool:
	if on == crouched:
		return true
	if not on and not _can_stand():
		return false
	crouched = on
	var cs := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if cs == null:
		for child in get_children():
			if child is CollisionShape3D:
				cs = child
				break
	if cs != null and cs.shape is CapsuleShape3D:
		(cs.shape as CapsuleShape3D).height = 1.0 if on else 1.7
		cs.position.y = 0.5 if on else 0.85
	_eye = CROUCH_EYE if on else STAND_EYE
	return true

func _can_stand() -> bool:
	if _stand_query == null:
		_stand_query = CapsuleShape3D.new()
		_stand_query.radius = 0.28
		_stand_query.height = 1.6
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = _stand_query
	params.transform = Transform3D(Basis.IDENTITY, global_position + Vector3(0.0, 0.85, 0.0))
	params.collision_mask = 1
	params.collide_with_bodies = true
	params.collide_with_areas = false
	params.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(params, 1).is_empty()

func _interact() -> void:
	if ray == null or not ray.is_colliding():
		return
	var collider := ray.get_collider()
	if collider != null and collider.has_method("interact"):
		collider.interact()
		if hands != null:
			hands.reach()
		var verb := verb_for(collider)
		if verb != &"":
			acted.emit(verb, collider)

## The stick on whatever is right in front: a wall, a door, a piece of
## furniture. With hands the knock lands at the end of the swing; a swing in
## the air is only a swish.
func _knock() -> void:
	if hands == null:
		_land_knock()
		return
	if hands.swing():
		swung.emit()

func _land_knock() -> void:
	if ray == null:
		return
	ray.force_raycast_update()
	if not ray.is_colliding():
		return
	if camera.global_position.distance_to(ray.get_collision_point()) > KNOCK_REACH:
		return
	if hands != null:
		hands.recoil()
	acted.emit(&"bater", ray.get_collider())

## What the house calls this gesture: doors open, other hinges fold.
static func verb_for(collider: Node) -> StringName:
	if VERBS.has(collider.name):
		return VERBS[collider.name]
	if "rotation_a" in collider:
		return &"abrir" if String(collider.name).begins_with("Door") else &"dobrar"
	return &""

## The catalogue spot under the crosshair, unless something solid stands
## clearly in front of it.
func catalog_target_in_view() -> Area3D:
	if catalog_ray == null or not catalog_ray.is_colliding():
		return null
	var area := catalog_ray.get_collider() as Area3D
	if area == null:
		return null
	if ray != null and ray.is_colliding():
		var origin := catalog_ray.global_position
		var solid := origin.distance_to(ray.get_collision_point())
		if solid < origin.distance_to(catalog_ray.get_collision_point()) - 0.35:
			return null
	return area

## Lean in to look: the view narrows, holds, and comes back.
func examine() -> void:
	if camera == null:
		return
	if _examine_tween != null and _examine_tween.is_valid():
		_examine_tween.kill()
	_examine_tween = create_tween()
	_examine_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_examine_tween.tween_property(camera, "fov", EXAMINE_FOV, 0.4)
	_examine_tween.tween_interval(1.2)
	_examine_tween.tween_property(camera, "fov", _base_fov, 0.4)

func get_look_ray() -> RayCast3D:
	return ray
