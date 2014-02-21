//
//  SLDoubleWideAPIClient.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLDoubleWideAPIClient.h"
#import "SLPersistenceStack.h"
#import "SLCredentialStore.h"
#import "Checkin.h"
#import "User.h"
#import "Venue.h"
#import "NearbyVenue.h"

//static NSString *serverAddress = @"http://127.0.0.1:8888";
//static NSString *serverAddress = @"http://10.0.1.7:8888";
static NSString *serverAddress = @"http://rocky-fjord-4357.herokuapp.com/";

@interface SLDoubleWideAPIClient ()

@property (nonatomic, strong) SLPersistenceStack *persistenceStack;

- (void)setAuthTokenHeader;
- (void)tokenChanged:(NSNotification *)notification;

- (User *)userFromDictionary:(NSDictionary *)dictionary;
- (Venue *)venueFromDictionary:(NSDictionary *)dictionary;

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
		
		NSURL *storeURL = [SLPersistenceStack defaultStoreURL];
		NSURL *modelURL = [SLPersistenceStack defaultModelURL];
		self.persistenceStack = [[SLPersistenceStack alloc] initWithStoreURL:storeURL modelURL:modelURL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenChanged:) name:@"token-changed" object:nil];
	}
	
	return self;
}

- (NSURLSessionDataTask *)venuesWithCompletion:(void (^)(NSArray *venues, NSError *error))completion
{
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] GET:@"/api/venues" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSArray class]]) {
			NSMutableArray *venues = [NSMutableArray array];
			for (NSDictionary *venueDict in responseObject) {
				Venue *venue = [self venueFromDictionary:venueDict];
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
	NSNumber *latitude = [NSNumber numberWithDouble:coordinate.latitude];
	NSNumber *longitude = [NSNumber numberWithDouble:coordinate.longitude];

	id params = @{
		@"lng": longitude,
		@"lat": latitude,
	};

	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] GET:@"/api/venues/search" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSDictionary class]]) {
			NSDictionary *responseDict = responseObject[ @"response" ];
			NSMutableArray *venues = [NSMutableArray array];
			NSArray *venuesArray = responseDict[ @"venues" ];
			int index = 0;
			for (NSDictionary *venueDict in venuesArray) {
				NSString *foursquareId = venueDict[ @"id" ];
				Venue *venue = [Venue venueWithFoursquareId:foursquareId inManagedObjectContext:self.persistenceStack.managedObjectContext];
				if (venue) {
					venue.name = venueDict[ @"name" ];
					venue.latitude = venueDict[ @"location" ][ @"lat" ];
					venue.longitude = venueDict[ @"location" ][ @"lng" ];
				}
				
				NearbyVenue *nearbyVenue = [NearbyVenue nearbyVenueWithLatitude:latitude longitude:longitude venue:venue inManagedObjectContext:self.persistenceStack.managedObjectContext];
				if (nearbyVenue) {
					nearbyVenue.index = [NSNumber numberWithInt:index++];
				}
				
				[venues addObject:nearbyVenue];
			}
			
			[self.persistenceStack save];
			
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

- (NSURLSessionDataTask *)checkInsWithUserId:(NSString *)userId completion:(void (^)(NSArray *checkIns, NSError *error))completion
{
	return nil;
}

- (NSURLSessionDataTask *)checkInsWithVenueId:(NSString *)venueId completion:(void (^)(NSArray *checkIns, NSError *error))completion
{
	NSString *path = [NSString stringWithFormat:@"/api/checkins?foursquare_id=%@", venueId];
	
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSDictionary class]]) {
			NSMutableArray *checkIns = [NSMutableArray array];
			for (NSDictionary *checkInDict in responseObject[ @"checkins" ]) {
				NSString *checkInId = checkInDict[ @"_id" ];
				CheckIn *checkIn = [CheckIn checkInWithDoubleWideId:checkInId inManagedObjectContext:self.persistenceStack.managedObjectContext];
				if (checkIn) {
					checkIn.user = [self userFromDictionary:checkInDict[ @"creator" ]];
					checkIn.venue = [self venueFromDictionary:checkInDict[ @"venue" ]];
					
					NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
					[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
					checkIn.creationDate = [dateFormat dateFromString:checkInDict[ @"createdAt" ]];
					
					NSArray *locationArray = checkInDict[ @"loc" ];
					if (locationArray.count == 2) {
						checkIn.latitude = locationArray[ 0 ];
						checkIn.longitude = locationArray[ 1 ];
					}

					[checkIns addObject:checkIn];
				}
			}

			if (completion) {
				completion(checkIns, nil);
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
		NSLog(@"Error: %@", error);
		if (completion) {
			completion(nil, error);
		}
	}];
	
	return task;
}

- (NSURLSessionDataTask *)checkInWithCoordinate:(CLLocationCoordinate2D)coordinate foursquareId:(NSString *)foursquareId completion:(void (^)(CheckIn *checkIn, NSError *error))completion
{
	id params = @{
		//@"auth_token" TODO-MAS: remove this? is auth_token being injected somewhere
		@"lng": [NSNumber numberWithDouble:coordinate.longitude],
		@"lat": [NSNumber numberWithDouble:coordinate.latitude],
		@"foursquare_id": foursquareId
	};
	
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] POST:@"/api/checkins" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		if ([responseObject isKindOfClass:[NSDictionary class]]) {
			NSDictionary *checkInDict = responseObject[ @"checkin" ];
			
			NSString *doubleWideId = checkInDict[ @"_id" ];
			CheckIn *checkIn = [CheckIn checkInWithDoubleWideId:doubleWideId inManagedObjectContext:self.persistenceStack.managedObjectContext];
			if (checkIn) {
				checkIn.user = [self userFromDictionary:checkInDict[ @"creator" ]];
				checkIn.venue = [self venueFromDictionary:checkInDict[ @"venue" ]];
				
				NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
				[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
				checkIn.creationDate = [dateFormat dateFromString:checkInDict[ @"createdAt" ]];
				
				NSArray *locationArray = checkInDict[ @"loc" ];
				if (locationArray.count == 2) {
					checkIn.latitude = locationArray[ 0 ];
					checkIn.longitude = locationArray[ 1 ];
				}
			}

			if (completion) {
				completion(checkIn, nil);
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

- (User *)userFromDictionary:(NSDictionary *)dictionary
{
	User *user = nil;
		
	NSString *doubleWideId = dictionary[ @"_id" ];
	if (doubleWideId) {
		user = [User userWithDoubleWideId:doubleWideId inManagedObjectContext:self.persistenceStack.managedObjectContext];
		user.nickname = dictionary[ @"nickname" ];
	}
	
	return user;
}

- (Venue *)venueFromDictionary:(NSDictionary *)dictionary
{
	Venue *venue = nil;
	
	NSString *foursquareId = dictionary[ @"foursquare_id" ];
	if (foursquareId) {
		venue = [Venue venueWithFoursquareId:foursquareId inManagedObjectContext:self.persistenceStack.managedObjectContext];
		venue.doubleWideId = dictionary[ @"_id" ];
	}
	
	return venue;
}

- (NSManagedObjectContext *)managedObjectContext;
{
	return self.persistenceStack.managedObjectContext;
}

@end
