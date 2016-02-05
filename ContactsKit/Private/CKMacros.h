//
//  CKMacros.h
//  ContactsKit
//
//  Created by Sergey Popov on 03.02.16.
//
//

#ifndef CKMacros_h
#define CKMacros_h

// Equality
#define CK_IS_EQUAL(obj1, obj2) (obj1 == obj2 || [obj1 isEqual:obj2])

#if TARGET_OS_IOS
// Address
#define kABAddressStreetKey         (__bridge NSString *)kABPersonAddressStreetKey
#define kABAddressCityKey           (__bridge NSString *)kABPersonAddressCityKey
#define kABAddressStateKey          (__bridge NSString *)kABPersonAddressStateKey
#define kABAddressZIPKey            (__bridge NSString *)kABPersonAddressZIPKey
#define kABAddressCountryKey        (__bridge NSString *)kABPersonAddressCountryKey
#define kABAddressCountryCodeKey    (__bridge NSString *)kABPersonAddressCountryCodeKey
// Social profile
#define kABSocialProfileURLKey              (__bridge_transfer NSString *)kABPersonSocialProfileURLKey
#define kABSocialProfileUsernameKey         (__bridge_transfer NSString *)kABPersonSocialProfileUsernameKey
#define kABSocialProfileUserIdentifierKey   (__bridge_transfer NSString *)kABPersonSocialProfileUserIdentifierKey
#define kABSocialProfileServiceKey          (__bridge_transfer NSString *)kABPersonSocialProfileServiceKey

#endif

#endif /* CKMacros_h */
