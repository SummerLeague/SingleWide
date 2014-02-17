//
//  SLLocationViewController.m
//  SingleWide
//
//  Created by Mark Stultz on 2/11/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

@import CoreLocation;
@import MapKit;

#import "SLLocationViewController.h"
#import "SLVenuesDataSource.h"
#import "SLDoubleWideAPIClient.h"
#import "SLCollectionViewCell.h"
#import "Venue.h"

static void *NearbyVenuesContext = &NearbyVenuesContext;

@interface SLLocationViewController () <SLVenuesDataSourceDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) SLVenuesDataSource *venuesDataSource;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) NSURLSessionDataTask *nearbyVenuesTask;

- (void)setupLocationManager;

@end

@implementation SLLocationViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupLocationManager];
	
	self.venuesDataSource = [[SLVenuesDataSource alloc] initWithCollectionView:self.collectionView];
	self.venuesDataSource.delegate = self;
	self.venuesDataSource.reusableCellIdentifier = @"cell";
	
	self.annotation = [[MKPointAnnotation alloc] init];
	self.activityIndicator.alpha = 1.0f;
	
	[self addObserver:self forKeyPath:@"nearbyVenues" options:NSKeyValueObservingOptionNew context:NearbyVenuesContext];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.locationManager stopUpdatingLocation];
}

- (void)setupLocationManager
{
	const CLLocationDistance oneHundredMeters = 10.0;
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.activityType = CLActivityTypeOther;
	self.locationManager.distanceFilter = oneHundredMeters;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	
	[self.locationManager startUpdatingLocation];
}

#pragma mark SLVenuesDataSourceDelegate

- (void)configureCell:(id)cell withObject:(id)object
{
	Venue *venue = object;
	SLCollectionViewCell *collectionViewCell = cell;
	collectionViewCell.label.text = venue.name;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	for (CLLocation *location in locations) {
		MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.0035, 0.0035));
		[self.mapView setCenterCoordinate:location.coordinate animated:YES];
		[self.mapView setRegion:region animated:YES];
		
		self.annotation.coordinate = location.coordinate;
		self.annotation.title = @"Current Location";
		self.annotation.subtitle = @"Look behind you.";
		[self.mapView addAnnotation:self.annotation];
		
		NSLog(@"location: %@", location);
		NSLog(@"lat: %lf", location.coordinate.latitude);
		NSLog(@"long: %lf", location.coordinate.longitude);
		
		if (!self.nearbyVenuesTask) {
			self.nearbyVenuesTask = [[SLDoubleWideAPIClient sharedClient] venuesNearCoordinate:location.coordinate completion:^(NSArray *venues, NSError *error) {
				dispatch_async( dispatch_get_main_queue(), ^{
					self.activityIndicator.alpha = 0.0f;
					self.venuesDataSource.nearbyVenues = venues;
					[self.collectionView reloadData];
				});
				self.nearbyVenuesTask = nil;
			}];
		}
	}
}

@end
