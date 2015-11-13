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

typedef enum {
	GridLayout = 0,
	ListLayout = 1,
	NSTableViewLayout = 2
} LayoutType;

@interface DemoWindowController ()
@property (nonatomic, strong) NSViewController *currentViewController;
@property (nonatomic, assign) LayoutType layoutType;
@end

@implementation DemoWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
	self.currentViewController = [[GridDemoViewController alloc] init];
}

- (id)init {
	return [super initWithWindowNibName:NSStringFromClass(self.class)];
}

- (void)selectLayout:(id)sender {
	LayoutType layout = (LayoutType)[sender selectedSegment];

	if (self.layoutType == layout)
		return;
	self.layoutType = layout;
	
	if (layout == GridLayout) {
		self.currentViewController = [[GridDemoViewController alloc] init];
	} else if (layout == ListLayout) {
		self.currentViewController = [[ListDemoViewController alloc] init];
	} else if (layout == NSTableViewLayout) {
		self.currentViewController = [[NSTableViewDemoViewController alloc] init];
	}
}

- (void)setCurrentViewController:(NSViewController *)currentViewController {
	if (_currentViewController == currentViewController)
		return;
	
	[_currentViewController.view removeFromSuperview];

	_currentViewController = currentViewController;
	_currentViewController.view.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
	
	self.containerBox.contentView = _currentViewController.view;
}

@end
