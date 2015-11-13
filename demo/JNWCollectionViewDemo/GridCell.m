//
//  GridCell.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/15/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "GridCell.h"
#import "NSImage+DemoAdditions.h"
#import "DemoImageCache.h"
#import "Label.h"

@implementation GridCell

- (void)setImage:(NSImage *)image {
	_image = image;
	self.backgroundImage = image;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self updateBackgroundImage];
}

- (void)updateBackgroundImage {
	NSImage *image = nil;
	
	if (self.selected) {
		NSString *identifier = [NSString stringWithFormat:@"%@%x", NSStringFromClass(self.class), self.selected];
		CGSize size = CGSizeMake(1, CGRectGetHeight(self.bounds));
		image = [DemoImageCache.sharedCache cachedImageWithIdentifier:identifier size:size withCreationBlock:^NSImage * (CGSize size) {
			return [NSImage highlightedGradientImageWithHeight:size.height];
		}];
	} else {
		image = self.image;
	}
	
	if (self.backgroundImage != image) {
		self.backgroundImage = image;
	}
}

@end
