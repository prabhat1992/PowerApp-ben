//
//  PAApplianceStatus.h
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PAPowerState;

@interface PAApplianceStatus : NSManagedObject

@property (nonatomic, retain) NSNumber * killowattDelta;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) PAPowerState *powerState;

@end
