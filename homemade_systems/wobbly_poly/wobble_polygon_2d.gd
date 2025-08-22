@tool
extends Polygon2D

@export_group("Position")
@export var base_position := Vector2.ZERO : set = _set_base_position

@export_group("Wobble Settings")
@export var points_intensity := 4.0 : set = _set_points_intensity
@export var whole_intensity := 0.5 : set = _set_whole_intensity
@export var speed := 1.0 : set = _set_speed

@export_group("Inheritance Settings")
@export var inherit_parent_wobble := false : set = _set_inherit_parent_wobble
@export var apply_whole_wobble_to_position := false : set = _set_apply_whole_wobble_to_position

@export_group("Advanced Settings")
@export var wobble_seed := 0.0 : set = _set_wobble_seed
@export var auto_randomize_seed := true
@export var time_offset := 1000.0 : set = _set_time_offset

var shader_material: ShaderMaterial
var whole_wobble_off_seed: float
var whole_wobble_speed_seed: float
var parent_wobble_offset: Vector2 = Vector2.ZERO

# Shader code as a string - will be compiled at runtime
const WOBBLE_SHADER = """
shader_type canvas_item;

uniform float points_intensity : hint_range(0.0, 20.0) = 4.0;
uniform float whole_intensity : hint_range(0.0, 10.0) = 0.5;
uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform float wobble_seed : hint_range(0.0, 1000.0) = 0.0;
uniform float time_offset : hint_range(0.0, 10000.0) = 1000.0;
uniform float whole_wobble_off_seed : hint_range(0.0, 100.0) = 0.0;
uniform float whole_wobble_speed_seed : hint_range(0.5, 2.5) = 1.5;
uniform bool apply_whole_wobble_to_position = false;
uniform vec2 parent_wobble_offset = vec2(0.0, 0.0);

varying vec2 world_vertex;

// Hash function to create consistent vertex indexing
float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void vertex() {
    vec2 original_pos = VERTEX;

    // Calculate time with offset and speed - matching original secs calculation
    float secs = (TIME + time_offset) * speed;

    // Create consistent vertex index from position hash
    float vertex_hash = hash12(original_pos + vec2(wobble_seed));
    float i = vertex_hash * 1000.0; // Scale to get varied indices

    // EXACT match to original point wobble calculations
    float x_rate_off = sin(i) * 1.0;  // Your original used * 1
    float y_rate_off = cos(i) * 1.0;  // Your original used * 1

    // Point wobble - exact formula from original
    float new_point_x = original_pos.x + sin(secs * (2.0 + x_rate_off) + i) * points_intensity;
    float new_point_y = original_pos.y + cos(secs * (2.0 + y_rate_off) - i) * points_intensity;

    // Calculate whole wobble - exact formula from original
    float whole_wobble_x = sin(secs * whole_wobble_speed_seed + whole_wobble_off_seed) * whole_intensity;
    float whole_wobble_y = cos(secs * whole_wobble_speed_seed + whole_wobble_off_seed) * whole_intensity;

    // Apply wobbles based on mode
    if (apply_whole_wobble_to_position) {
        // When using position mode, only apply point wobble to vertices
        VERTEX = vec2(new_point_x, new_point_y) + parent_wobble_offset;
    } else {
        // When not using position mode, apply both wobbles to vertices
        VERTEX = vec2(new_point_x + whole_wobble_x, new_point_y + whole_wobble_y) + parent_wobble_offset;
    }

    world_vertex = VERTEX;
}

void fragment() {
    COLOR = texture(TEXTURE, UV) * COLOR;
}
"""

func _ready() -> void:
    # Initialize base_position from current position if not set
    if base_position == Vector2.ZERO:
        base_position = position

    # Generate random seeds like the original
    whole_wobble_off_seed = randf_range(0, 100)
    whole_wobble_speed_seed = randf_range(0.5, 2.5)

    _setup_shader_material()

    if auto_randomize_seed:
        wobble_seed = randf_range(0.0, 100.0)
        _update_shader_params()

func _process(_delta: float) -> void:
    _update_position_and_inheritance()

func _setup_shader_material() -> void:
    # Create shader from code
    var shader = Shader.new()
    shader.code = WOBBLE_SHADER

    # Create and assign shader material
    shader_material = ShaderMaterial.new()
    shader_material.shader = shader
    material = shader_material

    _update_shader_params()

func _update_shader_params() -> void:
    if not shader_material:
        return

    shader_material.set_shader_parameter("points_intensity", points_intensity)
    shader_material.set_shader_parameter("whole_intensity", whole_intensity)
    shader_material.set_shader_parameter("speed", speed)
    shader_material.set_shader_parameter("wobble_seed", wobble_seed)
    shader_material.set_shader_parameter("time_offset", time_offset)
    shader_material.set_shader_parameter("whole_wobble_off_seed", whole_wobble_off_seed)
    shader_material.set_shader_parameter("whole_wobble_speed_seed", whole_wobble_speed_seed)
    shader_material.set_shader_parameter("apply_whole_wobble_to_position", apply_whole_wobble_to_position)
    shader_material.set_shader_parameter("parent_wobble_offset", parent_wobble_offset)

func _update_position_and_inheritance() -> void:
    # Calculate our own whole wobble for position or inheritance
    # Note: This is approximate since we can't access the exact shader TIME
    var secs = (Time.get_ticks_msec() / 1000.0 + time_offset) * speed
    var our_whole_wobble = Vector2(
        sin(secs * whole_wobble_speed_seed + whole_wobble_off_seed) * whole_intensity,
        cos(secs * whole_wobble_speed_seed + whole_wobble_off_seed) * whole_intensity
    )

    # Handle parent inheritance
    var inherited_offset = Vector2.ZERO
    if inherit_parent_wobble:
        var parent_wobbly = _find_parent_wobbly_polygon()
        if parent_wobbly:
            inherited_offset = parent_wobbly._get_current_whole_wobble()

    # Apply position wobble if enabled - OFFSET the base position
    if apply_whole_wobble_to_position:
        position = base_position + our_whole_wobble + inherited_offset
        parent_wobble_offset = Vector2.ZERO
    else:
        position = base_position + inherited_offset
        parent_wobble_offset = Vector2.ZERO

    # Update children that inherit from us
    _update_child_wobble_inheritance(our_whole_wobble + inherited_offset)

    # Update shader with current parent offset
    if shader_material:
        shader_material.set_shader_parameter("parent_wobble_offset", parent_wobble_offset)

func _find_parent_wobbly_polygon() -> Node:
    var parent = get_parent()
    while parent:
        if parent.has_method("_get_current_whole_wobble"):
            return parent
        parent = parent.get_parent()
    return null

func _get_current_whole_wobble() -> Vector2:
    var secs = (Time.get_ticks_msec() / 1000.0 + time_offset) * speed
    return Vector2(
        sin(secs * whole_wobble_speed_seed + whole_wobble_off_seed) * whole_intensity,
        cos(secs * whole_wobble_speed_seed + whole_wobble_off_seed) * whole_intensity
    )

func _update_child_wobble_inheritance(total_wobble: Vector2) -> void:
    for child in get_children():
        if child.has_method("_receive_parent_wobble"):
            child._receive_parent_wobble(total_wobble)

func _receive_parent_wobble(wobble: Vector2) -> void:
    if inherit_parent_wobble:
        parent_wobble_offset = wobble

# Setters for live updates in editor
func _set_base_position(value: Vector2) -> void:
    base_position = value

func _set_points_intensity(value: float) -> void:
    points_intensity = value
    _update_shader_params()

func _set_whole_intensity(value: float) -> void:
    whole_intensity = value
    _update_shader_params()

func _set_speed(value: float) -> void:
    speed = value
    _update_shader_params()

func _set_wobble_seed(value: float) -> void:
    wobble_seed = value
    _update_shader_params()

func _set_time_offset(value: float) -> void:
    time_offset = value
    _update_shader_params()

func _set_inherit_parent_wobble(value: bool) -> void:
    inherit_parent_wobble = value
    _update_shader_params()

func _set_apply_whole_wobble_to_position(value: bool) -> void:
    apply_whole_wobble_to_position = value
    _update_shader_params()

# Utility functions
func randomize_wobble() -> void:
    wobble_seed = randf_range(0.0, 100.0)
    whole_wobble_off_seed = randf_range(0, 100)
    whole_wobble_speed_seed = randf_range(0.5, 2.5)
    _update_shader_params()

func reset_wobble() -> void:
    time_offset = 1000.0
    randomize_wobble()

# Legacy methods for code compatibility
func set_base_position(new_pos: Vector2) -> void:
    base_position = new_pos

func get_base_position() -> Vector2:
    return base_position

# Optional: Pause wobble by setting speed to 0
func set_wobble_paused(paused: bool) -> void:
    speed = 0.0 if paused else 1.0
    _update_shader_params()
