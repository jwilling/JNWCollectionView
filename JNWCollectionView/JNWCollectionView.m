#import "JNWCollectionView.h"
#import "RBLClipView.h"
#import "JNWCollectionViewSection.h"
#import "JNWCollectionView+Private.h"
#import "JNWCollectionViewCell+Private.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger JNWTableViewMaximumNumberOfQueuedCells = 2;
static const CGFloat JNWTableViewDefaultRowHeight = 44.f;

typedef NS_ENUM(NSInteger, JNWTableViewSelectionType) {
	JNWTableViewSelectionTypeSingle,
	JNWTableViewSelectionTypeExtending,
	JNWTableViewSelectionTypeMultiple
};

@interface JNWCollectionView() {
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
@property (nonatomic, strong) NSMutableDictionary *visibleCellsMap;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

// Headers and footers
@property (nonatomic, strong) NSMutableDictionary *visibleTableHeaders;
@property (nonatomic, strong) NSMutableDictionary *visibleTableFooters;
@property (nonatomic, strong) NSMutableDictionary *reusableTableHeadersFooters;

@end

@implementation JNWCollectionView

static void JNWTableViewCommonInit(JNWCollectionView *_self) {
	_self.sectionData = [NSMutableArray array];
	_self.selectedIndexes = [NSMutableArray array];
	_self.visibleCellsMap = [NSMutableDictionary dictionary];
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
}

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

- (JNWCollectionViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier {
	return [self dequeueItemWithIdentifier:identifier inReusePool:self.reusableTableHeadersFooters];
}

- (void)enqueueReusableHeaderFooterView:(JNWCollectionViewHeaderFooterView *)view withIdentifier:(NSString *)identifier {
	[self enqueueItem:view withIdentifier:identifier inReusePool:self.reusableTableHeadersFooters];
}

- (JNWCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
	JNWCollectionViewCell *cell = [self dequeueItemWithIdentifier:identifier inReusePool:self.reusableTableCells];
	[cell prepareForReuse];
	return cell; 
}

- (void)enqueueReusableCell:(JNWCollectionViewCell *)cell withIdentifier:(NSString *)identifier {
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
		@autoreleasepool {
			// Create a new section
			NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
			NSInteger headerHeight = (_tableFlags.delegateHeightForHeader ? [self.delegate tableView:self heightForHeaderInSection:section] : 0);
			NSInteger footerHeight = (_tableFlags.delegateHeightForFooter ? [self.delegate tableView:self heightForFooterInSection:section] : 0);
			
			JNWCollectionViewSection *sectionInfo = [[JNWCollectionViewSection alloc] initWithNumberOfRows:numberOfRows];
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
	}
	
	self.contentHeight = tableViewHeight;
}


#pragma mark Cell Information

- (NSInteger)numberOfSections {
	return self.sectionData.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
	if (self.sectionData.count < section)
		return 0.f;
	return [(JNWCollectionViewSection *)self.sectionData[section] numberOfRows];
}

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point {
#warning implement
	return nil;
}

- (NSArray *)visibleCells {
	return self.visibleCellsMap.allValues;
}

- (NSArray *)allIndexPaths {
	NSMutableArray *indexPaths = [NSMutableArray array];
	for (JNWCollectionViewSection *section in self.sectionData) {
		for (NSInteger row = 0; row < section.numberOfRows; row++) {
			[indexPaths addObject:[NSIndexPath jnw_indexPathForRow:row inSection:section.index]];
		}
	}
	
	return indexPaths.copy;
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect {
	NSMutableArray *visibleRows = [NSMutableArray array];
	
	CGFloat top = rect.origin.y;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	for (JNWCollectionViewSection *section in self.sectionData) {
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

- (NSArray *)indexPathsForVisibleRows {
	return [self indexPathsForRowsInRect:self.documentVisibleRect];
}

- (JNWCollectionViewHeaderFooterView *)headerViewForSection:(NSInteger)section {
	return self.visibleTableHeaders[@(section)];
}

- (JNWCollectionViewHeaderFooterView *)footerViewForSection:(NSInteger)section {
	return self.visibleTableFooters[@(section)];
}

- (BOOL)validateIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.section < self.sectionData.count && indexPath.row < [self.sectionData[indexPath.section] numberOfRows]);
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWTableViewScrollPosition)scrollPosition animated:(BOOL)animated {
	CGRect rect = [self rectForRowAtIndexPath:indexPath];
	CGRect visibleRect = self.documentVisibleRect;
#warning this is actually pretty broken.
	
	switch (scrollPosition) {
			break;
		case JNWTableViewScrollPositionTop:
			// make the top of our rect flush with the top of the visible bounds
			rect.size.height = visibleRect.size.height;
			//rect.origin.y = self.documentVisibleRect.origin.y + rect.size.height;
			break;
		case JNWTableViewScrollPositionMiddle:
			// TODO
			break;
		case JNWTableViewScrollPositionBottom:
			// make the bottom of our rect flush with the bottom of the visible bounds
			//rect.origin.y = self.documentVisibleRect.origin.y + self.documentVisibleRect.size.height;
			rect.size.height = visibleRect.size.height;
			rect.origin.y -= visibleRect.size.height;
			break;
		case JNWTableViewScrollPositionNone:
			// no scroll needed
			break;
		case JNWTableViewScrollPositionNearest:
		default:
			break;
	}
	
	[(RBLClipView *)self.contentView scrollRectToVisible:rect animated:animated];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil || indexPath.section >= self.sectionData.count)
		return CGRectZero;
	
	JNWCollectionViewSection *section = self.sectionData[indexPath.section];
	CGFloat offset = [section realOffsetForRowAtIndex:indexPath.row];
	CGFloat height = [section heightForRowAtIndex:indexPath.row];
	return CGRectMake(0.f, offset, self.bounds.size.width, height);
}

- (CGRect)rectForHeaderInSection:(NSInteger)index {
	JNWCollectionViewSection *section = self.sectionData[index];
	return CGRectMake(0.f, section.offset - section.headerHeight, self.bounds.size.width, section.headerHeight);
}

- (CGRect)rectForFooterInSection:(NSInteger)index {
	JNWCollectionViewSection *section = self.sectionData[index];
	return CGRectMake(0.f, section.offset + section.height, self.bounds.size.width, section.footerHeight);
}

- (JNWCollectionViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil)
		return nil;
	return self.visibleCellsMap[indexPath];
}

- (NSIndexPath *)indexPathForCell:(JNWCollectionViewCell *)cell {
	__block NSIndexPath *indexPath = nil;
	
	[self.visibleCellsMap enumerateKeysAndObjectsUsingBlock:^(id key, id visibleCell, BOOL *stop) {
		if (cell == visibleCell) {
			indexPath = key;
			*stop = YES;
		}
	}];
	
	return indexPath;
}


- (NSIndexSet *)indexesForHeadersInRect:(CGRect)rect {
	CGFloat top = rect.origin.y;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	NSMutableIndexSet *visibleHeaders = [NSMutableIndexSet indexSet];
	
	for (JNWCollectionViewSection *section in self.sectionData) {
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
	
	for (JNWCollectionViewSection *section in self.sectionData) {
		CGFloat footerTopOffset = section.offset + section.height;
		if (section.footerHeight > 0 && footerTopOffset + section.footerHeight >= top && footerTopOffset <= bottom)
			[visibleFooters addIndex:section.index];
	}
	
	return visibleFooters;
}

- (JNWCollectionViewSection *)sectionForRowAtIndexPath:(NSIndexPath *)indexPath {
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
		for (NSIndexPath *indexPath in self.visibleCellsMap.allKeys) {
			JNWCollectionViewCell *cell = self.visibleCellsMap[indexPath];
			cell.frame = [self rectForRowAtIndexPath:indexPath];
			[cell setNeedsLayout:YES];
		}
	}

	NSArray *oldVisibleIndexPaths = [self.visibleCellsMap allKeys];
	NSArray *updatedVisibleIndexPaths = [self indexPathsForRowsInRect:self.documentVisibleRect];
	
	NSMutableArray *indexPathsToRemove = [NSMutableArray arrayWithArray:oldVisibleIndexPaths];
	[indexPathsToRemove removeObjectsInArray:updatedVisibleIndexPaths];
	
	NSMutableArray *indexPathsToAdd = [NSMutableArray arrayWithArray:updatedVisibleIndexPaths];
	[indexPathsToAdd removeObjectsInArray:oldVisibleIndexPaths];
		
	// Remove old cells and put them in the reuse queue
	for (NSIndexPath *indexPath in indexPathsToRemove) {
		JNWCollectionViewCell *cell = [self cellForRowAtIndexPath:indexPath];
		[self.visibleCellsMap removeObjectForKey:indexPath];

		[self enqueueReusableCell:cell withIdentifier:cell.reuseIdentifier];
		//[cell removeFromSuperview];
		
		[cell setHidden:YES];
		// TODO: Ensure setting views hidden will not be detrimental to performance.
	}
	
	// Add the new cells
	for (NSIndexPath *indexPath in indexPathsToAdd) {
		JNWCollectionViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
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
		
		self.visibleCellsMap[indexPath] = cell;
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
		JNWCollectionViewHeaderFooterView *header = [self headerViewForSection:idx];
		[self.visibleTableHeaders removeObjectForKey:@(idx)];
		[header removeFromSuperview];
		
		[self enqueueReusableHeaderFooterView:header withIdentifier:header.reuseIdentifier];
	}];
	
	[footerIndexesToRemove enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWCollectionViewHeaderFooterView *footer = [self footerViewForSection:idx];
		[self.visibleTableFooters removeObjectForKey:@(idx)];
		[footer removeFromSuperview];
		
		[self enqueueReusableHeaderFooterView:footer withIdentifier:footer.reuseIdentifier];
	}];
	
	[headerIndexesToAdd enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWCollectionViewHeaderFooterView *header = [self.dataSource tableView:self viewForHeaderInSection:idx];
		if (header == nil) {
			NSLog(@"header doesn't exist!");
		} else {
			header.frame = [self rectForHeaderInSection:idx];
			[self.documentView addSubview:header];
			
			self.visibleTableHeaders[@(idx)] = header;
		}
	}];
	
	[footerIndexesToAdd enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWCollectionViewHeaderFooterView *footer = [self.dataSource tableView:self viewForFooterInSection:idx];
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

// Returns the last object in the selection array.
- (NSIndexPath *)indexPathForSelectedRow {
	return self.selectedIndexes.lastObject;
}

// Both of these methods may return nil if there is no selection, or might
// return the same index path if there is no possible next/previous selection.
- (NSIndexPath *)indexPathForNextSelectableRowFromIndex:(NSIndexPath *)indexPath withOrder:(NSComparisonResult)order {
	if (indexPath == nil) return nil;
	
	NSInteger section = indexPath.section;
	NSIndexPath *attemptedIndexPath = nil;
	switch (order) {
		case NSOrderedAscending: {
			NSInteger numberOfRows = [self.sectionData[section] numberOfRows];
			attemptedIndexPath = [NSIndexPath jnw_indexPathByIncrementingRow:indexPath withCurrentSectionNumberOfRows:numberOfRows];
			break;
		}
		case NSOrderedDescending: {
			NSInteger previousNumberOfRows = 0;
			if (section - 1 >= 0)
				previousNumberOfRows = [self.sectionData[section - 1] numberOfRows];
			attemptedIndexPath = [NSIndexPath jnw_indexPathByDecrementingRow:indexPath withPreviousSectionNumberOfRows:previousNumberOfRows];
			break;
		}
		default:
			break;
	}
	
	if ([self validateIndexPath:attemptedIndexPath]) {
		return attemptedIndexPath;
	}
	return indexPath;
}

- (NSIndexPath *)indexPathForNextSelectableRow {
	return [self indexPathForNextSelectableRowFromIndex:[self indexPathForSelectedRow] withOrder:NSOrderedAscending];
}

- (NSIndexPath *)indexPathForPreviousSelectableRow {
	return [self indexPathForNextSelectableRowFromIndex:[self indexPathForSelectedRow] withOrder:NSOrderedDescending];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	// TODO animated
	JNWCollectionViewCell *cell = [self cellForRowAtIndexPath:indexPath];
	cell.selected = NO;
	[self.selectedIndexes removeObject:indexPath];
}

- (void)deselectRowsAtIndexPaths:(NSArray *)indexes animated:(BOOL)animated {
	// TODO animated
	NSArray *indexPaths = indexes.copy;
	for (NSIndexPath *indexPath in indexPaths) {
		[self deselectRowAtIndexPath:indexPath animated:animated];
	}
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	// TODO animated
	JNWCollectionViewCell *cell = [self cellForRowAtIndexPath:indexPath];
	cell.selected = YES;
	[self.selectedIndexes addObject:indexPath];
}

- (void)selectRowsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated {
	for (NSIndexPath *indexPath in indexPaths) {
		[self selectRowAtIndexPath:indexPath animated:animated];
	}
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
			atScrollPosition:(JNWTableViewScrollPosition)scrollPosition
					animated:(BOOL)animated {
	[self selectRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated selectionType:JNWTableViewSelectionTypeSingle];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
			atScrollPosition:(JNWTableViewScrollPosition)scrollPosition
					animated:(BOOL)animated
			   selectionType:(JNWTableViewSelectionType)selectionType {
#warning implement extending selection
	NSMutableSet *indexesToSelect = [NSMutableSet set];
	
	if (selectionType == JNWTableViewSelectionTypeSingle) {
		[indexesToSelect addObject:indexPath];
	} else if (selectionType == JNWTableViewSelectionTypeMultiple) {
		[indexesToSelect addObjectsFromArray:self.selectedIndexes];
		if ([indexesToSelect containsObject:indexPath]) {
			[indexesToSelect removeObject:indexPath];
		} else {
			[indexesToSelect addObject:indexPath];
		}
	} else if (selectionType == JNWTableViewSelectionTypeExtending) {
		// From what I have determined, this behavior should be as follows.
		// Take the index selected first, and select all rows between there and the
		// last selected row.
		NSIndexPath *firstIndex = (self.selectedIndexes.count > 0 ? self.selectedIndexes[0] : nil);
		if (firstIndex != nil) {
			[indexesToSelect addObject:firstIndex];
			
			NSComparisonResult order = [firstIndex compare:indexPath];
			NSIndexPath *nextIndex = [self indexPathForNextSelectableRowFromIndex:firstIndex withOrder:order];
			while (nextIndex != nil && ![nextIndex isEqual:indexPath]) {
				[indexesToSelect addObject:nextIndex];
				nextIndex = [self indexPathForNextSelectableRowFromIndex:nextIndex withOrder:order];
			}
		}
		
		[indexesToSelect addObject:indexPath];
	}
	
	NSMutableSet *indexesToDeselect = [NSMutableSet setWithArray:self.selectedIndexes];
	[indexesToDeselect minusSet:indexesToSelect];
	
	[self selectRowsAtIndexPaths:indexesToSelect.allObjects animated:animated];
	[self deselectRowsAtIndexPaths:indexesToDeselect.allObjects animated:animated];
	[self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)mouseDownInTableViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event {
	NSIndexPath *indexPath = [self indexPathForCell:cell];
	if (indexPath == nil) {
		NSLog(@"***index path not found for selection.");
	}
	
	// Detect if modifier flags are held down.
	// We prioritize the command key over the shift key.
	if (event.modifierFlags & NSCommandKeyMask) {
#warning TODO: animated flag should be a property
		[self selectRowAtIndexPath:indexPath atScrollPosition:JNWTableViewScrollPositionNearest animated:YES selectionType:JNWTableViewSelectionTypeMultiple];
	} else if (event.modifierFlags & NSShiftKeyMask) {
		[self selectRowAtIndexPath:indexPath atScrollPosition:JNWTableViewScrollPositionNearest animated:YES selectionType:JNWTableViewSelectionTypeExtending];
	} else {
		[self selectRowAtIndexPath:indexPath atScrollPosition:JNWTableViewScrollPositionNearest animated:YES];
	}
}

- (void)keyDown:(NSEvent *)theEvent {
	[self interpretKeyEvents:@[theEvent]];
}

- (void)moveUp:(id)sender {
	[self selectRowAtIndexPath:[self indexPathForPreviousSelectableRow] atScrollPosition:JNWTableViewScrollPositionNearest animated:YES];}

- (void)moveUpAndModifySelection:(id)sender {
#warning This, along with the corresponding moveDown* method, do not function properly.
	[self selectRowAtIndexPath:[self indexPathForPreviousSelectableRow] atScrollPosition:JNWTableViewScrollPositionNearest animated:YES selectionType:JNWTableViewSelectionTypeExtending];
}

- (void)moveDown:(id)sender {
	[self selectRowAtIndexPath:[self indexPathForNextSelectableRow] atScrollPosition:JNWTableViewScrollPositionNearest animated:YES];
}

- (void)moveDownAndModifySelection:(id)sender {
	[self selectRowAtIndexPath:[self indexPathForNextSelectableRow] atScrollPosition:JNWTableViewScrollPositionNearest animated:YES selectionType:JNWTableViewSelectionTypeExtending];
}

- (void)selectAll:(id)sender {
	// TODO animate
	[self selectRowsAtIndexPaths:[self allIndexPaths] animated:YES];
}

@end
