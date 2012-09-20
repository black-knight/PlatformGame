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

#import "Texture.h"

typedef struct {
    float x1, y1, z1;
    float x2, y2, z2;
    float x3, y3, z3;
    float x4, y4, z4;
    float texCoordX1, texCoordY1;
    float texCoordX2, texCoordY2;
    bool texCoordDefined;
} QUAD;

@interface Quads : NSObject {

@private
    
    QUAD *quads;
    int quadCount;
    int quadArraySize;

    Texture *texture;
    bool textureToggled;

    GLKVector4 color;
    GLKVector4 backgroundColor;
    
    GLfloat *vertices;
    
    GLuint vertexArray;
    GLuint vertexBuffer;

    GLKVector3 translation;
    GLKVector3 rotation;
}

- (id) initWithColor:(GLKVector4)col;
- (id) initWithTexture:(Texture*)texture;
- (id) initWithTexture:(Texture*)texture color:(GLKVector4)col;

- (void) end;

- (void) addQuadX:(float)x y:(float)y width:(float)width height:(float)height;
- (void) addQuadX:(float)x y:(float)y width:(float)width height:(float)height texCoordX1:(float)texCoordX1 texCoordY1:(float)texCoordY1 texCoordX2:(float)texCoordX2 texCoordY2:(float)texCoordY2;
- (void) addQuadX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 x4:(float)x4 y4:(float)y4;
- (void) addQuadX1:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 x3:(float)x3 y3:(float)y3 z3:(float)z3 x4:(float)x4 y4:(float)y4 z4:(float)z4;

- (void) render;
- (void) renderSingleQuad:(int)index;
- (void) renderRangeFrom:(int)index count:(int)count;

@property (readwrite) GLKVector4 color;
@property (readwrite) GLKVector4 backgroundColor;

@property (readwrite) Texture *texture;

@property (readwrite) GLKVector3 translation;
@property (readwrite) GLKVector3 rotation;

@end
