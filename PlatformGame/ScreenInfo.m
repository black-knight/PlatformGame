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

#import "ScreenInfo.h"
#import "Globals.h"

ScreenInfo *screenInfo;

@implementation ScreenInfo

@synthesize width;
@synthesize height;

@synthesize widthNoScale;
@synthesize heightNoScale;

@synthesize aspectRatio;
@synthesize aspectRatioX;
@synthesize aspectRatioY;

@synthesize rotation;

- (id) init {
    if (self = [super init]) {
        rotation = M_PI_2;
    }
    return self;
}

- (float) coordX:(float)x {
    return x * WORLD_SCALE * aspectRatioY;
}

- (float) coordY:(float)y {
    return y * WORLD_SCALE * aspectRatioX;
}

- (float) objectWidth:(float)w {
    return [self objectWidth:w scale:1.0f];
}

- (float) objectHeight:(float)h {
    return [self objectHeight:h scale:1.0f];
}

- (float) objectWidth:(float)w scale:(float)scale {
    return w * WORLD_SCALE * aspectRatioY * scale;
}

- (float) objectHeight:(float)h scale:(float)scale {
    return h * WORLD_SCALE * aspectRatioX * scale;
}

@end
