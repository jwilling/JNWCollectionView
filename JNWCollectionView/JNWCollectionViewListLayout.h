
#import "JNWCollectionViewLayout.h"

/// The supplementary view kind identifiers used for the header and the footer.
extern NSString * const JNWCollectionViewListLayoutHeaderKind;
extern NSString * const JNWCollectionViewListLayoutFooterKind;

/// The delegate is responsible for returning size information for the list layout.
@protocol JNWCollectionViewListLayoutDelegate <NSObject>

@optional

/// Asks the delegate for the size of the row at the specified index path.
///
/// Note that if all rows are the same height, this method should not be implemented.
/// Instead, `rowHeight` should be set manually for performance improvements.
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/// Asks the delegate for the height of the header or footer in the specified section.
///
/// The default height for both the header and footer is 0.
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

/// A layout subclass that displays items in a vertical list with rows of
/// items, similar to a table view.
@interface JNWCollectionViewListLayout : JNWCollectionViewLayout

/// The delegate for the list layout. The delegate, if needed, should be set before
/// the collection view is reloaded.
@property (nonatomic, unsafe_unretained) id<JNWCollectionViewListLayoutDelegate> delegate;

/// The height of all rows in the list. If the row heights for all items are
/// the same, setting this property directly instead of using the delegate method will
/// yield performance gains.
///
/// However, if the delegate method -collectionView:heightForRowAtIndexPath: is
/// implemented, it will take precedence over any value set here.
@property (nonatomic) CGFloat rowHeight;

/// The spacing between any adjacent cells.
///
/// Defaults to 0.
@property (nonatomic) CGFloat verticalSpacing;

/// If enabled, the headers will stick to the top of the visible area while
/// the section is still visible.
///
/// Defaults to NO.
@property (nonatomic) BOOL stickyHeaders;

@end
