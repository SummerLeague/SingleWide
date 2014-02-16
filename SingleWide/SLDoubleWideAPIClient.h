//
//  SLDoubleWideAPIClient.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@import CoreLocation;

@class Checkin;

@interface SLDoubleWideAPIClient : AFHTTPSessionManager

+ (SLDoubleWideAPIClient *)sharedClient;

- (id)initWithBaseURL:(NSURL *)url;

- (NSURLSessionDataTask *)venuesWithCompletion:(void (^)(NSArray *venues, NSError *error))completion;
- (NSURLSessionDataTask *)venuesNearCoordinate:(CLLocationCoordinate2D)coordinate completion:(void (^)(NSArray *venues, NSError *error))completion;

- (NSURLSessionDataTask *)checkinsWithUserId:(NSString *)userId completion:(void (^)(NSArray *checkins, NSError *error))completion;
- (NSURLSessionDataTask *)checkinsWithVenueId:(NSString *)venueId completion:(void (^)(NSArray *checkins, NSError *error))completion;
- (NSURLSessionDataTask *)checkinWithCoordinate:(CLLocationCoordinate2D)coordinate foursquareId:(NSString *)foursquareId completion:(void (^)(Checkin *checkin, NSError *error))completion;

@end
