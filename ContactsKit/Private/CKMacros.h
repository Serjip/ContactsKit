//
//  CKMacros.h
//  ContactsKit
//
//  Created by Sergey Popov on 03.02.16.
//
//

#ifndef CKMacros_h
#define CKMacros_h


#define __IS_EQUAL(x, y) (x == y || [x isEqual:y])

#if TARGET_OS_IOS
// Address
#define kABAddressStreetKey         (__bridge NSString *)kABPersonAddressStreetKey
#define kABAddressCityKey           (__bridge NSString *)kABPersonAddressCityKey
#define kABAddressStateKey          (__bridge NSString *)kABPersonAddressStateKey
#define kABAddressZIPKey            (__bridge NSString *)kABPersonAddressZIPKey
#define kABAddressCountryKey        (__bridge NSString *)kABPersonAddressCountryKey
#define kABAddressCountryCodeKey    (__bridge NSString *)kABPersonAddressCountryCodeKey

#endif

#endif /* CKMacros_h */
