
#import "JNWCollectionViewLayout.h"

@class JNWCollectionViewGridLayout;

/// The supplementary view kind identifiers used for the header and the footer.
extern NSString * const JNWCollectionViewGridLayoutHeaderKind;
extern NSString * const JNWCollectionViewGridLayoutFooterKind;

/// The delegate is responsible for returning size information for the grid layout.
@protocol JNWCollectionViewGridLayoutDelegate <NSObject>

@optional

/// Asks the delegate for the size of all the items in the grid layout.
///
/// If this method is implemented, `itemSize` will be set to returned values.
- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView;

/// Asks the delegate for the height of the header or footer in the specified section.
///
/// The default height for both the header and footer is 0.
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

/// Asks the delegate for section insets for a section in the grid layout
///
/// The default is (0, 0, 0, 0).
- (NSEdgeInsets)collectionView:(JNWCollectionView *)collectionView layout:(JNWCollectionViewGridLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

@end

/// A layout subclass that displays items in an evenly spaced grid. All items
/// have the same size, and are evenly spaced apart from each other.
@interface JNWCollectionViewGridLayout : JNWCollectionViewLayout

/// The delegate for the grid layout. The delegate, if needed, should be set before
/// the collection view is reloaded.
@property (nonatomic, unsafe_unretained) id<JNWCollectionViewGridLayoutDelegate> delegate;

/// The size of all the items in the grid layout.
///
/// Any values returned from the delegate method -sizeForItemInCollectionView: will
/// override any value set here.
@property (nonatomic, assign) CGSize itemSize;

/// Choose whether even padding between horizontal items is enabled.
///
/// Default is YES.
@property (nonatomic, assign) BOOL itemPaddingEnabled;

/// The vertical spacing between rows in the grid.
///
/// Defaults to 0.
@property (nonatomic, assign) CGFloat verticalSpacing;

/// Optional margins for items in the grid layout.
///
/// Defaults to 0
@property (nonatomic, assign) CGFloat itemHorizontalMargin;

@end
