
#import "JNWCollectionViewFramework.h"

@class JNWCollectionViewCell;
@interface JNWCollectionView ()

- (void)mouseExitedCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;
- (void)mouseEnteredCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;
- (void)mouseDownInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;
- (void)mouseUpInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;
- (void)doubleClickInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;
- (void)rightClickInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;

- (NSString *)kindForSupplementaryViewIdentifier:(NSString *)identifier;
- (NSArray *)allSupplementaryViewIdentifiers;

- (void)collectionViewLayoutWasInvalidated:(JNWCollectionViewLayout *)layout;

@end
