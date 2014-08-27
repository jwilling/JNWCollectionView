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

	if (!(self = [super initWithFrame:frameRect])) return nil;
  [self addSubview:_label = [JNWLabel.alloc initWithFrame:(NSRect){15, 10, frameRect.size.width, 20}]];
  _label.autoresizingMask = NSViewWidthSizable | NSViewMaxXMargin | NSViewMaxYMargin;
  _cellLabelText = @"";
  [self.label bind:@"text" toObject:self withKeyPath:@"cellLabelText" options:nil];
  return self;
}

- (void)setSelected:(BOOL)selected {

	[super setSelected:selected];
  [self updateBackgroundImage];
}
- (void)setHovered:(BOOL)hovered { [super setHovered:hovered]; [self updateBackgroundImage]; }

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
