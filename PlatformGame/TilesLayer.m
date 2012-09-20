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
#import "TextureLoader.h"
#import "ScreenInfo.h"

@implementation TilesLayer

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) dealloc {
    NSLog(@"Releasing layer");
}

- (void) initialize {
    NSLog(@"Initializing tiles layer");
    position = GLKVector2Make(0.0f, 0.0f);
    for (int i = 0; i < MAP_HEIGHT; i++) {
        for (int j = 0; j < MAP_WIDTH; j++) {
            tiles[i][j].type = 31;
        }
    }
    tiles[5][4].type = 0;
    tiles[5][5].type = 1;
    tiles[5][6].type = 2;
    tiles[5][7].type = 1;
    tiles[5][8].type = 3;
    tiles[6][4].type = 12;
    tiles[6][5].type = 13;
    tiles[6][6].type = 14;
    tiles[6][7].type = 13;
    tiles[6][8].type = 15;
    [self createTileMap];
}

- (void) createTileMap {
    tilesTexture = [textureLoader loadSynchroniously:TEXTURE_TILES_PLATFORM];
	[tilesTexture setBlendSrc:GL_SRC_ALPHA blendDst:GL_ONE_MINUS_SRC_ALPHA];
    
    tileQuads = [[Quads alloc] initWithTexture:tilesTexture];
    for (int i = 0; i < MAP_HEIGHT / TILE_MAP_BLOCK_SIZE; i++) {
        for (int j = 0; j < MAP_WIDTH / TILE_MAP_BLOCK_SIZE; j++) {
            [self createTileBlockX:j y:i];
        }
    }
    [tileQuads end];
}

- (void) createTileBlockX:(int)blockX y:(int)blockY {
    int tilesPerRow = 4;
    for (int i = 0; i < TILE_MAP_BLOCK_SIZE; i++) {
        for (int j = 0; j < TILE_MAP_BLOCK_SIZE; j++) {
            char tile = tiles[blockY * TILE_MAP_BLOCK_SIZE + i][blockX * TILE_MAP_BLOCK_SIZE + j].type;

            float texCoordX1 = ((tile % tilesPerRow) * TILE_WIDTH) / tilesTexture.width;
            float texCoordY1 = ((tile / tilesPerRow) * TILE_HEIGHT) / tilesTexture.height;
            float texCoordX2 = texCoordX1 + (TILE_WIDTH / tilesTexture.width);
            float texCoordY2 = texCoordY1 + (TILE_HEIGHT / tilesTexture.height);
            
            float x = [screenInfo coordX:j + (blockX * TILE_MAP_BLOCK_SIZE)];
            float y = [screenInfo coordY:i + (blockY * TILE_MAP_BLOCK_SIZE)];
            float width = [screenInfo objectWidth:1.0f];
            float height = [screenInfo objectHeight:1.0f];
            
            [tileQuads addQuadX:x y:y width:width height:height texCoordX1:texCoordX1 texCoordY1:texCoordY1 texCoordX2:texCoordX2 texCoordY2:texCoordY2];
        }
    }
}

- (void) update {
    [super update];
}

- (void) render {
    [super render];
    [self renderTileMap];
}

- (void) renderTileMap {
    int countX = 4;
    int countY = 4;

    for (int i = 0; i < countY; i++) {
        for (int j = 0; j < countX; j++) {
            int start = ((i * (MAP_WIDTH / TILE_MAP_BLOCK_SIZE)) + j) * TILE_MAP_BLOCK_SIZE * TILE_MAP_BLOCK_SIZE;
            int count = TILE_MAP_BLOCK_SIZE * TILE_MAP_BLOCK_SIZE;
            [tileQuads renderRangeFrom:start count:count];
        }
    }
}

@end
