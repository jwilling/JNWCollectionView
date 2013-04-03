//
//  JNWTableViewCell.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWTableViewCell.h"
#import "JNWTableViewCell+Private.h"
#import "JNWTableView+Private.h"

@interface JNWTableViewCellBackgroundView : NSView
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSImage *image;
@end

@implementation JNWTableViewCellBackgroundView

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	self.wantsLayer = YES;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
	return self;
}

- (void)setImage:(NSImage *)image {
	_image = image;
	[self setNeedsDisplay:YES];
}

- (void)setFrame:(NSRect)frameRect {
	if (CGRectEqualToRect(self.frame, frameRect))
		return;

	[super setFrame:frameRect];
	[self setNeedsDisplay:YES];
}

- (BOOL)wantsUpdateLayer {
	return YES;
}

- (void)updateLayer {
	if (self.image != nil) {
		self.layer.contents = self.image;
	} else if (self.color != nil) {
		self.layer.backgroundColor = self.color.CGColor;
	}
}

@end

@interface JNWTableViewCell()
@property (nonatomic, strong, readwrite) NSView *content;
@property (nonatomic, strong, readwrite) JNWTableViewCellBackgroundView *backgroundView;
@end

@implementation JNWTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithFrame:CGRectZero];
	if (self == nil) return nil;
	
	self.wantsLayer = YES;
	_reuseIdentifier = reuseIdentifier.copy;
	
	self.content = [[NSView alloc] initWithFrame:self.bounds];
	self.backgroundView = [[JNWTableViewCellBackgroundView alloc] initWithFrame:self.bounds];
	
	self.content.wantsLayer = YES;
	
	[self addSubview:self.content];
	[self addSubview:self.backgroundView positioned:NSWindowBelow relativeTo:self.content];
	
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
	
	return self;
}

- (void)layout {
	[super layout];
	
	self.content.frame = self.bounds;
	self.backgroundView.frame = self.bounds;
}

- (void)prepareForReuse {
	// for subclasses
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
	self.backgroundView.color = backgroundColor;
}

- (void)setBackgroundImage:(NSImage *)backgroundImage {
	self.backgroundView.image = backgroundImage;
}

- (void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	
	[self.tableView mouseDownInTableViewCell:self withEvent:theEvent];
}

@end
