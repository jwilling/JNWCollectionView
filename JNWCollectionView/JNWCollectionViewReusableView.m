
#import "JNWCollectionViewReusableView.h"
#import "JNWCollectionViewReusableView+Private.h"

@implementation JNWCollectionViewReusableView

- (instancetype)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect])) return nil;	self.wantsLayer = YES;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
	return self;
}

@end
