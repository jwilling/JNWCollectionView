//
//  JNWCollectionViewData.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 5/18/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JNWCollectionView;

// This class holds information about the state of the items (not cells) in the collection view.
// It is not exposed publicly.
@interface JNWCollectionViewSection : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSInteger numberOfItems;
@end

@interface JNWCollectionViewData : NSObject

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

// Recalculates the local section cache from the layout and data source.
- (void)recalculate;

@property (nonatomic, assign) NSInteger numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

// Contains all of the sections cached from the last -recalculate call.
@property (nonatomic, strong, readonly) NSArray *sections;

@end
