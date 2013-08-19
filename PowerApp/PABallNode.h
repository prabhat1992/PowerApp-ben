//
//  PABallNode.h
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PAApplianceStatus.h"

@interface PABallNode : SKSpriteNode

@property (strong, nonatomic) NSString *applianceName;

- (id)initWithSize:(CGSize)size;

@end
