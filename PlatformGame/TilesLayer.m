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

#import "TilesLayer.h"
#import "Globals.h"

@implementation TilesLayer

bool firstTimeRender = true;

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) dealloc {
    NSLog(@"Releasing layer");
    glDeleteFramebuffers(1, &offscreenFramebuffer);
    glDeleteRenderbuffers(1, &offscreenDepthBuffer);
    [offscreenTexture releaseTexture];
}

- (void) initialize {
    NSLog(@"Initializing tiles layer");
    [self createFramebuffer];
    [self createOffscreenQuad];
    [self createTiles];
    for (int i = 0; i < MAP_HEIGHT; i++) {
        for (int j = 0; j < MAP_WIDTH; j++) {
            bricks[i][j].type = 0;//(i+j)%40;
        }
    }
    bricks[0][0].type = 1;
    bricks[0][1].type = 2;
    bricks[0][2].type = 3;
    bricks[1][0].type = 5;
    bricks[1][1].type = 6;
    bricks[1][2].type = 7;
}

- (void) createFramebuffer {
    offscreenTexture = [[Texture alloc] init];

    offscreenTexture.width = textureAtLeastSize(screenWidthNoScale);
    offscreenTexture.height = textureAtLeastSize(screenHeightNoScale);
    
    [offscreenTexture setBlendSrc:GL_SRC_ALPHA blendDst:GL_ONE_MINUS_SRC_ALPHA];
    
    GLint oldFramebuffer;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFramebuffer);
    
    GLuint textureId;
    glGenFramebuffers(1, &offscreenFramebuffer);
    glGenTextures(1, &textureId); offscreenTexture.texId = textureId;
    glGenRenderbuffers(1, &offscreenDepthBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, offscreenFramebuffer);
    
    glBindTexture(GL_TEXTURE_2D, offscreenTexture.texId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, offscreenTexture.width, offscreenTexture.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, offscreenTexture.texId, 0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, offscreenDepthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, offscreenTexture.width, offscreenTexture.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, offscreenDepthBuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to create framebuffer object: %x", status);
        exit(-1);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);

    offscreenTexture.initialized = true;
}

- (void) createOffscreenQuad {
    offscreenQuad = [[Quads alloc] initWithTexture:offscreenTexture];
	[offscreenQuad addQuadX:0.0f y:0.0f width:aspectRatioX height:aspectRatioY];
    [offscreenQuad end];
}

- (void) createTiles {
    Texture *tilesTexture = [textureLoader loadSynchroniously:TEXTURE_TILES_PLATFORM];

    int tilesPerRow = 4;
    for (int i = 0; i < TILE_COUNT; i++) {
        float x = ((i % tilesPerRow) * TILE_WIDTH) / tilesTexture.width;
        float y = ((i / tilesPerRow) * TILE_HEIGHT) / tilesTexture.height;

        tileTexture[i] = [[Texture alloc] init];
        [tileTexture[i] setBlendSrc:GL_SRC_ALPHA blendDst:GL_ONE_MINUS_SRC_ALPHA];
        tileTexture[i].texId = tilesTexture.texId;
        tileTexture[i].texCoordX1 = x;
        tileTexture[i].texCoordY1 = y;
        tileTexture[i].texCoordX2 = x + (TILE_WIDTH / tilesTexture.width);
        tileTexture[i].texCoordY2 = y + (TILE_HEIGHT / tilesTexture.height);
        tileTexture[i].initialized = false; // No releasing of the texture

        tileQuad[i] = [[Quads alloc] initWithTexture:tileTexture[i]];
        [tileQuad[i] addQuadX:0.0f y:0.0f width:MAP_SCALE height:MAP_SCALE];
        [tileQuad[i] end];
    }
}

- (void) renderTilesOffscreen {
    //NSLog(@"Rendering offscreen!");
    
    GLint oldFramebuffer;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFramebuffer);
    
    GLint oldViewport[4];
    glGetIntegerv(GL_VIEWPORT, oldViewport);
    
    glBindFramebuffer(GL_FRAMEBUFFER, offscreenFramebuffer);
    
    glViewport(0, 0, offscreenTexture.width, offscreenTexture.height);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    for (int i = 0; i < MAP_HEIGHT; i++) {
        for (int j = 0; j < MAP_WIDTH; j++) {
            char brickType = bricks[i][j].type;
            if (brickType == 0) {
                continue;
            }
            [tileQuad[brickType - 1] setTranslation:GLKVector3Make(j * MAP_SCALE, i * MAP_SCALE, 0.0f)];
            [tileQuad[brickType - 1] render];
        }
    }

    glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);
    glViewport(oldViewport[0], oldViewport[1], oldViewport[2], oldViewport[3]);
}

- (void) update {
    [super update];
}

- (void) render {
    [super render];
    //if (firstTimeRender) {
        [self renderTilesOffscreen];
        firstTimeRender = false;
    //}
    [offscreenQuad render];
}

@end
