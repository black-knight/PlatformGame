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

#import "HeroCharacter.h"
#import "Globals.h"
#import "TextureLoader.h"
#import "ScreenInfo.h"

@implementation HeroCharacter

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    playerTexture = [textureLoader loadSynchroniously:TEXTURE_TILES_PLAYER];
    [playerTexture setBlendSrc:GL_SRC_ALPHA blendDst:GL_ONE_MINUS_SRC_ALPHA];
    [self createQuads];
}

- (void) createQuads {
    playerQuads = [[Quads alloc] initWithTexture:playerTexture];

    float width = [screenInfo objectWidth:1.0f scale:PLAYER_SCALE];
    float height = [screenInfo objectHeight:1.0f scale:PLAYER_SCALE];

    int numPerRow = 2;
    
    for (int i = 0; i < PLAYER_QUADS_COUNT; i++) {
        int x = i % numPerRow;
        int y = i / numPerRow;
        
        float texCoordX1 = x * PLAYER_PIXEL_WIDTH / playerTexture.width;
        float texCoordY1 = y * PLAYER_PIXEL_HEIGHT / playerTexture.height;
        float texCoordX2 = texCoordX1 + PLAYER_PIXEL_WIDTH / playerTexture.width;
        float texCoordY2 = texCoordY1 + PLAYER_PIXEL_HEIGHT / playerTexture.height;

	    [playerQuads addQuadX:0.0f y:0.0f width:width height:height texCoordX1:texCoordX1 texCoordY1:texCoordY1 texCoordX2:texCoordX2 texCoordY2:texCoordY2];
    }
    [playerQuads end];
}

- (void) updateWithStageInfo:(StageInfo*)stageInfo {
    [super updateWithStageInfo:stageInfo];
}

- (void) render {
    [super render];
    float x = [screenInfo coordX:position.x] - ([screenInfo objectWidth:1.0f scale:PLAYER_SCALE] / 2.0f);
    float y = [screenInfo coordY:position.y] - [screenInfo objectHeight:1.0f scale:PLAYER_SCALE];
    playerQuads.translation = GLKVector3Make(x, y, 0.0f);
    [playerQuads renderSingleQuad:0];
}

@end
