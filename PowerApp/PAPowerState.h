//
//  PAPowerState.h
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PAApplianceStatus;

@interface PAPowerState : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * generatedKillowatts;
@property (nonatomic, retain) NSNumber * usage;
@property (nonatomic, retain) NSOrderedSet *applianceStatuses;
@end

@interface PAPowerState (CoreDataGeneratedAccessors)

- (void)insertObject:(PAApplianceStatus *)value inApplianceStatusesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromApplianceStatusesAtIndex:(NSUInteger)idx;
- (void)insertApplianceStatuses:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeApplianceStatusesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInApplianceStatusesAtIndex:(NSUInteger)idx withObject:(PAApplianceStatus *)value;
- (void)replaceApplianceStatusesAtIndexes:(NSIndexSet *)indexes withApplianceStatuses:(NSArray *)values;
- (void)addApplianceStatusesObject:(PAApplianceStatus *)value;
- (void)removeApplianceStatusesObject:(PAApplianceStatus *)value;
- (void)addApplianceStatuses:(NSOrderedSet *)values;
- (void)removeApplianceStatuses:(NSOrderedSet *)values;

- (double)percentageUsageByApplianceStatus:(PAApplianceStatus *)status;

@end
