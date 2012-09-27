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

#import "Commander.h"

@implementation Commander

- (id) init {
    if (self = [super init]) {
        commandsSize = 16;
        commands = (COMMAND*) malloc(commandsSize * sizeof(COMMAND));
    }
    return self;
}

- (void) dealloc {
    if (commands != nil) {
        free(commands);
        commands = nil;
    }
}

- (void) reset {
    commandCount = 0;
}

+ (COMMAND) commandOfType:(int)type {
    COMMAND command;
    command.type = type;
    return command;
}

+ (COMMAND) commandOfType:(int)type targetPosition:(GLKVector2)target {
    COMMAND command;
    command.type = type;
    command.targetPosition = target;
    return command;
}

+ (COMMAND) commandOfType:(int)type targetPosition:(GLKVector2)target angle:(float)angle {
    COMMAND command;
    command.type = type;
    command.targetPosition = target;
    command.angle = angle;
    return command;
}

- (COMMAND) getCommand {
    if (commands != nil && commandCount > 0) {
        return commands[0];
    } else {
        return [Commander commandOfType:COMMAND_NONE];
    }
}

- (void) popCommand {
    if (commands != nil && commandsSize > 0) {
        for (int i = 1; i < commandCount; i++) {
            commands[i - 1] = commands[i];
        }
        commandCount--;
    }
}

- (void) addCommand:(COMMAND)command {
    if (commandCount >= commandsSize) {
        commandsSize += 16;
        COMMAND *newCommands = (COMMAND*) malloc(commandsSize * sizeof(COMMAND));
        for (int i = 0; i < commandCount; i++) {
            newCommands[i] = commands[i];
        }
        commands = newCommands;
    }
    commands[commandCount] = command;
    commandCount++;
}

@end
