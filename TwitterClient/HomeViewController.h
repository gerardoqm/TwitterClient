//
//  HomeTableViewController.h
//  TwitterClient
//
//  Created by Gerardo Quintanar Morales on 2/7/14.
//  Copyright (c) 2014 Gerardo Quintanar Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,PullToRefreshViewDelegate>
{

}

@property (strong, nonatomic) PullToRefreshView *pull;

@property (weak, nonatomic) IBOutlet UITableView *tweetTableView;
@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

-(IBAction)newTweet:(id)sender;

@end
