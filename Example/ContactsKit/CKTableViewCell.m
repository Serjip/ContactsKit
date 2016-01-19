//
//  CKTableViewCell.m
//  ContactsKit
//
//  Created by Sergey Popov on 19.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKTableViewCell.h"

@implementation CKTableViewCell

- (void)setContact:(CKContact *)contact
{
    
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
