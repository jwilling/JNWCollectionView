//
//  ListMarker.m
//  JNWCollectionViewDemo
//
//  Created by Marc Haisenko on 09.10.13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "ListMarker.h"

@implementation ListMarker

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor blueColor] set];
	NSRectFill(dirtyRect);
}

@end
