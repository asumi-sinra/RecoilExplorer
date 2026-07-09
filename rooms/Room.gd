extends Node2D

class_name Room

@export var room_name : String

@export var biome : Enums.BiomeType

@export_flags("Left","Right","Up","Down")
var connection : int

@export var weight : int = 10

@export var difficulty : int = 1

@export var is_boss_room := false

@export var is_treasure_room := false
