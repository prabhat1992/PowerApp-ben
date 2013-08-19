//
//  HealthViewController.m
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "HealthViewController.h"
#import "LineGraphScrollView.h"
#import "TipView.h"
#import "Tip.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>


@interface HealthViewController () {
    NSMutableArray *food, *exercise, *sleep;
}
- (IBAction)shareSocially:(id)sender;


- (IBAction)goBack:(id)sender;
@property (weak, nonatomic) IBOutlet LineGraphScrollView *scrollView;

@end

@implementation HealthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)share {
    
    SLComposeViewController *mySLComposerSheet;
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
    {
        mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"Test: %@", mySLComposerSheet.serviceType]]; //the message you want to post
        
        /*
         TODO Get screen shot image!
        */
        
        //[mySLComposerSheet addImage:yourimage]; //an image you could post
        
        
        //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = @"Action Cancelled";
                break;
            case SLComposeViewControllerResultDone:
                output = @"Post Successfull";
                break;
            default:
                break;
        } //check if everythink worked properly. Give out a message on the state.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)loadTips {
    
    food = [NSMutableArray new];
    
    Tip *t1 = [Tip new];
    t1.tipLeve = TLPoor;
    t1.tipType = TTFood;
    t1.content = @"poor eating habits can prevent you from acheiving optimal health.";
    t1.imageURL = @"icon_food-100x100@2x.png";
    [food addObject:t1];
    
    
    Tip *t2 = [Tip new];
    t2.tipLeve = TLAverage;
    t2.tipType = TTFood;
    t2.content = @"you're eating okay, but there is room for improvement.";
    t2.imageURL = @"icon_food-100x100@2x.png";
    [food addObject:t2];
    
    
    Tip *t3 = [Tip new];
    t3.tipLeve = TLGood;
    t3.tipType = TTFood;
    t3.content = @"keep up the good work! a little more effort will help you achieve optimum health.";
    t3.imageURL = @"icon_food-100x100@2x.png";
    [food addObject:t3];
    
    Tip *t4 = [Tip new];
    t4.tipLeve = TLPerfect;
    t4.tipType = TTFood;
    t4.content = @"you're doing great, keep up the good work!";
    t4.imageURL = @"icon_food-100x100@2x.png";
    [food addObject:t4];
    
    
    exercise = [NSMutableArray new];
    
    Tip *e1 = [Tip new];
    e1.tipLeve = TLPoor;
    e1.tipType = TTExercise;
    e1.content = @"more excercise will help you achieve better health.";
    e1.imageURL = @"icon_exercise-100x100@2x.png";
    [exercise addObject:e1];
    
    
    Tip *e2 = [Tip new];
    e2.tipLeve = TLAverage;
    e2.tipType = TTExercise;
    e2.content = @"you are doing okay! but there is room for improvement.";
    e2.imageURL = @"icon_exercise-100x100@2x.png";
    [exercise addObject:e2];
    
    
    Tip *e3 = [Tip new];
    e3.tipLeve = TLGood;
    e3.tipType = TTExercise;
    e3.content = @"keep up the good work! a little more effort will help you achieve optimum health.";
    e3.imageURL = @"icon_exercise-100x100@2x.png";
    [exercise addObject:e3];
    
    Tip *e4 = [Tip new];
    e4.tipLeve = TLPerfect;
    e4.tipType = TTExercise;
    e4.content = @"you're doing great, keep up the good work!";
    e4.imageURL = @"icon_exercise-100x100@2x.png";
    [exercise addObject:e4];
    
    
    sleep = [NSMutableArray new];
    
    Tip *s1 = [Tip new];
    s1.tipLeve = TLPoor;
    s1.tipType = TTSleep;
    s1.content = @"irregular sleep patterns can keep you from performing at your best.";
    s1.imageURL = @"icon_sleep-100x100@2x.png";
    [sleep addObject:s1];
    
    
    Tip *s2 = [Tip new];
    s2.tipLeve = TLAverage;
    s2.tipType = TTSleep;
    s2.content = @"try one less cup of coffee a day to help you sleep better.";
    s2.imageURL = @"icon_sleep-100x100@2x.png";
    [sleep addObject:s2];
    
    
    Tip *s3 = [Tip new];
    s3.tipLeve = TLGood;
    s3.tipType = TTSleep;
    s3.content = @"keep up the good work! you are healthy because of good sleeping habit";
    s3.imageURL = @"icon_sleep-100x100@2x.png";
    [sleep addObject:s3];
    
    Tip *s4 = [Tip new];
    s4.tipLeve = TLPerfect;
    s4.tipType = TTSleep;
    s4.content = @"keep up the good work!";
    s4.imageURL = @"icon_sleep-100x100@2x.png";
    [sleep addObject:s4];
}


- (void)addTips {
    
    [self.scrollView showPageControl];
    
    for (int i = 0; i < 4; i ++) {
        
        TipView *tip = [[TipView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 160)];
        tip.tipLabel.text = [[food objectAtIndex:i] content];
        tip.tipImageView.image = [UIImage imageNamed:[[food objectAtIndex:i] imageURL]];
    
        [self.scrollView addPanelView:tip];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadTips];
    [self addTips];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareSocially:(id)sender {
    [self share];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
