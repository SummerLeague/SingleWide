//
//  SLAppDelegate.m
//  SingleWide
//
//  Created by Mark Stultz on 2/11/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLAppDelegate.h"
#import "SLCredentialStore.h"

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Attempt to signin the user in the background.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		// Clear keychain on first run in case of reinstallation.
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
			[[[SLCredentialStore alloc] init] clearSavedCredentials];
			[[NSUserDefaults standardUserDefaults] setValue:@"1stRun" forKey:@"FirstRun"];
		}
	});
	
	return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
	return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
	return YES;
}

@end
