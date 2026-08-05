extends CanvasLayer

@onready var coin_count: Label = $Control/HBoxContainer/CoinCount


func _ready() -> void:
	update_display(CoinManager.coins)
	CoinManager.coins_changed.connect(update_display)


func update_display(amount: int) -> void:
	coin_count.text = str(amount)
