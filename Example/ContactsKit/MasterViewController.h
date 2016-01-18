//
//  MasterViewController.h
//  ContactsKit
//
//  Created by Sergey Popov on 18.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

