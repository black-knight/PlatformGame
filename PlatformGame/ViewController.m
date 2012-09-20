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

#import "ViewController.h"
#import "Game.h"
#import "Globals.h"
#import "ScreenInfo.h"

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
};

@interface ViewController () {

@private

    Game *game;

    float frameSeconds;
    double startTime;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end

@implementation ViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void) didBecomeInactive {
    [game deactivate];
}

- (void) didBecomeActive {
    [game reactivate];
}

- (void) acceleratedInX:(float)x Y:(float)y Z:(float)z {
    screenInfo.rotation = atan2(x, y) - M_PI_2;
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [self acceleratedInX:acceleration.x Y:acceleration.y Z:acceleration.z];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    screenInfo = [[ScreenInfo alloc] init];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
        exit(-1);
    }
    
    openglContext = self.context;
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    self.preferredFramesPerSecond = 60;
    
    [self setupGL];

    game = [[Game alloc] init];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    startTime = CFAbsoluteTimeGetCurrent();
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Warning: Low memory!");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders:@"Shader" index:0];
    
    glkEffect = [[GLKBaseEffect alloc] init];
    self.effect = glkEffect;

    glEnable(GL_DEPTH_TEST);
    
    [self getScreenSize];
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = nil;
    
    for (int i = 0; i < GLSL_PROGRAM_COUNT; i++) {
	    if (glslProgram[i]) {
    	    glDeleteProgram(glslProgram[i]);
        	glslProgram[i] = 0;
	    }
    }
}

- (void) getScreenSize {
    screenInfo.width = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
    screenInfo.height = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;

    screenInfo.widthNoScale = [UIScreen mainScreen].bounds.size.width;
    screenInfo.heightNoScale = [UIScreen mainScreen].bounds.size.height;
    
    screenInfo.aspectRatioX = MIN(1.0f, fabsf(screenInfo.width / screenInfo.height));
    screenInfo.aspectRatioY = MIN(1.0f, fabsf(screenInfo.height / screenInfo.width));
    screenInfo.aspectRatio = MIN(screenInfo.aspectRatioX, screenInfo.aspectRatioY);

    NSLog(@"Screen size: %i, %i", (int) screenInfo.width, (int) screenInfo.height);
    NSLog(@"Aspect ratio: %f, %f", screenInfo.aspectRatioX, screenInfo.aspectRatioY);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
    [game updateWithTimeInterval:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [game render];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders:(NSString*)filename index:(int)index {
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    glslProgram[index] = glCreateProgram();
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:filename ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:filename ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(glslProgram[index], vertShader);
    glAttachShader(glslProgram[index], fragShader);
    
    glBindAttribLocation(glslProgram[index], ATTRIB_VERTEX, "position");
    
    if (![self linkProgram:glslProgram[index]]) {
        NSLog(@"Failed to link program: %d", glslProgram[index]);
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (glslProgram) {
            glDeleteProgram(glslProgram[index]);
            glslProgram[index] = 0;
        }
        
        return NO;
    }
    
    uniformModelViewProjectionMatrix = glGetUniformLocation(glslProgram[index], "modelViewProjectionMatrix");
    
    if (vertShader) {
        glDetachShader(glslProgram[index], vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(glslProgram[index], fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog {
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog {
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
