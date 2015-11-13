//
//  Label.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 11/12/15.
//  Copyright © 2015 AppJon. All rights reserved.
//

#import "Label.h"

@implementation Label

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	[self commonInit];
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	[self commonInit];
	
	return self;
}

- (void)commonInit {
	self.bordered = NO;
	self.editable = NO;
	self.selectable = NO;
	self.drawsBackground = NO;
}

@end
