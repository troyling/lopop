//
//  LPUserProfileViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserProfileViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation LPUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _loadData];
}

- (void)_loadData {
    // present what's been previsouly cached and display the update from Facebook
    if ([PFUser currentUser]) {
        [self _presentProfileData];
    }
    
    // request data from Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // process the data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            
            NSMutableDictionary *profile = [[NSMutableDictionary alloc] init];
            
            if (facebookID) {
                profile[@"facebookID"] = facebookID;
            }
            
            if (name) {
                profile[@"name"] = name;
            }
            
            if (location) {
                profile[@"locaton"] = location;
            }
            
            if (gender) {
                profile[@"gender"] = gender;
            }
            
            if (birthday) {
                profile[@"birthday"] = birthday;
            }
            
            profile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            
            // save data to parse
            [[PFUser currentUser] setObject:profile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
            [self _presentProfileData];
        
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"Session error");
            // TODO should log user out
        } else {
            NSLog(@"Other error");
        }
    }];
}

- (void)_presentProfileData {
    NSLog(@"presenting profile data");
    NSDictionary *profile = [PFUser currentUser][@"profile"];
    
    if (profile) {
        NSString *name = profile[@"name"];
        NSString *profilePicURLStr = profile[@"pictureURL"];
        NSString *email = profile[@"email"];
        NSString *gender = profile[@"gender"];
        NSString *birthday = profile[@"birthday"];
        
        NSLog(@"email: %@", email);
        NSLog(@"gender: %@", gender);
        NSLog(@"birthday: %@", birthday);
        
        if (name) {
            _nameLabel.text = name;
        }
        
        if (profilePicURLStr) {
            // download the user's facebook profile picture
            NSURL *pictureURL = [NSURL URLWithString:profilePicURLStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:pictureURL];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError == nil && data != nil) {
                    _profileImageView.image = [UIImage imageWithData:data];
                    _profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
                    _profileImageView.clipsToBounds = YES;
                } else {
                    NSLog(@"Failed to load profile photo.");
                }
            }];
        }
    }
}

- (IBAction)logout:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        NSLog(@"Logging user out");
        [PFUser logOut];
        NSLog(@"%@", [PFUser currentUser]);
        
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPSignUpViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    }
}


@end
