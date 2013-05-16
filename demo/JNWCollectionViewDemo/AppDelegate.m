//
//  AppDelegate.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoWindowController.h"

@interface AppDelegate()
@property (nonatomic, strong) DemoWindowController *windowController;
@end

@implementation AppDelegate

- (void)awakeFromNib {
	self.windowController = [[DemoWindowController alloc] init];
	[self.windowController showWindow:nil];
}

@end
