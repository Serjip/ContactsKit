//
//  CKContact_Private.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKContact.h"
#import <AddressBook/AddressBook.h>

@class CNContact;

@interface CKContact ()

@property (nonatomic, assign, readonly) CKContactField fieldMask;

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask NS_DEPRECATED(10_6, 10_10, 6_0, 9_0);
- (void)mergeLinkedRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask NS_DEPRECATED(10_6, 10_10, 6_0, 9_0);

- (instancetype)initWithContact:(CNContact *)contact fieldMask:(CKContactField)fieldMask NS_AVAILABLE(10_10, 9_0);
- (void)mergeLinkedContact:(CNContact *)contact fieldMask:(CKContactField)fieldMask NS_AVAILABLE(10_10, 9_0);

@end
