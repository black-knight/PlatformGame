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

#import "Game.h"
#import "Globals.h"

#define FRAME_RATE ((1000.0f / 60.0f) / 1000.0f)

@implementation Game

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    frameSeconds = FRAME_RATE;
    textureLoader = [[TextureLoader alloc] init];
    stage = [[Stage alloc] init];
    [stage prepareStage:0];
}

- (void) reactivate {
    frameSeconds = FRAME_RATE;
}

- (void) deactivate {
    
}

- (void) updateWithTimeInterval:(double)timeSinceLastUpdate {
    frameSeconds = MIN(frameSeconds + timeSinceLastUpdate, FRAME_RATE * 2.0f);
    while (frameSeconds >= FRAME_RATE) {
        [self update];
        frameSeconds -= FRAME_RATE;
    }
}

- (void) update {
    [self setupView];
    [stage update];
}

- (void) setupView {
    sceneProjectionMatrix = GLKMatrix4MakeOrtho(0.0f, aspectRatioX, 0.0f, aspectRatioY, -1.0f, 1.0f);
    sceneModelViewMatrix = GLKMatrix4Identity;
}

- (void) render {
    glClearColor(0.2f, 0.4f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [stage render];
}


@end
