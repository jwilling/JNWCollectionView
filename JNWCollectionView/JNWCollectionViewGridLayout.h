//
//  JNWCollectionViewGridLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/10/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewLayout.h"

// The supplementary view kind identifiers used for the header and the footer.
extern NSString * const JNWCollectionViewGridLayoutHeaderKind;
extern NSString * const JNWCollectionViewGridLayoutFooterKind;

// The delegate is responsible for returning size information for the grid layout.
@protocol JNWCollectionViewGridLayoutDelegate <NSObject>

@optional

// Asks the delegate for the size of all the items in the grid layout.
//
// If this method is implemented, `itemSize` will be set to returned values.
- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView;

// Asks the delegate for the height of the header or footer in the specified section.
//
// The default height for both the header and footer is 0.
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

// A layout subclass that displays items in an evenly spaced grid. All items
// have the same size, and are evenly spaced apart from each other.
@interface JNWCollectionViewGridLayout : JNWCollectionViewLayout

// The delegate for the grid layout. The delegate, if needed, should be set before
// the collection view is reloaded.
@property (nonatomic, unsafe_unretained) id<JNWCollectionViewGridLayoutDelegate> delegate;

// The size of all the items in the grid layout.
//
// Any values returned from the delegate method -sizeForItemInCollectionView: will
// override any value set here.
@property (nonatomic, assign) CGSize itemSize;

@end
