/*
 Copyright (c) 2013, Marc Haisenko, equinux AG. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions
 of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

#import "JNWCollectionViewDropIndexPath.h"

@implementation JNWCollectionViewDropIndexPath

+ (instancetype)indexPathForItem:(NSInteger)item inSection:(NSInteger)section dropRelation:(JNWCollectionViewDropRelation)relation {
	NSUInteger indexPath[3] = { section , item , relation };
	return [self indexPathWithIndexes:indexPath length:3];
}

- (NSInteger)jnw_section {
	return [self indexAtPosition:0];
}

- (NSInteger)jnw_item {
	return [self indexAtPosition:1];
}

- (JNWCollectionViewDropRelation)jnw_relation {
	return [self indexAtPosition:2];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p section %ld item %ld relation %ld", [self class], self, self.jnw_section, self.jnw_item, (NSInteger)self.jnw_relation];
}

@end
