//
//  LineGraphView.h
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineGraphView : UIView

/* Graph an array of data
 @param NSArray of NSNumber items of data points to graph
 */
- (void)addLine:(NSArray*)data animated:(BOOL)animated;

/* Remove a layer at a given index from the screen. This will also delete the associated data array so if you need it back you will have to reload the data on your own.
 @param The index of the layer to remove
 */
- (void)removeLayerAtIndex:(int)index;

/* Add multiple lines to the graph at one time
 @param NSArray of NSArrays which are arrays of NSNumbers to of data points to be graphed.
 - (void)addLines:(NSArray*)lines animated:(BOOL)animated;
 */

@end
