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

#import "Globals.h"
#import "MoveableCharacter.h"
#import "Texture.h"
#import "Quads.h"

#define PLAYER_QUADS_COUNT 2

#define PLAYER_SCALE 1.0f
#define PLAYER_PIXEL_WIDTH 64
#define PLAYER_PIXEL_HEIGHT 64

#define PLAYER_MAX_SPEED_X 0.025f
#define PLAYER_MAX_SPEED_Y 0.5f
#define PLAYER_VELOCITY_DAMPEN 0.05f

#define PLAYER_GROUND_SLIP_ANGLE 0.3f
#define PLAYER_GROUND_SLIP_SPEED 0.001f

#define PLAYER_COLLISION_CHECK_COUNT 10
#define PLAYER_COLLISION_CHECK_DISTANCE (WORLD_SCALE * 0.1f)

@interface HeroCharacter : MoveableCharacter {

@private
    
    Texture *playerTexture;
    Quads *playerQuads;
    
    GLKVector2 groundPosition;
}

- (void) update;
- (void) render;

@end
