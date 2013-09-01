//
//  NSIndexPath+JNWAdditions.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (JNWAdditions)

+ (instancetype)jnw_indexPathForItem:(NSInteger)item inSection:(NSInteger)section;

@property (nonatomic, readonly) NSInteger item;
@property (nonatomic, readonly) NSInteger section;

@end
