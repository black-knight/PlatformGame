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

TILE TILE_EMPTY = {.type = 31};

@implementation TilesLayer

@synthesize mapWidth;
@synthesize mapHeight;

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
    mapWidth = MAP_WIDTH;
    mapHeight = MAP_HEIGHT;
    for (int i = 0; i < MAP_HEIGHT; i++) {
        for (int j = 0; j < MAP_WIDTH; j++) {
            tiles[i][j] = TILE_EMPTY;
        }
    }
    tiles[4][3].type = 0;
    tiles[4][4].type = 1;
    tiles[4][5].type = 2;
    tiles[4][6].type = 3;
    tiles[5][3].type = 12;
    tiles[5][4].type = 13;
    tiles[5][5].type = 14;
    tiles[5][6].type = 15;

    tiles[10][1].type = 0;
    tiles[10][2].type = 1;
    tiles[10][3].type = 2;
    tiles[10][4].type = 1;
    tiles[10][5].type = 3;
    tiles[11][1].type = 12;
    tiles[11][2].type = 13;
    tiles[11][3].type = 14;
    tiles[11][4].type = 13;
    tiles[11][5].type = 15;

    tiles[13][ 4].type = 0;
    tiles[13][ 5].type = 1;
    tiles[13][ 6].type = 2;
    tiles[13][ 7].type = 1;
    tiles[13][ 8].type = 2;
    tiles[13][ 9].type = 1;
    tiles[13][10].type = 3;
    tiles[14][ 4].type = 12;
    tiles[14][ 5].type = 13;
    tiles[14][ 6].type = 14;
    tiles[14][ 7].type = 13;
    tiles[14][ 8].type = 14;
    tiles[14][ 9].type = 13;
    tiles[14][10].type = 15;

    tiles[2][0].type = 19;
    tiles[3][0].type = 23;
    tiles[4][0].type = 23;
    tiles[5][0].type = 23;
    tiles[6][0].type = 23;
    tiles[7][0].type = 23;
    tiles[8][0].type = 23;
    tiles[9][0].type = 27;

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

- (bool) collisionAt:(GLKVector2)p {
    int tileX = (int) p.x;
    int tileY = (int) p.y;
    float offsetX = p.x - tileX;
    float offsetY = p.y - tileY;
    TILE tile = [self tileAtX:tileX y:tileY];
    if (tile.type == 1 || tile.type == 2) {
        return offsetY >= 0.3f;
    }
    if (tile.type == 13 || tile.type == 14) {
        return offsetY <= 0.7f;
    }
    if (tile.type == 0) {
        return offsetX >= 0.3f && offsetY >= 0.3f;
    }
    if (tile.type == 3) {
        return offsetX <= 0.7f && offsetY >= 0.3f;
    }
    if (tile.type == 12) {
        return offsetX >= 0.3f && offsetY <= 0.7f;
    }
    if (tile.type == 15) {
        return offsetX <= 0.7f && offsetY <= 0.7f;
    }
    if (tile.type == 19 || tile.type == 23 || tile.type == 27) {
        return offsetX >= 0.2f && offsetX <= 0.8f;
    }
    return tile.type != TILE_EMPTY.type;
}

- (float) angleAt:(GLKVector2)p {
    if (![self collisionAt:p]) {
        return 0.0f;
    }
    int tileX = (int) p.x;
    int tileY = (int) p.y;
    //float offsetX = p.x - tileX;
    //float offsetY = p.y - tileY;
    TILE tile = [self tileAtX:tileX y:tileY];
    //NSLog(@"%i vs %f, %f vs %i, %i", tile.type, offsetX, offsetY, tileX, tileY);
    if (tile.type == 1 || tile.type == 2) {
        return 0.0f;
    }
    if (tile.type == 13 || tile.type == 14) {
        return 0.0f;
    }
    if (tile.type == 0) {
        return 0.0f;
    }
    if (tile.type == 3) {
        return 0.0f;
    }
    if (tile.type == 12) {
        return 0.0f;
    }
    if (tile.type == 15) {
        return 0.0f;
    }
    if (tile.type == 19 || tile.type == 23 || tile.type == 27) {
        return M_PI_2;
    }
    return 0.0f; // TODO!
}

- (TILE) tileAtX:(int)x y:(int)y {
    return x >= 0 && y >= 0 && x < MAP_WIDTH && y < MAP_HEIGHT ? tiles[y][x] : emptyTile;
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
