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

@class JNWCollectionView;

// The data source is the protocol which defines a set of methods for both information about the data model
// and the views needed for creating the collection view.
//
// The object that conforms to the data source must implement both `-collectionView:numberOfItemsInSection:`
// and `-collectionView:cellForItemAtIndexPath:`, otherwise an exception will be thrown.
@protocol JNWCollectionViewDataSource <NSObject>
// Asks the data source how many items are in the section index specified. The first section begins at 0.
//
// Required.
- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

// Asks the data source for the view that should be used for the cell at the specified index path. The returned
// view must be non-nil, and it must be a subclass of JNWCollectionViewCell, otherwise an exception will be thrown.
//
// Required.
- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
// Asks the data source for the number of sections in the collection view.
//
// If this method is not implemented, the collection view will default to 1 section.
- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView;

// Asks the data source for the view used for the header or footer for the specified section. The returned
// view must be a subclass of JNWCollectionViewHeaderFooterView, otherwise an exception will be thrown.
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

@property (nonatomic, assign) BOOL animatesSelection; // TODO

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
- (void)selectAllItems;
- (void)deselectAllItems;


- (BOOL)validateIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForNextSelectableItemAfterIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForNextSelectableItemBeforeIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak) id<JNWCollectionViewDelegate> delegate;
@property (nonatomic, weak) id<JNWCollectionViewDataSource> dataSource;

- (void)reloadData;

- (JNWCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWCollectionViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier;

@end