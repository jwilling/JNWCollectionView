//
//  ListHeader.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 3/27/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "ListHeader.h"
#import "DemoImageCache.h"

@interface ListHeader()
@property (nonatomic) NSTextField *headerLabel;
@end

@implementation ListHeader

- initWithFrame:(NSRect)frameRect {

	if (!(self = [super initWithFrame:frameRect])) return nil;
	
	_headerLabel                  = [NSTextField.alloc initWithFrame:CGRectOffset(frameRect, 15, -3)];
	_headerLabel.bezeled          = _headerLabel.drawsBackground = _headerLabel.selectable = NO;
  _headerLabel.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	self.headerLabel.font         = [NSFont boldSystemFontOfSize:13];
	
	[self addSubview:self.headerLabel];
  _headerLabelText = @"";
	[self.headerLabel bind:@"stringValue" toObject:self withKeyPath:@"headerLabelText" options:nil];

  return self;
}

- (void)layout { [super layout]; }

- (BOOL)wantsUpdateLayer { return YES; }

- (void)updateLayer {

	CGSize size = CGSizeMake(1, CGRectGetHeight(self.bounds));

	self.layer.contents = [DemoImageCache.sharedCache cachedImageWithIdentifier:self.className size:size withCreationBlock:^NSImage *(CGSize size) {

    return [NSImage imageWithSize:CGSizeMake(2, 24) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {

      NSColor *start = [NSColor colorWithCalibratedRed:.9  green:.9  blue:.9  alpha:1],
                *end = [NSColor colorWithCalibratedRed:.95 green:.95 blue:.95 alpha:1];

			[[NSGradient.alloc initWithStartingColor:start endingColor:end] drawInRect:dstRect angle:90];
			
			[[start shadowWithLevel:.1] set];
			NSRectFill(NSMakeRect(0, 0, dstRect.size.width, 1));
			return YES;
		}];
	}];	
}

@end
