// Copyright (c) 2012, Daniel Andersen (dani_ande@yahoo.dk)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "Quads.h"
#import "Globals.h"

@implementation Quads

@synthesize color;
@synthesize backgroundColor;

@synthesize texture;

@synthesize translation;
@synthesize rotation;

- (id) initWithColor:(GLKVector4)col {
    if (self = [super init]) {
        [self initialize];
	    textureToggled = false;
	    color = col;
    }
    return self;
}

- (id) initWithTexture:(Texture*)tex {
    if (self = [super init]) {
        [self initialize];
	    texture = tex;
	    textureToggled = true;
    }
    return self;
}

- (id) initWithTexture:(Texture*)tex color:(GLKVector4)col {
    if (self = [super init]) {
        [self initialize];
	    texture = tex;
	    textureToggled = true;
	    color = col;
    }
    return self;
}

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) dealloc {
    if (quadCount != 0) {
        glDeleteBuffers(1, &vertexBuffer);
        glDeleteVertexArraysOES(1, &vertexArray);
    }
    if (quads != NULL) {
        free(quads);
        quads = NULL;
    }
    if (vertices != NULL) {
        free(vertices);
        vertices = NULL;
    }
}

- (void) initialize {
    quadCount = 0;
    quadArraySize = 0;
    quads = NULL;
    vertices = NULL;
    translation = GLKVector3Make(0.0f, 0.0f, 0.0f);
    rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
    backgroundColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
    color = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
}

- (void) end {
    if (quadCount == 0) {
        return;
    }
    [self generateCoordinates];
    [self generateVertexArrays];
}

- (void) generateCoordinates {
    if (vertices != NULL) {
        free(vertices);
    }
    vertices = (GLfloat*) malloc(quadCount * 6 * 5 * sizeof(GLfloat));
    int v = 0;
    for (int i = 0; i < quadCount; i++) {
        
        // Triangle 1
        vertices[v + 0] = quads[i].x1;
        vertices[v + 1] = quads[i].y1;
        vertices[v + 2] = quads[i].z1;
        vertices[v + 3] = quads[i].texCoordDefined ? quads[i].texCoordX2 : texture.texCoordX2;
        vertices[v + 4] = quads[i].texCoordDefined ? quads[i].texCoordY2 : texture.texCoordY2;
        v += 5;
        
        vertices[v + 0] = quads[i].x2;
        vertices[v + 1] = quads[i].y2;
        vertices[v + 2] = quads[i].z2;
        vertices[v + 3] = quads[i].texCoordDefined ? quads[i].texCoordX2 : texture.texCoordX2;
        vertices[v + 4] = quads[i].texCoordDefined ? quads[i].texCoordY1 : texture.texCoordY1;
        v += 5;
        
        vertices[v + 0] = quads[i].x3;
        vertices[v + 1] = quads[i].y3;
        vertices[v + 2] = quads[i].z3;
        vertices[v + 3] = quads[i].texCoordDefined ? quads[i].texCoordX1 : texture.texCoordX1;
        vertices[v + 4] = quads[i].texCoordDefined ? quads[i].texCoordY1 : texture.texCoordY1;
        v += 5;
        
        // Triangle 2
        vertices[v + 0] = quads[i].x3;
        vertices[v + 1] = quads[i].y3;
        vertices[v + 2] = quads[i].z3;
        vertices[v + 3] = quads[i].texCoordDefined ? quads[i].texCoordX1 : texture.texCoordX1;
        vertices[v + 4] = quads[i].texCoordDefined ? quads[i].texCoordY1 : texture.texCoordY1;
        v += 5;
        
        vertices[v + 0] = quads[i].x4;
        vertices[v + 1] = quads[i].y4;
        vertices[v + 2] = quads[i].z4;
        vertices[v + 3] = quads[i].texCoordDefined ? quads[i].texCoordX1 : texture.texCoordX1;
        vertices[v + 4] = quads[i].texCoordDefined ? quads[i].texCoordY2 : texture.texCoordY2;
        v += 5;
        
        vertices[v + 0] = quads[i].x1;
        vertices[v + 1] = quads[i].y1;
        vertices[v + 2] = quads[i].z1;
        vertices[v + 3] = quads[i].texCoordDefined ? quads[i].texCoordX2 : texture.texCoordX2;
        vertices[v + 4] = quads[i].texCoordDefined ? quads[i].texCoordY2 : texture.texCoordY2;
        v += 5;
    }
    free(quads);
    quads = NULL;
    quadArraySize = 0;
}

- (void) generateVertexArrays {
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, quadCount * 6 * 5 * sizeof(GLfloat), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), BUFFER_OFFSET(0));
    
    if (textureToggled) {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), BUFFER_OFFSET(3));
    } else {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }

    glBindVertexArrayOES(0);
    
    free(vertices);
    vertices = NULL;
}

- (void) addQuadX:(float)x y:(float)y width:(float)width height:(float)height {
    [self addQuadX1:x + width y1:y x2:x + width y2:y + height x3:x y3:y + height x4:x y4:y];
}

- (void) addQuadX:(float)x y:(float)y width:(float)width height:(float)height texCoordX1:(float)texCoordX1 texCoordY1:(float)texCoordY1 texCoordX2:(float)texCoordX2 texCoordY2:(float)texCoordY2 {
    [self addQuadX:x y:y width:width height:height];
    quads[quadCount - 1].texCoordX1 = texCoordX1;
    quads[quadCount - 1].texCoordY1 = texCoordY1;
    quads[quadCount - 1].texCoordX2 = texCoordX2;
    quads[quadCount - 1].texCoordY2 = texCoordY2;
    quads[quadCount - 1].texCoordDefined = true;
}

- (void) addQuadX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 x4:(float)x4 y4:(float)y4 {
    [self addQuadX1:x1 y1:y1 z1:0.0f x2:x2 y2:y2 z2:0.0f x3:x3 y3:y3 z3:0.0f x4:x4 y4:y4 z4:0.0f];
}

- (void) addQuadX1:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 x3:(float)x3 y3:(float)y3 z3:(float)z3 x4:(float)x4 y4:(float)y4 z4:(float)z4 {
    [self ensureQuadArraySize];
    quads[quadCount].x1 = x1;
    quads[quadCount].y1 = y1;
    quads[quadCount].z1 = z1;
    quads[quadCount].x2 = x2;
    quads[quadCount].y2 = y2;
    quads[quadCount].z2 = z2;
    quads[quadCount].x3 = x3;
    quads[quadCount].y3 = y3;
    quads[quadCount].z3 = z3;
    quads[quadCount].x4 = x4;
    quads[quadCount].y4 = y4;
    quads[quadCount].z4 = z4;
    quads[quadCount].texCoordDefined = false;
    quadCount++;
}

- (void) ensureQuadArraySize {
    if (quads != NULL && quadCount < quadArraySize) {
        return;
    }
    quadArraySize += 64;
    QUAD *oldQuads = quads;
    quads = (QUAD *)malloc(quadArraySize * sizeof(QUAD));
    for (int i = 0; i < quadCount; i++) {
        quads[i] = oldQuads[i];
    }
    free(oldQuads);
}

- (void) render {
    if (quadCount == 0) {
        return;
    }
    [self prepareRender];
    glBindVertexArrayOES(vertexArray);
    glDrawArrays(GL_TRIANGLES, 0, quadCount * 6);
}

- (void) renderSingleQuad:(int)index {
    if (quadCount == 0) {
        return;
    }
    [self prepareRender];
    glBindVertexArrayOES(vertexArray);
    glDrawArrays(GL_TRIANGLES, index * 6, 6);
}

- (void) renderRangeFrom:(int)index count:(int)count {
    if (quadCount == 0) {
        return;
    }
    [self prepareRender];
    glBindVertexArrayOES(vertexArray);
    glDrawArrays(GL_TRIANGLES, index * 6, count * 6);
}

- (void) prepareRender {
	if (!textureToggled) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    } else if (texture.blend.enabled) {
        glEnable(GL_BLEND);
        glBlendFunc(texture.blend.blendSrc, texture.blend.blendDst);
    } else {
        glDisable(GL_BLEND);
    }
    
    glkEffect.texture2d0.name = texture.texId;
    glkEffect.texture2d0.enabled = textureToggled ? GL_TRUE : GL_FALSE;

    glkEffect.useConstantColor = YES;
    glkEffect.constantColor = color;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(sceneModelViewMatrix, translation.x, translation.y, translation.z);
    if (rotation.x != 0.0f) {
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation.x, 1.0f, 0.0f, 0.0f);
    }
    if (rotation.y != 0.0f) {
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation.y, 0.0f, 1.0f, 0.0f);
    }
    if (rotation.z != 0.0f) {
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation.z, 0.0f, 0.0f, 1.0f);
    }
    
    glkEffect.transform.modelviewMatrix = modelViewMatrix;
    glkEffect.transform.projectionMatrix = sceneProjectionMatrix;
    
    [glkEffect prepareToDraw];
}

@end
