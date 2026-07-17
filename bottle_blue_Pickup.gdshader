shader_type spatial;
render_mode unshaded;
// Outline thickness (adjust as needed)
uniform float outline_width : hint_range(0.0, 0.2) = 0.05;

// Outline color
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Main texture (if your mesh has one)
uniform sampler2D albedo_texture : source_color;

// Vertex shader (optional, for custom effects)
void vertex() {
    // No custom vertex shader needed for this outline effect
}

// Fragment shader
void fragment() {
    // Sample the main texture
    vec4 albedo = texture(albedo_texture, UV);

    // Apply the outline color
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}