//
//  NSIndexPath+JNWAdditions.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "NSIndexPath+JNWAdditions.h"

@implementation NSIndexPath (JNWAdditions)

+ (instancetype)jnw_indexPathForItem:(NSUInteger)item inSection:(NSUInteger)section {
	NSUInteger indexPath[2] = { section , item };
	return [self indexPathWithIndexes:indexPath length:2];
}

- (NSInteger)section {
	return [self indexAtPosition:0];
}


- (NSInteger)item {
	return [self indexAtPosition:1];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:NSIndexPath.class])
		if (self.section == [(NSIndexPath *)object section] && self.item == [(NSIndexPath *)object item])
			return YES;
		
	return NO;
}

@end
