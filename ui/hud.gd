extends Node
class_name HUD

signal assigned(car, ghost: GhostCar, timer: GameTimer, track: TrackLoader)
signal next_lap

@export var splits: Splits
@export var laps: LapCounter
