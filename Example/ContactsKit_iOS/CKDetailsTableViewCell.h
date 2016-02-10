//
//  CKDetailsTableViewCell.h
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKDetailsTableViewCellDelegate;

@interface CKDetailsTableViewCell : UITableViewCell

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *value;
@property (weak) id<CKDetailsTableViewCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

@end

@protocol CKDetailsTableViewCellDelegate <NSObject>

- (void)cell:(CKDetailsTableViewCell *)cell didChangeValue:(NSString *)value forKey:(NSString *)key;

@end
