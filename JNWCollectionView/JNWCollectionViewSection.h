//
//  JNWTableViewSection.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/24/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	CGRect frame;
} JNWCollectionViewItemInfo;

@interface JNWCollectionViewSection : NSObject

@property (nonatomic, assign) CGRect sectionFrame;
@property (nonatomic, assign) CGRect headerFrame;
@property (nonatomic, assign) CGRect footerFrame;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSUInteger numberOfItems;
@property (nonatomic, readonly) JNWCollectionViewItemInfo *itemInfo;

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems;

- (CGRect)frameForItemAtIndex:(NSInteger)index;

@end