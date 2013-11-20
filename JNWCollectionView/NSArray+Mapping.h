//
// Created by chris on 18.11.13.
//

#import <Foundation/Foundation.h>

@interface NSArray (Mapping)

- (id)firstObject;
- (NSArray*)map:(id (^)(id))block;
@end
