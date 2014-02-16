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

@interface SLLocationViewController () <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *annotation;

- (void)setupLocationManager;

@end

@implementation SLLocationViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupLocationManager];
	
	//self.fetchedResultsDataSource = [[SLFetchedResultsDataSource alloc] initWithFetchedResultsController:fetchedResultsController collectionView:self.collectionView];
	//self.fetchedResultsDataSource.delegate = self;
	//self.fetchedResultsDataSource.reusableCellIdentifier = @"cell";
	self.annotation = [[MKPointAnnotation alloc] init];
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
	const CLLocationDistance oneHundredMeters = 100.0;
	const CLLocationAccuracy fiveMeters = 5.0;
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.activityType = CLActivityTypeOther;
	self.locationManager.distanceFilter = oneHundredMeters;
	self.locationManager.desiredAccuracy = fiveMeters;
	
	[self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	for( CLLocation *location in locations )
	{
		MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.0035, 0.0035));
		[self.mapView setCenterCoordinate:location.coordinate animated:YES];
		[self.mapView setRegion:region animated:YES];
		
		self.annotation.coordinate = location.coordinate;
		self.annotation.title = @"Current Location";
		self.annotation.subtitle = @"Look behind you.";
		[self.mapView addAnnotation:self.annotation];
	}
}

@end
