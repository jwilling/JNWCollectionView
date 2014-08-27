//
//  DemoWindowController.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/12/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "DemoWindowController.h"
#import "ListDemoViewController.h"
#import "GridDemoViewController.h"

#import "NSTableViewDemoViewController.h"

typedef NS_ENUM(NSUInteger, LayoutType) { ListLayout = 0, GridLayout, NSTableViewLayout, Unset };

@interface DemoWindowController ()
@property (nonatomic) LayoutType layoutType;
@end

@implementation DemoWindowController { NSViewController *currentViewController; }

- init {

  return self = [super initWithWindowNibName:NSStringFromClass(self.class)] ?
  _layoutType = Unset, self : nil;
}

- (void) windowDidLoad {  self.layoutType = ListLayout; }

- (void) setLayoutType:(LayoutType)type {

	if (_layoutType == type) return;
      _layoutType =  type;
	
  id newVC  = type == ListLayout         ? ListDemoViewController.new
            : type == GridLayout         ? GridDemoViewController.new
            : type == NSTableViewLayout  ? NSTableViewDemoViewController.new
                                         : currentViewController;

  if (currentViewController == newVC) return;

	[currentViewController.view removeFromSuperview];

  currentViewController = newVC;

	currentViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	
	self.containerBox.contentView = currentViewController.view;
}

@end
