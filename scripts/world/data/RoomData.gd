extends Resource
class_name RoomData


## Room名
@export var display_name: String = ""


## 実際にロードするScene
@export var scene: PackedScene


## 論理上の出口
@export var exits: Array[Enums.Direction] = []


## trueならRoomSceneが出口を実行時に有効化・無効化する
@export var configure_exits_at_runtime: bool = false


## デバッグ用バリエーション
## 0 = A、1 = B
@export_range(0, 1, 1) var debug_variant: int = 0
