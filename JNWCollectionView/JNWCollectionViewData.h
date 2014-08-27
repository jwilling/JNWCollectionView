
typedef struct  {
	NSInteger index;
	CGRect frame;
	NSInteger numberOfItems;
} JNWCollectionViewSection;

@class JNWCollectionView;

@interface JNWCollectionViewData : NSObject

/// Designated initializer.
- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

/// Recalculates the local section cache from the layout and data source, optionally re-preparing the layout.
- (void)recalculateAndPrepareLayout:(BOOL)prepareLayout;

/// The number of sections that the data source has reported.
@property (readonly) NSInteger numberOfSections;

/// Returns the number of items in the specified section.
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/// Contains all of the sections cached from the last -recalculate call.
@property (readonly) JNWCollectionViewSection *sections;

/// The size that contains all of the sections. This size is used to determine the content size of the scroll view.
@property (readonly) CGSize encompassingSize;

@end
