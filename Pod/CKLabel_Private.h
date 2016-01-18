//
//  CKLabel_Private.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKLabel.h"
#import <AddressBook/AddressBook.h>

@class CNLabeledValue;

@interface CKLabel ()

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index NS_DEPRECATED(10_6, 10_10, 6_0, 9_0);
- (instancetype)initWithLabledValue:(CNLabeledValue *)labledValue NS_AVAILABLE(10_10, 9_0);

@end
