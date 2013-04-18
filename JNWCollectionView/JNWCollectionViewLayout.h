//
//  JNWCollectionViewLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JNWCollectionViewMoveDirection) {
	JNWCollectionViewMoveDirectionLeft,
	JNWCollectionViewMoveDirectionRight,
	JNWCollectionViewMoveDirectionUp,
	JNWCollectionViewMoveDirectionDown
};

@class JNWCollectionView;
@interface JNWCollectionViewLayout : NSObject

@property (nonatomic, weak, readonly) JNWCollectionView *collectionView;

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

- (void)prepareLayout;

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)rectForHeaderAtIndex:(NSInteger)index;
- (CGRect)rectForFooterAtIndex:(NSInteger)index;


- (BOOL)wantsIndexPathsForItemsInRect;
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

- (NSIndexPath *)indexPathForItemAfterMove:(JNWCollectionViewMoveDirection)move withCurrentIndexPath:(NSIndexPath *)currentIndexPath;

@end
