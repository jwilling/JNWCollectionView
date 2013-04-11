//
//  JNWCollectionViewGridLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/10/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <JNWCollectionView/JNWCollectionView.h>

@class JNWCollectionView;
@protocol JNWCollectionViewGridLayoutDelegate <NSObject>

- (CGSize)collectionView:(JNWCollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

@interface JNWCollectionViewGridLayout : JNWCollectionViewLayout

//@property (nonatomic, assign) CGFloat minimumItemVerticalSeparation;
@property (nonatomic, assign) CGFloat minimumItemHorizontalSeparation;

@end
