//
//  SLAccountCreationViewController.m
//  SingleWide
//
//  Created by Bradley Griffith on 1/14/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLAccountCreationViewController.h"
#import "SLAccountCreator.h"

@interface SLAccountCreationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)createAccount:(id)sender;

@end

@implementation SLAccountCreationViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[_nicknameField becomeFirstResponder];
}

// TODO: Determine which one of these is appropriate, if either, for executing code
// prior to all events that segue away from this controller.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (IBAction)createAccount:(id)sender
{
	SLAccountCreator *accountCreator = [[SLAccountCreator alloc] init];
	[accountCreator createUserWithNickname:_nicknameField.text password:_passwordField.text success:^{
		[self performSegueWithIdentifier:@"locationSegue" sender:self];
	}
	failure:^(NSString *errorMessage) {
		NSLog(@"Error: %@", errorMessage);
		[_nicknameField becomeFirstResponder];
	}];
}

@end
