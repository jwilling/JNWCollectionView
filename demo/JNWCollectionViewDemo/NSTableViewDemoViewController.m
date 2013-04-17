//
//  NSTableViewDemoViewController.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "NSTableViewDemoViewController.h"
#import "DemoTableCellView.h"

@interface NSTableViewDemoViewController ()

@end

@implementation NSTableViewDemoViewController

- (id)init {
	return [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	DemoTableCellView *cell = [tableView makeViewWithIdentifier:@"Cell" owner:self];
	
	cell.labelText = [NSString stringWithFormat:@"%ld", row];
	
	return cell;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	return 44.f;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return 500;
}

@end
