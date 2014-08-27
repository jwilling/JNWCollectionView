//
//  AppDelegate.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

@import AppKit;
#import "DemoWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate { DemoWindowController *windowController; }

- (void)awakeFromNib {
	[windowController = DemoWindowController.new showWindow:nil];
}

@end
