//
//  JNWCollectionView+Private.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionView.h"

@class JNWCollectionViewCell;
@interface JNWCollectionView ()

- (void)mouseDownInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;
- (void)mouseDraggedInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;
- (void)mouseUpInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;

- (NSString *)kindForSupplementaryViewIdentifier:(NSString *)identifier;
- (NSArray *)allSupplementaryViewIdentifiers;

@end
