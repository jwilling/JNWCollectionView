#import <Cocoa/Cocoa.h>
#import "JNWCollectionViewCell.h"
#import "RBLScrollView.h"
#import "JNWCollectionViewReusableView.h"
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

// Asks the data source for the view used for the supplementary view for the specified section. The returned
// view must be a subclass of JNWCollectionViewReusableView, otherwise an exception will be thrown.
//
// Note that this data source method will *not* be called unless a class has been registered for a supplementary
// view kind. So if you wish to use supplementary views, you must register at least one class using
// -registerClass:forSupplementaryViewOfKind:withReuseIdentifier:.
- (JNWCollectionViewReusableView *)collectionView:(JNWCollectionView *)collectionView viewForSupplementaryViewOfKind:(NSString *)kind inSection:(NSInteger)section;

@end


// The delegate is the protocol which defines a set of methods with information about mouse clicks and selection.
//
// All delegate methods are optional.
@protocol JNWCollectionViewDelegate <NSObject>
@optional
// Tells the delegate that the mouse is down inside of the item at the specified index path.
- (void)collectionView:(JNWCollectionView *)collectionView mouseDownInItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the mouse click originating from the item at the specified index path is now up.
//
// The mouse up event can occur outside of the originating cell.
- (void)collectionView:(JNWCollectionView *)collectionView mouseUpInItemAtIndexPath:(NSIndexPath *)indexPath;

// Asks the delegate if the item at the specified index should be selected.
- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the item at the specified index has been selected.
- (void)collectionView:(JNWCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// Asks the delegate if the item at the specified index should be deselected.
- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the item at the specified index has been deselected.
- (void)collectionView:(JNWCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the specified index path has been scrolled to.
- (void)collectionView:(JNWCollectionView *)collectionView didScrollToItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface JNWCollectionView : RBLScrollView

@property (nonatomic, weak) id<JNWCollectionViewDelegate> delegate;
@property (nonatomic, weak) id<JNWCollectionViewDataSource> dataSource;

// Calling this method will cause the collection view to clean up all the views and
// recalculate item info. It will then perform a layout pass.
//
// This method should be called after the data source has been set and initial setup on the collection
// view has been completed.
- (void)reloadData;

// In order for cell or supplementary view dequeueing to occur, a class must be registered with the appropriate
// registration method.
//
// The class passed in will be used to initialize a new instance of the view, as needed. The class
// must be a subclass of JNWCollectionViewCell for the cell class, and JNWCollectionViewReusableView
// for the supplementary view class, otherwise an exception will be thrown.
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)registerClass:(Class)supplementaryViewClass forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)reuseIdentifier;

// These methods are used to create or reuse a new view. Cells should not be created manually. Instead,
// these methods should be called with a reuse identifier previously registered using
// -registerClass:forCellWithReuseIdentifier: or -registerClass:forSupplementaryViewOfKind:withReuseIdentifier:.
//
// If a class was not previously registered, the base cell or supplementary view class will be used to create the view.
//
// The identifer must not be nil, otherwise an exception will be thrown.
- (JNWCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWCollectionViewReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)kind withReuseIdentifer:(NSString *)identifier;

@property (nonatomic, strong) JNWCollectionViewLayout *collectionViewLayout;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

// These will be provided in flipped coordinates.
- (CGRect)rectForSupplementaryViewWithKind:(NSString *)kind inSection:(NSInteger)section;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)rectForSection:(NSInteger)section;

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForCell:(JNWCollectionViewCell *)cell;
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;
- (NSIndexSet *)indexesForSectionsInRect:(CGRect)rect;

- (JNWCollectionViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (JNWCollectionViewReusableView *)supplementaryViewForKind:(NSString *)kind reuseIdentifier:(NSString *)reuseIdentifier inSection:(NSInteger)section;
- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleItems;
- (NSArray *)indexPathsForSelectedItems;

@property (nonatomic, assign) BOOL animatesSelection; // TODO

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)selectAllItems;
- (void)deselectAllItems;

- (BOOL)validateIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForNextSelectableItemAfterIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForNextSelectableItemBeforeIndexPath:(NSIndexPath *)indexPath;

@end
