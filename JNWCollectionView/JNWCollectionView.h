#import <Cocoa/Cocoa.h>
#import "JNWCollectionViewCell.h"
#import "RBLScrollView.h"
#import "JNWCollectionViewHeaderFooterView.h"
#import "NSIndexPath+JNWAdditions.h"

typedef NS_ENUM(NSInteger, JNWCollectionViewScrollPosition) {
	JNWCollectionViewScrollPositionNone, // does not scroll, only selects
	JNWCollectionViewScrollPositionNearest,
	JNWCollectionViewScrollPositionTop,
	JNWCollectionViewScrollPositionMiddle,
	JNWCollectionViewScrollPositionBottom
};

typedef NS_ENUM(NSInteger, JNWCollectionViewScrollDirection) {
	JNWCollectionViewScrollDirectionVertical,
	JNWCollectionViewScrollDirectionHorizontal
};

@class JNWCollectionView;
@protocol JNWCollectionViewDataSource <NSObject>
- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView;
- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForHeaderInSection:(NSInteger)section;
- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForFooterInSection:(NSInteger)section;
@end

@protocol JNWCollectionViewDelegate <NSObject>
@optional
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)section;

- (CGFloat)collectionView:(JNWCollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView widthForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView widthForFooterInSection:(NSInteger)section;

// Implemented in place of -collectionView:heightForItemAtIndexPath, for when a width needs to be specified.
//
// If both are implemented, this will take priority over -collectionView:heightForItemAtIndexPath.
//
// If not implemented, the width defaults to the collection view's width.
- (CGSize)collectionView:(JNWCollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)collectionView:(JNWCollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)collectionView:(JNWCollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath; // TODO

- (void)collectionView:(JNWCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)collectionView:(JNWCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
@end


@interface JNWCollectionView : RBLScrollView


// If variable row heights are not needed, setting the row height
// here will have significant performance benefits if you have many
// rows in your table view.
//
// Note that this value will be ignored if collectionView:heightForRowAtIndexPath:
// is implemented.
//
// Defaults to 44.
//@property (nonatomic, assign) CGFloat rowHeight;


@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat itemVerticalPadding;
@property (nonatomic, assign) CGFloat itemHorizontalPadding;

@property (nonatomic, assign) JNWCollectionViewScrollDirection scrollDirection;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

// These will be provided in flipped coordinates.
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForFooterInSection:(NSInteger)section;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForCell:(JNWCollectionViewCell *)cell;
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

- (JNWCollectionViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleItems;
- (JNWCollectionViewHeaderFooterView *)headerViewForSection:(NSInteger)section;
- (JNWCollectionViewHeaderFooterView *)footerViewForSection:(NSInteger)section;

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

@property (nonatomic, weak) id<JNWCollectionViewDelegate> delegate;
@property (nonatomic, weak) id<JNWCollectionViewDataSource> dataSource;

- (void)reloadData;

- (JNWCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWCollectionViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier;

@end