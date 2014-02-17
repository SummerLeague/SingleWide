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

@interface SLCheckInViewController () <SLVenuesDataSourceDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) SLVenuesDataSource *venuesDataSource;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *annotation;

- (void)setupLocationManager;
- (void)setVenues:(NSArray *)venues;

@end

@implementation SLCheckInViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupLocationManager];
	
	self.venuesDataSource = [[SLVenuesDataSource alloc] initWithTableView:self.tableView];
	self.venuesDataSource.delegate = self;
	self.venuesDataSource.reusableCellIdentifier = @"cell";
	
	self.annotation = [[MKPointAnnotation alloc] init];
	self.activityIndicator.alpha = 1.0f;
	
	[self addObserver:self forKeyPath:@"nearbyVenues" options:NSKeyValueObservingOptionNew context:NearbyVenuesContext];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.locationManager stopUpdatingLocation];
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
	self.venuesDataSource.nearbyVenues = venues;
	[self.tableView reloadData];
}

#pragma mark SLVenuesDataSourceDelegate

- (void)configureCell:(id)cell withObject:(id)object
{
	Venue *venue = object;
	UITableViewCell *tableViewCell = cell;
	tableViewCell.textLabel.text = venue.name;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation *location = locations.lastObject;
	MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.0035, 0.0035));
	[self.mapView setCenterCoordinate:location.coordinate animated:YES];
	[self.mapView setRegion:region animated:YES];
	
	self.annotation.coordinate = location.coordinate;
	self.annotation.title = @"Current Location";
	self.annotation.subtitle = @"Look behind you.";
	[self.mapView selectAnnotation:self.annotation animated:YES];
	[self.mapView addAnnotation:self.annotation];
	
	NSLog(@"location: %@", location);
	NSLog(@"lat: %lf", location.coordinate.latitude);
	NSLog(@"long: %lf", location.coordinate.longitude);
	
	[[SLDoubleWideAPIClient sharedClient] venuesNearCoordinate:location.coordinate completion:^(NSArray *venues, NSError *error) {
		dispatch_async( dispatch_get_main_queue(), ^{
			[self setVenues:venues];
		});
	}];
	[self.locationManager stopUpdatingLocation];
}

@end
