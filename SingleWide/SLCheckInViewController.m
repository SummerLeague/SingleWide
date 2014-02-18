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
#import "SLTableViewDataSource.h"
#import "SLDoubleWideAPIClient.h"
#import "Venue.h"

@interface SLCheckInViewController () <SLTableViewDataSourceDelegate, CLLocationManagerDelegate, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) SLTableViewDataSource *dataSource;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) Venue *selectedVenue;

- (void)setupLocationManager;
- (void)setVenues:(NSArray *)venues;

@end

@implementation SLCheckInViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupLocationManager];
	
	self.tableView.delegate = self;
	
	self.dataSource = [[SLTableViewDataSource alloc] initWithTableView:self.tableView];
	self.dataSource.delegate = self;
	self.dataSource.reusableCellIdentifier = @"cell";
	
	self.annotation = [[MKPointAnnotation alloc] init];
	[self resetLocation:self];
	
	self.activityIndicator.alpha = 1.0f;
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
		Venue *venue = [self.dataSource.objects objectAtIndex:self.tableView.indexPathForSelectedRow.row];
		viewController.venue = venue;
	}
	else {
		return [super prepareForSegue:segue sender:sender];
	}
}

- (IBAction)resetLocation:(id)sender
{
	if (self.selectedVenue) {
		self.selectedVenue = nil;
		
		self.annotation.title = @"Current Location";
		self.annotation.subtitle = @"Look behind you.";
		
		[self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)setSelectedVenue:(Venue *)selectedVenue
{
	if (_selectedVenue != selectedVenue) {
		_selectedVenue = selectedVenue;
		
		if (_selectedVenue) {
			[[SLDoubleWideAPIClient sharedClient] checkInWithCoordinate:self.annotation.coordinate foursquareId:_selectedVenue.foursquareId completion:^(CheckIn *checkIn, NSError *error) {
				if (error) {
					NSLog(@"Error: %@", error);
				}
				
				if (checkIn) {
					NSLog(@"%@", checkIn);
				}
				
				self.annotation.title = _selectedVenue.name;
				self.annotation.subtitle = @"";
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

- (void)setVenues:(NSArray *)venues
{
	self.activityIndicator.alpha = 0.0f;
	self.dataSource.objects = venues;
	[self.tableView reloadData];
}

#pragma mark SLTableViewDataSourceDelegate

- (void)configureCell:(id)cell withObject:(id)object
{
	Venue *venue = object;
	UITableViewCell *tableViewCell = cell;
	tableViewCell.textLabel.text = venue.name;
	tableViewCell.accessoryType = (object == self.selectedVenue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
			[self setVenues:venues];
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
