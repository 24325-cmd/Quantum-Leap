class_name Enforcer extends Enemy

# --- Reused Nodes from your system ---
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Hitbox = $Hitbox
@onready var detection_component: DetectionComponent = $Components/DetectionComponent
@onready var enemy_state_machine: EnemyStateMachine = $EnemyStateMachine
@onready var damaged_audio: AudioStreamPlayer = $Audio/DamagedAudio
@onready var death_audio: AudioStreamPlayer = $Audio/DeathAudio
@onready var death_state: EnemyDeathState = $EnemyStateMachine/DeathState

# --- New Gun Specific Nodes ---
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer

# --- Export Variables ---
@export_category("Physics")
@export var speed: float = 40.0 # Slightly slower than Cyborg to feel heavy
@export var gravity: float = 980

@export_category("Weapon")
@export var bullet_scene: PackedScene # Drag your bullet scene here
@export var attack_cooldown: float = 1.5

func _ready() -> void:
	apply_level_difficulty()
	enemy_state_machine.configure(self)
	hitbox.take_damage.connect(_on_take_damage)
	
	# Match your default direction setup
	direction = -1.0 

func _process(delta: float) -> void:
	set_direction()
	# Update gun muzzle position to match the facing direction
	update_muzzle_position()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

# --- New Shooting Function ---
# Call this function from your custom EnemyStateMachine (e.g., inside an AttackState)
func shoot_weapon() -> void:
	if not shoot_timer.is_stopped() or not bullet_scene:
		return
		
	# Instantiating the projectile
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	
	# Passing your game's movement direction variable to the projectile
	if "direction" in bullet:
		bullet.direction = direction
	elif bullet.has_method("set_direction"):
		bullet.set_direction(direction)
		
	get_tree().current_scene.add_child(bullet)
	
	# Trigger the cooldown
	shoot_timer.start(attack_cooldown)

func update_muzzle_position() -> void:
	# Ensures the gun marker flips to the correct side of the body
	muzzle.position.x = abs(muzzle.position.x) * direction

func _on_take_damage(amount: int) -> void:
	damaged_audio.play()
	current_health -= amount
	
	sprite.modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)
	
	if current_health <= 0:
		enemy_state_machine.change_state(death_state)
		sprite.hide()
