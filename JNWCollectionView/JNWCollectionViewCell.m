
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

- initWithFrame:(NSRect)frameRect {

  if (!(self = [super initWithFrame:frameRect])) return nil;
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
	self.layer.contents = self.image;
	self.layer.backgroundColor = self.color.CGColor;
}

@end

@interface JNWCollectionViewCell()
@property (nonatomic, strong) JNWCollectionViewCellBackgroundView *backgroundView;
@end

@implementation JNWCollectionViewCell {  NSTrackingArea *trackingArea; }
@synthesize contentView = _contentView;

- (instancetype)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect])) return nil;	
	self.wantsLayer = YES;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;

	_backgroundView = [[JNWCollectionViewCellBackgroundView alloc] initWithFrame:self.bounds];
	_backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	
	_crossfadeDuration = 0.25;
	
	[self addSubview:_backgroundView positioned:NSWindowBelow relativeTo:_contentView];
	
	return self;
}

- (void)prepareForReuse {
	[self.backgroundView.layer removeAllAnimations];
	
	// for subclasses
}

- (void)willLayoutWithFrame:(CGRect)frame {
	// for subclasses
}

- (NSView *)contentView {
	if (_contentView == nil) {
		_contentView = [[NSView alloc] initWithFrame:self.bounds];
		[self configureContentView:_contentView];
	}
	
	return _contentView;
}

- (void)setContentView:(NSView *)contentView {
	if (_contentView) {
		[_contentView removeFromSuperview];
	}
	
	_contentView = contentView;
	[self configureContentView:contentView];
}

- (void)configureContentView:(NSView *)contentView {
	contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	contentView.wantsLayer = YES;
	
	[self addSubview:contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animate {
	if (animate && self.selected != selected) {
		CATransition   * transition = CATransition.animation;
		transition.duration         = self.crossfadeDuration;
		[self.backgroundView.layer addAnimation:transition forKey:@"fade"];
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

- (void)updateTrackingAreas { [super updateTrackingAreas];

  trackingArea && [self.trackingAreas containsObject:trackingArea] ?:
                  [self              addTrackingArea:trackingArea = trackingArea ?:

  [NSTrackingArea.alloc initWithRect:NSZeroRect
                             options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited
                               owner:self userInfo:nil]];
}

- (void) mouseEntered:(NSEvent*)e {	[self setHovered:YES withEvent:e];  }
- (void)  mouseExited:(NSEvent*)e { [self setHovered:NO  withEvent:e];  }
- (void)  scrollWheel:(NSEvent*)e { [super scrollWheel:e];

  if (self.hovered && !NSPointInRect([self convertPoint:e.locationInWindow fromView:nil],self.frame))
    [self setHovered:NO withEvent:e];
}

- (void)setHovered:(BOOL)h withEvent:(NSEvent*)e { if (self.hovered == h) return;

  (self.hovered = h) ? [self.collectionView mouseEnteredCollectionViewCell:self withEvent:e]
                     : [self.collectionView mouseExitedCollectionViewCell:self  withEvent:e];
}

- (void)     mouseDown:(NSEvent*)theEvent {
	[super mouseDown:theEvent];
	
	[self.collectionView mouseDownInCollectionViewCell:self withEvent:theEvent];
}

- (void)       mouseUp:(NSEvent *)theEvent {
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
