//
//  Shader.fsh
//  PlatformGame
//
//  Created by Daniel Andersen on 9/17/12.
//  Copyright (c) 2012 Daniel Andersen. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
