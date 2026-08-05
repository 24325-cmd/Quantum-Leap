class_name HealthPotion extends Collectible

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@export var heal_amount: int = 1


func collect(player: Player) -> void:
	if player.current_health < player.max_health:
		player.heal(heal_amount)
		super.collect(player)
		audio.play()

		await audio.finished
		queue_free()
