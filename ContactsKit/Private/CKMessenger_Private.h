//
//  CKMessenger_Private.h
//  Pods
//
//  Created by Sergey P on 05.02.16.
//
//

#import "CKMessenger.h"
#import <AddressBook/AddressBook.h>

@interface CKMessenger ()

- (instancetype)initWithMessengerDictionary:(NSDictionary *)dictionary;
- (BOOL)addPropertiesToMultiValue:(ABMutableMultiValueRef)mutableMultiValueRef;

@end

@interface CKMutableMessenger ()

@end
