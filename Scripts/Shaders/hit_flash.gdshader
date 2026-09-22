shader_type canvas_item;

uniform bool active = false;
uniform vec4 flash_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    if (active) {
        // Keeps original alpha (transparency) while replacing color with solid white
        COLOR = vec4(flash_color.rgb, texture_color.a);
    } else {
        COLOR = texture_color;
    }
}