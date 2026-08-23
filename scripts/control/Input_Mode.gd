extends Node

#入力モードが変わったことを伝えるシグナルを定義
signal input_mode_changed(new_device)

#入力モードの定義
enum InputDevice {
	KEYBORAD_AND_MOUSE,
	GAMEPAD
}

var current_input_device : InputDevice = InputDevice.KEYBORAD_AND_MOUSE

#入力モードがセットされたら呼ばれる
func set_input_device(new_device: InputDevice):
	#セットされたモードがcurrentと一致してるなら何もしない
	if current_input_device == new_device:
		return
		
	#一致してないならシグナル(何のデバイスに変わったか引数)を発信する
	current_input_device = new_device
	input_mode_changed.emit(new_device)
	
func _input(event):
	# --- マウス or キーボード入力があったら ---
	if event is InputEventMouseMotion \
	or event is InputEventMouseButton \
	or event is InputEventKey:
		set_input_device(InputDevice.KEYBORAD_AND_MOUSE) #入力モードをキーマウにする

	# --- ゲームパッド入力があったら ---
	elif event is InputEventJoypadButton:
			set_input_device(InputDevice.GAMEPAD)

	elif event is InputEventJoypadMotion:
		# スティックがある程度倒されたときだけ反応（ドリフト対策）
		if abs(event.axis_value) > 0.2:
			set_input_device(InputDevice.GAMEPAD) #入力モードをパッドにする
