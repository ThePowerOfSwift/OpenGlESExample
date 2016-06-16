attribute vec4 position;
attribute vec2 texCoordIn;

varying vec2 textureOut;

void main() {
    textureOut = vec2(texCoordIn.x, 1.0 - texCoordIn.y);
    gl_Position = position;
}