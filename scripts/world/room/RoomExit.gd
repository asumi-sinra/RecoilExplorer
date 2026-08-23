extends Area2D
class_name RoomExit


signal exit_requested(direction: Enums.Direction)


## =========================
## この出口が論理マップ上の
## どの方向へ移動する出口か
## =========================

@export var direction: Enums.Direction = Enums.Direction.RIGHT


func _ready() -> void:

	body_entered.connect(
		_on_body_entered
	)


## =========================
## Playerが出口に触れた
## =========================

func _on_body_entered(
	body: Node2D
) -> void:

	## Player以外では反応しない
	if not body.is_in_group("player"):
		return


	exit_requested.emit(
		direction
	)
