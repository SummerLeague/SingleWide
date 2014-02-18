//
//  SLCheckInIndexViewController.m
//  SingleWide
//
//  Created by Mark Stultz on 2/17/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLCheckInIndexViewController.h"
#import "SLTableViewDataSource.h"
#import "CheckIn.h"

@interface SLCheckInIndexViewController () <SLTableViewDataSourceDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SLTableViewDataSource *dataSource;

@end

@implementation SLCheckInIndexViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.dataSource = [[SLTableViewDataSource alloc] initWithTableView:self.tableView];
	self.dataSource.delegate = self;
	self.dataSource.reusableCellIdentifier = @"cell";
}

#pragma mark SLTableViewDataSourceDelegate

- (void)configureCell:(id)cell withObject:(id)object
{
	CheckIn *checkIn = object;
	UITableViewCell *tableViewCell = cell;
	tableViewCell.textLabel.text = checkIn.doubleWideId;
}

@end
