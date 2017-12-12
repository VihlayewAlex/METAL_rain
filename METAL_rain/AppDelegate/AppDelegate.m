//
//  AppDelegate.m
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/11/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) MainWindowController* mainWindowController;

@end

@implementation AppDelegate

#pragma mark Synthesizing accessors

@synthesize mainWindowController;

#pragma mark Life cycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupWindows];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark Setup

- (void)setupWindows
{
    mainWindowController = [[MainWindowController alloc] init];
    [mainWindowController showWindow:nil];
}

@end
