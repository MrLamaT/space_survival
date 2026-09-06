shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;

uniform float distortion : hint_range(0.0, 0.1) = 0.1;
uniform float wave_amplitude : hint_range(0.0, 0.03) = 0.03;
uniform float wave_speed : hint_range(0.0, 0.5) = 0.5;
uniform float wave_frequency : hint_range(0.0, 10.0) = 10.0;
uniform float time_scale : hint_range(0.0, 1.0) = 1.0;

uniform vec3 color_tint : source_color = vec3(0.1, 0.3, 0.6);
uniform float tint_intensity : hint_range(0.0, 0.5) = 0.5;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 uv_centered = uv * 2.0 - 1.0;
    
    float time = TIME * time_scale;
    float wave1 = sin(uv.y * wave_frequency + time * wave_speed) * wave_amplitude;
    float wave2 = cos(uv.x * wave_frequency * 0.7 + time * wave_speed * 1.3) * wave_amplitude * 0.6;
    
    vec2 wave_offset = vec2(wave1 + wave2 * 0.3, wave2 * 0.4 + wave1 * 0.2);
    
    float radius = length(uv_centered);
    float factor = 1.0 + distortion * radius * radius * 0.5;
    vec2 distorted_uv = (uv_centered / factor) * 0.5 + 0.5;
    
    distorted_uv += wave_offset * 0.5;
    
    vec3 color = texture(screen_texture, distorted_uv).rgb;
    
    color = mix(color, color * color_tint, tint_intensity);
    
    color.r *= 0.95;
    color.g *= 0.97;
    color.b *= 1.02;
    
    ALBEDO = color;
}