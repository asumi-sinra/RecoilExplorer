extends Resource
class_name RoomData


## =========================
## 表示名
## =========================

@export var display_name: String


## =========================
## 実際のRoomシーン
## =========================

@export var scene: PackedScene


## =========================
## このRoomが持つ論理上の出口
## =========================

@export var exits: Array[Enums.Direction]
