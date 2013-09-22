/*
 Copyright (c) 2013, Jonathan Willing. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions
 of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

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

- (void)willLayoutWithFrame:(CGRect)frame {
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

- (void)mouseUp:(NSEvent *)theEvent {
	[super mouseUp:theEvent];
	
	[self.collectionView mouseUpInCollectionViewCell:self withEvent:theEvent];
	
	if (theEvent.clickCount == 2) {
		[self.collectionView doubleClickInCollectionViewCell:self withEvent:theEvent];
	}
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    [self.collectionView rightClickInCollectionViewCell:self withEvent:theEvent];
}

#pragma mark NSObject

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; frame = %@; layer = <%@: %p>>", self.class, self, NSStringFromRect(self.frame), self.layer.class, self.layer];
}

@end
