//
//  AppDelegate.m
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import "AppDelegate.h"
#import "WindowController.h"
#import "SeriesInfo.h"
#import "UserDefaults.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [UserDefaults registerDefaults];
    [UserDefaults loadDefaults:self.seriesInfo];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return  NSTerminateNow;
}

@end
