shader_type canvas_item;

//shadertoy 4lKXWD

uniform vec4 bg_color: source_color = vec4(0,0,0,0.1);
uniform float dash_color: hint_range(0.0, 1.0, 0.1) = 1;
uniform float empty_color: hint_range(0.0, 1.0, 0.1) = 0;

const vec2 center = vec2(0.5, 0.5);

void fragment() {
		vec2 fw = fwidth(UV);
		vec2 dist = abs(UV - center);
		if (all(lessThan(dist, center)) && any(greaterThan(dist, center - fw))) {
			float dir = (dist.x > dist.y) ? -sign(UV.x - center.x) : sign(UV.y - center.y);
			float dash = step(0.5, fract((FRAGCOORD.x + FRAGCOORD.y) * dir / 10.0 + TIME));
			float col = mix(dash_color, empty_color, dash);
			COLOR = vec4(col, col, col, 1);
		} else { COLOR = bg_color; }
}

