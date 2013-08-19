//
//  PABallNode.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "PABallNode.h"

@interface PABallNode ()

@end

@implementation PABallNode

- (id)initWithSize:(CGSize)size {

    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"tex.png"] color:[SKColor colorWithRed:167.0f/255.0f green:218/255.0f blue:167/255.0f alpha:1.0f] size:size];
    
    if (self) {
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2 + 1.0f];
        self.physicsBody.restitution = 0.9f;
        self.physicsBody.friction = 0.4;
        self.physicsBody.dynamic = YES;
        self.blendMode = SKBlendModeAlpha;
        self.colorBlendFactor = 1.0f;
        
    }
    
    return self;
    
}

@end
