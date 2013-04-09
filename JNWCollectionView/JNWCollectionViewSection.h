//
//  JNWTableViewSection.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/24/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	CGSize size;
	CGFloat yOffset; // offset from the top of the section
	CGFloat xOffset; // offset from the left of the section
} JNWCollectionViewItemInfo;

@interface JNWCollectionViewSection : NSObject

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems;

- (CGFloat)heightForItemAtIndex:(NSInteger)index;
- (CGFloat)widthForItemAtIndex:(NSInteger)index;
- (CGSize)sizeForItemAtIndex:(NSInteger)index;

- (CGFloat)relativeVerticalOffsetForItemAtIndex:(NSInteger)index;
- (CGFloat)relativeHorizontalOffsetForItemAtIndex:(NSInteger)index;
- (CGFloat)verticalOffsetForItemAtIndex:(NSInteger)index;
- (CGFloat)horizontalOffsetForItemAtIndex:(NSInteger)index;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSUInteger numberOfItems;
@property (nonatomic, readonly) JNWCollectionViewItemInfo *itemInfo;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat horizontalOffset;



@end