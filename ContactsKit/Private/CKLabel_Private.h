//
//  CKLabel_Private.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKLabel.h"
#import <AddressBook/AddressBook.h>

@interface CKLabel () <NSMutableCopying>

@property (nonatomic, strong) NSString *originalLabel;

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;
- (BOOL)setLabledValue:(ABMutableMultiValueRef)mutableMultiValue;

@end
