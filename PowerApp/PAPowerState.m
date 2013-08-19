//
//  PAPowerState.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "PAPowerState.h"
#import "PAApplianceStatus.h"

@implementation PAPowerState

@dynamic date;
@dynamic generatedKillowatts;
@dynamic usage;
@dynamic applianceStatuses;

- (double)percentageUsageOfMinuteByApplianceStatus:(PAApplianceStatus *)status {
    
    return [status.killowattDelta doubleValue] / [self.usage doubleValue];
    
}

@end
