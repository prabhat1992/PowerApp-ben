//
//  PABallAnimationScheme.h
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PAApplianceStatus.h"

@protocol PABallAnimationSceneDelegate

- (void)ballSelectedForApplianceName:(NSString *)appliance;

@end

@interface PABallAnimationScene : SKScene

@property (assign, nonatomic) CGRect enclosingRect;
@property (weak, nonatomic) NSObject<PABallAnimationSceneDelegate> *delegate;

- (id)initWithRect:(CGRect)rect;
- (void)populateScene;

@end
