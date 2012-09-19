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
            tiles[i][j].type = 0;
        }
    }
    tiles[1][0].type = 0;
    tiles[1][1].type = 1;
    tiles[1][2].type = 3;
    tiles[2][0].type = 4;
    tiles[2][1].type = 5;
    tiles[2][2].type = 7;
    tiles[3][0].type = 4;
    tiles[3][1].type = 5;
    tiles[3][2].type = 7;
    [self createTileMap];
}

- (void) createTileMap {
    tilesTexture = [textureLoader loadSynchroniously:TEXTURE_TILES_PLATFORM];

    for (int i = 0; i < MAP_HEIGHT / TILE_MAP_BLOCK_SIZE; i++) {
        for (int j = 0; j < MAP_WIDTH / TILE_MAP_BLOCK_SIZE; j++) {
            [self createTileBlockX:j y:i];
        }
    }
    [self generateTileBlockVertexArray];
}

- (void) createTileBlockX:(int)blockX y:(int)blockY {
    int tilesPerRow = 4;
    int v = 0;
    for (int i = 0; i < TILE_MAP_BLOCK_SIZE; i++) {
        for (int j = 0; j < TILE_MAP_BLOCK_SIZE; j++) {
            char tile = tiles[blockY * TILE_MAP_BLOCK_SIZE + i][blockX * TILE_MAP_BLOCK_SIZE + j].type;

            float texCoordX1 = ((tile % tilesPerRow) * TILE_WIDTH) / tilesTexture.width;
            float texCoordY1 = ((tile / tilesPerRow) * TILE_HEIGHT) / tilesTexture.height;
            float texCoordX2 = texCoordX1 + (TILE_WIDTH / tilesTexture.width);
            float texCoordY2 = texCoordY1 + (TILE_HEIGHT / tilesTexture.height);
            
            float x1 = (j + blockX * TILE_MAP_BLOCK_SIZE) * MAP_SCALE;
            float y1 = -(i + blockY * TILE_MAP_BLOCK_SIZE) * MAP_SCALE + aspectRatioX;
            float x2 = x1 + MAP_SCALE;
            float y2 = y1 + MAP_SCALE;
            
            // Triangle 1
            tileMapBlockVertices[blockY][blockX][v + 0] = x2;
            tileMapBlockVertices[blockY][blockX][v + 1] = y1;
            tileMapBlockVertices[blockY][blockX][v + 2] = 0.0f;
            tileMapBlockVertices[blockY][blockX][v + 3] = texCoordX2;
            tileMapBlockVertices[blockY][blockX][v + 4] = texCoordY2;
            v += 5;
            
            tileMapBlockVertices[blockY][blockX][v + 0] = x2;
            tileMapBlockVertices[blockY][blockX][v + 1] = y2;
            tileMapBlockVertices[blockY][blockX][v + 2] = 0.0f;
            tileMapBlockVertices[blockY][blockX][v + 3] = texCoordX2;
            tileMapBlockVertices[blockY][blockX][v + 4] = texCoordY1;
            v += 5;
            
            tileMapBlockVertices[blockY][blockX][v + 0] = x1;
            tileMapBlockVertices[blockY][blockX][v + 1] = y2;
            tileMapBlockVertices[blockY][blockX][v + 2] = 0.0f;
            tileMapBlockVertices[blockY][blockX][v + 3] = texCoordX1;
            tileMapBlockVertices[blockY][blockX][v + 4] = texCoordY1;
            v += 5;
            
            // Triangle 2
            tileMapBlockVertices[blockY][blockX][v + 0] = x1;
            tileMapBlockVertices[blockY][blockX][v + 1] = y2;
            tileMapBlockVertices[blockY][blockX][v + 2] = 0.0f;
            tileMapBlockVertices[blockY][blockX][v + 3] = texCoordX1;
            tileMapBlockVertices[blockY][blockX][v + 4] = texCoordY1;
            v += 5;
            
            tileMapBlockVertices[blockY][blockX][v + 0] = x1;
            tileMapBlockVertices[blockY][blockX][v + 1] = y1;
            tileMapBlockVertices[blockY][blockX][v + 2] = 0.0f;
            tileMapBlockVertices[blockY][blockX][v + 3] = texCoordX1;
            tileMapBlockVertices[blockY][blockX][v + 4] = texCoordY2;
            v += 5;
            
            tileMapBlockVertices[blockY][blockX][v + 0] = x2;
            tileMapBlockVertices[blockY][blockX][v + 1] = y1;
            tileMapBlockVertices[blockY][blockX][v + 2] = 0.0f;
            tileMapBlockVertices[blockY][blockX][v + 3] = texCoordX2;
            tileMapBlockVertices[blockY][blockX][v + 4] = texCoordY2;
            v += 5;
        }
    }
}

- (void) generateTileBlockVertexArray {
    glGenVertexArraysOES(1, &tileMapVertexArray);
    glBindVertexArrayOES(tileMapVertexArray);
    
    glGenBuffers(1, &tileMapVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, tileMapVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(tileMapBlockVertices), tileMapBlockVertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), BUFFER_OFFSET(3));
    
    glBindVertexArrayOES(0);
}

- (void) update {
    [super update];
}

- (void) render {
    [super render];
    [self renderTileMap];
}

- (void) renderTileMap {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glkEffect.texture2d0.name = tilesTexture.texId;
    glkEffect.texture2d0.enabled = GL_TRUE;
    
    glkEffect.useConstantColor = YES;
    glkEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    glkEffect.transform.modelviewMatrix = GLKMatrix4Translate(sceneModelViewMatrix, position.x, position.y, 0.0f);
    glkEffect.transform.projectionMatrix = sceneProjectionMatrix;
    
    [glkEffect prepareToDraw];

    int countX = 2;
    int countY = 2;

    for (int i = 0; i < countY; i++) {
        for (int j = 0; j < countX; j++) {
            int startOffset = ((i * (MAP_WIDTH / TILE_MAP_BLOCK_SIZE)) + j) * 6 * TILE_MAP_BLOCK_SIZE * TILE_MAP_BLOCK_SIZE;
            glBindVertexArrayOES(tileMapVertexArray);
            glDrawArrays(GL_TRIANGLES, startOffset, 6 * TILE_MAP_BLOCK_SIZE * TILE_MAP_BLOCK_SIZE);
        }
    }
}

- (void) renderTileBlockX:(int)x y:(int)y {
}

@end
