//
//  JNWTableViewSection.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/24/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWTableViewSection.h"

@implementation JNWTableViewSection

- (instancetype)initWithNumberOfRows:(NSInteger)numberOfRows {
	self = [super init];
	_numberOfRows = numberOfRows;
	_rowInfo = calloc(numberOfRows, sizeof(JNWTableViewRowInfo));
	return self;
}

//- (NSInteger)indexForRowAtAbsoluteOffset:(CGFloat)offset {
//	CGFloat relativeOffset = offset - self.offset;
//	NSInteger low = 0;
//	NSInteger high = self.numberOfRows;
//	
//	if (offset < 0 || offset > self.height)
//		return NSNotFound;
//	
//	return JNWRowInfoBinarySearch(self.rowInfo, low, high, self.numberOfRows, relativeOffset);
//}

- (CGFloat)heightForRowAtIndex:(NSInteger)index {
	if (index < self.numberOfRows && index >= 0)
		return self.rowInfo[index].rowHeight;
	return 0.f;
}

- (CGFloat)relativeOffsetForRowAtIndex:(NSInteger)index {
	if (index < self.numberOfRows && index >= 0)
		return self.rowInfo[index].yOffset;
	return 0.f;
}

- (CGFloat)realOffsetForRowAtIndex:(NSInteger)index {
	return self.offset + [self relativeOffsetForRowAtIndex:index];
}

//NSInteger JNWRowInfoBinarySearch(JNWTableViewRowInfo info[], NSInteger low, NSInteger high, NSInteger numberOfRows, NSInteger offset) {
//	// Perform a modified binary search to find the row with the specified offset.
//	while (low <= high) {
//		NSInteger mid = (low + high) / 2;
//		JNWTableViewRowInfo midVal = info[mid];
//		
//		if (midVal.yOffset <= offset && mid <= numberOfRows - 1 && offset < info[mid + 1].yOffset)
//			return mid;
//		else if (midVal.yOffset < offset && mid == numberOfRows - 1 && offset <= midVal.yOffset + midVal.rowHeight)
//			return mid;
//		else if (midVal.yOffset < offset)
//			low = mid + 1;
//		else if (midVal.yOffset > offset)
//			high = mid - 1;
//	}
//	
//	return NSNotFound;
//}

- (void)dealloc {
	if (_rowInfo != NULL)
		free(_rowInfo);
}

@end

