#import <Cocoa/Cocoa.h>
#import "JNWCollectionViewCell.h"
#import "RBLScrollView.h"
#import "JNWCollectionViewHeaderFooterView.h"
#import "NSIndexPath+JNWAdditions.h"

typedef NS_ENUM(NSInteger, JNWTableViewScrollPosition) {
	JNWTableViewScrollPositionNone, // does not scroll, only selects
	JNWTableViewScrollPositionNearest,
	JNWTableViewScrollPositionTop,
	JNWTableViewScrollPositionMiddle,
	JNWTableViewScrollPositionBottom
};

@class JNWCollectionView;
@protocol JNWTableViewDataSource <NSObject>
- (NSUInteger)tableView:(JNWCollectionView *)tableView numberOfRowsInSection:(NSInteger)section;
- (JNWCollectionViewCell *)tableView:(JNWCollectionView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(JNWCollectionView *)tableView;
- (JNWCollectionViewHeaderFooterView *)tableView:(JNWCollectionView *)tableView viewForHeaderInSection:(NSInteger)section;
- (JNWCollectionViewHeaderFooterView *)tableView:(JNWCollectionView *)tableView viewForFooterInSection:(NSInteger)section;
@end

@protocol JNWTableViewDelegate <NSObject>
@optional
- (CGFloat)tableView:(JNWCollectionView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(JNWCollectionView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(JNWCollectionView *)tableView heightForFooterInSection:(NSInteger)section;

- (BOOL)tableView:(JNWCollectionView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)tableView:(JNWCollectionView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)tableView:(JNWCollectionView *)tableView didUnHighlightRowAtIndexPath:(NSIndexPath *)indexPath; // TODO

- (void)tableView:(JNWCollectionView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)tableView:(JNWCollectionView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
@end


@interface JNWCollectionView : RBLScrollView


// If variable row heights are not needed, setting the row height
// here will have significant performance benefits if you have many
// rows in your table view.
//
// Note that this value will be ignored if tableView:heightForRowAtIndexPath:
// is implemented.
//
// Defaults to 44.
@property (nonatomic, assign) CGFloat rowHeight;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

// These will be provided in flipped coordinates.
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForFooterInSection:(NSInteger)section;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForCell:(JNWCollectionViewCell *)cell;
- (NSArray *)indexPathsForRowsInRect:(CGRect)rect;

- (JNWCollectionViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleRows;
- (JNWCollectionViewHeaderFooterView *)headerViewForSection:(NSInteger)section;
- (JNWCollectionViewHeaderFooterView *)footerViewForSection:(NSInteger)section;

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWTableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWTableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@property (nonatomic, weak) id<JNWTableViewDelegate> delegate;
@property (nonatomic, weak) id<JNWTableViewDataSource> dataSource;

- (void)reloadData;

- (JNWCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWCollectionViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier;

@end