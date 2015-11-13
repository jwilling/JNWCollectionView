//
//  ListCell.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "ListCell.h"
#import "NSImage+DemoAdditions.h"
#import "DemoImageCache.h"
#import "Label.h"

@interface ListCell()
@property (nonatomic, strong) Label *label;
@end

@implementation ListCell

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	
	self.label = [[Label alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.label];
	
	return self;
}

- (void)layout {
	[super layout];
	
	CGRect labelRect = CGRectMake(15, 10, 100, 20);
	if (!CGRectEqualToRect(labelRect, self.label.frame)) {
		self.label.frame = labelRect;
	}
}

- (void)setCellLabelText:(NSString *)cellLabelText {
	_cellLabelText = cellLabelText;
	self.label.stringValue = cellLabelText;
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
