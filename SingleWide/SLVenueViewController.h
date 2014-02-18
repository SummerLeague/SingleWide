//
//  SLVenueViewController.h
//  SingleWide
//
//  Created by Mark Stultz on 2/17/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;
@import MapKit;

@class Venue;

@interface SLVenueViewController : UIViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Venue *venue;

@end
