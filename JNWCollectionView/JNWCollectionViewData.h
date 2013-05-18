//
//  JNWCollectionViewData.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 5/18/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JNWCollectionView;

@interface JNWCollectionViewSection : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSInteger numberOfItems;
@end

@interface JNWCollectionViewData : NSObject

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

- (void)recalculate;

@property (nonatomic, assign) NSInteger numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, strong) NSMutableDictionary *cellClassMap; // { identifier : class }
@property (nonatomic, strong) NSMutableDictionary *supplementaryViewClassMap; // { "kind/identifier" : class }

@end
