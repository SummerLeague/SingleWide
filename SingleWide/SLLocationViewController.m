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
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *annotation;

@end

@implementation SLLocationViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	const CLLocationDistance oneHundredMeters = 100.0;
	const CLLocationAccuracy fiveMeters = 5.0;
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.activityType = CLActivityTypeOther;
	self.locationManager.distanceFilter = oneHundredMeters;
	self.locationManager.desiredAccuracy = fiveMeters;
	
	[self.locationManager startUpdatingLocation];
	
	self.annotation = [[MKPointAnnotation alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.locationManager stopUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	for( CLLocation *location in locations )
	{
		MKCoordinateRegion region = MKCoordinateRegionMake( location.coordinate, MKCoordinateSpanMake( 0.0035, 0.0035 ) );
		[self.mapView setCenterCoordinate:location.coordinate animated:YES];
		[self.mapView setRegion:region animated:YES];
		
		self.annotation.coordinate = location.coordinate;
		[self.mapView addAnnotation:self.annotation];
	}
}

@end
