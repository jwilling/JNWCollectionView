//
//  TableViewHeader.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/27/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "TableViewHeader.h"

@interface TableViewHeader()
@property (nonatomic, strong) NSTextField *headerLabel;
@end

@implementation TableViewHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	self.headerLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
	self.headerLabel.bezeled = NO;
	self.headerLabel.drawsBackground = NO;
	self.headerLabel.selectable = NO;
	self.headerLabel.font = [NSFont boldSystemFontOfSize:13];
	
	[self addSubview:self.headerLabel];
	
	return self;
}

- (NSImage *)sharedBackgroundImage {
	static NSImage *backgroundImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		backgroundImage = [NSImage imageWithSize:CGSizeMake(2, 24) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			NSColor *start = [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1];
			NSColor *end = [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1];
			NSGradient *gradient = nil;
			
			gradient = [[NSGradient alloc] initWithStartingColor:start endingColor:end];
			[gradient drawInRect:dstRect angle:90];
			
			[[start shadowWithLevel:0.1] set];
			NSRectFill(NSMakeRect(0, 0, dstRect.size.width, 1));
			return YES;
		}];
	});
	
	return backgroundImage;
}

- (void)layout {
	[super layout];
	
	CGRect cellLabelFrame = self.bounds;
	cellLabelFrame.size.width = 100;
	self.headerLabel.frame = CGRectOffset(cellLabelFrame, 15, -3);
}

- (BOOL)wantsUpdateLayer {
	return YES;
}

- (void)updateLayer {
	self.layer.contents = self.sharedBackgroundImage;
}

- (void)setHeaderLabelText:(NSString *)headerLabelText {
	_headerLabelText = headerLabelText;
	self.headerLabel.stringValue = headerLabelText;
}

@end
