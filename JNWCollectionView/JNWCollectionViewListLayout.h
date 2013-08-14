//
//  JNWCollectionViewListLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewLayout.h"

extern NSString * const JNWCollectionViewListLayoutHeaderKind;
extern NSString * const JNWCollectionViewListLayoutFooterKind;

@protocol JNWCollectionViewListLayoutDelegate <NSObject>

@optional
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

@interface JNWCollectionViewListLayout : JNWCollectionViewLayout

@property (nonatomic, assign) id<JNWCollectionViewListLayoutDelegate> delegate;
@property (nonatomic, assign) CGFloat rowHeight;

@end
