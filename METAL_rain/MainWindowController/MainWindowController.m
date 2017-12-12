//
//  MainWindowController.m
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/11/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

#pragma mark Initialization

- (instancetype)init
{
    NSString* nibName = NSStringFromClass([self class]);
    self = [super initWithWindowNibName:nibName];
    if (self) {
        [[self window] setTitle:@"METAL Rain - Lab8 by Alex Vihlayew"];
        [[self window] setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    }
    return self;
}

#pragma mark Life cycle

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    MainViewController* mainViewController = [[MainViewController alloc] init];
    [[self window] setContentViewController:mainViewController];
}

@end

