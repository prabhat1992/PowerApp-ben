//
//  PAUserSettingsManager.h
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAUserSettingsManager : NSObject

@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSNumber *costOfPowerPerKillowatt;

@end
