//
//  PAPowerState+CoreDataHelper.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "PAPowerState+CoreDataHelper.h"

//static NSString *const kItemsKey = @"applianceStatuses";

@implementation PAPowerState (CoreDataHelper)

- (void)addApplianceStatusesObject:(PAApplianceStatus *)value {

    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.applianceStatuses];
    [tempSet addObject:value];
    self.applianceStatuses = tempSet;
}


- (void)addApplianceStatuses:(NSOrderedSet *)values {
    
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.applianceStatuses];
    [tempSet addObjectsFromArray:[values array]];
    self.applianceStatuses = tempSet;
    
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"Pow: %@ %f", self.date, [self.usage doubleValue]];
    
}

@end
