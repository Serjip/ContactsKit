//
//  CKDetailsTableViewCell.m
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKDetailsTableViewCell.h"

@interface CKDetailsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation CKDetailsTableViewCell {
    Class _class;
    NSDateFormatter *_formatter;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"dd-MM-yyyy";
}

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

- (void)setValue:(id)value ofClass:(Class)aClass
{
    _class = aClass;
    
    NSString *text = nil;
    
    if (_class == [NSString class])
    {
        text = value;
    }
    else if (_class == [NSDate class])
    {
        text = [_formatter stringFromDate:value];
    }
    
    self.textField.text = text;
}

- (id)value
{
    id value = nil;
    
    if (_class == [NSString class])
    {
        value = self.textField.text;
    }
    else if (_class == [NSDate class])
    {
        value = [_formatter dateFromString:self.textField.text];
    }
    
    return value;
}

#pragma mark - Actions

- (IBAction)actionEditing:(id)sender
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
