//
//  NSIndexPath+JNWAdditions.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

// Additions for NSIndexPath that provide easier mapping to items and sections.
@interface NSIndexPath (JNWAdditions)

// Creates a new index path with the specified item and section.
+ (instancetype)jnw_indexPathForItem:(NSInteger)item inSection:(NSInteger)section;

// The index path item.
@property (nonatomic, readonly) NSInteger jnw_item;

// The index path section.
@property (nonatomic, readonly) NSInteger jnw_section;

@end
