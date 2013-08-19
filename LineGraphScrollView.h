//
//  LineGraphScrollView.h
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineGraphScrollView : UIScrollView

@property (nonatomic, assign) NSUInteger page; //Zero based number of page

//Add content view from the scrollview
- (void)addPanelView:(UIView*) view;
- (void)addPanelView:(UIView*) view atIndex:(NSUInteger) index;
- (void)addPanelViewsWithArray:(NSArray*) contentViews;

//Remove content view from the scrollview
- (void)deletePanelView:(UIView*) view;
- (void)deletePanelViewAtIndex:(NSUInteger) index;
- (void)removeAllPanels;

- (void) setPage:(NSUInteger)page animated:(BOOL) animated;

- (void)initialize;

- (NSUInteger)currentPageIndex;

- (void)showPageControl;

@end
