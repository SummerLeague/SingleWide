//
//  SLCheckInViewController.m
//  SingleWide
//
//  Created by Mark Stultz on 2/11/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

@import CoreLocation;
@import MapKit;

#import "SLCheckInViewController.h"
#import "SLVenueViewController.h"
#import "SLFetchedResultsDataSource.h"
#import "SLDoubleWideAPIClient.h"
#import "Venue.h"
#import "NearbyVenue.h"

@interface SLCheckInViewController () <SLFetchedResultsDataSourceDelegate, CLLocationManagerDelegate, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SLFetchedResultsDataSource *dataSource;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) NearbyVenue *selectedNearbyVenue;

- (void)setupLocationManager;

@end

@implementation SLCheckInViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupLocationManager];
	
	self.tableView.delegate = self;
	
	self.dataSource = [[SLFetchedResultsDataSource alloc] initWithFetchedResultsController:nil tableView:self.tableView];
	self.dataSource.delegate = self;
	self.dataSource.reusableCellIdentifier = @"cell";
	
	self.annotation = [[MKPointAnnotation alloc] init];
	self.annotation.title = @"Current Location";
	self.annotation.subtitle = @"Look behind you.";

	[self resetLocation:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.locationManager stopUpdatingLocation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"checkInSegue"]) {
		SLVenueViewController *viewController = segue.destinationViewController;
		NearbyVenue *nearbyVenue = self.dataSource.selectedItem;
		viewController.venue = nearbyVenue.venue;
	}
	else {
		return [super prepareForSegue:segue sender:sender];
	}
}

- (IBAction)resetLocation:(id)sender
{
	if (self.selectedNearbyVenue) {
		self.selectedNearbyVenue = nil;
	}
}

- (void)setSelectedNearbyVenue:(NearbyVenue *)selectedNearbyVenue
{
	if (_selectedNearbyVenue != selectedNearbyVenue) {
		_selectedNearbyVenue = selectedNearbyVenue;
		
		if (_selectedNearbyVenue) {
			[[SLDoubleWideAPIClient sharedClient] checkInWithCoordinate:self.annotation.coordinate foursquareId:_selectedNearbyVenue.venue.foursquareId completion:^(CheckIn *checkIn, NSError *error) {
				if (error) {
					NSLog(@"Error: %@", error);
				}
				
				if (checkIn) {
					NSLog(@"%@", checkIn);
				}
				
			}];
		}
	}
}

- (void)setupLocationManager
{
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.activityType = CLActivityTypeOther;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	
	[self.locationManager startUpdatingLocation];
}

#pragma mark SLTableViewDataSourceDelegate

- (void)configureCell:(id)cell withObject:(id)object
{
	NearbyVenue *nearbyVenue = object;
	UITableViewCell *tableViewCell = cell;
	tableViewCell.textLabel.text = nearbyVenue.venue.name;
	tableViewCell.accessoryType = (object == self.dataSource.selectedItem) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation *location = locations.lastObject;
	MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.0035, 0.0035));
	[self.mapView setCenterCoordinate:location.coordinate animated:YES];
	[self.mapView setRegion:region animated:YES];
	
	self.annotation.coordinate = location.coordinate;
	[self.mapView addAnnotation:self.annotation];
	[self.mapView selectAnnotation:self.annotation animated:YES];
	
	[[SLDoubleWideAPIClient sharedClient] venuesNearCoordinate:location.coordinate completion:^(NSArray *venues, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNumber *latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
			NSNumber *longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
			NSFetchedResultsController *fetchedResultsController = [NearbyVenue nearbyVenueFetchedResultsControllerWithLatitude:latitude longitude:longitude inManagedObjectContext:[SLDoubleWideAPIClient sharedClient].managedObjectContext];
			[self.dataSource setFetchedResultsController:fetchedResultsController];
			[self.tableView reloadData];
		});
	}];
	
	[self.locationManager stopUpdatingLocation];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"checkInSegue" sender:self];
}

@end
