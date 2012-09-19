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

#import "Layer.h"
#import "Texture.h"
#import "Quads.h"

#define TILE_WIDTH 128.0f
#define TILE_HEIGHT 128.0f
#define TILE_COUNT 64

#define MAP_WIDTH 32
#define MAP_HEIGHT 32
#define MAP_SCALE (1.0f / 4.0f)

#define TILE_MAP_BLOCK_SIZE 2
#define TILE_MAP_WIDTH (MAP_WIDTH / TILE_MAP_BLOCK_SIZE)
#define TILE_MAP_HEIGHT (MAP_HEIGHT / TILE_MAP_BLOCK_SIZE)
#define TILE_MAP_VERTICES_COUNT (TILE_MAP_BLOCK_SIZE * TILE_MAP_BLOCK_SIZE * 6 * 5)

typedef struct {
    char type;
} TILE;

@interface TilesLayer : Layer {

@private

	TILE tiles[MAP_HEIGHT][MAP_WIDTH];

    GLfloat tileMapBlockVertices[TILE_MAP_HEIGHT][TILE_MAP_WIDTH][TILE_MAP_VERTICES_COUNT];
    
    GLuint tileMapVertexArray;
    GLuint tileMapVertexBuffer;

    Texture *tilesTexture;
    
    GLKVector2 position;
}

@end
