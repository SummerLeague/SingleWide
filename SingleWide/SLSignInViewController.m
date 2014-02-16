//
//  SLSignInViewController.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLSignInViewController.h"
#import "SLUserAuthenticator.h"

@interface SLSignInViewController ()

@property (nonatomic, weak) IBOutlet UITextField *nicknameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

- (IBAction)signIn:(id)sender;

@end

@implementation SLSignInViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.nicknameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"locationSegue"]) {
		SLUserAuthenticator *authenticator = [[SLUserAuthenticator alloc] init];
		[authenticator loginWithStoredCredentials:^{} failure:^(NSString *errorMessage) {}];
	}
	else {
		return [super prepareForSegue:segue sender:sender];
	}
}

- (IBAction)signIn:(id)sender
{
	SLUserAuthenticator *authenticator = [[SLUserAuthenticator alloc] init];
	[authenticator loginWithNickname:self.nicknameTextField.text password:self.passwordTextField.text success:^{
		[self performSegueWithIdentifier:@"locationSegue" sender:self];
	}
	failure:^(NSString *errorMessage) {
		[self.nicknameTextField becomeFirstResponder];
	}];
}

@end
