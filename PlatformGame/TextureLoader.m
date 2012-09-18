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
        [self initializeDictionary];
        
    }
    return self;
}

- (void) initializeDictionary {
    textures = [NSMutableDictionary dictionary];
    [textures setObject:[[Texture alloc] initWithFilename:[[NSBundle mainBundle] pathForResource:@"platforms" ofType:@"png"]] forKey:[NSNumber numberWithInt:TEXTURE_TILES_PLATFORM]];
}

- (Texture*) loadSynchroniously:(int)textureNumber {
    NSError *error;
    Texture *texture = [self load:textureNumber];
    if (texture.initialized) {
        return texture;
    }
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texture.filename options:nil error:&error];
    if (error) {
        NSLog(@"Error loading texture synchronously: %@ [%@]", texture.filename, error.description);
        exit(-1);
    }
    [self textureFromTextureInfo:textureInfo texture:texture];
    return texture;
}

- (void) loadAsynchroniously:(int)textureNumber callback:(void(^)(Texture*))callback {
    Texture *texture = [self load:textureNumber];
    if (texture.initialized) {
        callback(texture);
        return;
    }
    [textureLoader textureWithContentsOfFile:texture.filename options:nil queue:NULL completionHandler:^(GLKTextureInfo *textureInfo, NSError *error) {
        if (error) {
            NSLog(@"Error loading texture asynchronously: %@ [%@]", error, error.description);
            exit(-1);
        }
        [self textureFromTextureInfo:textureInfo texture:texture];
        callback(texture);
    }];
}

- (Texture*) load:(int)number {
    return [textures objectForKey:[NSNumber numberWithInt:number]];
}

- (void) textureFromTextureInfo:(GLKTextureInfo*)textureInfo texture:(Texture*)texture {
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if (texture.repeat) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    texture.texId = textureInfo.name;
	texture.width = textureInfo.width;
	texture.height = textureInfo.height;
    texture.initialized = true;
}

@end
