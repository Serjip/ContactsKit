//
//  CKDetailsTableViewController.h
//  ContactsKit
//
//  Created by Sergey Popov on 08.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKPropertyTableViewController.h"

@class CKContact;

@interface CKDetailsTableViewController : CKPropertyTableViewController

- (instancetype)initWithContact:(CKContact *)contact;

@end
