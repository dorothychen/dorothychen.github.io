// first three are bottom anchors; don't fuck with them!
float[][] vertices = [];
float yw;

void initWater() {
    yw = height * 0.3;

    // bottom right
    vertices.push([width+100, height+100]);

    // bottom right
    vertices.push([width+100, height+100]);

    // bottom left
    vertices.push([-100, height+100]);

    // top left
    vertices.push([-100,  yw]);
    vertices.push([0,  1.1*yw]);
    vertices.push([0.3*width, 1.2*yw]);
    vertices.push([0.5*width, 1*yw]);
    vertices.push([0.7*width,  0.9*yw]);
    vertices.push([0.9*width, 1.1*yw]);
    vertices.push([width, yw]);

    // top right
    vertices.push([width+100, yw]);
}

float yoff = 0.0;
void drawCurve() {
    noStroke();
    fill(46, 151, 169);

    // for perlin noise
    float dx = 0.05f;
    float dy = 0.01f;
    float xoff = 0.0; 
    
    beginShape();
    for (int i = 0; i < vertices.length; i++) {
        float[] v = vertices[i];
        if (i >= 3) { 
            v[1] = map(noise(xoff, yoff), 0, 1, 0.5 * yw, 1.7 * yw); 
        }
        curveVertex(v[0], v[1]);
        xoff += dx;
    }
    yoff += dy;
    endShape(CLOSE);
}


void setup() {
    // set up window
    size(window.innerWidth, window.innerHeight); 
    smooth();
    frameRate(30);

    // load initial vertices for water
    initWater();

}

void draw() {
    background(187,222,251);
    drawCurve();
}




