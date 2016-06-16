precision mediump float;
uniform sampler2D textureImage;
varying mediump vec2 textureOut;

void main() {
    mediump vec4 RGBA;
    RGBA = texture2D(textureImage, textureOut);
    gl_FragColor = RGBA ;
}