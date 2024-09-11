shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_disabled;

// Color properties for toon shading
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D color_ramp : source_color; // Color ramp texture for shading

// Outline properties
uniform float outline_width = 0.02;
uniform vec4 outline_color = vec4(0.0, 0.0, 0.0, 1.0);

// Toon shading steps
uniform int toon_steps = 4;

// Fresnel properties for rim lighting
uniform float fresnel_power = 4.0;
uniform vec4 fresnel_color = vec4(1.0, 1.0, 1.0, 1.0);

float calculate_fresnel(vec3 normal, vec3 view_dir) {
    return pow(1.0 - max(dot(normalize(normal), normalize(view_dir)), 0.0), fresnel_power);
}

void fragment() {
    // Basic color shading
    vec3 light_dir = normalize(LIGHT_VERTEX);
    float dot_nl = max(dot(NORMAL, light_dir), 0.0);

    // Toon shading based on steps
    float toon_shade = floor(dot_nl * float(toon_steps)) / float(toon_steps);

    // Apply color ramp for toon shading
    vec3 color = texture(color_ramp, vec2(toon_shade, 0.0)).rgb * base_color.rgb;

    // Fresnel effect for rim lighting
    float fresnel_effect = calculate_fresnel(NORMAL, VIEW);
    color += fresnel_effect * fresnel_color.rgb;

    ALBEDO = color;
}

void light() {
    // Apply the toon lighting model
    vec3 light_dir = normalize(LIGHT);
    float dot_nl = max(dot(NORMAL, light_dir), 0.0);
    float toon_shade = floor(dot_nl * float(toon_steps)) / float(toon_steps);

    // Use light color for toon steps
    DIFFUSE_LIGHT = toon_shade * LIGHT_COLOR;
}

void vertex() {
    // Add outline in vertex shader
    VERTEX += NORMAL * outline_width;
}
