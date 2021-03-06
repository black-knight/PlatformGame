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

#import "Physics.h"
#import "ScreenInfo.h"

@implementation Physics

+ (GLKVector2) addForceToPosition:(GLKVector2)position force:(GLKVector2)force {
    return GLKVector2Add(position, force);
}

+ (GLKVector2) addForceToVelocity:(GLKVector2)velocity force:(GLKVector2)force {
    return GLKVector2Add(velocity, force);
}

+ (GLKVector2) addForceToVelocity:(GLKVector2)velocity force:(GLKVector2)force max:(float)max {
    GLKVector2 newVelocity = GLKVector2Add(velocity, force);
    if (GLKVector2Length(newVelocity) > max) {
        return GLKVector2MultiplyScalar(GLKVector2Normalize(newVelocity), max);
    } else {
        return newVelocity;
    }
}

+ (GLKVector2) dampenVelocity:(GLKVector2)velocity factor:(float)factor {
    return GLKVector2MultiplyScalar(velocity, 1.0f - factor);
}

+ (GLKVector2) restrictVelocityToMax:(GLKVector2)velocity max:(float)max {
    if (GLKVector2Length(velocity) > max) {
        return GLKVector2MultiplyScalar(GLKVector2Normalize(velocity), max);
    } else {
        return velocity;
    }
}

+ (GLKVector2) restrictVelocityToMax:(GLKVector2)velocity maxX:(float)maxX maxY:(float)maxY {
    velocity.x = MAX(MIN(velocity.x, maxX), -maxX);
    velocity.y = MAX(MIN(velocity.y, maxY), -maxY);
    return velocity;
}

+ (GLKVector2) rotationVector {
    return GLKVector2Make(cos(screenInfo.rotation), sin(screenInfo.rotation));
}

+ (GLKVector2) gravityInRotation {
    return GLKVector2Make(cos(screenInfo.rotation) * GRAVITY, sin(screenInfo.rotation) * GRAVITY);
}

+ (GLKVector2) projectVector:(GLKVector2)v1 onto:(GLKVector2)v2 {
    return GLKVector2Project(v1, v2);
}

+ (float) angleDistanceFrom:(float)a1 to:(float)a2 {
    if (ABS(a1 - a2) > M_PI) {
        a1 += (a1 < a2 ? M_PI : -M_PI) * 2.0f;
    }
    return ABS(a2 - a1);
}

+ (float) angleDifferenceFrom:(float)a1 to:(float)a2 {
    if (ABS(a1 - a2) > M_PI) {
        a1 += (a1 < a2 ? M_PI : -M_PI) * 2.0f;
    }
    return a2 - a1;
}

@end
