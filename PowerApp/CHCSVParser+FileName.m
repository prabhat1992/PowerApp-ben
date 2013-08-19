//
//  CHCSVParser+FileName.m
//  PowerApp
//
//  Created by Ben Deming on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "CHCSVParser+FileName.h"

static char *fileNameKey;

@implementation CHCSVParser (FileName)

- (NSString *)fileName {

    return objc_getAssociatedObject(self, &fileNameKey);
    
}

- (void)setFileName:(NSString *)fileName {
    
    objc_setAssociatedObject(self, &fileNameKey, fileName, OBJC_ASSOCIATION_RETAIN);
    
}

@end
