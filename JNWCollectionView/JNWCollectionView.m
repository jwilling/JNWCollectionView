#import "JNWCollectionView.h"
#import "RBLClipView.h"
#import "JNWCollectionViewSection.h"
#import "JNWCollectionView+Private.h"
#import "JNWCollectionViewCell+Private.h"
#import <QuartzCore/QuartzCore.h>
#import "JNWCollectionViewListLayout.h"
#import "JNWCollectionViewDocumentView.h"

//static const NSUInteger JNWCollectionViewMaximumNumberOfQueuedCells = 2;

typedef NS_ENUM(NSInteger, JNWCollectionViewSelectionType) {
	JNWCollectionViewSelectionTypeSingle,
	JNWCollectionViewSelectionTypeExtending,
	JNWCollectionViewSelectionTypeMultiple
};

@interface JNWCollectionView() {
	struct {
		unsigned int dataSourceNumberOfSections;
		unsigned int dataSourceViewForHeader;
		unsigned int dataSourceViewForFooter;
	} _tableFlags;
	
	CGRect _lastDrawnBounds;
}

@property (nonatomic, strong) NSMutableArray *sectionData;
@property (nonatomic, assign) CGSize contentSize;

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

static void JNWCollectionViewCommonInit(JNWCollectionView *_self) {
	_self.sectionData = [NSMutableArray array];
	_self.selectedIndexes = [NSMutableArray array];
	_self.visibleCellsMap = [NSMutableDictionary dictionary];
	_self.visibleTableFooters = [NSMutableDictionary dictionary];
	_self.visibleTableHeaders = [NSMutableDictionary dictionary];
	_self.scrollDirection = JNWCollectionViewScrollDirectionVertical;
	
	_self.reusableTableCells = [NSMutableDictionary dictionary];
	_self.reusableTableHeadersFooters = [NSMutableDictionary dictionary];
	
	// By default we are layer-backed.
	_self.wantsLayer = YES;
	
	_self.documentView = [[JNWCollectionViewDocumentView alloc] initWithFrame:CGRectZero];
	
	// Flip the document view since it's easier to lay out
	// starting from the top, not the bottom.
	[_self.documentView setFlipped:YES];
	
	_self.collectionViewLayout = [[JNWCollectionViewListLayout alloc] initWithCollectionView:_self];
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	JNWCollectionViewCommonInit(self);
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	JNWCollectionViewCommonInit(self);
	return self;
}

#pragma mark Delegate and data source

- (void)setDelegate:(id<JNWCollectionViewDelegate>)delegate {	
	_delegate = delegate;
}

- (void)setDataSource:(id<JNWCollectionViewDataSource>)dataSource {
	_dataSource = dataSource;
	_tableFlags.dataSourceNumberOfSections = [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)];
	_tableFlags.dataSourceViewForHeader = [dataSource respondsToSelector:@selector(collectionView:viewForHeaderInSection:)];
	_tableFlags.dataSourceViewForFooter = [dataSource respondsToSelector:@selector(collectionView:viewForFooterInSection:)];
	NSAssert([dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)],
			 @"data source must implement collectionView:numberOfItemsInSection");
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
	[self recalculateItemInfo];	
	[self layoutDocumentView];
	[self layoutCells];
	[self layoutHeaderFooters];
}

- (void)recalculateItemInfo {
	NSAssert(self.collectionViewLayout != nil, @"layout cannot be nil.");
	
	[self.sectionData removeAllObjects];
	
	
	// Find how many sections we have in the collection view.
	// We default to 1 if the data source doesn't implement the optional method.
	NSUInteger numberOfSections = 1;
	if (_tableFlags.dataSourceNumberOfSections)
		numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
	
	// We run an initial pass through the sections and create empty section data so that
	// the layout can query for this information when it calculates the frames.
	for (NSInteger section = 0; section < numberOfSections; section++) {
		NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:section];
		JNWCollectionViewSection *sectionInfo = [[JNWCollectionViewSection alloc] initWithNumberOfItems:numberOfItems];
		sectionInfo.index = section;
		[self.sectionData addObject:sectionInfo];
	}
		
	
	// Tell our layout we are about to need new layout data.
	[self.collectionViewLayout prepareLayout];
	
	
	CGRect contentFrame = CGRectZero;

	// Now we go through and fill in the frames from the layout.
	for (NSInteger section = 0; section < numberOfSections; section++) {
		JNWCollectionViewSection *sectionInfo = self.sectionData[section];
		sectionInfo.headerFrame = [self.collectionViewLayout rectForHeaderAtIndex:section];
		sectionInfo.footerFrame = [self.collectionViewLayout rectForFooterAtIndex:section];
		
		CGRect sectionFrame = CGRectZero;
		CGRect previousRect = CGRectZero;
		for (NSInteger item = 0; item < sectionInfo.numberOfItems; item++) {
			NSIndexPath *indexPath = [NSIndexPath jnw_indexPathForItem:item inSection:section];
			CGRect itemFrame = [self.collectionViewLayout rectForItemAtIndexPath:indexPath];
			sectionInfo.itemInfo[item].frame = itemFrame;
			previousRect = itemFrame;
			
			sectionFrame = CGRectUnion(sectionFrame, itemFrame);
		}
		
		sectionFrame = CGRectUnion(sectionFrame, sectionInfo.headerFrame);
		sectionFrame = CGRectUnion(sectionFrame, sectionInfo.footerFrame);
		sectionInfo.sectionFrame = sectionFrame;
		
		contentFrame = CGRectUnion(contentFrame, sectionFrame);
	}
	
	self.contentSize = contentFrame.size;
}

- (void)setScrollDirection:(JNWCollectionViewScrollDirection)scrollDirection {
	if (scrollDirection == JNWCollectionViewScrollDirectionHorizontal) {
		self.hasVerticalScroller = NO;
		self.hasHorizontalScroller = YES;
	} else {
		self.hasHorizontalScroller = NO;
		self.hasVerticalScroller = YES;
	}
	
	//TODO: Fully implement this.
}

#pragma mark Cell Information

- (NSInteger)numberOfSections {
	return self.sectionData.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	if (self.sectionData.count < section)
		return 0.f;
	return [(JNWCollectionViewSection *)self.sectionData[section] numberOfItems];
}

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point {
#warning implement
	return nil;
}

- (NSArray *)visibleCells {
	return self.visibleCellsMap.allValues;
}

- (NSArray *)allIndexPaths {
	NSMutableArray *indexPaths = [NSMutableArray array];
	for (JNWCollectionViewSection *section in self.sectionData) {
		for (NSInteger row = 0; row < section.numberOfItems; row++) {
			[indexPaths addObject:[NSIndexPath jnw_indexPathForItem:row inSection:section.index]];
		}
	}
	
	return indexPaths.copy;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
	if ([self.collectionViewLayout wantsIndexPathsForItemsInRect]) {
		return [self.collectionViewLayout indexPathsForItemsInRect:rect];
	}
		
	NSMutableArray *visibleRows = [NSMutableArray array];
	
	for (JNWCollectionViewSection *section in self.sectionData) {
		if (!CGRectIntersectsRect(section.sectionFrame, rect))
			continue;
		
		NSUInteger numberOfItems = section.numberOfItems;
		for (NSInteger item = 0; item < numberOfItems; item++) {
			if (CGRectIntersectsRect(section.itemInfo[item].frame, rect)) {
				[visibleRows addObject:[NSIndexPath jnw_indexPathForItem:item inSection:section.index]];
			}
			
		}
	}
	return visibleRows;
}

- (NSIndexSet *)indexesForHeadersInRect:(CGRect)rect {
	NSMutableIndexSet *visibleHeaders = [NSMutableIndexSet indexSet];
	
	for (JNWCollectionViewSection *section in self.sectionData) {
		if (CGRectIntersectsRect(section.headerFrame, rect) && !CGRectIsEmpty(section.headerFrame))
			[visibleHeaders addIndex:section.index];
	}
	
	return visibleHeaders;
}

- (NSIndexSet *)indexesForFootersInRect:(CGRect)rect {
	NSMutableIndexSet *visibleFooters = [NSMutableIndexSet indexSet];
	
	for (JNWCollectionViewSection *section in self.sectionData) {
		if (CGRectIntersectsRect(section.footerFrame, rect) && !CGRectIsEmpty(section.footerFrame))
			[visibleFooters addIndex:section.index];
	}
	
	return visibleFooters;
}

- (NSArray *)indexPathsForVisibleItems {
	return [self indexPathsForItemsInRect:self.documentVisibleRect];
}

- (JNWCollectionViewHeaderFooterView *)headerViewForSection:(NSInteger)section {
	return self.visibleTableHeaders[@(section)];
}

- (JNWCollectionViewHeaderFooterView *)footerViewForSection:(NSInteger)section {
	return self.visibleTableFooters[@(section)];
}

- (BOOL)validateIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.section < self.sectionData.count && indexPath.item < [self.sectionData[indexPath.section] numberOfItems]);
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
	CGRect rect = [self rectForItemAtIndexPath:indexPath];
	CGRect visibleRect = self.documentVisibleRect;
#warning this is actually pretty broken. get it working with horizontal scroll
	
	switch (scrollPosition) {
			break;
		case JNWCollectionViewScrollPositionTop:
			// make the top of our rect flush with the top of the visible bounds
			rect.size.height = visibleRect.size.height;
			//rect.origin.y = self.documentVisibleRect.origin.y + rect.size.height;
			break;
		case JNWCollectionViewScrollPositionMiddle:
			// TODO
			break;
		case JNWCollectionViewScrollPositionBottom:
			// make the bottom of our rect flush with the bottom of the visible bounds
			//rect.origin.y = self.documentVisibleRect.origin.y + self.documentVisibleRect.size.height;
			rect.size.height = visibleRect.size.height;
			rect.origin.y -= visibleRect.size.height;
			break;
		case JNWCollectionViewScrollPositionNearest:
			
			break;
		case JNWCollectionViewScrollPositionNone:
			// no scroll needed
		default:
			break;
	}
	
	[(RBLClipView *)self.contentView scrollRectToVisible:rect animated:animated];
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil || indexPath.section < self.sectionData.count) {
		JNWCollectionViewSection *section = self.sectionData[indexPath.section];
		return section.itemInfo[indexPath.item].frame;
	}
	
	return CGRectZero;
}

- (CGRect)rectForHeaderInSection:(NSInteger)index {
	if (index >= 0 && index < self.sectionData.count) {
		JNWCollectionViewSection *section = self.sectionData[index];
		return section.headerFrame;
	}
	return CGRectZero;
}

- (CGRect)rectForFooterInSection:(NSInteger)index {
	if (index >= 0 && index < self.sectionData.count) {
		JNWCollectionViewSection *section = self.sectionData[index];
		return section.footerFrame;
	}
	return CGRectZero;
}

- (CGRect)rectForSection:(NSInteger)index {
	if (index >= 0 && index < self.sectionData.count) {
		JNWCollectionViewSection *section = self.sectionData[index];
		return section.sectionFrame;
	}
	return CGRectZero;
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

- (JNWCollectionViewSection *)sectionForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil)
		return nil;
	
	return self.sectionData[indexPath.section];
}


#pragma mark Layout

- (void)layout {
	[super layout];
	
	if (!CGSizeEqualToSize([self.documentView frame].size, self.contentSize)) {
		[self layoutDocumentView];
	}
	
	if (!CGRectEqualToRect(self.bounds, _lastDrawnBounds)) {
		// TODO: Do we need to recalculate everything?
		[self recalculateItemInfo];
		
		[self layoutCellsWithRedraw:YES];
		[self layoutHeaderFootersWithRedraw:YES];
		_lastDrawnBounds = self.bounds;
		NSLog(@"%@ cached rects invalid, redrawing.", self);
	} else {
		[self layoutCells];
		[self layoutHeaderFooters];
	}
}

- (void)layoutDocumentView {
	NSView *documentView = self.documentView;
	documentView.frameSize = self.contentSize;
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
			cell.frame = [self rectForItemAtIndexPath:indexPath];
			[cell setNeedsLayout:YES];
		}
	}

	NSArray *oldVisibleIndexPaths = [self.visibleCellsMap allKeys];
	NSArray *updatedVisibleIndexPaths = [self indexPathsForItemsInRect:self.documentVisibleRect];


	NSMutableArray *indexPathsToRemove = [NSMutableArray arrayWithArray:oldVisibleIndexPaths];
	[indexPathsToRemove removeObjectsInArray:updatedVisibleIndexPaths];
	
	NSMutableArray *indexPathsToAdd = [NSMutableArray arrayWithArray:updatedVisibleIndexPaths];
	[indexPathsToAdd removeObjectsInArray:oldVisibleIndexPaths];
	
	// Remove old cells and put them in the reuse queue
	for (NSIndexPath *indexPath in indexPathsToRemove) {
		JNWCollectionViewCell *cell = [self cellForRowAtIndexPath:indexPath];
		[self.visibleCellsMap removeObjectForKey:indexPath];

		[self enqueueReusableCell:cell withIdentifier:cell.reuseIdentifier];
		
		[cell setHidden:YES];
		// TODO: Ensure setting views hidden will not be detrimental to performance.
	}
	
	// Add the new cells
	for (NSIndexPath *indexPath in indexPathsToAdd) {
		JNWCollectionViewCell *cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
		NSAssert(cell != nil, @"collectionView:cellForItemAtIndexPath: must return a non-nil cell.");
		
		cell.indexPath = indexPath;
		cell.collectionView = self;
		cell.frame = [self rectForItemAtIndexPath:indexPath];
		
		if (cell.superview == nil) {
			[self.documentView addSubview:cell];
		} else {
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
		JNWCollectionViewHeaderFooterView *header = [self.dataSource collectionView:self viewForHeaderInSection:idx];
		if (header == nil) {
			NSLog(@"header doesn't exist!");
		} else {
			header.frame = [self rectForHeaderInSection:idx];
			[self.documentView addSubview:header];
			
			self.visibleTableHeaders[@(idx)] = header;
		}
	}];
	
	[footerIndexesToAdd enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWCollectionViewHeaderFooterView *footer = [self.dataSource collectionView:self viewForFooterInSection:idx];
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
			NSInteger numberOfItems = [self.sectionData[section] numberOfItems];
			attemptedIndexPath = [NSIndexPath jnw_indexPathByIncrementingRow:indexPath withCurrentSectionNumberOfRows:numberOfItems];
			break;
		}
		case NSOrderedDescending: {
			NSInteger previousNumberOfItems = 0;
			if (section - 1 >= 0)
				previousNumberOfItems = [self.sectionData[section - 1] numberOfItems];
			attemptedIndexPath = [NSIndexPath jnw_indexPathByDecrementingRow:indexPath withPreviousSectionNumberOfRows:previousNumberOfItems];
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

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
			atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition
					animated:(BOOL)animated {
	[self selectRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated selectionType:JNWCollectionViewSelectionTypeSingle];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
			atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition
					animated:(BOOL)animated
			   selectionType:(JNWCollectionViewSelectionType)selectionType {
#warning implement extending selection
	NSMutableSet *indexesToSelect = [NSMutableSet set];
	
	if (selectionType == JNWCollectionViewSelectionTypeSingle) {
		[indexesToSelect addObject:indexPath];
	} else if (selectionType == JNWCollectionViewSelectionTypeMultiple) {
		[indexesToSelect addObjectsFromArray:self.selectedIndexes];
		if ([indexesToSelect containsObject:indexPath]) {
			[indexesToSelect removeObject:indexPath];
		} else {
			[indexesToSelect addObject:indexPath];
		}
	} else if (selectionType == JNWCollectionViewSelectionTypeExtending) {
		// From what I have determined, this behavior should be as follows.
		// Take the index selected first, and select all items between there and the
		// last selected item.
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
	[self scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)mouseDownInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event {
	[self.window makeFirstResponder:self];
	
	NSIndexPath *indexPath = [self indexPathForCell:cell];
	if (indexPath == nil) {
		NSLog(@"***index path not found for selection.");
	}
	
	// Detect if modifier flags are held down.
	// We prioritize the command key over the shift key.
	if (event.modifierFlags & NSCommandKeyMask) {
#warning TODO: animated flag should be a property
		[self selectRowAtIndexPath:indexPath atScrollPosition:JNWCollectionViewScrollPositionNearest animated:YES selectionType:JNWCollectionViewSelectionTypeMultiple];
	} else if (event.modifierFlags & NSShiftKeyMask) {
		[self selectRowAtIndexPath:indexPath atScrollPosition:JNWCollectionViewScrollPositionNearest animated:YES selectionType:JNWCollectionViewSelectionTypeExtending];
	} else {
		[self selectItemAtIndexPath:indexPath atScrollPosition:JNWCollectionViewScrollPositionNearest animated:YES];
	}
}

- (void)keyDown:(NSEvent *)theEvent {
	[self interpretKeyEvents:@[theEvent]];
}

- (void)moveUp:(id)sender {
	[self selectItemAtIndexPath:[self indexPathForPreviousSelectableRow] atScrollPosition:JNWCollectionViewScrollPositionNearest animated:YES];}

- (void)moveUpAndModifySelection:(id)sender {
#warning This, along with the corresponding moveDown* method, does not function properly.
	[self selectRowAtIndexPath:[self indexPathForPreviousSelectableRow] atScrollPosition:JNWCollectionViewScrollPositionNearest animated:YES selectionType:JNWCollectionViewSelectionTypeExtending];
}

- (void)moveDown:(id)sender {
	[self selectItemAtIndexPath:[self indexPathForNextSelectableRow] atScrollPosition:JNWCollectionViewScrollPositionNearest animated:YES];
}

- (void)moveDownAndModifySelection:(id)sender {
	[self selectRowAtIndexPath:[self indexPathForNextSelectableRow] atScrollPosition:JNWCollectionViewScrollPositionNearest animated:YES selectionType:JNWCollectionViewSelectionTypeExtending];
}

- (void)selectAll:(id)sender {
	// TODO animate
	[self selectRowsAtIndexPaths:[self allIndexPaths] animated:YES];
}

@end
