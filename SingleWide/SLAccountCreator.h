//
//  SLAccountCreator.h
//  SingleWide
//
//  Created by Bradley Griffith on 1/14/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)();
typedef void (^FailureBlock)(NSString *errorMessage);

@interface SLAccountCreator : NSObject

- (NSURLSessionDataTask *)createUserWithNickname:(NSString *)nickname
                                        password:(NSString *)password
                                         success:(SuccessBlock)success
                                         failure:(FailureBlock)failure;

@end
