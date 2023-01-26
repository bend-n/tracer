extends Node3D
class_name Car

@onready var ball := $Ball as RigidBody3D
@onready var car_mesh := $CarMesh as Node3D
@onready var ground_ray := $CarMesh/GroundRay as RayCast3D
# mesh references
@onready var right_wheel := $CarMesh/frontright as MeshInstance3D
@onready var left_wheel := $CarMesh/frontleft as MeshInstance3D
@onready var skid_l = $CarMesh/SkidL as GPUParticles3D
@onready var skid_r = $CarMesh/SkidR as GPUParticles3D
@onready var body_mesh := $CarMesh/body as MeshInstance3D
@export var show_debug := false

var acceleration := 35.0 # ai must change this for randomness
const sphere_offset := Vector3(0, -2, .5)
const max_steering_range := deg_to_rad(40.0)
const turn_speed := 2.0
const wheel_turn_speed := 0.2
const turn_stop_limit := 0.75
const body_tilt := 685.0

var throttle := 0.0
var _steering := 0.0

func _ready():
    $Ball/DebugMesh.visible = show_debug
    ground_ray.add_exception(ball)

func steer(to: float) -> void:
    _steering = clamp(lerpf(_steering, -to, wheel_turn_speed), -max_steering_range, max_steering_range)
    if is_zero_approx(_steering) or (_steering < .05 && _steering > -.05):
        _steering = 0
    # rotate wheels for effect
    right_wheel.rotation.y = _steering * .75
    left_wheel.rotation.y = _steering * .75

func move_mesh(delta: float) -> void:
   # just lerp the y due to trimesh bouncing
   car_mesh.transform.origin.x = ball.transform.origin.x + sphere_offset.x
   car_mesh.transform.origin.z = ball.transform.origin.z + sphere_offset.z
   car_mesh.transform.origin.y = lerp(car_mesh.transform.origin.y, ball.transform.origin.y + sphere_offset.y, 1 * delta)
   ball.apply_central_force(-car_mesh.global_transform.basis.z * throttle)

func turn(delta: float) -> void:
    if ball.linear_velocity.length() > turn_stop_limit:
        var new_basis := car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, _steering)
        car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
        car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
        # tilt body for effect
        body_mesh.rotation.z = lerp(body_mesh.rotation.z, clampf((-_steering * .2) * ball.linear_velocity.length_squared() / body_tilt, -.4, .4), 10 * delta)

func floor_mesh(delta: float) ->  void:
    var n = ground_ray.get_collision_normal()
    var xform := align_with_y(car_mesh.global_transform, n.normalized())
    car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)

func _physics_process(delta: float) -> void:
    move_mesh(delta)

    # if not ground_ray.is_colliding():
    #     return

    # print(ball.linear_velocity.normalized().dot(-car_mesh.transform.basis.y))
    # if throttle < 0 && :
    #     steering = -steering

    # drift particles
    var drift: bool = ball.linear_velocity.length() > 25 and abs(ball.linear_velocity.normalized().dot(-car_mesh.transform.basis.z)) > .5
    skid_l.emitting = drift
    skid_r.emitting = drift

    turn(delta)
    floor_mesh(delta)

func align_with_y(xform: Transform3D, new_y: Vector3) -> Transform3D:
    xform.basis.y = new_y
    xform.basis.x = -xform.basis.z.cross(new_y)
    xform.basis = xform.basis.orthonormalized()
    return xform
