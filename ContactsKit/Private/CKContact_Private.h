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
- (void)mergeLinkedRecordRef:(ABRecordRef)recordRef mergeMask:(CKContactField)mergeMask;

@end

@interface CKMutableContact ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSData *thumbnailData;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *modificationDate;

- (BOOL)setRecordRef:(ABRecordRef)recordRef error:(NSError **)error;

@end
