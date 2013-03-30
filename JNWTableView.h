#import <Cocoa/Cocoa.h>
#import "JNWTableViewCell.h"
#import "JNWTableViewHeaderFooterView.h"
#import "NSIndexPath+JNWAdditions.h"

typedef NS_ENUM(NSInteger, JNWTableViewScrollPosition) {
    JNWTableViewScrollPositionNearest,
    JNWTableViewScrollPositionTop,
    JNWTableViewScrollPositionMiddle,
    JNWTableViewScrollPositionBottom
};

@class JNWTableView;
@protocol JNWTableViewDataSource <NSObject>
- (NSUInteger)tableView:(JNWTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (JNWTableViewCell *)tableView:(JNWTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(JNWTableView *)tableView;
- (JNWTableViewHeaderFooterView *)tableView:(JNWTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (JNWTableViewHeaderFooterView *)tableView:(JNWTableView *)tableView viewForFooterInSection:(NSInteger)section;
@end

@protocol JNWTableViewDelegate <NSObject>
@optional
- (CGFloat)tableView:(JNWTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(JNWTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(JNWTableView *)tableView heightForFooterInSection:(NSInteger)section;

- (BOOL)tableView:(JNWTableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)tableView:(JNWTableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)tableView:(JNWTableView *)tableView didUnHighlightRowAtIndexPath:(NSIndexPath *)indexPath; // TODO

- (void)tableView:(JNWTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
- (void)tableView:(JNWTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath; // TODO
@end


@interface JNWTableView : NSScrollView


// If variable row heights are not needed, setting the row height
// here will have significant performance benefits if you have many
// rows in your table view.
//
// Note that this value will be ignored if tableView:heightForRowAtIndexPath:
// is implemented.
//
// Defaults to 44.
@property (nonatomic, assign) CGFloat rowHeight;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;

// These will be provided in flipped coordinates.
- (CGRect)rectForHeaderInSection:(NSUInteger)section;
- (CGRect)rectForFooterInSection:(NSUInteger)section;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForCell:(JNWTableViewCell *)cell;
- (NSArray *)indexPathsForRowsInRect:(CGRect)rect;

- (JNWTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleRows;
- (JNWTableViewHeaderFooterView *)headerViewForSection:(NSUInteger)section;
- (JNWTableViewHeaderFooterView *)footerViewForSection:(NSUInteger)section;

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWTableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@property (nonatomic, weak) id<JNWTableViewDelegate> delegate;
@property (nonatomic, weak) id<JNWTableViewDataSource> dataSource;

- (void)reloadData;

- (JNWTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWTableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier;

@end