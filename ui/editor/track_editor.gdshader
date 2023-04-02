shader_type canvas_item;

void fragment() {
    
    // rect boundaries
    vec2 rectMin = vec2(0.4, 0.2);
    vec2 rectMax = vec2(0.8, 0.8);

    vec2 center = (rectMin + rectMax) / 2.0;
    vec2 halfSize = center - rectMin;
    vec2 fw = fwidth(UV);
    
    vec2 dist = abs(UV - center);
    
    float col = 0.0;
    if (all(lessThan(dist, halfSize)) && any(greaterThan(dist, halfSize - fw))) {
        // for pixel here I could use fragCoord.xy, but on textures you don't have it
        // using fwidth is a tricky way to operate in screenspace sizes on all surfaces
        // of course it's an approximation, but it's a pretty good one, here, uncomment this 
        // line to try fragCoord, it gives almost the same result:
        //vec2 pixel = fragCoord.xy;
        vec2 pixel = UV / fw;
        float aspect = halfSize.y / halfSize.x;
        float dir = (dist.x * aspect > dist.y) ?
              -sign(UV.x - center.x) : sign(UV.y - center.y);
        float dash = step(0.5, fract((pixel.x + pixel.y) * dir / 10.0 + TIME));
        col = mix(1.0, 0.0, dash);
    }
    
	COLOR = vec4(col, col, col, 1.0);
}

