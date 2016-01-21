//
//  CKTableViewCell.m
//  ContactsKit
//
//  Created by Sergey Popov on 19.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKTableViewCell.h"

#import <ContactsKit/ContactsKit.h>

@interface CKTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@end

@implementation CKTableViewCell

- (void)setContact:(CKContact *)contact
{
    if (contact.imageData)
    {
        self.photoImageView.image = [UIImage imageWithData:contact.thumbnailData scale:[UIScreen mainScreen].scale];
    }
    else
    {
        self.photoImageView.image = [UIImage imageNamed:@"ContactPlaceholder"];
    }
    
    self.mainLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    self.subLabel.text = [NSString stringWithFormat:@"%@ (%@)", contact.phones.firstObject.number, contact.phones.firstObject.localizedLabel];;
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
