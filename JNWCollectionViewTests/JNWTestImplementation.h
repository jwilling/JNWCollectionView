//
//  JNWTestImplementation.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/27/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNWCollectionView.h"
#import "JNWCollectionViewListLayout.h"
#import "JNWCollectionViewGridLayout.h"

extern const NSInteger kTestDataSourceNumberOfItems;
extern const NSInteger kTestDataSourceNumberOfSections;
extern NSString * const kTestDataSourceCellIdentifier;
extern NSString * const kTestDataSourceHeaderIdentifier;
extern NSString * const kTestDataSourceFooterIdentifier;


@interface JNWTestDataSource : NSObject <JNWCollectionViewDataSource>

@end

@interface JNWTestDelegate : NSObject <JNWCollectionViewDelegate>

@end

@interface JNWTestListLayoutDelegate : NSObject <JNWCollectionViewListLayoutDelegate>

@end

@interface JNWTestGridLayoutDelegate : NSObject <JNWCollectionViewGridLayoutDelegate>

@end
