//
//  GraphViewController.m
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "GraphViewController.h"
#import "LineGraphView.h"
#import "BarGraphView.h"
#import "LineGraphScrollView.h"
#import "PADataManager.h"

@interface GraphViewController () <NSURLConnectionDataDelegate> {
    NSMutableArray *barViews;
    NSMutableData *responseData;
}
- (IBAction)goBack:(id)sender;
- (IBAction)graphAlphaData:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *applianceTitleLabel;

@property (strong, nonatomic) NSString *applianceName;

@property (weak, nonatomic) IBOutlet LineGraphScrollView *lineGraphScrollView;
@property (weak, nonatomic) IBOutlet LineGraphView *lineGraphView;

@end

@implementation GraphViewController

- (id)initWithApplianceName:(NSString *)applianceName
{
    self = [super initWithNibName:@"GraphViewController" bundle:nil];
    if (self) {
        
        _applianceName = applianceName;
        
    }
    return self;
}

- (void)scrollViewDidEndDecelerating:(LineGraphScrollView *)scrollView {
    
    NSLog(@"current page = %d", scrollView.currentPageIndex);
    BarGraphView *view = [barViews objectAtIndex:scrollView.currentPageIndex];
    [view animateLables];
}

- (void)addBarPanels {
    
    for (int i = 0; i < 3; i++) {
        
        BarGraphView *bar = [[BarGraphView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.lineGraphScrollView.bounds), CGRectGetHeight(self.lineGraphScrollView.bounds))];
        bar.tag = i;
        
        if (!barViews)
            barViews = [NSMutableArray new];
        [barViews addObject:bar];
        [self.lineGraphScrollView addPanelView:bar];
        
        int numOfBars;
        
        if (i == 0)
            numOfBars = 7;
        else if (i == 1)
            numOfBars = 30;
        else
            numOfBars = 365;
        
        NSMutableArray *barValues = [NSMutableArray new];
        for (int j = 0; j < numOfBars; j++) {
            float value = arc4random() % 30;
            [barValues addObject:[NSNumber numberWithFloat:value]];
        }
        
        if (barValues.count > 100) {
            
            NSMutableArray *newValues = [NSMutableArray new];
            __block float runner = 0.0f;
            
            [barValues enumerateObjectsUsingBlock:^(NSNumber *val, NSUInteger idx, BOOL *stop) {
                
                runner += val.floatValue;
                
                if (idx % 30 == 0 && idx > 0) {
                    [newValues addObject:[NSNumber numberWithFloat:runner]];
                    runner = 0.0f;
                }
                
            }];
            
            [barValues removeAllObjects];
            [barValues addObjectsFromArray:newValues];
            
        }
        
        
        NSLog(@"%d", barValues.count);
        
        [bar addBars:barValues];
    }
    
    [self scrollViewDidEndDecelerating:self.lineGraphScrollView];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)graphAlphaData:(id)sender {
    
    if ([(UIButton*)sender tag] == 0) {

        [self addBarPanels];
        
        [self.lineGraphView addLine:[self dataTest] animated:YES];
    }
    else {
        
        [self.lineGraphView addLine:[self extraData] animated:YES];
    }

}

- (NSArray*)dataTest {
    
    
    NSArray *data = [[PADataManager sharedInstance] fetchPowerStatesForAge:PADataManagerFetchAgeDay];
    
    NSLog(@"%@", data);
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"DataTest"
                                               ofType:@"txt"];

    
    NSString* fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *adjData = [NSMutableArray new];
    
    [allLinedStrings enumerateObjectsUsingBlock:^(NSString *strValue, NSUInteger idx, BOOL *stop) {
        [adjData addObject:[NSNumber numberWithFloat:[strValue floatValue]]];
    }];
    return adjData;
}

- (NSArray*)extraData {
    NSString*  path = [[NSBundle mainBundle] pathForResource:@"ExtraData"
                                                      ofType:@"txt"];
    
    
    NSString* fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *adjData = [NSMutableArray new];
    
    [allLinedStrings enumerateObjectsUsingBlock:^(NSString *strValue, NSUInteger idx, BOOL *stop) {
        [adjData addObject:[NSNumber numberWithFloat:[strValue floatValue]]];
    }];
    
    return  adjData;
}

- (void)loadDataFromServer{
    //
    
    
    /*
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.mongolab.com/api/1/clusters/rs-ds031468/databases/energymonster/collections/consumption0909?apiKey=rxYYDoHuU1X_4LBBpW9fLG54cObbGZvk"]];
    NSURLConnection *con = [[NSURLConnection alloc] init];
    (void)[con initWithRequest:req delegate:self];
    */
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.mongolab.com/api/1/clusters/rs-ds031468/databases/energymonster/collections/consumption0909?apiKey=rxYYDoHuU1X_4LBBpW9fLG54cObbGZvk"]];
    //NSURLResponse * response = nil;
    //NSError * error = nil;
    /*
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    */
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error == nil)
        {
            // Parse data here
            
            NSError *readError;
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&readError];
            
            NSLog(@"array: %@", array);
            
        }
    }];
    

    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addBarPanels];
    
    [self.lineGraphView addLine:[self extraData] animated:YES];
    
    [self.lineGraphView addLine:[self dataTest] animated:YES];
    
    /*
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });
     */
    
    //[self loadDataFromServer];
    
    self.applianceTitleLabel.text = self.applianceName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
