#import "JNWTableView.h"
#import "JNWTableViewSection.h"
#import "JNWTableView+Private.h"
#import "JNWTableViewCell+Private.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger JNWTableViewMaximumNumberOfQueuedCells = 2;
static const CGFloat JNWTableViewDefaultRowHeight = 44.f;

@interface JNWTableView() {
	struct {
		unsigned int delegateHeightForRow;
		unsigned int delegateHeightForHeader;
		unsigned int delegateHeightForFooter;
		unsigned int dataSourceNumberOfSections;
		unsigned int dataSourceViewForHeader;
		unsigned int dataSourceViewForFooter;
	} _tableFlags;
	
	CGRect _lastDrawnBounds;
}

@property (nonatomic, strong) NSMutableArray *sectionData;
@property (nonatomic, assign) CGFloat contentHeight;


// Cells
@property (nonatomic, strong) NSMutableDictionary *reusableTableCells;
@property (nonatomic, strong) NSMutableDictionary *visibleCells;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

// Headers and footers
@property (nonatomic, strong) NSMutableDictionary *visibleTableHeaders;
@property (nonatomic, strong) NSMutableDictionary *visibleTableFooters;
@property (nonatomic, strong) NSMutableDictionary *reusableTableHeadersFooters;

@end

@implementation JNWTableView

static void JNWTableViewCommonInit(JNWTableView *_self) {
	_self.sectionData = [NSMutableArray array];
	_self.selectedIndexes = [NSMutableArray array];
	_self.visibleCells = [NSMutableDictionary dictionary];
	_self.visibleTableFooters = [NSMutableDictionary dictionary];
	_self.visibleTableHeaders = [NSMutableDictionary dictionary];
	_self.rowHeight = JNWTableViewDefaultRowHeight;
	
	_self.reusableTableCells = [NSMutableDictionary dictionary];
	_self.reusableTableHeadersFooters = [NSMutableDictionary dictionary];
	// By default we are layer-backed.
	_self.wantsLayer = YES;
	
	// Flip the document view since it's easier to lay out
	// starting from the top, not the bottom.
	[_self.documentView setFlipped:YES];
	
	//[NSTimer scheduledTimerWithTimeInterval:5.f target:_self selector:@selector(log) userInfo:nil repeats:YES];
}

//- (void)log {
//	NSLog(@"%ld rows visible.", self.visibleCells.count);
//	[self.visibleCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		NSLog(@"visible row: %@",obj);
//	}];
//	[self.reusableTableCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		NSLog(@"reuse %@",obj);
//	}];
//}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	JNWTableViewCommonInit(self);
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	JNWTableViewCommonInit(self);
	return self;
}

#pragma mark Delegate and data source

- (void)setDelegate:(id<JNWTableViewDelegate>)delegate {	
	_delegate = delegate;
	_tableFlags.delegateHeightForRow = [delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
	_tableFlags.delegateHeightForHeader = [delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
	_tableFlags.delegateHeightForFooter = [delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
}

- (void)setDataSource:(id<JNWTableViewDataSource>)dataSource {
	_dataSource = dataSource;
	_tableFlags.dataSourceNumberOfSections = [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)];
	_tableFlags.dataSourceViewForHeader = [dataSource respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
	_tableFlags.dataSourceViewForFooter = [dataSource respondsToSelector:@selector(tableView:viewForFooterInSection:)];
	
	NSAssert([dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)],
			 @"data source should implement tableView:numberOfRowsInSection");
}


#pragma mark Queueing and dequeuing

- (id)dequeueItemWithIdentifier:(NSString *)identifier inReusePool:(NSDictionary *)reuse {
	if (identifier == nil)
		return nil;
	
	NSMutableArray *reusableItems = reuse[identifier];
	if (reusableItems != nil) {
		id reusableItem = [reusableItems lastObject];
		
		if (reusableItem != nil) {
			[reusableItems removeObject:reusableItem];
			return reusableItem;
		}
	}
	
	return nil;
}

- (void)enqueueItem:(id)item withIdentifier:(NSString *)identifier inReusePool:(NSMutableDictionary *)reuse {
	if (identifier == nil)
		return;
	
	NSMutableArray *reusableCells = reuse[identifier];
	if (reusableCells == nil) {
		reusableCells = [NSMutableArray array];
		reuse[identifier] = reusableCells;
	}
	
	//NSLog(@"%ld", reusableCells.count);

//	if (reusableCells.count > JNWTableViewMaximumNumberOfQueuedCells) {
//		if ([item isKindOfClass:NSView.class] && [item superview] != nil)
//			[(NSView *)item removeFromSuperview];
//		return;
//	}
	
	//NSLog(@"%ld", reusableCells.count);
	
	[reusableCells addObject:item];
}

- (JNWTableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier {
	return [self dequeueItemWithIdentifier:identifier inReusePool:self.reusableTableHeadersFooters];
}

- (void)enqueueReusableHeaderFooterView:(JNWTableViewHeaderFooterView *)view withIdentifier:(NSString *)identifier {
	[self enqueueItem:view withIdentifier:identifier inReusePool:self.reusableTableHeadersFooters];
}

- (JNWTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
	JNWTableViewCell *cell = [self dequeueItemWithIdentifier:identifier inReusePool:self.reusableTableCells];
	[cell prepareForReuse];
	return cell; 
}

- (void)enqueueReusableCell:(JNWTableViewCell *)cell withIdentifier:(NSString *)identifier {
	[self enqueueItem:cell withIdentifier:identifier inReusePool:self.reusableTableCells];
}

- (void)reloadData {
	[self recalculateHeightAndRowInfo];
	[self layoutDocumentView];
	[self layoutCells];
	[self layoutHeaderFooters];
}

- (void)recalculateHeightAndRowInfo {
	[self.sectionData removeAllObjects];
	
	CGFloat tableViewHeight = 0.f;
	
	// Find how many sections we have in the table view.
	// We default to 1 if the data source doesn't implement the optional method.
	NSUInteger numberOfSections = 1;
	if (_tableFlags.dataSourceNumberOfSections)
		numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
	
	for (NSInteger section = 0; section < numberOfSections; section++) {
		// Create a new section
		NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
		NSInteger headerHeight = (_tableFlags.delegateHeightForHeader ? [self.delegate tableView:self heightForHeaderInSection:section] : 0);
		NSInteger footerHeight = (_tableFlags.delegateHeightForFooter ? [self.delegate tableView:self heightForFooterInSection:section] : 0);
		
		JNWTableViewSection *sectionInfo = [[JNWTableViewSection alloc] initWithNumberOfRows:numberOfRows];
		sectionInfo.index = section;
		sectionInfo.offset = tableViewHeight + headerHeight;
		sectionInfo.height = 0;
		sectionInfo.headerHeight = headerHeight;
		sectionInfo.footerHeight = footerHeight;
		
		
		// Calculate the individual height of each row, and also
		// keep track of the total height of the section.
		for (NSInteger row = 0; row < numberOfRows; row++) {
			CGFloat rowHeight = 0;
			if (_tableFlags.delegateHeightForRow) {
				NSIndexPath *indexPath = [NSIndexPath jnw_indexPathForRow:row inSection:section];
				rowHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
			} else {
				rowHeight = self.rowHeight;
			}
			
			sectionInfo.rowInfo[row].rowHeight = rowHeight;
			sectionInfo.rowInfo[row].yOffset = sectionInfo.height;
			sectionInfo.height += rowHeight;
		}		
		
		tableViewHeight += sectionInfo.height + footerHeight + headerHeight;
		[self.sectionData addObject:sectionInfo];
	}
	
	self.contentHeight = tableViewHeight;
}





#pragma mark Cell accessors

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil || indexPath.section >= self.sectionData.count)
		return CGRectZero;
	
	JNWTableViewSection *section = self.sectionData[indexPath.section];
	CGFloat offset = [section realOffsetForRowAtIndex:indexPath.row];
	CGFloat height = [section heightForRowAtIndex:indexPath.row];
	return CGRectMake(0.f, offset, self.bounds.size.width, height);
}

- (CGRect)rectForHeaderInSection:(NSUInteger)index {
	JNWTableViewSection *section = self.sectionData[index];
	return CGRectMake(0.f, section.offset - section.headerHeight, self.bounds.size.width, section.headerHeight);
}

- (CGRect)rectForFooterInSection:(NSUInteger)index {
	JNWTableViewSection *section = self.sectionData[index];
	return CGRectMake(0.f, section.offset + section.height, self.bounds.size.width, section.footerHeight);
}

- (JNWTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil)
		return nil;
	return self.visibleCells[indexPath];
}

- (JNWTableViewHeaderFooterView *)headerAtSectionIndex:(NSUInteger)index {
	return self.visibleTableHeaders[@(index)];
}

- (JNWTableViewHeaderFooterView *)footerAtSectionIndex:(NSUInteger)index {
	return self.visibleTableFooters[@(index)];
}

- (NSIndexPath *)indexPathForCell:(JNWTableViewCell *)cell {
	__block NSIndexPath *indexPath = nil;
	
	[self.visibleCells enumerateKeysAndObjectsUsingBlock:^(id key, id visibleCell, BOOL *stop) {
		if (cell == visibleCell) {
			indexPath = key;
			*stop = YES;
		}
	}];
	
	return indexPath;
}

// Returns the last object in the selection array. There may be more than just one.
- (NSIndexPath *)indexPathForSelectedRow {
	return self.selectedIndexes.lastObject;
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect {
	NSMutableArray *visibleRows = [NSMutableArray array];
	
	CGFloat top = rect.origin.y;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	for (JNWTableViewSection *section in self.sectionData) {
		NSUInteger numberOfRows = section.numberOfRows;
		if (section.offset + section.height < top || section.offset > bottom) {
			continue;
		}
		
		for (NSInteger row = 0; row < numberOfRows; row++) {
			CGFloat absoluteRowOffset = section.offset + section.rowInfo[row].yOffset;
			CGFloat absoluteRowTop = absoluteRowOffset + section.rowInfo[row].rowHeight;

			if (absoluteRowTop < top)
				continue;
			else if (absoluteRowOffset > bottom)
				break;
			else if (absoluteRowTop >= top && absoluteRowOffset <= bottom) {
				[visibleRows addObject:[NSIndexPath jnw_indexPathForRow:row inSection:section.index]];
			}
		}
	}
	return visibleRows;
}

- (NSIndexSet *)indexesForHeadersInRect:(CGRect)rect {
	CGFloat top = rect.origin.y;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	NSMutableIndexSet *visibleHeaders = [NSMutableIndexSet indexSet];
	
	for (JNWTableViewSection *section in self.sectionData) {
		CGFloat headerTopOffset = section.offset - section.headerHeight;
		if (section.headerHeight > 0 && section.offset >= top && headerTopOffset <= bottom)
			[visibleHeaders addIndex:section.index];
	}
	
	return visibleHeaders;
}

- (NSIndexSet *)indexesForFootersInRect:(CGRect)rect {
	CGFloat top = rect.origin.y;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	NSMutableIndexSet *visibleFooters = [NSMutableIndexSet indexSet];
	
	for (JNWTableViewSection *section in self.sectionData) {
		CGFloat footerTopOffset = section.offset + section.height;
		if (section.footerHeight > 0 && footerTopOffset + section.footerHeight >= top && footerTopOffset <= bottom)
			[visibleFooters addIndex:section.index];
	}
	
	return visibleFooters;
}

- (JNWTableViewSection *)sectionForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil)
		return nil;
	
	return self.sectionData[indexPath.section];
}


#pragma mark Layout

- (void)layout {
	[super layout];
	
	if ([self.documentView frame].size.height != self.contentHeight)
		[self layoutDocumentView];
	
	if (!CGRectEqualToRect(self.bounds, _lastDrawnBounds)) {
		[self layoutCellsWithRedraw:YES];
		[self layoutHeaderFootersWithRedraw:YES];
		_lastDrawnBounds = self.bounds;
	} else {
		[self layoutCells];
		[self layoutHeaderFooters];
	}
}

- (void)layoutDocumentView {
	NSView *documentView = self.documentView;
	documentView.frameSize = CGSizeMake(self.bounds.size.width, self.contentHeight);
}

- (void)layoutCells {
	[self layoutCellsWithRedraw:NO];
}

- (void)layoutCellsWithRedraw:(BOOL)needsVisibleRedraw {
	if (self.dataSource == nil)
		return;
	
	if (needsVisibleRedraw) {
		for (NSIndexPath *indexPath in self.visibleCells.allKeys) {
			JNWTableViewCell *cell = self.visibleCells[indexPath];
			cell.frame = [self rectForRowAtIndexPath:indexPath];
			[cell setNeedsLayout:YES];
		}
	}

	NSArray *oldVisibleIndexPaths = [self.visibleCells allKeys];
	NSArray *updatedVisibleIndexPaths = [self indexPathsForRowsInRect:self.documentVisibleRect];
	
	NSMutableArray *indexPathsToRemove = [NSMutableArray arrayWithArray:oldVisibleIndexPaths];
	[indexPathsToRemove removeObjectsInArray:updatedVisibleIndexPaths];
	
	NSMutableArray *indexPathsToAdd = [NSMutableArray arrayWithArray:updatedVisibleIndexPaths];
	[indexPathsToAdd removeObjectsInArray:oldVisibleIndexPaths];
		
	// Remove old cells and put them in the reuse queue
	for (NSIndexPath *indexPath in indexPathsToRemove) {
		JNWTableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
		[self.visibleCells removeObjectForKey:indexPath];

		[self enqueueReusableCell:cell withIdentifier:cell.reuseIdentifier];
		//[cell removeFromSuperview];
		
#warning look into hiding the cell instead of removing it from the superview
		[cell setHidden:YES];
		
	}
	
	// Add the new cells
	for (NSIndexPath *indexPath in indexPathsToAdd) {
		JNWTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
		NSAssert(cell != nil, @"tableView:cellForRowAtIndexPath: must return a non-nil cell.");
		
		cell.tableView = self;
		cell.frame = [self rectForRowAtIndexPath:indexPath];
		//[self.documentView addSubview:cell];
		
		if (cell.superview == nil)
			[self.documentView addSubview:cell];
		else {
			[cell setHidden:NO];
		}
		
		if ([self.selectedIndexes containsObject:indexPath])
			cell.selected = YES;
		else
			cell.selected = NO;
		
		self.visibleCells[indexPath] = cell;
	}
}

- (void)layoutHeaderFooters {
	[self layoutHeaderFootersWithRedraw:NO];
}

- (void)layoutHeaderFootersWithRedraw:(BOOL)needsVisibleRedraw {
	if (!_tableFlags.dataSourceViewForHeader && !_tableFlags.dataSourceViewForFooter)
		return;
	
	NSMutableIndexSet *oldVisibleHeaderIndexes = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *oldVisibleFooterIndexes = [NSMutableIndexSet indexSet];

	for (NSNumber *index in self.visibleTableHeaders.allKeys) {
		[oldVisibleHeaderIndexes addIndex:index.unsignedIntegerValue];
		if (needsVisibleRedraw) {
			[self.visibleTableHeaders[index] setFrame:[self rectForHeaderInSection:index.unsignedIntegerValue]];
		}
	}
	
	for (NSNumber *index in self.visibleTableFooters.allKeys) {
		[oldVisibleFooterIndexes addIndex:index.unsignedIntegerValue];
		if (needsVisibleRedraw) {
			[self.visibleTableFooters[index] setFrame:[self rectForFooterInSection:index.unsignedIntegerValue]];
		}
	}
	
	NSIndexSet *updatedVisibleHeaderIndexes = [self indexesForHeadersInRect:self.documentVisibleRect];
	NSIndexSet *updatedVisibleFooterIndexes = [self indexesForFootersInRect:self.documentVisibleRect];
	
	NSMutableIndexSet *headerIndexesToRemove = oldVisibleHeaderIndexes.mutableCopy;
	NSMutableIndexSet *footerIndexesToRemove = oldVisibleFooterIndexes.mutableCopy;
	[headerIndexesToRemove removeIndexes:updatedVisibleHeaderIndexes];
	[footerIndexesToRemove removeIndexes:updatedVisibleFooterIndexes];
	
	NSMutableIndexSet *headerIndexesToAdd = updatedVisibleHeaderIndexes.mutableCopy;
	NSMutableIndexSet *footerIndexesToAdd = updatedVisibleFooterIndexes.mutableCopy;
	[headerIndexesToAdd removeIndexes:oldVisibleHeaderIndexes];
	[footerIndexesToAdd removeIndexes:oldVisibleFooterIndexes];
	
	[headerIndexesToRemove enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWTableViewHeaderFooterView *header = [self headerAtSectionIndex:idx];
		[self.visibleTableHeaders removeObjectForKey:@(idx)];
		[header removeFromSuperview];
		
		[self enqueueReusableHeaderFooterView:header withIdentifier:header.reuseIdentifier];
	}];
	
	[footerIndexesToRemove enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWTableViewHeaderFooterView *footer = [self footerAtSectionIndex:idx];
		[self.visibleTableFooters removeObjectForKey:@(idx)];
		[footer removeFromSuperview];
		
		[self enqueueReusableHeaderFooterView:footer withIdentifier:footer.reuseIdentifier];
	}];
	
	[headerIndexesToAdd enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWTableViewHeaderFooterView *header = [self.dataSource tableView:self viewForHeaderInSection:idx];
		if (header == nil) {
			NSLog(@"header doesn't exist!");
		} else {
			header.frame = [self rectForHeaderInSection:idx];
			[self.documentView addSubview:header];
			
			self.visibleTableHeaders[@(idx)] = header;
		}
	}];
	
	[footerIndexesToAdd enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWTableViewHeaderFooterView *footer = [self.dataSource tableView:self viewForFooterInSection:idx];
		if (footer == nil) {
			NSLog(@"footer doesn't exist!");
		} else {
			footer.frame = [self rectForFooterInSection:idx];
			[self.documentView addSubview:footer];
			
			self.visibleTableFooters[@(idx)] = footer;
		}
	}];
}


#pragma mark Mouse events and selection

- (BOOL)canBecomeKeyView {
	return YES;
}


- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	return YES;
}

- (BOOL)resignFirstResponder {
	return YES;
}

- (void)mouseDownInTableViewCell:(JNWTableViewCell *)cell withEvent:(NSEvent *)event {
	NSIndexPath *indexPath = [self indexPathForCell:cell];
	if (indexPath == nil) {
		NSLog(@"***index path not found for selection.");
	}
	
	//NSMutableArray *indexSetsToRemove = [NSMutableArray arrayWithCapacity:self.selectedIndexes.count];
	for (NSIndexSet *indexSetToDeselect in self.selectedIndexes) {
		NSIndexPath *indexToDeselect = self.selectedIndexes.lastObject;
		JNWTableViewCell *cell = [self cellForRowAtIndexPath:indexToDeselect];
		cell.selected = NO;
		//[indexSetsToRemove addObject:indexToDeselect];
	}
	[self.selectedIndexes removeAllObjects];
	//[self.selectedIndexes removeObjectsInArray:indexSetsToRemove];
	
	cell.selected = YES;
	[self.selectedIndexes addObject:indexPath];
	
	// for now, just delete previous selections
	// TODO: see if we need to extend selection
}

- (void)keyDown:(NSEvent *)theEvent {
	[self interpretKeyEvents:@[theEvent]];
}

- (BOOL)validateIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.section <= self.sectionData.count && indexPath.row <= [self.sectionData[indexPath.section] numberOfRows]);
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath {
	JNWTableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
	if (cell == nil || ![self validateIndexPath:indexPath])
		return;
	
	NSIndexPath *oldIndexPath = [self indexPathForSelectedRow];
	if (oldIndexPath != nil) {
		JNWTableViewCell *oldCell = [self cellForRowAtIndexPath:oldIndexPath];
		oldCell.selected = NO;
		[self.selectedIndexes removeObject:oldIndexPath];
	}
	
	cell.selected = YES;
	[self.selectedIndexes addObject:indexPath];
}


- (void)moveDown:(id)sender {
	NSIndexPath *oldIndexPath = [self indexPathForSelectedRow];
	[self selectRowAtIndexPath:[NSIndexPath jnw_indexPathForRow:oldIndexPath.row + 1 inSection:oldIndexPath.section]];
}

- (void)moveUp:(id)sender {
	NSIndexPath *oldIndexPath = [self indexPathForSelectedRow];
	[self selectRowAtIndexPath:[NSIndexPath jnw_indexPathForRow:oldIndexPath.row - 1 inSection:oldIndexPath.section]];
}

- (void)moveUpAndModifySelection:(id)sender {
	NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)moveDownAndModifySelection:(id)sender {
	NSLog(@"%s",__PRETTY_FUNCTION__);
}

@end
