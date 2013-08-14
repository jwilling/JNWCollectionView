//
//  JNWCollectionViewGridLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/10/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewLayout.h"

extern NSString * const JNWCollectionViewGridLayoutHeaderIdentifier;
extern NSString * const JNWCollectionViewGridLayoutFooterIdentifier;

@protocol JNWCollectionViewGridLayoutDelegate <NSObject>

@optional
- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

@interface JNWCollectionViewGridLayout : JNWCollectionViewLayout

@property (nonatomic, weak) id<JNWCollectionViewGridLayoutDelegate> delegate;
@property (nonatomic, assign) CGSize itemSize;

@end
