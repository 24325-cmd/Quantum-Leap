class_name Coin extends Collectible


func collect(player: Player) -> void:
	XPManager.register_coin_collected(player)
	super.collect(player)
