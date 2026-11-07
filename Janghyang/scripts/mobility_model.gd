extends RefCounted
## How far Elias's body carries him: walking, a short run until the breath
## gives out, crouching, the slow steps of eyes closed, a person's hop. No bar
## on screen: the breath tells it.

const WALK := 2.6
const SPRINT := 4.4
const CROUCH := 1.3
const PRETEND := 1.1
const GRAVITY := 9.8
const JUMP_VELOCITY := 3.5
const DRAIN := 0.17
const RECOVER := 0.1
## Out of breath, he runs again only after this much comes back.
const RECOVERED := 0.6
const SPRINT_FOV := 7.0

var stamina := 1.0
var winded := false

## One tick. Returns whether he is running.
func update(dt: float, wants_sprint: bool, moving: bool) -> bool:
	var running := wants_sprint and moving and not winded and stamina > 0.0
	if running:
		stamina -= DRAIN * dt
		if stamina <= 0.0:
			stamina = 0.0
			winded = true
	else:
		stamina = minf(1.0, stamina + RECOVER * dt)
		if winded and stamina >= RECOVERED:
			winded = false
	return running

## 0 rested, 1 gasping.
func strain() -> float:
	return clampf(1.0 - stamina, 0.0, 1.0)

static func speed_for(sprinting: bool, crouched: bool, pretending: bool) -> float:
	if crouched:
		return CROUCH
	if pretending:
		return PRETEND
	return SPRINT if sprinting else WALK

static func fov_for(base: float, speed: float) -> float:
	return base + clampf((speed - WALK) / (SPRINT - WALK), 0.0, 1.0) * SPRINT_FOV
