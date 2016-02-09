//
//  CKDetailsTableViewCell.h
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKDetailsTableViewCell : UITableViewCell

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *value;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

@end
