//
//  CKPropertyTableViewController.h
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKPropertyTableViewControllerDelegate;

@interface CKPropertyTableViewController : UITableViewController

@property (weak) id<CKPropertyTableViewControllerDelegate> delegate;

- (instancetype)initWithObject:(id)anObject ofClass:(Class)aClass;

@end

@protocol CKPropertyTableViewControllerDelegate <NSObject>

- (void)propertyTableController:(CKPropertyTableViewController *)vc didSaveObject:(id)object;

@end
