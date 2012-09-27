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
#import "StageInfo.h"
#import "Physics.h"

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

    onGround = false;
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

	    [playerQuads addQuadX:-[screenInfo objectWidth:PLAYER_SCALE] / 2.0f y:-[screenInfo objectHeight:PLAYER_SCALE] width:width height:height texCoordX1:texCoordX1 texCoordY1:texCoordY1 texCoordX2:texCoordX2 texCoordY2:texCoordY2];
    }
    [playerQuads end];
}

- (void) update {
    [super update];
    [self updateGroundInfo];
    [self calculateVelocity];
    //NSLog(@"%f, %f vs %f, %f", position.x, position.y, velocity.x, velocity.y);
    [self applyVelocity];
    [self calculatePlayerRotation];
}

- (void) updateGroundInfo {
    onGroundInPreviousFrame = onGround;
    groundPosition = GLKVector2Add(position, GLKVector2MultiplyScalar([Physics rotationVector], PLAYER_COLLISION_CHECK_DISTANCE));
    onGround = [self solidBetweenP1:position p2:groundPosition];
}

- (void) applyVelocity {
    position = [Physics addForceToPosition:position force:velocity];
    if (position.y > 20.0f) {
        position.y = 0.0f;
    }
}

- (void) calculateVelocity {
    [self addGravity];
    [self adjustVelocityWhenOnGround];
    velocity = [Physics dampenVelocity:velocity factor:PLAYER_VELOCITY_DAMPEN];
    velocity = [Physics restrictVelocityToMax:velocity maxX:PLAYER_MAX_SPEED_X maxY:PLAYER_MAX_SPEED_Y];
}

- (void) addGravity {
    velocity = [Physics addForceToVelocity:velocity force:[Physics gravityInRotation]];
}

- (void) adjustVelocityWhenOnGround {
    if (!onGround) {
        return;
    }
    float groundAngle = [stageInfo.tilesLayer angleAt:groundPosition];
    velocity = [Physics projectVector:[Physics dampenVelocity:velocity factor:PLAYER_GROUND_SLIP_RESISTANCE]
                                 onto:GLKVector2Make(cos(groundAngle), sin(groundAngle))];
}

- (void) calculatePlayerRotation {
    rotation = screenInfo.rotation - M_PI_2;
}

- (bool) solidBetweenP1:(GLKVector2)p1 p2:(GLKVector2)p2 {
    float length = GLKVector2Distance(p1, p2);
    for (float l = 0; l <= length; l += PLAYER_COLLISION_CHECK_LEAP) {
        GLKVector2 p = GLKVector2Add(p1, GLKVector2MultiplyScalar(GLKVector2Subtract(p2, p1), l));
        if ([stageInfo.tilesLayer collisionAt:p]) {
            return true;
        }
    }
    return [stageInfo.tilesLayer collisionAt:p2];
}

- (GLKVector2) lastPositionBeforeFirstSolidBetweenP1:(GLKVector2)p1 p2:(GLKVector2)p2 {
    GLKVector2 oldP = p1;
    float length = GLKVector2Distance(p1, p2);
    for (float l = 0; l <= length; l += PLAYER_COLLISION_CHECK_LEAP) {
        GLKVector2 p = GLKVector2Add(p1, GLKVector2MultiplyScalar(GLKVector2Subtract(p2, p1), l));
        if ([stageInfo.tilesLayer collisionAt:p]) {
            return oldP;
        }
        oldP = p;
    }
    if ([stageInfo.tilesLayer collisionAt:p2]) {
        return oldP;
    }
    return p1;
}

- (void) render {
    [super render];
    playerQuads.translation = GLKVector3Make([screenInfo coordX:position.x], [screenInfo coordY:position.y], 0.0f);
    playerQuads.rotation = GLKVector3Make(0.0f, 0.0f, rotation);
    [playerQuads renderSingleQuad:0];
}

@end
