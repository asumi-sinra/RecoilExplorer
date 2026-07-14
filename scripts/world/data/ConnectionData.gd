class_name ConnectionData

var direction : Enums.Direction

var connected : bool = false

var type : Enums.ConnectionType = Enums.ConnectionType.NORMAL


func _init(dir : Enums.Direction):

	direction = dir
