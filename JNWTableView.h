#import <Cocoa/Cocoa.h>
#import "JNWTableViewCell.h"
#import "JNWTableViewHeaderFooterView.h"
#import "NSIndexPath+JNWAdditions.h"

@class JNWTableView;
@protocol JNWTableViewDataSource <NSObject>
- (NSUInteger)tableView:(JNWTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (JNWTableViewCell *)tableView:(JNWTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (JNWTableViewHeaderFooterView *)tableView:(JNWTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (JNWTableViewHeaderFooterView *)tableView:(JNWTableView *)tableView viewForFooterInSection:(NSInteger)section;

@optional
- (NSInteger)numberOfSectionsInTableView:(JNWTableView *)tableView;
@end

@protocol JNWTableViewDelegate <NSObject>
@optional
- (CGFloat)tableView:(JNWTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(JNWTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(JNWTableView *)tableView heightForFooterInSection:(NSInteger)section;
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

@property (nonatomic, weak) id<JNWTableViewDelegate> delegate;
@property (nonatomic, weak) id<JNWTableViewDataSource> dataSource;

- (void)reloadData;

- (JNWTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JNWTableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier;

@end