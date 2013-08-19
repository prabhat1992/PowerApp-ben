//
//  PADataGenerator.h
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kPADataManagerKeyMappings @{ @"OVEN" : @"Oven", @"DRYE" : @"Dryer", @"AIR" : @"Air condenser/compressor", @"REFRIGERATOR" : @"Refrigerator", @"MICROWAVE": @"Microwave", @"DININGROOM" : @"Dining Room", @"BATHROOM" : @"Bathroom", @"DISHWASHER" : @"Dishwasher", @"FURNACE" : @"Furnace", @"LIVINGROOM" : @"Living Room", @"MASTERBED" : @"Master Bedroom", @"CAR1" : @"EV Charging Station" }

typedef NS_ENUM(NSUInteger, PADataManagerFetchAge) {
    
    PADataManagerFetchAgeDay,
    PADataManagerFetchAgeWeek,
    PADataManagerFetchAgeMonth,
    PADataManagerFetchAgeYear,
    PADataManagerFetchAgeAll
    
};

@interface PADataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)generatePowerStatesWithCompletionBlock:(void (^)())block;
- (NSArray *)fetchPowerStatesForAge:(PADataManagerFetchAge)fetchAge;

- (double)killowattsOfUseOfApplianceType:(NSString *)label forAge:(PADataManagerFetchAge)fetchAge;

+ (PADataManager *)sharedInstance;

@end