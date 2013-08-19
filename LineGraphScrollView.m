//
//  LineGraphScrollView.m
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "LineGraphScrollView.h"
#import <QuartzCore/CATransaction.h>

//NSString * const ContentOffsetKey = @"contentOffset";
const CGFloat PageControlHeight2 = 30.0;

@interface LineGraphScrollView ()

@property (nonatomic, readonly) NSTimer *animationTimer;
@property (nonatomic, readonly) NSMutableArray* views;
@property (nonatomic, readonly) UIPageControl* pageControl;

- (void)updateViewPositionAndPageControl;

- (void)changePage:(UIPageControl*) aPageControl;

- (void)autoScroll;


- (NSUInteger)currentPageIndex;

@end

@implementation LineGraphScrollView

@synthesize views;
@synthesize pageControl;

#pragma mark -
#pragma mark Subclass

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

#pragma mark -
#pragma mark Initialization

- (void)initialize {
    NSLog(@"init with frame");
    
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = YES;
    self.scrollsToTop = NO;
    self.scrollEnabled = YES;
    self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    //Place page control
    CGRect frame = CGRectMake(self.contentOffset.x, 0, self.frame.size.width, PageControlHeight2);
    
    UIPageControl* aPageControl = [[UIPageControl alloc] initWithFrame:frame];
    [aPageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    aPageControl.defersCurrentPageDisplay = YES;
    aPageControl.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    aPageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.941f green:0.941f blue:0.941f alpha:1.000f];
    //[self addSubview:aPageControl];
    
    pageControl = aPageControl;
    
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postTap)];
    //[self addGestureRecognizer:tap];
    
}

- (void)showPageControl {
    [self addSubview:pageControl];
}

- (void) setPagingEnabled:(BOOL) pagingEnabled {
    if (pagingEnabled)
        [super setPagingEnabled:pagingEnabled];
    else
        [NSException raise:@"Disabling pagingEnabled" format:@"Paging enabled should not be disabled here"];
}

#pragma mark -
#pragma mark Add/Remove content

- (void) addPanelView:(UIView *)view {
    [self addPanelView:view atIndex:[self.views count]];
}

- (void) addPanelView:(UIView *)view atIndex:(NSUInteger)index {
    [self insertSubview:view atIndex:index];
    [self.views insertObject:view atIndex:index];
    [self updateViewPositionAndPageControl];
    self.contentOffset = CGPointMake(0, - self.scrollIndicatorInsets.top);
    [self flashScrollIndicators];
    
}

- (void)addPanelViewsWithArray:(NSArray *)contentViews {
    for (UIView* contentView in contentViews) {
        [self addPanelView:contentView];
    }
}

- (void) deletePanelView:(UIView *)view {
    [view removeFromSuperview];
    [self.views removeObject:view];
    [self updateViewPositionAndPageControl];
}

- (void)deletePanelViewAtIndex:(NSUInteger)index {
    [self deletePanelView:[self.views objectAtIndex:index]];
}

- (void) removeAllPanels {
    for (UIView* view in self.views) {
        [view removeFromSuperview];
    }
    
    [self.views removeAllObjects];
    [self updateViewPositionAndPageControl];
}

#pragma mark -
#pragma mark Layout

- (void) updateViewPositionAndPageControl {
    
    [self.views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIView *view = (UIView *) obj;
        
        view.frame = CGRectMake((self.frame.size.width - view.frame.size.width) / 2 + self.frame.size.width * idx, (self.frame.size.height - view.frame.size.height) / 2, view.frame.size.width, view.frame.size.height);
        
    }];
    
    UIEdgeInsets inset = self.scrollIndicatorInsets;
    
    CGFloat heightInset = inset.top + inset.bottom;
    
    self.contentSize = CGSizeMake(self.frame.size.width * [self.views count], self.frame.size.height - heightInset);
    
    self.pageControl.numberOfPages = self.views.count;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    //Avoid that the pageControl move
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CGRect frame = self.pageControl.frame;
    frame.origin.x = self.contentOffset.x;
    frame.origin.y = self.frame.size.height - PageControlHeight2 - self.scrollIndicatorInsets.bottom - self.scrollIndicatorInsets.top;
    frame.size.width = self.frame.size.width;
    self.pageControl.frame = frame;
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark Getters/Setters

- (void) setFrame:(CGRect) newFrame {
    [super setFrame:newFrame];
    [self updateViewPositionAndPageControl];
}

- (void) changePage:(UIPageControl*) aPageControl {
    [self setPage:aPageControl.currentPage animated:YES];
}

- (void) setContentOffset:(CGPoint) new {
    new.y = -self.scrollIndicatorInsets.top;
    [super setContentOffset:new];
    
    self.pageControl.currentPage = self.page; //Update the page number
}

- (NSMutableArray*) views {
    if (views == nil) {
        views = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return views;
}

- (NSUInteger) page {
    return (self.contentOffset.x + self.frame.size.width / 2) / self.frame.size.width;
}

- (void) setPage:(NSUInteger)page {
    [self setPage:page animated:NO];
}

- (void) setPage:(NSUInteger)page animated:(BOOL) animated {
    [self setContentOffset:CGPointMake(page * self.frame.size.width, - self.scrollIndicatorInsets.top) animated:animated];
}

- (void)autoScroll {
    int page = [self currentPageIndex];
    
    if (page + 1 > ([views count] - 1))
        [self setPage:0 animated:YES];
    else
        [self setPage:page + 1 animated:YES];
}

- (NSUInteger)currentPageIndex {
    return (floor((self.contentOffset.x - self.frame.size.width / 2) / self.frame.size.width) + 1);
}

@end
