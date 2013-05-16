//
//  JNWCollectionViewCell+Private.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionView.h"

@interface JNWCollectionViewCell ()
@property (nonatomic, copy, readwrite) NSString *reuseIdentifier;
@property (nonatomic, assign, readwrite) JNWCollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSIndexPath *indexPath;
@end
