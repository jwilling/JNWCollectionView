//
//  Person.m
//  JNWCollectionViewDemo
//
//  Created by Deadpikle on 8/4/16.
//  Copyright © 2016 AppJon. All rights reserved.
//

#import "Person.h"

@implementation Person

-(instancetype)initWithName:(NSString*)name {
	self = [super init];
	if (self) {
		self.name = name;
	}
	return self;
}

@end
