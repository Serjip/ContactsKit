//
//  CKTableViewCell.h
//  ContactsKit
//
//  Created by Sergey Popov on 19.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKContact;

@interface CKTableViewCell : UITableViewCell

- (void)setContact:(CKContact *)contact;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

@end
