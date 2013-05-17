//
//  JNWCollectionViewLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JNWCollectionViewDirection) {
	JNWCollectionViewDirectionLeft,
	JNWCollectionViewDirectionRight,
	JNWCollectionViewDirectionUp,
	JNWCollectionViewDirectionDown
};

@interface JNWCollectionViewLayoutAttributes : NSObject
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat alpha;
@end

@class JNWCollectionView;
@interface JNWCollectionViewLayout : NSObject

@property (nonatomic, weak, readonly) JNWCollectionView *collectionView;

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

- (void)prepareLayout;

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (JNWCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemInSection:(NSInteger)section kind:(NSString *)kind;

- (BOOL)wantsIndexPathsForItemsInRect;
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

// Subclasses must implement this method for arrowed selection to work.
- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)direction currentIndexPath:(NSIndexPath *)currentIndexPath;

@end
