//
//  ProfileViewController.m
//  TwitterClient
//
//  Created by Gerardo Quintanar Morales on 2/7/14.
//  Copyright (c) 2014 Gerardo Quintanar Morales. All rights reserved.
//

#import "ProfileViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [[NSArray alloc] initWithArray:[account
                                                                        accountsWithAccountType:accountType]];
             
             if(arrayOfAccounts != nil && [arrayOfAccounts count] == 0)
             {
                 // Handle failure to get account access
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                 message:@"There are no Twitter accounts configured. You must add or create one in Settings"
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
                 [alert show];
                 //self.statusLabel.text = @"No account = No tweets";
             }
             else {
                 //self.statusLabel.text = @"";
                 
                 
                 ACAccount *twitterAccount =
                 [arrayOfAccounts lastObject];
                 
                 NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 NSDictionary *parameters = @{@"screen_name" : [twitterAccount username]};
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 
                 [postRequest performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      self.dataSource = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:NSJSONReadingMutableLeaves
                                         error:&error];
                      if (self.dataSource!=nil) {
                          self.name.text = [self.dataSource objectForKey:@"name"];
                          self.bio.text = [self.dataSource objectForKey:@"description"];
                          self.location.text = [self.dataSource objectForKey:@"location"];

                          [self downloadImageWithURL:[NSURL URLWithString:self.dataSource[@"profile_banner_url"]] completionBlock:^(BOOL succeeded, UIImage *image) {
                              if (succeeded) {
                                  [self.backgroundImage setImage:image];
                                  
                              }
                          }];
                          [self downloadImageWithURL:[NSURL URLWithString:self.dataSource[@"profile_image_url"]] completionBlock:^(BOOL succeeded, UIImage *image) {
                              if (succeeded) {
                                  [self.profileImage setImage:image];
                                  
                              }
                          }];

                      }
                      
                  }];
                 
                 
             }
             
         }
     }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Extra methods

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}


@end
