//
//  JNWTableViewHeaderFooterView.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewHeaderFooterView.h"

@implementation JNWCollectionViewHeaderFooterView

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	self.wantsLayer = YES;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
	return self;
}

@end
