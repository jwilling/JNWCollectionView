
//  DemoWindowController.m 						-  JNWCollectionViewDemo
//  Created by Jonathan Willing on 4/12/13.  -  Copyright (c) 2013 AppJon. All rights reserved.

#import "DemoWindowController.h"
#import "ListDemoViewController.h"
#import "GridDemoViewController.h"
#import "NSTableViewDemoViewController.h"

typedef NS_ENUM( NSUInteger, LayoutType ) { ListLayout, GridLayout, NSTableViewLayout };

@interface DemoWindowController    ()
@property 					 NSArray * viewControllers;
@property (nonatomic) LayoutType   layoutType;
@end

@implementation DemoWindowController

-   (id) init {	return [super initWithWindowNibName:NSStringFromClass(self.class)];	}

- (void) awakeFromNib {  

	_contentView.subviews = [_viewControllers = @[	ListDemoViewController.new, 
																	GridDemoViewController.new, 
														  NSTableViewDemoViewController.new	]
																		 valueForKeyPath:@"view"]; 	
	NSRect rect		= _contentView.bounds;
	rect.origin.x -= rect.size.width;
	for (id view in _contentView.subviews)								[view setFrame:rect];
	[_contentView.subviews[ _layoutType = ListLayout ] setFrame:_contentView.bounds];
															[self.window makeKeyAndOrderFront:nil]; 
}

- (void) setLayoutType:(LayoutType)type {  	if (_layoutType == type) return; 

	NSView *current 			= _contentView.subviews[_layoutType];
	NSRect rect 				= _contentView.bounds;
	rect.origin.x 			  += rect.size.width;
	current.animator.frame 	= rect;
	rect 							= _contentView.bounds;
	rect.origin.x 			  -= rect.size.width;
	[current	= _contentView.subviews[_layoutType = type] setFrame:rect];
	rect.origin.x 			  += rect.size.width;
	current.animator.frame	= rect;
}

@end

int main(int argc, char *argv[])	{	return NSApplicationMain(argc, (const char **)argv);	}

