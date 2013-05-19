//
//  GridCell.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/15/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "GridCell.h"
#import "JNWLabel.h"
#import "NSImage+DemoAdditions.h"
#import "DemoImageCache.h"

@interface GridCell()
@property (nonatomic, strong) JNWLabel *label;
@end

@implementation GridCell

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	
	self.label = [[JNWLabel alloc] initWithFrame:CGRectZero];
	[self addSubview:self.label];
	
	return self;
}

- (void)setLabelText:(NSString *)labelText {
	_labelText = labelText;
	self.label.text = labelText;
}

- (void)layout {
	[super layout];
	
	CGRect labelRect = self.bounds;
	if (!CGRectEqualToRect(labelRect, self.label.frame)) {
		self.label.frame = labelRect;
	}
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self updateBackgroundImage];
}

- (void)updateBackgroundImage {
	NSString *identifier = [NSString stringWithFormat:@"%@%x", NSStringFromClass(self.class), self.selected];
	CGSize size = CGSizeMake(1, CGRectGetHeight(self.bounds));
	self.backgroundImage = [DemoImageCache.sharedCache cachedImageWithIdentifier:identifier size:size withCreationBlock:^NSImage * (CGSize size) {
		if (self.selected)
			return [NSImage highlightedGradientImageWithHeight:size.height];
		return [NSImage standardGradientImageWithHeight:size.height];
	}];
}

@end
