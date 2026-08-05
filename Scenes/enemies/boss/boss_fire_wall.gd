class_name BossFireWall extends Node2D

@export var lifetime: float = 0.55

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer = $Audio


func _ready() -> void:
	animation_player.play("burn")
	if audio.stream:
		audio.play()

	await get_tree().create_timer(lifetime).timeout
	queue_free()
