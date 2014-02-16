//
//  SLDoubleWideAPIClient.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface SLDoubleWideAPIClient : AFHTTPSessionManager

+ (SLDoubleWideAPIClient *)sharedClient;

@end
