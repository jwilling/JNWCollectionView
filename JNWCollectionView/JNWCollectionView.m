#import "JNWCollectionView.h"
#import "RBLClipView.h"
#import "JNWCollectionViewSection.h"
#import "JNWCollectionView+Private.h"
#import "JNWCollectionViewCell+Private.h"
#import "JNWCollectionViewHeaderFooterView+Private.h"
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
		
		unsigned int delegateMouseDown;
		unsigned int delegateMouseUp;
		unsigned int delegateShouldSelect;
		unsigned int delegateDidSelect;
		unsigned int delegateShouldDeselect;
		unsigned int delegateDidDeselect;
	} _tableFlags;
	
	CGRect _lastDrawnBounds;
	BOOL _wantsLayout;
}

@property (nonatomic, strong) NSMutableArray *sectionData;
@property (nonatomic, assign) CGSize contentSize;

// Cells
@property (nonatomic, strong) NSMutableDictionary *reusableTableCells;
@property (nonatomic, strong) NSMutableDictionary *visibleCellsMap;
@property (nonatomic, strong) NSMutableDictionary *cellClassMap;

// Selection
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

// Headers and footers
@property (nonatomic, strong) NSMutableDictionary *visibleTableHeaders;
@property (nonatomic, strong) NSMutableDictionary *visibleTableFooters;
@property (nonatomic, strong) NSMutableDictionary *reusableTableHeadersFooters;
@property (nonatomic, strong) NSMutableDictionary *headerFooterClassMap;

@end

@implementation JNWCollectionView

static void JNWCollectionViewCommonInit(JNWCollectionView *_self) {
	_self.sectionData = [NSMutableArray array];
	_self.selectedIndexes = [NSMutableArray array];
	_self.cellClassMap = [NSMutableDictionary dictionary];
	_self.headerFooterClassMap = [NSMutableDictionary dictionary];
	_self.visibleCellsMap = [NSMutableDictionary dictionary];
	_self.visibleTableFooters = [NSMutableDictionary dictionary];
	_self.visibleTableHeaders = [NSMutableDictionary dictionary];	
	_self.reusableTableCells = [NSMutableDictionary dictionary];
	_self.reusableTableHeadersFooters = [NSMutableDictionary dictionary];
	
	// By default we are layer-backed.
	_self.wantsLayer = YES;
	
	// Set the document view to a custom class that returns YES to -isFlipped.
	_self.documentView = [[JNWCollectionViewDocumentView alloc] initWithFrame:CGRectZero];

	_self.hasHorizontalScroller = NO;
	_self.hasVerticalScroller = YES;
	
	_self.collectionViewLayout = [[JNWCollectionViewListLayout alloc] initWithCollectionView:_self];
	
	// We don't want to perform an initial layout pass until the user has called -reloadData.
	_self->_wantsLayout = NO;
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
	_tableFlags.delegateMouseUp = [delegate respondsToSelector:@selector(collectionView:mouseUpInItemAtIndexPath:)];
	_tableFlags.delegateMouseDown = [delegate respondsToSelector:@selector(collectionView:mouseDownInItemAtIndexPath:)];
	_tableFlags.delegateShouldSelect = [delegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)];
	_tableFlags.delegateDidSelect = [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
	_tableFlags.delegateShouldDeselect = [delegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)];
	_tableFlags.delegateDidDeselect = [delegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)];
}

- (void)setDataSource:(id<JNWCollectionViewDataSource>)dataSource {
	_dataSource = dataSource;
	_tableFlags.dataSourceNumberOfSections = [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)];
	_tableFlags.dataSourceViewForHeader = [dataSource respondsToSelector:@selector(collectionView:viewForHeaderInSection:)];
	_tableFlags.dataSourceViewForFooter = [dataSource respondsToSelector:@selector(collectionView:viewForFooterInSection:)];
	NSAssert([dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)],
			 @"data source must implement collectionView:numberOfItemsInSection");
	NSAssert([dataSource respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)],
			 @"data source must implement collectionView:cellForItemAtIndexPath:");
}


#pragma mark Queueing and dequeuing

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)reuseIdentifier {
	NSParameterAssert(cellClass);
	NSParameterAssert(reuseIdentifier);
	NSAssert([cellClass isSubclassOfClass:JNWCollectionViewCell.class], @"registered cell class must be a subclass of JNWCollectionViewCell");
	self.cellClassMap[reuseIdentifier] = cellClass;
}

- (void)registerClass:(Class)headerFooterClass forHeaderFooterWithReuseIdentifier:(NSString *)reuseIdentifier {
	NSParameterAssert(headerFooterClass);
	NSParameterAssert(reuseIdentifier);
	NSAssert([headerFooterClass isSubclassOfClass:JNWCollectionViewHeaderFooterView.class],
			 @"registered header/footer class must be a subclass of JNWCollectionViewHeaderFooterView");
	self.headerFooterClassMap[reuseIdentifier] = headerFooterClass;
}

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

- (JNWCollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);
	JNWCollectionViewCell *cell = [self dequeueItemWithIdentifier:identifier inReusePool:self.reusableTableCells];

	// If the view doesn't exist, we go ahead and create one. If we have a class registered
	// for this identifier, we use it, otherwise we just create an instance of JNWCollectionViewCell.
	if (cell == nil) {
		Class cellClass = self.cellClassMap[identifier];

		if (cellClass == nil) {
			cellClass = JNWCollectionViewCell.class;
		}
		
		cell = [[cellClass alloc] initWithFrame:CGRectZero];
	}
	
	cell.reuseIdentifier = identifier;
	[cell prepareForReuse];
	return cell;
}

- (JNWCollectionViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifer:(NSString *)identifier {
	NSParameterAssert(identifier);
	JNWCollectionViewHeaderFooterView *headerFooter = [self dequeueItemWithIdentifier:identifier inReusePool:self.reusableTableHeadersFooters];

	if (headerFooter == nil) {
		Class headerFooterClass = self.headerFooterClassMap[identifier];
		if (headerFooterClass == nil) {
			headerFooterClass = JNWCollectionViewHeaderFooterView.class;
		}
		
		headerFooter = [[headerFooterClass alloc] initWithFrame:CGRectZero];
	}
	
	return headerFooter;
}

- (void)enqueueReusableHeaderFooterView:(JNWCollectionViewHeaderFooterView *)view withIdentifier:(NSString *)identifier {
	[self enqueueItem:view withIdentifier:identifier inReusePool:self.reusableTableHeadersFooters];
}

- (void)enqueueReusableCell:(JNWCollectionViewCell *)cell withIdentifier:(NSString *)identifier {
	[self enqueueItem:cell withIdentifier:identifier inReusePool:self.reusableTableCells];
}

- (void)reloadData {
	_wantsLayout = YES;
	
	// Remove any selected indexes we've been tracking.
	[self.selectedIndexes removeAllObjects];
	
	// Remove any queued views.
	[self.reusableTableCells removeAllObjects];
	[self.reusableTableHeadersFooters removeAllObjects];
		
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
	// TODO: Optimize, and perhaps have an option to defer this to the layout class.
	for (JNWCollectionViewSection *section in self.sectionData) {
		if (!CGRectContainsPoint(section.sectionFrame, point))
			continue;
		
		NSUInteger numberOfItems = section.numberOfItems;
		for (NSInteger item = 0; item < numberOfItems; item++) {
			if (CGRectContainsPoint(section.itemInfo[item].frame, point)) {
				return [NSIndexPath jnw_indexPathForItem:item inSection:section.index];
			}
		}
	}
	
	return nil;
}

- (NSArray *)visibleCells {
	return self.visibleCellsMap.allValues;
}

- (BOOL)validateIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.section < self.sectionData.count && indexPath.item < [self.sectionData[indexPath.section] numberOfItems]);
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
		
		// Check once more whether or not the document view needs to be resized.
		// If there are a different number of items, `contentSize` might have changed.
		if (!CGSizeEqualToSize([self.documentView frame].size, self.contentSize)) {
			[self layoutDocumentView];
		}
		
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
	if (!_wantsLayout)
		return;
	
	NSView *documentView = self.documentView;
	documentView.frameSize = self.contentSize;
}

- (void)layoutCells {
	[self layoutCellsWithRedraw:NO];
}

- (void)layoutCellsWithRedraw:(BOOL)needsVisibleRedraw {
	if (self.dataSource == nil || !_wantsLayout)
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
	}
	
	// Add the new cells
	for (NSIndexPath *indexPath in indexPathsToAdd) {
		JNWCollectionViewCell *cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
		
		// If any of these are true this cell isn't valid, and we'll be forced to skip it and throw the relevant exceptions.
		if (cell == nil || ![cell isKindOfClass:JNWCollectionViewCell.class]) {
			NSAssert(cell != nil, @"collectionView:cellForItemAtIndexPath: must return a non-nil cell.");
			// Although we have checked to ensure the class registered for the cell is a subclass
			// of JNWCollectionViewCell earlier, there's always the chance that the user has
			// not used the dedicated dequeuing method to retrieve their newly created cell and
			// instead have just created it themselves. There's not much we can do to prevent this,
			// so it's probably worth it to double check this one more time.
			NSAssert([cell isKindOfClass:JNWCollectionViewCell.class],
					 @"collectionView:cellForItemAtIndexPath: must return an instance or subclass of JNWCollectionViewCell.");
			continue;
		}
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
	if ((!_tableFlags.dataSourceViewForHeader && !_tableFlags.dataSourceViewForFooter) || !_wantsLayout)
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
			NSLog(@"nil view returned for %@", NSStringFromSelector(@selector(collectionView:viewForHeaderInSection:)));
		} else {
			if ([header isKindOfClass:JNWCollectionViewHeaderFooterView.class]) {
				header.frame = [self rectForHeaderInSection:idx];
				[self.documentView addSubview:header];
				
				self.visibleTableHeaders[@(idx)] = header;
			} else {
				NSAssert(NO, @"view returned from %@ should be a subclass of %@", NSStringFromSelector(@selector(collectionView:viewForHeaderInSection:)), NSStringFromClass(JNWCollectionViewHeaderFooterView.class));
			}
		}
	}];
	
	[footerIndexesToAdd enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		JNWCollectionViewHeaderFooterView *footer = [self.dataSource collectionView:self viewForFooterInSection:idx];
		if (footer == nil) {
			NSLog(@"nil view returned for %@", NSStringFromSelector(@selector(collectionView:viewForFooterInSection:)));
		} else {
			if ([footer isKindOfClass:JNWCollectionViewHeaderFooterView.class]) {
				
				footer.frame = [self rectForFooterInSection:idx];
				[self.documentView addSubview:footer];
				
				self.visibleTableFooters[@(idx)] = footer;
			} else {
				NSAssert(NO, @"view returned from %@ should be a subclass of %@", NSStringFromSelector(@selector(collectionView:viewForFooterInSection:)), NSStringFromClass(JNWCollectionViewHeaderFooterView.class));
			}
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

- (NSArray *)indexPathsForSelectedItems {
	return self.selectedIndexes.copy;
}

- (void)deselectItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated {
	for (NSIndexPath *indexPath in indexPaths) {
		[self deselectItemAtIndexPath:indexPath animated:animated];
	}
}

- (void)selectItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated {
	for (NSIndexPath *indexPath in indexPaths) {
		[self selectItemAtIndexPath:indexPath animated:animated];
	}
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	if (_tableFlags.delegateShouldDeselect && ![self.delegate collectionView:self shouldDeselectItemAtIndexPath:indexPath])
		return;
	
	// TODO animated
	JNWCollectionViewCell *cell = [self cellForRowAtIndexPath:indexPath];
	cell.selected = NO;
	[self.selectedIndexes removeObject:indexPath];
	
	if (_tableFlags.delegateDidDeselect)
		[self.delegate collectionView:self didDeselectItemAtIndexPath:indexPath];
}



- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	if (_tableFlags.delegateShouldSelect && ![self.delegate collectionView:self shouldSelectItemAtIndexPath:indexPath])
		return;
	
	// TODO animated
	JNWCollectionViewCell *cell = [self cellForRowAtIndexPath:indexPath];
	cell.selected = YES;
	[self.selectedIndexes addObject:indexPath];
	
	if (_tableFlags.delegateDidSelect)
		[self.delegate collectionView:self didSelectItemAtIndexPath:indexPath];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
			atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition
					animated:(BOOL)animated {
	[self selectItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated selectionType:JNWCollectionViewSelectionTypeSingle];
}

- (NSIndexPath *)indexPathForNextSelectableItemAfterIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.item + 1 >= [self.sectionData[indexPath.section] numberOfItems]) {
		// Jump up to the next section
		NSIndexPath *newIndexPath = [NSIndexPath jnw_indexPathForItem:0 inSection:indexPath.section + 1];
		if ([self validateIndexPath:newIndexPath])
			return newIndexPath;
	} else {
		return [NSIndexPath jnw_indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
	}
	return nil;
}

- (NSIndexPath *)indexPathForNextSelectableItemBeforeIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.item - 1 >= 0) {
		return [NSIndexPath jnw_indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
	} else if(indexPath.section - 1 >= 0 && self.sectionData.count) {
		NSInteger numberOfItems = [self.sectionData[indexPath.section - 1] numberOfItems];
		NSIndexPath *newIndexPath = [NSIndexPath jnw_indexPathForItem:numberOfItems - 1 inSection:indexPath.section - 1];
		if ([self validateIndexPath:newIndexPath])
			return newIndexPath;
	}
	return nil;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
			atScrollPosition:(JNWCollectionViewScrollPosition)scrollPosition
					animated:(BOOL)animated
			   selectionType:(JNWCollectionViewSelectionType)selectionType {
	if (indexPath == nil)
		return;
	
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
			
			if (![firstIndex isEqual:indexPath]) {
				NSComparisonResult order = [firstIndex compare:indexPath];
				NSIndexPath *nextIndex = firstIndex;
				
				while (nextIndex != nil && ![nextIndex isEqual:indexPath]) {
					[indexesToSelect addObject:nextIndex];
					
					if (order == NSOrderedAscending) {
						nextIndex = [self indexPathForNextSelectableItemAfterIndexPath:nextIndex];
					} else if (order == NSOrderedDescending) {
						nextIndex = [self indexPathForNextSelectableItemBeforeIndexPath:nextIndex];
					}
				}
			}
		}
		
		[indexesToSelect addObject:indexPath];
	}
	
	NSMutableSet *indexesToDeselect = [NSMutableSet setWithArray:self.selectedIndexes];
	[indexesToDeselect minusSet:indexesToSelect];
	
	[self selectItemsAtIndexPaths:indexesToSelect.allObjects animated:animated];
	[self deselectItemsAtIndexPaths:indexesToDeselect.allObjects animated:animated];
	[self scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)mouseDownInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event {
	[self.window makeFirstResponder:self];
	
	NSIndexPath *indexPath = [self indexPathForCell:cell];
	if (indexPath == nil) {
		NSLog(@"***index path not found for selection.");
	}
	
	if (_tableFlags.delegateMouseDown) {
		[self.delegate collectionView:self mouseDownInItemAtIndexPath:indexPath];
	}
	
	// Detect if modifier flags are held down.
	// We prioritize the command key over the shift key.
	if (event.modifierFlags & NSCommandKeyMask) {
		[self selectItemAtIndexPath:indexPath atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection selectionType:JNWCollectionViewSelectionTypeMultiple];
	} else if (event.modifierFlags & NSShiftKeyMask) {
		[self selectItemAtIndexPath:indexPath atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection selectionType:JNWCollectionViewSelectionTypeExtending];
	} else {
		[self selectItemAtIndexPath:indexPath atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection];
	}
}

- (void)mouseUpInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event {
	if (_tableFlags.delegateMouseUp) {
		NSIndexPath *indexPath = [self indexPathForCell:cell];
		
		[self.delegate collectionView:self mouseUpInItemAtIndexPath:indexPath];
	}
}

- (void)keyDown:(NSEvent *)theEvent {
	[self interpretKeyEvents:@[theEvent]];
}

- (void)moveUp:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionUp currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection];}

- (void)moveUpAndModifySelection:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionUp currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection selectionType:JNWCollectionViewSelectionTypeExtending];
}

- (void)moveDown:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionDown currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection];
}

- (void)moveDownAndModifySelection:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionDown currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection selectionType:JNWCollectionViewSelectionTypeExtending];
}

- (void)moveRight:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionRight currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection];
}

- (void)moveRightAndModifySelection:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionRight currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection selectionType:JNWCollectionViewSelectionTypeExtending];
}

- (void)moveLeft:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionLeft currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection];
}

- (void)moveLeftAndModifySelection:(id)sender {
	NSIndexPath *toSelect = [self.collectionViewLayout indexPathForNextItemInDirection:JNWCollectionViewDirectionLeft currentIndexPath:[self indexPathForSelectedRow]];
	[self selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNearest animated:self.animatesSelection selectionType:JNWCollectionViewSelectionTypeExtending];
}

- (void)selectAll:(id)sender {
	[self selectItemsAtIndexPaths:[self allIndexPaths] animated:self.animatesSelection];
}

- (void)deselectAllItems {
	[self deselectItemsAtIndexPaths:[self allIndexPaths] animated:self.animatesSelection];
}

- (void)selectAllItems {
	[self selectAll:nil];
}

@end
