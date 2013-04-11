//
//  JNWCollectionViewListLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <JNWCollectionView/JNWCollectionView.h>

@protocol JNWCollectionViewListLayoutDelegate <NSObject>

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

@interface JNWCollectionViewListLayout : JNWCollectionViewLayout

@end
