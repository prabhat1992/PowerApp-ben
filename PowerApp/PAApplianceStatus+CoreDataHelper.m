//
//  PAApplianceStatus+CoreDataHelper.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "PAApplianceStatus+CoreDataHelper.h"

@implementation PAApplianceStatus (CoreDataHelper)

- (NSString *)description {
    
    return [NSString stringWithFormat:@"App: %@ %f ", self.label, [self.killowattDelta doubleValue]];
    
}

@end
