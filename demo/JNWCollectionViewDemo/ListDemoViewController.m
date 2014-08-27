//

#import "ListDemoViewController.h"
#import "ListHeader.h"
#import "ListCell.h"

static NSString * const cellIdentifier    = @"CELL",
                * const headerIdentifier  = @"HEADER";

@implementation ListDemoViewController { NSMutableArray *colors; JNWCollectionView *collectionView; }

- init { self = [super initWithNibName:nil bundle:nil];

    colors = @[].mutableCopy;
    for (float i = 0; i < 360; i++) {
      [colors addObject:[NSColor colorWithDeviceHue:i/360. saturation:1 brightness:1 alpha:1]];
    }
    return self;
}

- (void) loadView {

	self.view = [NSView.alloc initWithFrame:CGRectZero];
	self.view.wantsLayer = YES;
	
	[self.view addSubview:collectionView = [JNWCollectionView.alloc initWithFrame:self.view.bounds]];
	collectionView.autoresizingMask      = NSViewWidthSizable | NSViewHeightSizable;
	collectionView.dataSource            = self;
	JNWCollectionViewListLayout *layout  = JNWCollectionViewListLayout.new;
//	layout.rowHeight                   = 44.f;
	layout.delegate                      = self;
  layout.stickyHeaders                 = YES;
	collectionView.collectionViewLayout  = layout;
	
	[collectionView registerClass:ListCell.class   forCellWithReuseIdentifier:cellIdentifier];
	[collectionView registerClass:ListHeader.class forSupplementaryViewOfKind:JNWCollectionViewListLayoutHeaderKind withReuseIdentifier:headerIdentifier];
	
	collectionView.animatesSelection     = YES;
	[collectionView reloadData];
}

- (JNWCollectionViewCell*) collectionView:(JNWCollectionView*)v cellForItemAtIndexPath:(NSIndexPath*)iP {

	ListCell *cell       = (id)[v dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.cellLabelText   = [NSString stringWithFormat:@"%ld - sect:%ld row:%lu (%@)", iP.jnw_item, iP.jnw_section,iP.length, iP];
  cell.backgroundColor = colors[iP.jnw_item];
	return cell;
}

- (JNWCollectionViewReusableView*) collectionView:(JNWCollectionView*)v viewForSupplementaryViewOfKind:(NSString*)k inSection:(NSInteger)s {

	ListHeader *header     = (id)[v dequeueReusableSupplementaryViewOfKind:k withReuseIdentifer:headerIdentifier];
	header.headerLabelText = [NSString stringWithFormat:@"Header %ld - %@ Colors", s, s ? @"Cooler" : @"Warmer"];
	return header;
}

// Can be used in place of setting the collective height of the layout, as seen above in `-loadView`, if a variable-row height list view is wanted.

- (CGFloat)collectionView:(JNWCollectionView*)v heightForRowAtIndexPath:(NSIndexPath*)iP {

    return (arc4random() % 109) + 44.f;
}

- (NSUInteger)collectionView:(JNWCollectionView*)v numberOfItemsInSection:(NSInteger)s {

  return colors.count/2;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView*)v {

  return 2;
}

- (CGFloat)collectionView:(JNWCollectionView*)v heightForHeaderInSection:(NSInteger)index {
	return 24;
}

@end
