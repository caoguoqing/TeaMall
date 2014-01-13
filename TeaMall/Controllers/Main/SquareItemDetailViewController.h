//
//  SquareItemDetailViewController.h
//  TeaMall
//
//  Created by vedon on 13/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class starView;
@interface SquareItemDetailViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UILabel *transactionNum;
@property (weak, nonatomic) IBOutlet UILabel *transactionDate;
@property (weak, nonatomic) IBOutlet UILabel *transactionType;
@property (weak, nonatomic) IBOutlet starView *littleStarView;


- (IBAction)contactCustomerServiceAction:(id)sender;
@end