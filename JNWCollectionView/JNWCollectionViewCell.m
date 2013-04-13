//
//  JNWTableViewCell.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewCell.h"
#import "JNWCollectionViewCell+Private.h"
#import "JNWCollectionView+Private.h"

@interface JNWCollectionViewCellBackgroundView : NSView
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSImage *image;
@end

@implementation JNWCollectionViewCellBackgroundView

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

@interface JNWCollectionViewCell()
@property (nonatomic, strong, readwrite) NSView *contentView;
@property (nonatomic, strong, readwrite) JNWCollectionViewCellBackgroundView *backgroundView;
@end

@implementation JNWCollectionViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithFrame:CGRectZero];
	if (self == nil) return nil;
	
	self.wantsLayer = YES;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;

	_reuseIdentifier = reuseIdentifier.copy;
	
	_contentView = [[NSView alloc] initWithFrame:self.bounds];
	_contentView.wantsLayer = YES;

	_backgroundView = [[JNWCollectionViewCellBackgroundView alloc] initWithFrame:self.bounds];
	
	[self addSubview:_contentView];
	[self addSubview:_backgroundView positioned:NSWindowBelow relativeTo:_contentView];
	
	
	return self;
}

- (void)layout {
	[super layout];
	
	self.contentView.frame = self.bounds;
	self.backgroundView.frame = self.bounds;
}

- (void)prepareForReuse {
	// for subclasses
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
	[(JNWCollectionViewCellBackgroundView *)self.backgroundView setColor:backgroundColor];
}

- (void)setBackgroundImage:(NSImage *)backgroundImage {
	[(JNWCollectionViewCellBackgroundView *)self.backgroundView setImage:backgroundImage];
}

- (void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	
	[self.collectionView mouseDownInCollectionViewCell:self withEvent:theEvent];
}

@end
