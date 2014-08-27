/*
 Copyright (c) 2013, Jonathan Willing. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions
 of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

#import "JNWCollectionViewCell.h"
#import "JNWCollectionViewReusableView.h"
#import "NSIndexPath+JNWAdditions.h"
#import "JNWScrollView.h"

typedef NS_ENUM(NSInteger, JNWCollectionViewScrollPosition) {
	/// Does not scroll, only selects.
	JNWCollectionViewScrollPositionNone,
	/// Scrolls the minimum amount necessary to make visible.
	JNWCollectionViewScrollPositionNearest,
	/// Scrolls the rect to be at the top of the screen, if possible.
	JNWCollectionViewScrollPositionTop,
	/// Center the rect in the center of the screen, if possible.
	JNWCollectionViewScrollPositionMiddle,
	/// Scrolls the rect to be at the bottom of the screen, if possible.
	JNWCollectionViewScrollPositionBottom
};

@class JNWCollectionView;

#pragma mark - Data Source Protocol

/*! 
  The data source is the protocol which defines a set of methods for both information about the data model and the views needed for creating the collection view. The object that conforms to the data source must implement both @c -collectionView:numberOfItemsInSection: and @c -collectionView:cellForItemAtIndexPath:, otherwise an exception will be thrown.
 */
@protocol JNWCollectionViewDataSource <NSObject> @required

/*! Asks the data source how many items are in the section index specified. The first section begins at 0. 
 */
- (NSUInteger)collectionView:(JNWCollectionView*)v numberOfItemsInSection:(NSInteger)s;

/*! Asks the data source for the view that should be used for the cell at the specified index path. The returned view must be non-nil, and it must be a subclass of JNWCollectionViewCell, otherwise an exception will be thrown. 
 */
- (JNWCollectionViewCell *)collectionView:(JNWCollectionView*)v cellForItemAtIndexPath:(NSIndexPath*)p;

@optional
/*! Asks the data source for the number of sections in the collection view.
  @note If this method is not implemented, the collection view will default to 1 section.
 */
- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)v;

/*! Asks the data source for the view used for the supplementary view for the specified section. The returned view must be a subclass of JNWCollectionViewReusableView, otherwise an exception will be thrown.

  @note that this data source method will *not* be called unless a class has been registered for a supplementary view kind. So if you wish to use supplementary views, you must register at least one class using @link -registerClass:forSupplementaryViewOfKind:withReuseIdentifier:.
*/
- (JNWCollectionViewReusableView *)collectionView:(JNWCollectionView *)v viewForSupplementaryViewOfKind:(NSString *)kind inSection:(NSInteger)section;

@end

#pragma mark Delegate Protocol

/*! The delegate is the protocol which defines a set of methods with information about mouse clicks and selection.
  @note All delegate methods are optional.
 */
@protocol JNWCollectionViewDelegate <NSObject> @optional

/// Notifies delegate when the mouse is down inside of the item at the specified index path.
- (void)collectionView:(JNWCollectionView*)v mouseDownInItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate when the the mouse has "entered" or "exited" the item at the specified index path.
- (void)collectionView:(JNWCollectionView*)v mouseEnteredItemAtIndexPath:(NSIndexPath*)iP;
- (void)collectionView:(JNWCollectionView*)v  mouseExitedItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate when the mouse click originating from the item at the specified index path is now up.
/// @note The mouse up event can occur outside of the originating cell.
- (void)collectionView:(JNWCollectionView *)v mouseUpInItemAtIndexPath:(NSIndexPath *)iP;

/// Asks the delegate if the item at the specified index path should be selected.
- (BOOL)collectionView:(JNWCollectionView *)v shouldSelectItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate that the item at the specified index path has been selected.
- (void)collectionView:(JNWCollectionView *)v didSelectItemAtIndexPath:(NSIndexPath *)iP;

/// Asks the delegate if the item at the specified index path should be deselected.
- (BOOL)collectionView:(JNWCollectionView *)v shouldDeselectItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate that the item at the specified index path has been deselected.
- (void)collectionView:(JNWCollectionView *)v didDeselectItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate that the item at the specified index path has been double-clicked.
- (void)collectionView:(JNWCollectionView *)v didDoubleClickItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate that the item at the specified index path has been right-clicked.
- (void)collectionView:(JNWCollectionView *)v didRightClickItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate that the specified index path has been scrolled to.
- (void)collectionView:(JNWCollectionView *)v didScrollToItemAtIndexPath:(NSIndexPath *)iP;

/// Notifies delegate that the cell for the specified index path has been put back into the reuse queue.
- (void)collectionView:(JNWCollectionView *)v didEndDisplayingCell:(JNWCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)iP;

@end

#pragma mark Reloading and customizing

@class JNWCollectionViewLayout;
@interface JNWCollectionView : JNWScrollView

/// The delegate for the collection view.
@property (nonatomic, unsafe_unretained) IBOutlet id<JNWCollectionViewDelegate> delegate;

/// The data source for the collection view. @warning Required.
@property (nonatomic, unsafe_unretained) IBOutlet id<JNWCollectionViewDataSource> dataSource;

/*! @brief Ask collection view to clean up all the views and recalculate item info. It will then perform a layout pass. This method should be called after the data source has been set and initial setup on the collection view has been completed.
 */
- (void)reloadData;

/*! @brief In order for cell or supplementary view dequeueing to occur, a class must be registered with the appropriate registration method. The class passed in will be used to initialize a new instance of the view, as needed. The class must be a subclass of JNWCollectionViewCell for the cell class, and JNWCollectionViewReusableView for the supplementary view class, otherwise an exception will be thrown.
  @note Registering a class or nib are exclusive: registering one will unregister the other.
 */
- (void)registerClass:(Class)supplementaryViewClass forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)reuseId;
- (void)registerClass:(Class)cellClass                                                   forCellWithReuseIdentifier:(NSString *)reuseId;

/*! You can also register a nib instead of a class to be able to dequeue a cell or supplementary view.
  @param nib The nib must contain a top-level object of a subclass of @see JNWCollectionViewCell for the cell, and @see JNWCollectionViewReusableView for the supplementary view, otherwise an exception will be thrown when dequeuing.
  @warning Registering a class or nib are exclusive: registering one will unregister the other.
*/
- (void)registerNib:(NSNib *)cellNib                                                   forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(NSNib *)supplementaryViewNib forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)reuseId;

/*! These methods are used to create or reuse a new view. Cells should not be created manually. Instead, these methods should be called with a reuse identifier previously registered using @c -registerClass:forCellWithReuseIdentifier: or @c -registerClass:forSupplementaryViewOfKind:withReuseIdentifier:.

  If a class was not previously registered, the base cell class will be used to create the view. However, for supplementary views, the class must be registered, otherwise the collection view will not attempt to load any supplementary views for that kind.

  @note The identifer must not be nil, otherwise an exception will be thrown.
 */
- (JNWCollectionViewCell *)                                                 dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWCollectionViewReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)kind withReuseIdentifer:(NSString *)identifier;

/*!  The layout is responsible for providing the positioning and layout attributes for cells and views.
  
  It is also responsible for handling selection changes that are performed via the keyboard. See the documentation in @link JNWCollectionViewLayout.h.
  A valid layout must be set before calling -reloadData, otherwise an exception will be thrown.
  Layouts must not be reused between separate collection view instances. A single layout can be associated with only one collection view at any given time. Defaults to nil.
*/
@property (nonatomic) JNWCollectionViewLayout *collectionViewLayout;

/*! The background color determines what is drawn underneath any cells that might be visible at the time. If this is a repeating pattern image, it will scroll along with the content. Defaults to a white color. 
 */
@property (nonatomic) NSColor *backgroundColor;

/*! Sets whether the collection view draws the background color. If the collection view background color needs to be transparent, this should be disabled. Defaults to YES.
 */
@property (nonatomic) BOOL drawsBackground;

#pragma mark - Information

/// Returns the total number of sections.
@property (readonly) NSInteger numberOfSections;

/// Returns the number of items in the specified section.
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/*! The following methods will return frames in flipped coordinates, where the origin is the top left point in the scroll view. All of these methods will return CGRectZero if an invalid index path or section is specified.
 */
- (CGRect)rectForSupplementaryViewWithKind:(NSString *)kind inSection:(NSInteger)section;
- (CGRect)rectForSection:(NSInteger)section; /// the frame encompassing the cells and views in the specified section

/*! Provides the size of the visible document area in which the collection view is currently displaying cells and other supplementary views.
    @note Equivalent to the size of -documentVisibleRect.
 */
@property (readonly) CGSize visibleSize;

/// Returns the index path for the item at the specified point, otherwise nil if no item is found.
- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;

/// Returns the index path for the specified cell, otherwise returns nil if the cell isn't visible.
- (NSIndexPath *)indexPathForCell:(JNWCollectionViewCell *)cell;

/// Returns an array of all of the index paths contained within the specified frame.
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

/// Returns an index set containing the indexes for all sections that intersect the specified rect.
- (NSIndexSet *)indexesForSectionsInRect:(CGRect)rect;

/// Returns the cell at the specified index path, otherwise returns nil if the index path is invalid or if the cell is not visible.
- (JNWCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)iP;

/*! Returns the supplementary view of the specified kind and reuse identifier in the section, otherwise returns nil if the supplementary view is no longer visible or if the kind and reuse identifier are invalid or have not been previously registered in @see -registerClass:forSupplementaryViewOfKind:reuseIdentifier:.
 */
- (JNWCollectionViewReusableView *)supplementaryViewForKind:(NSString *)kind reuseIdentifier:(NSString *)reuseId inSection:(NSInteger)section;

/// Returns an array of all the currently visible cells. The cells are not guaranteed to be in any order.
@property (readonly) NSArray *visibleCells;

/// Returns the index paths for all the items in the visible rect. Order is not guaranteed.
@property (readonly) NSArray * indexPathsForVisibleItems;

/// Returns the index paths for any selected items. Order is not guaranteed.
@property (readonly) NSArray * indexPathsForSelectedItems;

@property (readonly) NSIndexPath * hoveredItemIndex;

#pragma mark - Selection

/// If set (default is NO), any changes to the backgroundImage or backgroundColor properties of the collection view cell are animated with a crossfade.
@property (nonatomic) BOOL animatesSelection;

/// If set to NO, the collection view will not automatically select cells either through clicks or through keyboard actions. Defaults to YES.
@property (nonatomic) BOOL allowsSelection;

/*! Scrolls the collection view to the item at the specified path, optionally animated. The scroll position determines where the item is positioned on the screen.
 */
- (void)scrollToItemAtIndexPath:(NSIndexPath *)iP atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

/*! Selects the item at the specified index path, deselecting any other selected items in the process, optionally animated.
  The collection view will then scroll to that item in the position as determined by scrollPosition. If no scroll is desired, pass in JNWCollectionViewScrollPositionNone to prevent the scroll..
 */
- (void)selectItemAtIndexPath:(NSIndexPath *)iP atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

/// Selects all items in the collection view.
- (void)selectAllItems;

/// Deselects all items in the collection view.
- (void)deselectAllItems;

@end
