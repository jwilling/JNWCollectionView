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
@property (nonatomic, strong) JNWLabel *label;
@end

@implementation ListCell

- (instancetype)initWithFrame:(NSRect)frameRect {

	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	
	self.label = [[JNWLabel alloc] initWithFrame:CGRectZero];
}
- (void)layout {
	[super layout];
	
	CGRect labelRect = CGRectMake(15, 10, 100, 20);
	if (!CGRectEqualToRect(labelRect, self.label.frame)) {
		self.label.frame = labelRect;
	}
}

- (void)setCellLabelText:(NSString *)cellLabelText { _cellLabelText = self.label.text = cellLabelText; }

- (void)setCellLabelText:(NSString *)cellLabelText {
	_cellLabelText = cellLabelText;
	self.label.text = cellLabelText;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
- (void)setHovered:(BOOL)hovered { [super setHovered:hovered]; [self updateBackgroundImage]; }
}

- (void)updateBackgroundImage {
	NSString *identifier = [NSString stringWithFormat:@"%@%x%x%@", self.className, self.selected, self.hovered,self.backgroundColor.description];
	CGSize size = CGSizeMake(1, CGRectGetHeight(self.bounds));
	self.backgroundImage  = [DemoImageCache.sharedCache cachedImageWithIdentifier:identifier size:size withCreationBlock:^NSImage * (CGSize size) {
    return self.selected  ? [NSImage highlightedGradientImageWithHeight:size.height] :
            self.hovered  ? [NSImage gradientImageWithHeight:size.height color:self.backgroundColor]
                          : [NSImage standardGradientImageWithHeight:size.height];
  }];
}

@end
