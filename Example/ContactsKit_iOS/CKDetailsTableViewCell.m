//
//  CKDetailsTableViewCell.m
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKDetailsTableViewCell.h"

@interface CKDetailsTableViewCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation CKDetailsTableViewCell

#pragma mark - Properties

- (void)setName:(NSString *)name
{
    self.label.text = name;
    self.textField.placeholder = name;
}

- (NSString *)name
{
    return self.label.text;
}

- (void)setValue:(NSString *)value
{
    self.textField.text = value;
}

- (NSString *)value
{
    return self.textField.text;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate cell:self didChangeValue:self.value forKey:self.name];
}

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
