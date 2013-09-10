//
//  NSIndexPath+JNWAdditions.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "NSIndexPath+JNWAdditions.h"

@implementation NSIndexPath (JNWAdditions)

+ (instancetype)jnw_indexPathForItem:(NSInteger)item inSection:(NSInteger)section {
	NSUInteger indexPath[2] = { section , item };
	return [self indexPathWithIndexes:indexPath length:2];
}

- (NSInteger)jnw_section {
	return [self indexAtPosition:0];
}


- (NSInteger)jnw_item {
	return [self indexAtPosition:1];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:NSIndexPath.class]) {
		if (self.jnw_section == [(NSIndexPath *)object jnw_section] && self.jnw_item == [(NSIndexPath *)object jnw_item]) {
			return YES;
		}
	}

	return NO;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"<%@: %p; section = %ld; item = %ld>", self.class, self, self.jnw_section, self.jnw_item];
}

@end
