//
//  MainViewController.m
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/11/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) AVRenderer* METAL_renderer;

@end

@implementation MainViewController

#pragma mark Synthesizing accessors

@synthesize METAL_renderer;

#pragma mark Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AVRenderer* renderer = [[AVRenderer alloc] init];
    METAL_renderer = renderer;
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [METAL_renderer setupLayerOver:[[self view] layer]];
    [METAL_renderer drawRainWithRaindropsCount:200];
}

@end

