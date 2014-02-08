//
//  HomeTableViewController.m
//  TwitterClient
//
//  Created by Gerardo Quintanar Morales on 2/7/14.
//  Copyright (c) 2014 Gerardo Quintanar Morales. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize pull;

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

    [self getTimeLine];
    
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tweetTableView];
    [pull setDelegate:self];
    [self.tweetTableView addSubview:pull];


}


- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self performSelectorInBackground:@selector(reloadTableData) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) reloadTableData
{
    // call to reload your data
    [self getTimeLine];
    [self.tweetTableView reloadData];
    [pull finishedLoading];
}

-(IBAction)newTweet:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
        }
        
    }
    
}
- (void)getTimeLine {
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
                 self.statusLabel.text = @"No account = No tweets";
             }
             else {
                 self.statusLabel.text = @"";

                 
                 ACAccount *twitterAccount =
                 [arrayOfAccounts lastObject];
                 
                 NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com"
                                      @"/1.1/statuses/home_timeline.json"];
                 
                 NSDictionary *parameters = @{@"screen_name" : [twitterAccount username],
                                              @"include_rts" : @"1",
                                              @"contributor_details" : @"1",
                                              @"count" : @"20"};
                 
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
                      
                      if (self.dataSource.count != 0) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.tweetTableView reloadData];
                          });
                      }
                  }];

                 
             }

         }
              }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"customTweetCell";
    
    UITableViewCell *cell = [self.tweetTableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }

    if ([self.dataSource valueForKey:@"errors"]==nil) {
        NSLog(@"Errors!");
    }
    else
    {
        
        NSDictionary *tweet = _dataSource[[indexPath row]];
        NSDictionary *user = [tweet objectForKey:@"user"];
        UILabel *labelTweet = (UILabel *)[cell viewWithTag:100];
        [labelTweet setText:tweet[@"text"]];
        //NSLog(@"profile_image_url :%@",user[@"profile_image_url"]);
        UIImageView *profileImage = (UIImageView *)[cell viewWithTag:200];
        [self downloadImageWithURL:[NSURL URLWithString:user[@"profile_image_url"]] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                [profileImage setImage:image];
                
            }
        }];

    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"detailPushSegue"])
    {
        DetailViewController *detailViewController = (DetailViewController *)segue.destinationViewController;

        
    }
    
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
