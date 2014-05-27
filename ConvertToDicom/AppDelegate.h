//
//  AppDelegate.h
//  ConvertToDicom
//
//  Created by Tim Allman on 2014-03-24.
//  Copyright (c) 2014 Tim Allman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowController.h"

@class SeriesInfo;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet WindowController *windowController;
@property (weak) IBOutlet SeriesInfo *seriesInfo;

@end
