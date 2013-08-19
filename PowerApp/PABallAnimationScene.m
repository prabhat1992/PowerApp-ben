//
//  PABallAnimationScheme.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "PABallAnimationScene.h"
#import "PADataManager.h"
#import "PAPowerState.h"
#import "PAApplianceStatus.h"
#import "PABallNode.h"

@interface PABallAnimationScene ()

@end

@implementation PABallAnimationScene

- (id)initWithRect:(CGRect)rect {
    
    self = [super initWithSize:rect.size];
    
    if (self) {
        
        self.enclosingRect = rect;
        
        SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.enclosingRect];
        
        self.name = NSStringFromClass([self class]);
        self.scaleMode = SKSceneScaleModeAspectFill;
        self.physicsBody = body;
        self.physicsWorld.gravity = CGPointMake(0.0f, -9.8f);
        
        [self populateScene];
        
    }
    
    return self;
    
}

- (void)populateScene {
    
    [self removeAllChildren];
    
    // Present the scene.
    
    for (NSString *key in kPADataManagerKeyMappings) {
        
        double kw = [[PADataManager sharedInstance] killowattsOfUseOfApplianceType:key forAge:PADataManagerFetchAgeDay];
        
        CGFloat size = (kw / 6.0f) * 220.0f;
        
        if (size < 42.0f)
            size = 42.0f;
        
        CGFloat pos = (arc4random() % (int)self.size.width) + 1;
        
        PABallNode *sprite = [[PABallNode alloc] initWithSize:CGSizeMake(size, size)];
        sprite.applianceName = key;
        sprite.position = CGPointMake(pos, self.size.height);
        sprite.name = [NSString stringWithFormat:@"%@ Blob", key];
        sprite.zPosition = 1.0f;
        
        SKAction *action = [SKAction moveByX:0.0f y:(-(self.size.height - sprite.size.height) - [UIApplication sharedApplication].statusBarFrame.size.height) duration:1.0f];
        [sprite runAction:action];
        
        [self addChild:sprite];
        
    }
    
    // Add background
    SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:self.size];
    backgroundNode.name = @"background";
    backgroundNode.position = CGPointMake(CGRectGetMidX(self.enclosingRect), CGRectGetMidY(self.enclosingRect));
    backgroundNode.physicsBody.dynamic = NO;
    backgroundNode.blendMode = SKBlendModeReplace;
    backgroundNode.zPosition = 2.0f;
    backgroundNode.alpha = 0.9f;
    
    [self addChild:backgroundNode];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (SKSpriteNode *node in self.children) {
        
        if ([node isKindOfClass:[PABallNode class]]) {
            
            PABallNode *ball = (PABallNode *)node;
            
            UITouch *touch = [touches anyObject];
            
            if (CGRectContainsPoint(ball.frame, [touch locationInNode:node]))
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(ballSelectedForApplianceName:)])
                    [self.delegate ballSelectedForApplianceName:ball.applianceName];
            
            
        }
        
    }
    
}

@end
