//
//  SLVenuesDataSource.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLVenuesDataSource.h"
#import "Venue.h"

@interface SLVenuesDataSource () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SLVenuesDataSource

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
	return self.nearbyVenues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	Venue *venue = [self.nearbyVenues objectAtIndex:indexPath.row];
	id cell = [self.tableView dequeueReusableCellWithIdentifier:self.reusableCellIdentifier forIndexPath:indexPath];
	[self.delegate configureCell:cell withObject:venue];
	return cell;
}

@end
