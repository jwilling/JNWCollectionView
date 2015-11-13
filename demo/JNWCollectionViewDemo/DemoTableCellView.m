//
//  DemoTableCellView.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "DemoTableCellView.h"
#import "NSImage+DemoAdditions.h"
#import "DemoImageCache.h"
#import "Label.h"

@interface DemoTableCellView()
@property (nonatomic, strong) Label *label;
@end

@implementation DemoTableCellView

- (void)commonInit {
	self.wantsLayer = YES;
	self.layer.backgroundColor = [NSColor redColor].CGColor;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
	
	self.label = [[Label alloc] initWithFrame:self.bounds];
	self.label.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self addSubview:self.label];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self == nil) return nil;
	[self commonInit];
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
	[self commonInit];
    return self;
}

- (void)setLabelText:(NSString *)labelText {
	_labelText = labelText;
	
	self.label.stringValue = labelText;
}

- (BOOL)wantsUpdateLayer {
	return YES;
}

- (void)updateLayer {
	NSString *identifier = NSStringFromClass(self.class);
	CGSize size = CGSizeMake(1, CGRectGetHeight(self.bounds));
	self.layer.contents = [DemoImageCache.sharedCache cachedImageWithIdentifier:identifier size:size withCreationBlock:^NSImage * (CGSize size) {
		return [NSImage standardGradientImageWithHeight:size.height];
	}];
}

@end
