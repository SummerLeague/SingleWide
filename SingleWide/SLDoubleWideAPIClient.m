//
//  SLDoubleWideAPIClient.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLDoubleWideAPIClient.h"
#import "SLCredentialStore.h"
#import "Checkin.h"
#import "User.h"
#import "Venue.h"

//static NSString *serverAddress = @"http://127.0.0.1:8888";
//static NSString *serverAddress = @"http://10.0.1.7:8888";
static NSString *serverAddress = @"http://rocky-fjord-4357.herokuapp.com/";

@interface SLDoubleWideAPIClient ()

- (void)setAuthTokenHeader;
- (void)tokenChanged:(NSNotification *)notification;

@end

@implementation SLDoubleWideAPIClient

+ (SLDoubleWideAPIClient *)sharedClient
{
	static SLDoubleWideAPIClient *sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NSURL URLWithString:serverAddress];
		sharedClient = [[SLDoubleWideAPIClient alloc] initWithBaseURL:baseURL];
	});
	
	return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
	self = [super initWithBaseURL:url];
	if (self) {
		self.responseSerializer = [AFJSONResponseSerializer serializer];
		[self setAuthTokenHeader];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenChanged:) name:@"token-changed" object:nil];
	}
	
	return self;
}

- (NSURLSessionDataTask *)venuesWithCompletion:(void (^)(NSArray *venues, NSError *error))completion
{
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] GET:@"/venues" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSArray class]]) {
			NSMutableArray *venues = [NSMutableArray array];
			for (NSDictionary *venue in responseObject) {
				NSString *venueId = venue[ @"_id" ];
				NSString *foursquareId = venue[ @"foursquare_id" ];
				Venue *venue = [[Venue alloc] initWithVenueId:venueId foursquareId:foursquareId];
				[venues addObject:venue];
			}
			
			if (completion) {
				completion(venues, nil);
			}
		}
		else {
			/* Response was not a NSArray */
			if (completion) {
				completion(nil, nil);
			}
		}
	}
	failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (completion) {
			completion(nil, error);
		}
	}];
	
	return task;
}

- (NSURLSessionDataTask *)venuesNearCoordinate:(CLLocationCoordinate2D)coordinate completion:(void (^)(NSArray *venues, NSError *error))completion
{
	id params = @{
		@"lng": [NSNumber numberWithDouble:coordinate.longitude],
		@"lat": [NSNumber numberWithDouble:coordinate.latitude],
	};

	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] GET:@"/venues/search" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isEqualToString:[NSDictionary class]]) {
			NSMutableArray *venues = [NSMutableArray array];
			NSArray *venuesArray = responseObject[ @"venues" ];
			for( NSDictionary *venueDict in venuesArray ) {
				NSString *foursquareId = venueDict[ @"id" ];
				NSString *venueName = venueDict[ @"name" ];
				/*
				 "location": {
				 "address": "1836 W Davis St",
				 "lat": 32.74920395813301,
				 "lng": -96.84974424775343,
				 "distance": 23,
				 "postalCode": "75208",
				 "cc": "US",
				 "city": "Dallas",
				 "state": "TX",
				 "country": "United States"
				 },
				*/
				
				Venue *venue = [[Venue alloc] initWithVenueId:@"" foursquareId:foursquareId];
				venue.name = venueName;
				[venues addObject:venue];
			}
			
			if (completion) {
				completion(venues, nil);
			}
		}
		else {
			/* Response was not a NSArray */
			if (completion) {
				completion(nil, nil);
			}
		}
	}
	failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (completion) {
			completion(nil, error);
		}
	}];
	
	return task;
}

- (NSURLSessionDataTask *)checkinsWithUserId:(NSString *)userId completion:(void (^)(NSArray *checkins, NSError *error))completion
{
	id params = @{
		@"user_id": userId,
	};
	
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] GET:@"/checkins" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSArray class]]) {
			NSMutableArray *checkins = [NSMutableArray array];
			for (NSDictionary *checkinDict in responseObject) {
				NSDictionary *creatorDict = checkinDict[ @"creator" ];
				NSString *creatorId = creatorDict[ @"_id" ];
				NSString *nickname = creatorDict[ @"nickname" ];
				User *user = [[User alloc] initWithDoublewideId:creatorId nickname:nickname];
				
				NSDictionary *venueDict = checkinDict[ @"venue" ];
				NSString *venueId = venueDict[ @"_id" ];
				NSString *venueFoursquareId = venueDict[ @"foursquare_id" ];
				Venue *venue = [[Venue alloc] initWithVenueId:venueId foursquareId:venueFoursquareId];
				
				// TODO-MAS: This might be an array
				NSDictionary *locationDict = checkinDict[ @"location" ];
				locationDict = locationDict;
				
				Checkin *checkin = [[Checkin alloc] initWithUser:user venue:venue];
				[checkins addObject:checkin];
			}
			
			if (completion) {
				completion(checkins, nil);
			}
		}
		else {
			/* Response was not a NSArray */
			if (completion) {
				completion(nil, nil);
			}
		}
	}
	failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (completion) {
			completion(nil, error);
		}
	}];
	
	return task;
}

- (NSURLSessionDataTask *)checkinsWithVenueId:(NSString *)venueId completion:(void (^)(NSArray *checkins, NSError *error))completion
{
	id params = @{
	  @"venue_id": venueId,
	};
	
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] GET:@"/checkins" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSArray class]]) {
			NSMutableArray *checkins = [NSMutableArray array];
			for (NSDictionary *checkinDict in responseObject) {
				NSDictionary *creatorDict = checkinDict[ @"creator" ];
				NSString *creatorId = creatorDict[ @"_id" ];
				NSString *nickname = creatorDict[ @"nickname" ];
				User *user = [[User alloc] initWithDoublewideId:creatorId nickname:nickname];
				
				NSDictionary *venueDict = checkinDict[ @"venue" ];
				NSString *venueId = venueDict[ @"_id" ];
				NSString *venueFoursquareId = venueDict[ @"foursquare_id" ];
				Venue *venue = [[Venue alloc] initWithVenueId:venueId foursquareId:venueFoursquareId];
				
				// TODO-MAS: This might be an array
				NSDictionary *locationDict = checkinDict[ @"location" ];
				locationDict = locationDict;
				
				Checkin *checkin = [[Checkin alloc] initWithUser:user venue:venue];
				[checkins addObject:checkin];
			}
			
			if (completion) {
				completion(checkins, nil);
			}
		}
		else {
			/* Response was not a NSArray */
			if (completion) {
				completion(nil, nil);
			}
		}
	}
	failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (completion) {
			completion(nil, error);
		}
	}];
	
	return task;
}

- (NSURLSessionDataTask *)checkinWithCoordinate:(CLLocationCoordinate2D)coordinate foursquareId:(NSString *)foursquareId completion:(void (^)(Checkin *checkin, NSError *error))completion
{
	id params = @{
		//@"auth_token" TODO-MAS: remove this? is auth_token being injected somewhere
		@"lng": [NSNumber numberWithDouble:coordinate.longitude],
		@"lat": [NSNumber numberWithDouble:coordinate.latitude],
		@"foursquare_id": foursquareId
	};
	
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] POST:@"/checkins" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSDictionary class]]) {
			NSDictionary *creatorDict = responseObject[ @"creator" ];
			NSString *creatorId = creatorDict[ @"_id" ];
			NSString *nickname = creatorDict[ @"nickname" ];
			User *user = [[User alloc] initWithDoublewideId:creatorId nickname:nickname];
			
			NSDictionary *venueDict = responseObject[ @"venue" ];
			NSString *venueId = venueDict[ @"_id" ];
			NSString *venueFoursquareId = venueDict[ @"foursquare_id" ];
			Venue *venue = [[Venue alloc] initWithVenueId:venueId foursquareId:venueFoursquareId];
			
			// TODO-MAS: This might be an array
			NSDictionary *locationDict = responseObject[ @"location" ];
			locationDict = locationDict;
			
			Checkin *checkin = [[Checkin alloc] initWithUser:user venue:venue];
			if (completion) {
				completion(checkin, nil);
			}
		}
		else {
			/* Response was not a NSDictionary */
			if (completion) {
				completion(nil, nil);
			}
		}
	}
	failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (completion) {
			completion(nil, error);
		}
	}];

	return task;
}

- (void)setAuthTokenHeader
{
	SLCredentialStore *store = [[SLCredentialStore alloc] init];
	NSString *authToken = [store authToken];
	[self.requestSerializer setValue:authToken forHTTPHeaderField:@"auth_token"];
}

- (void)tokenChanged:(NSNotification *)notification
{
	[self setAuthTokenHeader];
}

@end
