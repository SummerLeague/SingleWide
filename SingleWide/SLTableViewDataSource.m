//
//  SLTableViewDataSource.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLTableViewDataSource.h"

@interface SLTableViewDataSource () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SLTableViewDataSource

- (id)initWithTableView:(UITableView *)tableView
{
	self = [super init];
	if (self) {
		self.tableView = tableView;
		self.tableView.dataSource = self;
	}
	
	return self;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	id cell = [self.tableView dequeueReusableCellWithIdentifier:self.reusableCellIdentifier forIndexPath:indexPath];
	[self.delegate configureCell:cell withObject:[self.objects objectAtIndex:indexPath.row]];
	return cell;
}

@end
