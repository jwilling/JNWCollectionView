#import <Cocoa/Cocoa.h>
#import "JNWCollectionViewCell.h"
#import "RBLScrollView.h"
#import "JNWCollectionViewHeaderFooterView.h"
#import "NSIndexPath+JNWAdditions.h"
#import "JNWCollectionViewLayout.h"

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
- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)collectionView:(JNWCollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)collectionView:(JNWCollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath; // TODO

- (void)collectionView:(JNWCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)collectionView:(JNWCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // TODO
@end


@interface JNWCollectionView : RBLScrollView


@property (nonatomic, strong) JNWCollectionViewLayout *collectionViewLayout;

@property (nonatomic, assign) JNWCollectionViewScrollDirection scrollDirection;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

// These will be provided in flipped coordinates.
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForFooterInSection:(NSInteger)section;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)rectForSection:(NSInteger)section;

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForCell:(JNWCollectionViewCell *)cell;
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

- (JNWCollectionViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleItems;
- (NSArray *)indexPathsForSelectedItems;
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