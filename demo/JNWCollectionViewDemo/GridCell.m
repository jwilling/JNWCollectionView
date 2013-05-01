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
	if (selected) {
		self.backgroundImage = [NSImage highlightedGradientImageWithHeight:self.bounds.size.height];
	} else {
		self.backgroundImage = [NSImage standardGradientImageWithHeight:self.bounds.size.height];
	}
}

@end
