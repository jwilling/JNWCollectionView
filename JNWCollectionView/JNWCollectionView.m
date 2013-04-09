#import "JNWCollectionView.h"
#import "RBLClipView.h"
#import "JNWCollectionViewSection.h"
#import "JNWCollectionView+Private.h"
#import "JNWCollectionViewCell+Private.h"
#import <QuartzCore/QuartzCore.h>

//static const NSUInteger JNWCollectionViewMaximumNumberOfQueuedCells = 2;
//static const CGFloat JNWCollectionViewDefaultRowHeight = 44.f;
static const CGSize JNWCollectionViewDefaultSize = (CGSize){ 44.f, 44.f };
static const CGFloat JNWCollectionViewDefaultHorizontalPadding = 0.f;
static const CGFloat JNWCollectionViewDefaultVerticalPadding = 0.f;

typedef NS_ENUM(NSInteger, JNWCollectionViewSelectionType) {
	JNWCollectionViewSelectionTypeSingle,
	JNWCollectionViewSelectionTypeExtending,
	JNWCollectionViewSelectionTypeMultiple
};

@interface JNWCollectionView() {
	struct {
		unsigned int delegateHeightForItem;
		unsigned int delegateHeightForHeader;
		unsigned int delegateHeightForFooter;
		unsigned int delegateWidthForItem;
		unsigned int delegateWidthForHeader;
		unsigned int delegateWidthForFooter;
		unsigned int delegateSizeForItem;
		
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
	//_self.rowHeight = JNWTableViewDefaultRowHeight;
	_self.itemVerticalPadding = JNWCollectionViewDefaultVerticalPadding;
	_self.itemHorizontalPadding = JNWCollectionViewDefaultHorizontalPadding;
	
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
	_tableFlags.delegateHeightForItem = [delegate respondsToSelector:@selector(collectionView:heightForItemAtIndexPath:)];
	_tableFlags.delegateHeightForHeader = [delegate respondsToSelector:@selector(collectionView:heightForHeaderInSection:)];
	_tableFlags.delegateHeightForFooter = [delegate respondsToSelector:@selector(collectionView:heightForFooterInSection:)];
	_tableFlags.delegateWidthForItem = [delegate respondsToSelector:@selector(collectionView:widthForItemAtIndexPath:)];
	_tableFlags.delegateWidthForHeader = [delegate respondsToSelector:@selector(collectionView:widthForHeaderAtIndexPath:)];
	_tableFlags.delegateWidthForFooter = [delegate respondsToSelector:@selector(collectionView:widthForFooterAtIndexPath:)];

	_tableFlags.delegateSizeForItem = [delegate respondsToSelector:@selector(collectionView:sizeForItemAtIndexPath:)];
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
	[self.sectionData removeAllObjects];
	
	CGFloat collectionViewHeight = 0.f;
	CGFloat collectionViewWidth = 0.f;
	BOOL verticalScroll = (self.scrollDirection == JNWCollectionViewScrollDirectionVertical);
	// Find how many sections we have in the collection view.
	// We default to 1 if the data source doesn't implement the optional method.
	NSUInteger numberOfSections = 1;
	if (_tableFlags.dataSourceNumberOfSections)
		numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
	
	for (NSInteger section = 0; section < numberOfSections; section++) {
		@autoreleasepool {
			// Create a new section
			NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:section];
			NSInteger headerHeight = (_tableFlags.delegateHeightForHeader ? [self.delegate collectionView:self heightForHeaderInSection:section] : 0);
			NSInteger footerHeight = (_tableFlags.delegateHeightForFooter ? [self.delegate collectionView:self heightForFooterInSection:section] : 0);
			
			JNWCollectionViewSection *sectionInfo = [[JNWCollectionViewSection alloc] initWithNumberOfItems:numberOfItems];
			sectionInfo.index = section;
			sectionInfo.headerHeight = headerHeight;
			sectionInfo.footerHeight = footerHeight;
			
			if (verticalScroll) {
				sectionInfo.verticalOffset = collectionViewHeight + headerHeight;
			} else {
				sectionInfo.horizontalOffset = collectionViewWidth + headerHeight;
			}
			
			// Calculate the individual height of each row, and also
			// keep track of the total height of the section.
			for (NSInteger item = 0; item < numberOfItems; item++) {
				CGSize itemSize = CGSizeZero;
				NSIndexPath *indexPath = [NSIndexPath jnw_indexPathForRow:item inSection:section];
				
				if (_tableFlags.delegateSizeForItem) {
					itemSize = [self.delegate collectionView:self sizeForItemAtIndexPath:indexPath];
				} else {
					if (_tableFlags.delegateHeightForItem)
						itemSize.height = [self.delegate collectionView:self heightForItemAtIndexPath:indexPath];
					else if (!_tableFlags.delegateWidthForItem) {
						// when height and width aren't specified
						itemSize = self.itemSize;
					} else {
						itemSize.height = CGRectGetHeight(self.documentVisibleRect) - 2*self.itemVerticalPadding;
					}
					
					if (_tableFlags.delegateWidthForItem) {
						itemSize.width = [self.delegate collectionView:self widthForItemAtIndexPath:indexPath];
					} else if (_tableFlags.delegateHeightForItem) {
						itemSize.width = CGRectGetWidth(self.documentVisibleRect) - 2*self.itemHorizontalPadding;
					}
				}
				
				// determine the position for the new item
				CGPoint position = CGPointMake(sectionInfo.width, sectionInfo.height);
				CGFloat deltaX = 0;
				CGFloat deltaY = 0;
				
				if (self.scrollDirection == JNWCollectionViewScrollDirectionVertical) {
					if (position.x + 2 * self.itemHorizontalPadding + itemSize.width > CGRectGetWidth(self.documentVisibleRect)) {
						deltaY = itemSize.height + self.itemVerticalPadding;
						position.x = self.itemHorizontalPadding;
						position.y += deltaY;
						sectionInfo.width = 0;
						
					} else {
						deltaX = self.itemHorizontalPadding + itemSize.width;
						position.x += self.itemHorizontalPadding;
					}
				}
#warning implement horizontal
				
				sectionInfo.itemInfo[item].size = itemSize;
				sectionInfo.itemInfo[item].xOffset = position.x;
				sectionInfo.itemInfo[item].yOffset = position.y;
				
				sectionInfo.height += deltaY;
				sectionInfo.width += deltaX;
			}
			
			collectionViewHeight += sectionInfo.height + headerHeight + footerHeight;
			collectionViewWidth += sectionInfo.width + headerHeight + footerHeight;
			[self.sectionData addObject:sectionInfo];
		}
	}
	
	if (self.scrollDirection == JNWCollectionViewScrollDirectionVertical) {
		self.contentSize = CGSizeMake(CGRectGetWidth(self.documentVisibleRect), collectionViewHeight);
	} else {
		self.contentSize = CGSizeMake(collectionViewWidth, CGRectGetHeight(self.documentVisibleRect));
	}

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
			[indexPaths addObject:[NSIndexPath jnw_indexPathForRow:row inSection:section.index]];
		}
	}
	
	return indexPaths.copy;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
	NSMutableArray *visibleRows = [NSMutableArray array];
	BOOL verticalScroll = (self.scrollDirection == JNWCollectionViewScrollDirectionVertical);
	
	CGFloat side1 = (verticalScroll ? rect.origin.y : rect.origin.x);
	CGFloat side2 = side1 + (verticalScroll ? rect.size.height : rect.size.width);
	
	for (JNWCollectionViewSection *section in self.sectionData) {
		NSUInteger numberOfItems = section.numberOfItems;
		if (verticalScroll && (section.verticalOffset + section.height < side1 || section.verticalOffset > side2)) {
			continue;
		} else if (!verticalScroll && (section.horizontalOffset + section.width < side1 || section.horizontalOffset > side2)) {
			continue;
		}
		
		for (NSInteger item = 0; item < numberOfItems; item++) {
			CGFloat absoluteItemOffset = (verticalScroll ? section.verticalOffset + section.itemInfo[item].yOffset
										  : section.horizontalOffset + section.itemInfo[item].xOffset);
			CGFloat absoluteItemTopOrSide = absoluteItemOffset + (verticalScroll ? section.itemInfo[item].size.height
																  : section.itemInfo[item].size.width);
			
			if (absoluteItemTopOrSide < side1)
				continue;
			else if (absoluteItemOffset > side2)
				break;
			else if (absoluteItemTopOrSide >= side1 && absoluteItemOffset <= side2) {
				[visibleRows addObject:[NSIndexPath jnw_indexPathForRow:item inSection:section.index]];
			}
		}
	}
	return visibleRows;
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
	return (indexPath.section < self.sectionData.count && indexPath.row < [self.sectionData[indexPath.section] numberOfItems]);
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
		case JNWCollectionViewScrollPositionNone:
			// no scroll needed
			break;
		case JNWCollectionViewScrollPositionNearest:
		default:
			break;
	}
	
	[(RBLClipView *)self.contentView scrollRectToVisible:rect animated:animated];
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil || indexPath.section >= self.sectionData.count)
		return CGRectZero;
	
	JNWCollectionViewSection *section = self.sectionData[indexPath.section];
	CGFloat horizontalOffset = [section horizontalOffsetForItemAtIndex:indexPath.row];
	CGFloat verticalOffset = [section verticalOffsetForItemAtIndex:indexPath.row];
	return (CGRect){ .size = [section sizeForItemAtIndex:indexPath.row], .origin = CGPointMake(horizontalOffset, verticalOffset)};
}

- (CGRect)rectForHeaderInSection:(NSInteger)index {
	JNWCollectionViewSection *section = self.sectionData[index];
#warning implement this
	return CGRectZero;
	//return CGRectMake(0.f, section.offset - section.headerHeight, self.bounds.size.width, section.headerHeight);
}

- (CGRect)rectForFooterInSection:(NSInteger)index {
	JNWCollectionViewSection *section = self.sectionData[index];
#warning implement this
	return CGRectZero;
	//return CGRectMake(0.f, section.offset + section.height, self.bounds.size.width, section.footerHeight);
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
#warning implement this
	/*
	CGFloat top = rect.origin.y;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	NSMutableIndexSet *visibleHeaders = [NSMutableIndexSet indexSet];
	
	for (JNWCollectionViewSection *section in self.sectionData) {
		CGFloat headerTopOffset = section.offset - section.headerHeight;
		if (section.headerHeight > 0 && section.offset >= top && headerTopOffset <= bottom)
			[visibleHeaders addIndex:section.index];
	}
	
	return visibleHeaders;
	 */
	return nil;
}

- (NSIndexSet *)indexesForFootersInRect:(CGRect)rect {
#warning implement this
	/*
	CGFloat top = rect.origin.y;
	CGFloat bottom = rect.origin.y + rect.size.height;
	
	NSMutableIndexSet *visibleFooters = [NSMutableIndexSet indexSet];
	
	for (JNWCollectionViewSection *section in self.sectionData) {
		CGFloat footerTopOffset = section.offset + section.height;
		if (section.footerHeight > 0 && footerTopOffset + section.footerHeight >= top && footerTopOffset <= bottom)
			[visibleFooters addIndex:section.index];
	}
	
	return visibleFooters;
	 */
	return nil;
}

- (JNWCollectionViewSection *)sectionForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == nil)
		return nil;
	
	return self.sectionData[indexPath.section];
}


#pragma mark Layout

- (void)layout {
	[super layout];
	
	if (CGSizeEqualToSize([self.documentView frame].size, self.contentSize)) {
		[self layoutDocumentView];
	}
	
	if (!CGRectEqualToRect(self.bounds, _lastDrawnBounds)) {
#warning TODO: Determine whether item recalculation is needed.
		[self recalculateItemInfo];
		
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
	documentView.frameSize = self.contentSize;//CGSizeMake(self.bounds.size.width, self.contentHeight);
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
		
		cell.tableView = self;
		cell.frame = [self rectForItemAtIndexPath:indexPath];
		
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

- (void)mouseDownInTableViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event {
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
#warning This, along with the corresponding moveDown* method, do not function properly.
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
