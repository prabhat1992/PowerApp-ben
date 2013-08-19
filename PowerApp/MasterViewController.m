//
//  MasterViewController.m
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MasterViewController.h"
#import "PABallAnimationScene.h"
#import "PAPowerState.h"
#import "PAApplianceStatus.h"
#import "PADataManager.h"
#import "GraphViewController.h"
#import "HealthViewController.h"

@interface MasterViewController () <PABallAnimationSceneDelegate>

@property (strong, nonatomic) PABallAnimationScene *scene;

@property (weak, nonatomic) IBOutlet UILabel *usageLabel;
@property (weak, nonatomic) IBOutlet SKView *sceneView;
- (IBAction)pushHealth:(id)sender;

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usageLabel.text = @"3.4%";
    
    SKView *skView = self.sceneView;
        
    // Create and configure the scene.
    self.scene = [[PABallAnimationScene alloc] initWithRect:[self correctedScreenRect]];
    self.scene.delegate = self;
    [skView presentScene:self.scene];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    self.scene.enclosingRect = [self correctedScreenRect];
    [self.scene populateScene];
    
}

- (CGRect)correctedScreenRect {
    
    CGRect correctedRect = self.sceneView.bounds;
    correctedRect.size.height -= self.navigationController.navigationBar.frame.size.height;
    correctedRect.size.height -= [UIApplication sharedApplication].statusBarFrame.size.height;
    correctedRect.size.height -= 20.0f;
    correctedRect.size.width -= 42.0f;
    return correctedRect;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ballSelectedForApplianceName:(NSString *)appliance {
    
    GraphViewController *graph = [[GraphViewController alloc] initWithApplianceName:appliance];
    [self.navigationController pushViewController:graph animated:YES];
    
}

- (IBAction)pushHealth:(id)sender {
    
    HealthViewController *health = [[HealthViewController alloc] initWithNibName:@"HealthViewController" bundle:nil];
    [self.navigationController pushViewController:health animated:YES];
}
@end
