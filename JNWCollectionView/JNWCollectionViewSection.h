//
//  JNWTableViewSection.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/24/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	CGFloat rowHeight;
	CGFloat yOffset;
} JNWTableViewRowInfo;

@interface JNWCollectionViewSection : NSObject

- (instancetype)initWithNumberOfRows:(NSInteger)numberOfRows;
- (CGFloat)heightForRowAtIndex:(NSInteger)index;
- (CGFloat)relativeOffsetForRowAtIndex:(NSInteger)index;
- (CGFloat)realOffsetForRowAtIndex:(NSInteger)index;

//- (NSInteger)indexForRowAtAbsoluteOffset:(CGFloat)offset;

@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, readonly) JNWTableViewRowInfo *rowInfo;

@end