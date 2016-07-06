//
//  CKDetailsTableViewController.h
//  ContactsKit
//
//  Created by Sergey Popov on 08.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKPropertyTableViewController.h"

@class CKAddressBook, CKContact;

@interface CKDetailsTableViewController : CKPropertyTableViewController <CKPropertyTableViewControllerDelegate>

@property (strong, nonatomic) CKAddressBook *addressBook;

- (instancetype)initWithContact:(CKContact *)contact;

@end
