//
//  PADataGenerator.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "PADataManager.h"
#import "CHCSVParser.h"
#import "PAPowerState.h"
#import "PAApplianceStatus.h"
#import "CHCSVParser+FileName.h"

@interface PADataManager () <CHCSVParserDelegate, NSFetchedResultsControllerDelegate>

@property (copy) void (^completionBlock)();

@property (strong, nonatomic) NSMutableArray *documentsToProcess;
@property (strong, nonatomic) PAPowerState *currentPowerState;
@property (strong, nonatomic) NSMutableArray *columnLabels;

@property (strong, nonatomic) NSDateFormatter *dateFormater;

@property (assign, nonatomic) NSUInteger lineNumber;

@end

@implementation PADataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static PADataManager *sharedInstance = nil;

+ (void)initialize {
    
    static BOOL initialized = NO;
    if (!initialized) {
        
        initialized = YES;
        sharedInstance = [[PADataManager alloc] init];
        
    }
    
}

+ (PADataManager *)sharedInstance {
    
    return sharedInstance;
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.documentsToProcess = [[NSMutableArray alloc] init];
        self.columnLabels = [[NSMutableArray alloc] init];
        
        self.dateFormater = [[NSDateFormatter alloc] init];
        [self.dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [self.dateFormater setDateFormat:@"M/dd/yy HH:mm"];
        
    }
    
    return self;
    
}

- (void)generatePowerStatesWithCompletionBlock:(void (^)())block {
    
    self.completionBlock = block;
    
    [self.documentsToProcess removeAllObjects];
    
    [self.documentsToProcess addObjectsFromArray:@[ @"Home 02_1min-2012-0903", @"Home 02_1min-2012-0904", @"Home 02_1min-2012-0905", /*@"Home 02_1min-2012-0906", @"Home 02_1min-2012-0907", @"Home 02_1min-2012-0908", @"Home 02_1min-2012-0909"*/ ]];
    
    NSMutableArray *parsers = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in self.documentsToProcess) {
        
        CHCSVParser *parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"csv"]];
        parser.fileName = fileName;
        parser.delegate = self;
        [parsers addObject:parser];
        
    }
    
    for (CHCSVParser *parser in parsers)
        [parser parse];
    
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    
    if (self.completionBlock != nil)
        self.completionBlock(nil);
    
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    
    NSLog(@"Began");
    
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    
    [self.documentsToProcess removeObject:parser.fileName];
    
    if (self.documentsToProcess.count == 0)
        if (self.completionBlock != nil)
            self.completionBlock();
    
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    
    self.lineNumber = recordNumber;
    
    if (self.lineNumber == 1) {
        
        [self.columnLabels removeAllObjects];
        
    }
    
    else {
        
        PAPowerState *state = [[PAPowerState alloc] initWithEntity:[NSEntityDescription entityForName:@"PAPowerState" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        self.currentPowerState = state;
        
    }
    
    
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    
    [self saveContext];
    self.currentPowerState = nil;
    
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    
    if (self.lineNumber == 1) {
        
        [self.columnLabels addObject:field];
        
    }
    
    else if (self.lineNumber > 1) {
        
        if (fieldIndex == 0) {
            
            [self.currentPowerState setDate:[self.dateFormater dateFromString:field]];
            
        }
        
        else if (fieldIndex == 1) {
            
            [self.currentPowerState setUsage:[NSNumber numberWithDouble:[field doubleValue]]];
            
        }
        
        else if (fieldIndex == 2) {
            
            [self.currentPowerState setGeneratedKillowatts:[NSNumber numberWithDouble:[field doubleValue]]];
            
        }
        
        else if (fieldIndex > 3) {
            
            NSString *colName = [self.columnLabels objectAtIndex:fieldIndex];
            
            NSUInteger start = [(NSString *)colName rangeOfString:@"["].location;
            
            NSString *realKey = [[(NSString *)colName substringToIndex:start] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
            realKey = [realKey stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            
            BOOL isAppliance = [[kPADataManagerKeyMappings allKeys] containsObject:realKey];
            BOOL containsKw = [(NSString *)colName rangeOfString:@"kW" options:NSCaseInsensitiveSearch].location != NSNotFound;
            
            if (isAppliance && containsKw) {
                
                PAApplianceStatus *status = [[PAApplianceStatus alloc] initWithEntity:[NSEntityDescription entityForName:@"PAApplianceStatus" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
                status.killowattDelta = [NSNumber numberWithDouble:[field doubleValue]];
                status.label = [kPADataManagerKeyMappings valueForKey:realKey];
                
                [self.currentPowerState addApplianceStatusesObject:status];
                
            }
            
        }
        
    }
    
}

- (NSFetchedResultsController *)fetchedResultsControllerForFetchAge:(PADataManagerFetchAge)age entity:(NSEntityDescription *)entity prediate:(NSPredicate *)predicate
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    [fetchRequest setEntity:entity];
    if (predicate != nil)
        [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return aFetchedResultsController;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PowerApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PowerApp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSArray *)fetchPowerStatesForAge:(PADataManagerFetchAge)fetchAge {
    
    NSFetchedResultsController *frc = [self fetchedResultsControllerForFetchAge:fetchAge entity:[NSEntityDescription entityForName:@"PAPowerState" inManagedObjectContext:self.managedObjectContext] prediate:[NSPredicate predicateWithFormat:@"date < %@", [self comparitiveDateForFetchAge:fetchAge]]];
    [frc performFetch:nil];
    return frc.fetchedObjects;
    
}

- (double)killowattsOfUseOfApplianceType:(NSString *)label forAge:(PADataManagerFetchAge)fetchAge {
    
    NSFetchedResultsController *frc = [self fetchedResultsControllerForFetchAge:fetchAge entity:[NSEntityDescription entityForName:@"PAPowerState" inManagedObjectContext:self.managedObjectContext] prediate:[NSPredicate predicateWithFormat:@"date < %@", [self comparitiveDateForFetchAge:fetchAge]]];
    [frc performFetch:nil];

    double usage = (((double)rand() / (double)RAND_MAX) * 3);
    
    /*for (PAPowerState *state in frc.fetchedObjects) {
        
        NSArray *items = [[state.applianceStatuses array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"label LIKE %@", label]];
        
        for (PAApplianceStatus *status in items)
            usage += [status.killowattDelta doubleValue];
        
    }*/
    
    return usage;
    
}

- (NSDate *)comparitiveDateForFetchAge:(PADataManagerFetchAge)age {
    
    NSDate *comparativeDate;
    
    switch (age) {
        case PADataManagerFetchAgeDay:
            comparativeDate = [NSDate dateWithTimeIntervalSinceNow:-86400];
            break;
        case PADataManagerFetchAgeWeek:
            comparativeDate = [NSDate dateWithTimeIntervalSinceNow:-604800];
            break;
        case PADataManagerFetchAgeMonth:
            comparativeDate = [NSDate dateWithTimeIntervalSinceNow:-2628000];
            break;
        case PADataManagerFetchAgeYear:
            comparativeDate = [NSDate dateWithTimeIntervalSinceNow:-3.15569e7];
            break;
        case PADataManagerFetchAgeAll:
            comparativeDate = [NSDate dateWithTimeIntervalSince1970:0];
            break;
        default:
            break;
    }
    
    return comparativeDate;
    
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
