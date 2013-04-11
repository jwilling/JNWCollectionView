//
//  JNWCollectionViewGridLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/10/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <JNWCollectionView/JNWCollectionView.h>

@protocol JNWCollectionViewGridLayoutDelegate <NSObject>

- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

@interface JNWCollectionViewGridLayout : JNWCollectionViewLayout

@property (nonatomic, assign) CGSize itemSize;

@end
