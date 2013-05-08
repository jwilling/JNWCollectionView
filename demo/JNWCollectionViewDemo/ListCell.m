//
//  TableViewCell.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "ListCell.h"
#import "NSImage+DemoAdditions.h"
#import "JNWLabel.h"

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
	
	if (selected)
		self.backgroundImage = [NSImage highlightedGradientImageWithHeight:self.bounds.size.height];
	else
		self.backgroundImage = [NSImage standardGradientImageWithHeight:self.bounds.size.height];
}

@end
