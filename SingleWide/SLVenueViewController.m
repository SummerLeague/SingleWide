//
//  SLVenueViewController.m
//  SingleWide
//
//  Created by Mark Stultz on 2/17/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLVenueViewController.h"
#import "SLFetchedResultsDataSource.h"
#import "SLDoubleWideAPIClient.h"
#import "Venue.h"
#import "NearbyVenue.h"

@interface SLVenueViewController () <SLFetchedResultsDataSourceDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *checkInButton;
@property (nonatomic, strong) SLFetchedResultsDataSource *dataSource;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) NSURLSessionDataTask *checkInTask;

- (IBAction)checkIn:(id)sender;

@end

@implementation SLVenueViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSFetchedResultsController *fetchedResultsController = [NearbyVenue nearbyVenueFetchedResultsControllerWithLatitude:self.venue.latitude longitude:self.venue.longitude inManagedObjectContext:[SLDoubleWideAPIClient sharedClient].managedObjectContext];
	self.dataSource = [[SLFetchedResultsDataSource alloc] initWithFetchedResultsController:fetchedResultsController tableView:self.tableView];
	self.dataSource.delegate = self;
	self.dataSource.reusableCellIdentifier = @"cell";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.venue = self.venue;
	self.navigationItem.title = self.venue.name;
	
	self.annotation = [[MKPointAnnotation alloc] init];
	self.annotation.coordinate = CLLocationCoordinate2DMake(self.venue.latitude.doubleValue, self.venue.longitude.doubleValue);
	self.annotation.title = self.venue.name;
	self.annotation.subtitle = [NSString stringWithFormat:@"(%.4f, %.4f)", self.venue.latitude.floatValue, self.venue.longitude.floatValue];
	[self.mapView addAnnotation:self.annotation];
	[self.mapView selectAnnotation:self.annotation animated:YES];
	
	MKCoordinateRegion region = MKCoordinateRegionMake(self.annotation.coordinate, MKCoordinateSpanMake(0.0035, 0.0035));
	[self.mapView setCenterCoordinate:self.annotation.coordinate animated:YES];
	[self.mapView setRegion:region animated:YES];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
	[super encodeRestorableStateWithCoder:coder];
	[coder encodeObject:self.venue.foursquareId forKey:@"venue.foursquareId"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
	[super decodeRestorableStateWithCoder:coder];
	NSString *foursquareId = [coder decodeObjectForKey:@"venue.foursquareId"];
	if (foursquareId) {
		NSManagedObjectContext *managedObjectContext = [SLDoubleWideAPIClient sharedClient].managedObjectContext;
		self.venue = [Venue venueWithFoursquareId:foursquareId inManagedObjectContext:managedObjectContext];
	}
}

- (IBAction)checkIn:(id)sender
{
	if (self.checkInButton.enabled) {
		self.checkInButton.enabled = NO;
		[self.checkInButton setTitle:@"Checking in..." forState:UIControlStateNormal];
		
		if (!self.checkInTask) {
			self.checkInTask = [[SLDoubleWideAPIClient sharedClient] checkInWithCoordinate:self.coordinate foursquareId:self.venue.foursquareId completion:^(CheckIn *checkIn, NSError *error) {
				[self.checkInButton setTitle:@"You are checked in here." forState:UIControlStateNormal];
				self.checkInTask = nil;
			}];
		}
	}
}

#pragma mark SLTableViewDataSourceDelegate

- (void)configureCell:(id)cell withObject:(id)object
{
	Venue *venue = object;
	UITableViewCell *tableViewCell = cell;
	tableViewCell.textLabel.text = venue.name;
}

@end
