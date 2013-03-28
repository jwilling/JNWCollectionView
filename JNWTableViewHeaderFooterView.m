//
//  JNWTableViewHeaderFooterView.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWTableViewHeaderFooterView.h"

@implementation JNWTableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithFrame:CGRectZero];
	if (self == nil) return nil;
	_reuseIdentifier = reuseIdentifier;
	self.wantsLayer = YES;
	return self;
}

@end
