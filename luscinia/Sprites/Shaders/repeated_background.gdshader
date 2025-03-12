shader_type canvas_item;

uniform vec4 color_tint : source_color = vec4(1,1,1,1);
uniform float offset_amount :hint_range(0, 5, 0.1) = 0;
uniform float texture_size:hint_range(1, 1000, 0.01) = 1;
uniform float rotation:hint_range(0, 360, 1) = 0;
uniform vec2 scroll_speed = vec2(0, 0);
const float degrees_to_radians = PI/180.0;

void fragment() { 
    vec2 upos = UV; 
	vec2 texture_ratio = TEXTURE_PIXEL_SIZE * texture_size;
	float angle_rot = degrees_to_radians * rotation;
	mat2 rotation_matrix = mat2(vec2(cos(angle_rot), sin(angle_rot)), vec2(-sin(angle_rot), cos(angle_rot)));
	vec2 scroll = (scroll_speed*texture_ratio) * TIME;
	vec2 pos = vec2((upos.x+scroll.x)/texture_ratio.x, (upos.y+scroll.y)/texture_ratio.y) * rotation_matrix;
	float offset = floor(pos.x);
	pos.y += offset * offset_amount * texture_ratio.y;
	vec4 color = texture(TEXTURE, pos ); 
	color *= color_tint;
    COLOR = color;
}