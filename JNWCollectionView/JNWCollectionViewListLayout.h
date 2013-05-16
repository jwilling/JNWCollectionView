//
//  JNWCollectionViewListLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <JNWCollectionView/JNWCollectionView.h>

extern NSString * const JNWCollectionViewListLayoutHeaderIdentifier;
extern NSString * const JNWCollectionViewListLayoutFooterIdentifier;

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
