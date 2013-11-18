//
// Created by chris on 18.11.13.
//

#import <Foundation/Foundation.h>

@interface NSSet (Map)

- (NSSet*)map:(id (^)(id))block;

- (NSSet*)setByRemovingObjectsFromArray:(NSArray*)array;
@end
