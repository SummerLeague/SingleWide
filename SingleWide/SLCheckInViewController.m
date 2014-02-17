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
#import "SLVenuesDataSource.h"
#import "SLDoubleWideAPIClient.h"
#import "Venue.h"

static void *NearbyVenuesContext = &NearbyVenuesContext;

@interface SLCheckInViewController () <SLVenuesDataSourceDelegate, CLLocationManagerDelegate, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *resetButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) SLVenuesDataSource *venuesDataSource;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) Venue *selectedVenue;

- (IBAction)resetLocation:(id)sender;

- (void)setupLocationManager;
- (void)enableResetButton;
- (void)setVenues:(NSArray *)venues;

@end

@implementation SLCheckInViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupLocationManager];
	
	self.tableView.delegate = self;
	
	self.venuesDataSource = [[SLVenuesDataSource alloc] initWithTableView:self.tableView];
	self.venuesDataSource.delegate = self;
	self.venuesDataSource.reusableCellIdentifier = @"cell";
	
	self.annotation = [[MKPointAnnotation alloc] init];
	[self resetLocation:self];
	
	self.activityIndicator.alpha = 1.0f;
	
	[self addObserver:self forKeyPath:@"nearbyVenues" options:NSKeyValueObservingOptionNew context:NearbyVenuesContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.locationManager stopUpdatingLocation];
}

- (IBAction)resetLocation:(id)sender
{
	if (self.selectedVenue) {
		self.selectedVenue = nil;
		
		self.resetButton.title = @"";
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
			[[SLDoubleWideAPIClient sharedClient] checkinWithCoordinate:self.annotation.coordinate foursquareId:_selectedVenue.foursquareId completion:^(Checkin *checkin, NSError *error) {
				if (error) {
					NSLog(@"Error: %@", error);
				}
				
				self.annotation.title = _selectedVenue.name;
				self.annotation.subtitle = @"";
				
				[self enableResetButton];
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

- (void)enableResetButton
{
	self.resetButton.title = @"Reset";
}

- (void)setVenues:(NSArray *)venues
{
	self.activityIndicator.alpha = 0.0f;
	self.venuesDataSource.nearbyVenues = venues;
	[self.tableView reloadData];
}

#pragma mark SLVenuesDataSourceDelegate

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
	if (!self.selectedVenue) {
		self.selectedVenue = [self.venuesDataSource.nearbyVenues objectAtIndex:indexPath.row];
	}
	
	[self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
