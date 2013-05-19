//
//  ListCell.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "ListCell.h"
#import "NSImage+DemoAdditions.h"
#import "JNWLabel.h"
#import "DemoImageCache.h"

@interface ListCell()
@property (nonatomic, strong) JNWLabel *cellLabel;
@end

@implementation ListCell

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	
	self.cellLabel = [[JNWLabel alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.cellLabel];
	
	return self;
}

- (void)layout {
	[super layout];
	
	CGRect cellLabelFrame = self.bounds;
	cellLabelFrame.size.width = 50;
	self.cellLabel.frame = CGRectOffset(cellLabelFrame, 15, -15);
}

- (void)setCellLabelText:(NSString *)cellLabelText {
	_cellLabelText = cellLabelText;
	self.cellLabel.text = cellLabelText;
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
