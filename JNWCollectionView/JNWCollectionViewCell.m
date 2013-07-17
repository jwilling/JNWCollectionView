//
//  JNWCollectionViewCell.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewCell.h"
#import "JNWCollectionViewCell+Private.h"
#import "JNWCollectionView+Private.h"
#import <QuartzCore/QuartzCore.h>

@interface JNWCollectionViewCellBackgroundView : NSView
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, weak) JNWCollectionView *collectionView;
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

- (void)setColor:(NSColor *)color {
	_color = color;
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
@property (nonatomic, strong) JNWCollectionViewCellBackgroundView *backgroundView;
@end

@implementation JNWCollectionViewCell

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	
	self.wantsLayer = YES;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;

	
	_contentView = [[NSView alloc] initWithFrame:self.bounds];
	_contentView.wantsLayer = YES;

	_backgroundView = [[JNWCollectionViewCellBackgroundView alloc] initWithFrame:self.bounds];
	
	_crossfadeDuration = 0.25;
	
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
	[self.backgroundView.layer removeAnimationForKey:@"contents"];
	
	// for subclasses
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animate {
	if (animate && self.selected != selected) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
		animation.duration = self.crossfadeDuration;
		[self.backgroundView.layer addAnimation:animation forKey:@"contents"];
	}
	
	self.selected = selected;
}

- (NSDraggingImageComponent *)draggingImageRepresentation {
	NSDraggingImageComponent *component = [[NSDraggingImageComponent alloc]init];
	NSSize imgSize = self.bounds.size;
	
    NSBitmapImageRep *bir = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [bir setSize:imgSize];
	
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:bir];
	
    NSImage *image = [[NSImage alloc] initWithSize:imgSize];
    [image addRepresentation:bir];

	component.contents = image;
    return component;
}

- (void)setCollectionView:(JNWCollectionView *)collectionView {
	_collectionView = collectionView;
	self.backgroundView.collectionView = collectionView;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
	self.backgroundView.color = backgroundColor;
}

- (NSColor *)backgroundColor {
	return self.backgroundView.color;
}

- (void)setBackgroundImage:(NSImage *)backgroundImage {
	self.backgroundView.image = backgroundImage;
}

- (NSImage *)backgroundImage {
	return self.backgroundView.image;
}

- (void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	
	[self.collectionView mouseDownInCollectionViewCell:self withEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	[super mouseDragged:theEvent];
	
	[self.collectionView mouseDraggedInCollectionViewCell:self withEvent:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
	[super mouseUp:theEvent];
	
	[self.collectionView mouseUpInCollectionViewCell:self withEvent:theEvent];
}

#pragma mark NSObject

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; frame = %@; layer = <%@: %p>>", self.class, self, NSStringFromRect(self.frame), self.layer.class, self.layer];
}

@end
