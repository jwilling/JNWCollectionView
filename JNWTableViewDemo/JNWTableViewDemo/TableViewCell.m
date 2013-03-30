//
//  TableViewCell.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell()
@property (nonatomic, strong) NSTextField *cellLabel;
@end

@implementation TableViewCell


typedef void(^NSGraphicsStateBlock)();
static void NSGraphicsContextState(CGContextRef ctx, NSGraphicsStateBlock block) {
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	[NSGraphicsContext setCurrentContext:context];
	block();
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawBackgroundInRect:(CGRect)dstRect selected:(BOOL)selected {
	CGRect b = dstRect;
	CGFloat top = selected ? .82 : 0.81;
	CGFloat bottom = selected ? .76 : 0.87;
	NSGradient *gradient = [[NSGradient alloc] initWithColors: @[[NSColor colorWithCalibratedRed:top green:top blue:top alpha:1],
							[NSColor colorWithCalibratedRed:bottom green:bottom blue:bottom alpha:1]]];
	[gradient drawInRect:b angle:90];
	
	[[[NSColor whiteColor] colorWithAlphaComponent:0.6] setFill];
	NSRectFillUsingOperation(CGRectMake(0, b.size.height-1, b.size.width, 1), NSCompositeSourceOver);
	
	[[[NSColor blackColor] colorWithAlphaComponent:0.08] setFill];
	NSRectFillUsingOperation(CGRectMake(0, 0, b.size.width, 1), NSCompositeSourceOver);
}

- (NSImage *)sharedBackgroundImage {
	static NSImage *backgroundImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		backgroundImage = [NSImage imageWithSize:CGSizeMake(2, 44) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			[self drawBackgroundInRect:dstRect selected:NO];
			return YES;
		}];
	});
	
	return backgroundImage;
}

- (NSImage *)sharedSelectedBackgroundImage {
	static NSImage *backgroundImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		backgroundImage = [NSImage imageWithSize:CGSizeMake(2, 44) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			[self drawBackgroundInRect:dstRect selected:YES];
			return YES;
		}];
	});
	
	return backgroundImage;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	if (self == nil) return nil;
	
	self.cellLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
	self.cellLabel.bezeled = NO;
	self.cellLabel.drawsBackground = NO;
	self.cellLabel.selectable = NO;
	
	[self.content addSubview:self.cellLabel];
	self.backgroundImage = self.sharedBackgroundImage;
	
	return self;
}

- (void)layout {
	[super layout];
	
	CGRect cellLabelFrame = self.bounds;
	cellLabelFrame.size.width = 50;
	self.cellLabel.frame = CGRectOffset(cellLabelFrame, 15, -15);
}

- (void)setCellLabelText:(NSString *)cellLabelText {
	_cellLabelText = cellLabelText;
	self.cellLabel.stringValue = cellLabelText;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	
	if (selected)
		self.backgroundImage = [self sharedSelectedBackgroundImage];
	else
		self.backgroundImage = [self sharedBackgroundImage];
}

@end
