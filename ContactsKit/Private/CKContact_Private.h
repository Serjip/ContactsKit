//
//  CKContact_Private.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKContact.h"
#import <AddressBook/AddressBook.h>
#import "CKAddressBook.h"

@interface CKContact ()

@property (nonatomic, assign, readonly) CKContactField fieldMask;

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask;
- (void)mergeLinkedRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask;

@end
