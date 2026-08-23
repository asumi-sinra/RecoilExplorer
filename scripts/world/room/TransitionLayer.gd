extends CanvasLayer
class_name TransitionLayer


## =========================
## フェード時間
## =========================

@export var fade_duration: float = 0.25


## =========================
## 暗転用ColorRect
## =========================

var fade_rect: ColorRect


func _ready() -> void:

	layer = 100

	fade_rect = ColorRect.new()
	fade_rect.name = "FadeRect"

	add_child(
		fade_rect
	)


	## 画面全体を覆う
	fade_rect.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


	## 入力は邪魔しない
	fade_rect.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


	## 黒
	fade_rect.color = Color.BLACK


	## 最初は透明
	fade_rect.modulate.a = 0.0


## =========================
## 暗転
## =========================

func fade_out() -> void:

	if fade_rect == null:
		return


	var tween: Tween = (
		create_tween()
	)


	tween.tween_property(
		fade_rect,
		"modulate:a",
		1.0,
		fade_duration
	)


	await tween.finished


## =========================
## 明転
## =========================

func fade_in() -> void:

	if fade_rect == null:
		return


	var tween: Tween = (
		create_tween()
	)


	tween.tween_property(
		fade_rect,
		"modulate:a",
		0.0,
		fade_duration
	)


	await tween.finished
