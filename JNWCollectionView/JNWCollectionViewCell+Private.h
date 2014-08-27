
#import "JNWCollectionViewFramework.h"

@interface JNWCollectionViewCell ()
@property (nonatomic, copy, readwrite) NSString *reuseIdentifier;
@property (nonatomic, weak, readwrite) JNWCollectionView *collectionView;
@property (nonatomic, readwrite) NSIndexPath *indexPath;
@end
