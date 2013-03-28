//
//  NSIndexPath+JNWAdditions.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (JNWAdditions)

+ (instancetype)jnw_indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section;

@property (nonatomic, readonly) NSUInteger row;
@property (nonatomic, readonly) NSUInteger section;

@end
