//
//  SLSignInViewController.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLSignInViewController.h"

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
	//if( [segue.identifier isEqualToString:@"scannerSegue"] )
	{
		//SLUserAuthenticator *authenticator = [[SLUserAuthenticator alloc] init];
		//[authenticator loginWithStoredCredentials:^{} failure:^(NSString *errorMessage) {}];
	}
	//else
	{
		return [super prepareForSegue:segue sender:sender];
	}
}

- (IBAction)signIn:(id)sender
{
//	SLUserAuthenticator *authenticator = [[SLUserAuthenticator alloc] init];
//	[authenticator loginWithNickname:_nicknameField.text password:_passwordField.text success:
	 
	 
	 /*^{
										 // Dismiss HUD.
										 [SVProgressHUD dismiss];
										 [self performSegueWithIdentifier:@"scannerSegue" sender:self];
									 }
									 failure:^(NSString *errorMessage) {
										 [SVProgressHUD showErrorWithStatus:errorMessage];
										 [_nicknameField becomeFirstResponder];
									 }];*/
}

@end
