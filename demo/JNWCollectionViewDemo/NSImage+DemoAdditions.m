//
//  NSImage+DemoAdditions.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "NSImage+DemoAdditions.h"

@implementation NSImage (DemoAdditions)

+ (BOOL) drawBackgroundInRect:(CGRect)dstRect highlighted:(BOOL)highlighted { return [self drawBackgroundInRect:dstRect color:nil highlighted:highlighted]; }

+ (BOOL) drawBackgroundInRect:(CGRect)dstRect color:(NSColor*)c highlighted:(BOOL)highlighted {

	CGRect    b = dstRect;
	CGFloat top = highlighted ? .8 : .81,
       bottom = highlighted ? .7 : .87;

  NSColor * botC = c ? c
                     : [NSColor colorWithCalibratedRed:bottom green:bottom blue:bottom alpha:1],
          * topC = c ? [NSColor colorWithHue:c.hueComponent saturation:c.saturationComponent
                                                            brightness:c.brightnessComponent - .2 alpha:1]
                     : [NSColor colorWithCalibratedRed:top green:top blue:top alpha:1];

  NSGradient *gradient = [NSGradient.alloc initWithColors: @[topC,botC]];
	[gradient drawInRect:b angle:90];
	
	[[NSColor.whiteColor colorWithAlphaComponent:0.6] setFill];
	NSRectFillUsingOperation(CGRectMake(0, b.size.height-1, b.size.width, 1), NSCompositeSourceOver);
	
	[[NSColor.blackColor colorWithAlphaComponent:0.08] setFill];
	NSRectFillUsingOperation(CGRectMake(0, 0, b.size.width, 1), NSCompositeSourceOver);
  return YES;
}

+ (NSImage *)standardGradientImageWithHeight:(CGFloat)height {

	return [NSImage imageWithSize:CGSizeMake(1, height) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
		return [self drawBackgroundInRect:dstRect highlighted:NO];
	}];
}

+ (NSImage *)highlightedGradientImageWithHeight:(CGFloat)height {

	return [NSImage imageWithSize:CGSizeMake(1, height) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
		return [self drawBackgroundInRect:dstRect highlighted:YES];
	}];
}

+ (NSImage *) gradientImageWithHeight:(CGFloat)height color:(NSColor*)c {

	return [NSImage imageWithSize:CGSizeMake(1, height) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
		return [self drawBackgroundInRect:dstRect color:c highlighted:YES];
	}];
}
@end
