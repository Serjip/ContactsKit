//
//  CKAddress_Private.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKAddress.h"
#import <AddressBook/AddressBook.h>

@interface CKAddress ()

- (instancetype)initWithAddressDictionary:(NSDictionary *)dictionary;
- (BOOL)addPropertiesToMultiValue:(ABMutableMultiValueRef)mutableMultiValueRef;

@end

@interface CKMutableAddress ()

@end
