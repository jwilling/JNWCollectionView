//
//  NSIndexPath+JNWAdditions.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (JNWAdditions)

+ (instancetype)jnw_indexPathForItem:(NSUInteger)row inSection:(NSUInteger)section;

+ (instancetype)jnw_indexPathByIncrementingRow:(NSIndexPath *)indexPath withCurrentSectionNumberOfRows:(NSInteger)currentSectionRows;
+ (instancetype)jnw_indexPathByDecrementingRow:(NSIndexPath *)indexPath withPreviousSectionNumberOfRows:(NSInteger)previousSectionRows;

@property (nonatomic, readonly) NSInteger item;
@property (nonatomic, readonly) NSInteger section;

@end
