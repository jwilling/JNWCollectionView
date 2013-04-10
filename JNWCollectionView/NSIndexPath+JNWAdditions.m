//
//  NSIndexPath+JNWAdditions.m
//  JNWTableViewDemo
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

+ (instancetype)jnw_indexPathByIncrementingRow:(NSIndexPath *)indexPath withCurrentSectionNumberOfRows:(NSInteger)currentSectionRows {
	if (indexPath == nil) return nil;
	NSInteger row = indexPath.item + 1;
	NSInteger section = indexPath.section;
	if (row >= currentSectionRows) {
		section += 1;
		row = 0;
	}
	return [self jnw_indexPathForItem:row inSection:section];
}

+ (instancetype)jnw_indexPathByDecrementingRow:(NSIndexPath *)indexPath withPreviousSectionNumberOfRows:(NSInteger)previousSectionRows {
	if (indexPath == nil) return nil;
	NSInteger row = indexPath.item - 1;
	NSInteger section = indexPath.section;
	if (row < 0) {
		section -= 1;
		row = previousSectionRows - 1; // will be invalid if the previous section has 0 rows
	}
	return [self jnw_indexPathForItem:row inSection:section];
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
