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
	ListLayout = 0,
	GridLayout = 1,
	NSTableViewLayout = 2
} LayoutType;

@interface DemoWindowController ()
@property (nonatomic, strong) NSViewController *currentViewController;
@property (nonatomic, assign) LayoutType layoutType;
@end

@implementation DemoWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
	self.currentViewController = [[ListDemoViewController alloc] init];
}

- (id)init {
	return [super initWithWindowNibName:NSStringFromClass(self.class)];
}

- (void)selectLayout:(id)sender {
	NSInteger layout = [sender selectedSegment];

	if (self.layoutType == layout)
		return;
	self.layoutType = layout;
	
	if (layout == ListLayout) {
		self.currentViewController = [[ListDemoViewController alloc] init];
	} else if (layout == GridLayout) {
		self.currentViewController = [[GridDemoViewController alloc] init];
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

- (IBAction)addItem:(id)sender
{
    if ([self.currentViewController respondsToSelector:@selector(addItem:)]) {
        [self.currentViewController performSelector:@selector(addItem:) withObject:sender];
    }
}

@end
