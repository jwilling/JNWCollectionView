//
//  NSIndexPath+JNWAdditions.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "NSIndexPath+JNWAdditions.h"

@implementation NSIndexPath (JNWAdditions)

+ (instancetype)jnw_indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section {
	NSUInteger indexPath[2] = { section , row };
	return [self indexPathWithIndexes:indexPath length:2];
}

- (NSUInteger)section {
	return [self indexAtPosition:0];
}


- (NSUInteger)row {
	return [self indexAtPosition:1];
}

@end
