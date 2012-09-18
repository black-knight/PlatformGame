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

@implementation Texture

@synthesize texId;

@synthesize width;
@synthesize height;

@synthesize texCoordX1;
@synthesize texCoordY1;
@synthesize texCoordX2;
@synthesize texCoordY2;

@synthesize blend;

- (id) initWithId:(GLuint)textureId {
    if (self = [super init]) {
        [self resetToDefault];
        texId = textureId;
    }
    return self;
}

- (id) initWithId:(GLuint)textureId width:(float) texWidth height:(float)texHeight {
    if (self = [super init]) {
        [self resetToDefault];
        texId = textureId;
        width = texWidth;
        height = texHeight;
    }
    return self;
}

- (id) initWithId:(GLuint)textureId texCoordX1:(float)x1 texCoordY1:(float)y1 texCoordX2:(float)x2 texCoordY2:(float)y2 {
    if (self = [super init]) {
        [self resetToDefault];
        texId = textureId;
        texCoordX1 = x1;
        texCoordY1 = y1;
        texCoordX2 = x2;
        texCoordY2 = y2;
    }
    return self;
}

- (void) resetToDefault {
    width = 0.0f;
    height = 0.0f;
    texCoordX1 = 0.0f;
    texCoordY1 = 0.0f;
    texCoordX2 = 1.0f;
    texCoordY2 = 1.0f;
    blend.enabled = false;
}

@end
