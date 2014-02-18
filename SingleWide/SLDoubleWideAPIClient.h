//
//  SLDoubleWideAPIClient.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@import CoreLocation;

@class CheckIn;

@interface SLDoubleWideAPIClient : AFHTTPSessionManager

+ (SLDoubleWideAPIClient *)sharedClient;

- (id)initWithBaseURL:(NSURL *)url;

- (NSURLSessionDataTask *)venuesWithCompletion:(void (^)(NSArray *venues, NSError *error))completion;
- (NSURLSessionDataTask *)venuesNearCoordinate:(CLLocationCoordinate2D)coordinate completion:(void (^)(NSArray *venues, NSError *error))completion;

- (NSURLSessionDataTask *)checkIisWithUserId:(NSString *)userId completion:(void (^)(NSArray *checkIns, NSError *error))completion;
- (NSURLSessionDataTask *)checkInsWithVenueId:(NSString *)venueId completion:(void (^)(NSArray *checkIns, NSError *error))completion;
- (NSURLSessionDataTask *)checkInWithCoordinate:(CLLocationCoordinate2D)coordinate foursquareId:(NSString *)foursquareId completion:(void (^)(CheckIn *checkIn, NSError *error))completion;

@end
