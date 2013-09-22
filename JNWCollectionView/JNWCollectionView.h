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

#import <Cocoa/Cocoa.h>
#import "JNWCollectionViewCell.h"
#import "JNWCollectionViewReusableView.h"
#import "NSIndexPath+JNWAdditions.h"
#import "JNWScrollView.h"

typedef NS_ENUM(NSInteger, JNWCollectionViewScrollPosition) {
	JNWCollectionViewScrollPositionNone, // does not scroll, only selects
	JNWCollectionViewScrollPositionNearest, // scrolls the minimum amount necessary to make visible
	JNWCollectionViewScrollPositionTop, // scrolls the rect to be at the top of the screen, if possible
	JNWCollectionViewScrollPositionMiddle, // center the rect in the center of the screen, if possible
	JNWCollectionViewScrollPositionBottom // scrolls the rect to be at the bottom of the screen, if possible
};

@class JNWCollectionView;

#pragma mark - Data Source Protocol

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

#pragma mark Delegate Protocol

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

// Asks the delegate if the item at the specified index path should be selected.
- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the item at the specified index path has been selected.
- (void)collectionView:(JNWCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// Asks the delegate if the item at the specified index path should be deselected.
- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the item at the specified index path has been deselected.
- (void)collectionView:(JNWCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the item at the specified index path has been double-clicked.
- (void)collectionView:(JNWCollectionView *)collectionView didDoubleClickItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the item at the specified index path has been right-clicked.
- (void)collectionView:(JNWCollectionView *)collectionView didRightClickItemAtIndexPath:(NSIndexPath *)indexPath;

// Tells the delegate that the specified index path has been scrolled to.
- (void)collectionView:(JNWCollectionView *)collectionView didScrollToItemAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark Reloading and customizing

@class JNWCollectionViewLayout;
@interface JNWCollectionView : JNWScrollView

// The delegate for the collection view.
@property (nonatomic, unsafe_unretained) id<JNWCollectionViewDelegate> delegate;

// The data source for the collection view.
//
// Required.
@property (nonatomic, unsafe_unretained) id<JNWCollectionViewDataSource> dataSource;

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
// If a class was not previously registered, the base cell class will be used to create the view.
// However, for supplementary views, the class must be registered, otherwise the collection view
// will not attempt to load any supplementary views for that kind.
//
// The identifer must not be nil, otherwise an exception will be thrown.
- (JNWCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWCollectionViewReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)kind withReuseIdentifer:(NSString *)identifier;

// The layout is responsible for providing the positioning and layout attributes for cells and views.
// It is also responsible for handling selection changes that are performed via the keyboard. See the
// documentation in JNWCollectionViewLayout.h.
//
// A valid layout must be set before calling -reloadData, otherwise an exception will be thrown.
//
// Defaults to nil.
@property (nonatomic, strong) JNWCollectionViewLayout *collectionViewLayout;

// The background color determines what is drawn underneath any cells that might be visible
// at the time. This is different from NSScrollView's background color, which only sets the
// color underneath the document view.
//
// Defaults to a clear color.
@property (nonatomic, strong) NSColor *backgroundColor;

#pragma mark - Information

// Returns the total number of sections.
- (NSInteger)numberOfSections;

// Returns the number of items in the specified section.
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

// The following methods will return frames in flipped coordinates, where the origin is the
// top left point in the scroll view. All of these methods will return CGRectZero if an invalid
// index path or section is specified.
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)rectForSupplementaryViewWithKind:(NSString *)kind inSection:(NSInteger)section;
- (CGRect)rectForSection:(NSInteger)section; // the frame encompassing the cells and views in the specified section

// Provides the size of the visible document area in which the collection view is currently
// displaying cells and other supplementary views.
//
// Equivalent to the size of -documentVisibleRect.
@property (nonatomic, assign, readonly) CGSize visibleSize;

// Returns the index path for the item at the specified point, otherwise nil if no item is found.
- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;

// Returns the index path for the specified cell, otherwise returns nil if the cell isn't visible.
- (NSIndexPath *)indexPathForCell:(JNWCollectionViewCell *)cell;

// Returns an array of all of the index paths contained within the specified frame.
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

// Returns an index set containing the indexes for all sections that intersect the specified rect.
- (NSIndexSet *)indexesForSectionsInRect:(CGRect)rect;

// Returns the cell at the specified index path, otherwise returns nil if the index path
// is invalid or if the cell is not visible.
- (JNWCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

// Returns the supplementary view of the specified kind and reuse identifier in the section, otherwise returns nil if
// the supplementary view is no longer visible or if the kind and reuse identifier are invalid or have not been
// previously registered in -registerClass:forSupplementaryViewOfKind:reuseIdentifier:.
- (JNWCollectionViewReusableView *)supplementaryViewForKind:(NSString *)kind reuseIdentifier:(NSString *)reuseIdentifier inSection:(NSInteger)section;

// Returns an array of all the currently visible cells. The cells are not guaranteed to be in any order.
- (NSArray *)visibleCells;

// Returns the index paths for all the items in the visible rect. Order is not guaranteed.
- (NSArray *)indexPathsForVisibleItems;

// Returns the index paths for any selected items. Order is not guaranteed.
- (NSArray *)indexPathsForSelectedItems;

#pragma mark - Selection

// If set to YES, any changes to the backgroundImage or backgroundColor properties of the collection view cell
// will be animated with a crossfade.
//
// Defaults to NO.
@property (nonatomic, assign) BOOL animatesSelection;

// If set to NO, the collection view will not automatically select cells either through clicks or
// through keyboard actions.
//
// Defaults to YES.
@property (nonatomic, assign) BOOL allowsSelection;

// Scrolls the collection view to the item at the specified path, optionally animated. The scroll position determines
// where the item is positioned on the screen.
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

// Selects the item at the specified index path, deselecting any other selected items in the process, optionally animated.
// The collection view will then scroll to that item in the position as determined by scrollPosition. If no scroll is
// desired, pass in JNWCollectionViewScrollPositionNone to prevent the scroll..
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

// Selects all items in the collection view.
- (void)selectAllItems;

// Deselects all items in the collection view.
- (void)deselectAllItems;

@end
