shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, ambient_light_disabled, blend_add, shadows_disabled;

group_uniforms ColorAndPattern;
uniform vec4 color : source_color;
uniform float pattern_scroll_speed = 0.025;
uniform vec2 pattern_uv_scale = vec2(6.0, 3.0);
uniform sampler2D pattern_texture : source_color;
group_uniforms;

group_uniforms Intensity;
uniform float fresnel_power: hint_range(0.5, 8.0) = 4.0;
uniform float edge_intensity: hint_range(0.0, 2.0) = 1.5;
uniform float center_intensity : hint_range(0.0, 1.0) = 0.1;
group_uniforms;

group_uniforms Pulsing;
uniform float pulsing_strength = 0.25;
uniform float pulsing_speed = 1.0;
group_uniforms;

group_uniforms Scanlines;
uniform float scanline_frequency = 0.5;
uniform float scanline_width : hint_range(0, 0.5) = 0.1;
uniform float scanline_intensity = 0.35;
group_uniforms;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

void vertex() {
	float pulse_distance = sin(TIME * pulsing_speed) * 0.1 * pulsing_strength;
	VERTEX += NORMAL * pulse_distance;
}

float get_linear_depth(sampler2D depth_texture, vec2 screen_uv, mat4 inv_projection_matrix, bool use_opengl_ndc) {
	float depth_raw = texture(depth_texture, screen_uv).x;
	vec3 ndc;
	if (use_opengl_ndc){
		ndc = vec3(screen_uv, depth_raw) * 2.0 - 1.0;
	} else {
		ndc = vec3(screen_uv * 2.0 - 1.0, depth_raw);
	}
	vec4 position_view = inv_projection_matrix * vec4(ndc, 1.0);
	position_view.xyz /= position_view.w;
	return -position_view.z;
}

void fragment() {
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power) * edge_intensity;
	fresnel = fresnel + center_intensity;
	float depth = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);
	depth = depth + VERTEX.z;
	depth = pow(1.0 - clamp(depth, 0, 1), fresnel_power) * edge_intensity;
	fresnel = fresnel + depth;
	float scrolling_time = TIME * pattern_scroll_speed;
	vec4 pattern = texture(pattern_texture, (UV * pattern_uv_scale) + vec2(scrolling_time));
	fresnel *= pattern.r;
	float uv_offset = mod(-TIME * scanline_frequency, 2.0) - 1.0;
	float scanline = smoothstep(0.5 - scanline_width, 0.5, UV.y + uv_offset)
			* (1.0 - smoothstep(0.5, 0.5 + scanline_width, UV.y + uv_offset)) * pattern.r;
	ALBEDO = vec3(0);
	EMISSION = color.rgb;
	ALPHA = smoothstep(0.0, 1.0, fresnel + scanline * scanline_intensity);
}
