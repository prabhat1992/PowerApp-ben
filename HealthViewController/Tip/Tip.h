//
//  Tip.h
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TipType) {
    TTFood,
    TTExercise,
    TTSleep
};

typedef NS_ENUM(NSUInteger, TipLevel) {
    TLPoor,
    TLAverage,
    TLGood,
    TLPerfect
};

@interface Tip : NSObject

@property (nonatomic, assign) NSString *content;
@property (nonatomic, assign) NSString *imageURL;

@property (nonatomic, assign) TipType tipType;
@property (nonatomic, assign) TipLevel tipLeve;

@end
