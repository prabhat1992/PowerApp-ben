//
//  PAUserSettingsManager.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "PAUserSettingsManager.h"

@implementation PAUserSettingsManager

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.postalCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"postalCode"];
        self.costOfPowerPerKillowatt = [[NSUserDefaults standardUserDefaults] objectForKey:@"costOfPowerPerKillowatt"];
        
    }
    
    return self;
    
}

- (void)setPostalCode:(NSString *)postalCode {
    
    _postalCode = postalCode;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.postalCode forKey:@"postalCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)setCostOfPowerPerKillowatt:(NSNumber *)ppk {
    
    _costOfPowerPerKillowatt = ppk;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.costOfPowerPerKillowatt forKey:@"costOfPowerPerKillowatt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
