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

#import "TextureLoader.h"
#import "Globals.h"

@implementation TextureLoader

- (id) init {
    if (self = [super init]) {
        NSLog(@"Initializing texture loader");
        textureLoader = [[GLKTextureLoader alloc] initWithSharegroup:openglContext.sharegroup];
    }
    return self;
}

- (Texture*) loadSynchroniously:(NSString*)filename repeat:(bool)repeat {
    NSError *error;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filename options:nil error:&error];
    if (error) {
        NSLog(@"Error loading texture synchronously: %@", filename);
        return NULL;
    }
    return [self textureFromTextureInfo:textureInfo repeat:repeat];
}

- (void) loadAsynchroniously:(NSString*)filename repeat:(bool)repeat callback:(void(^)(Texture*))callback {
    [textureLoader textureWithContentsOfFile:filename options:nil queue:NULL completionHandler:^(GLKTextureInfo *textureInfo, NSError *error) {
        if (error) {
            NSLog(@"Error loading texture asynchronously: %@", error);
        }
        callback([self textureFromTextureInfo:textureInfo repeat:repeat]);
    }];
}

- (Texture*) textureFromTextureInfo:(GLKTextureInfo*)textureInfo repeat:(bool)repeat {
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if (repeat) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    return [[Texture alloc] initWithId:textureInfo.name width:textureInfo.width height:textureInfo.height];
}

@end
