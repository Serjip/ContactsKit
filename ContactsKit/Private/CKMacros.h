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
#define kABSocialProfileURLKey              (__bridge NSString *)kABPersonSocialProfileURLKey
#define kABSocialProfileUsernameKey         (__bridge NSString *)kABPersonSocialProfileUsernameKey
#define kABSocialProfileUserIdentifierKey   (__bridge NSString *)kABPersonSocialProfileUserIdentifierKey
#define kABSocialProfileServiceKey          (__bridge NSString *)kABPersonSocialProfileServiceKey

// Messenger
#define kABInstantMessageUsernameKey    (__bridge NSString *)kABPersonInstantMessageUsernameKey
#define kABInstantMessageServiceKey     (__bridge NSString *)kABPersonInstantMessageServiceKey

#define kABInstantMessageServiceAIM			(__bridge NSString *)kABPersonInstantMessageServiceAIM          // AIM
#define kABInstantMessageServiceFacebook	(__bridge NSString *)kABPersonInstantMessageServiceFacebook		// Facebook
#define kABInstantMessageServiceGaduGadu	(__bridge NSString *)kABPersonInstantMessageServiceGaduGadu		// Gadu-Gadu
#define kABInstantMessageServiceGoogleTalk	(__bridge NSString *)kABPersonInstantMessageServiceGoogleTalk	// Google Talk
#define kABInstantMessageServiceICQ			(__bridge NSString *)kABPersonInstantMessageServiceICQ          // ICQ
#define kABInstantMessageServiceJabber		(__bridge NSString *)kABPersonInstantMessageServiceJabber		// Jabber
#define kABInstantMessageServiceMSN			(__bridge NSString *)kABPersonInstantMessageServiceMSN          // MSN
#define kABInstantMessageServiceQQ			(__bridge NSString *)kABPersonInstantMessageServiceQQ           // QQ
#define kABInstantMessageServiceSkype		(__bridge NSString *)kABPersonInstantMessageServiceSkype        // Skype
#define kABInstantMessageServiceYahoo		(__bridge NSString *)kABPersonInstantMessageServiceYahoo        // Yahoo!

#endif

#endif /* CKMacros_h */
