//
//  DetailViewController.m
//  TwitterClient
//
//  Created by Gerardo Quintanar Morales on 2/8/14.
//  Copyright (c) 2014 Gerardo Quintanar Morales. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

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
    //self.navigationItem.backBarButtonItem.title = @"Timeline";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];

    NSLog(@"self.tweet: %@",self.tweet);
    
    NSDictionary *user = self.tweet[@"user"];
    
    self.tweetText.text = self.tweet[@"text"];
    self.displayName.text = user[@"name"];
    self.userName.text = @"@";
    self.userName.text = [self.userName.text stringByAppendingString: user[@"screen_name"]];
    self.tweetTime.text = self.tweet[@"created_at"];
    [self downloadImageWithURL:[NSURL URLWithString:user[@"profile_image_url"]] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            // change the image in the cell
            [self.userImage setImage:image];
            
        }
    }];

    

}

-(void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
