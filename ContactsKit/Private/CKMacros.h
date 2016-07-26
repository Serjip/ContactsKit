//
//  CKMacros.h
//  ContactsKit
//
//  Created by Sergey Popov on 02/03/16.
//  Copyright (c) 2016 Sergey Popov <serj@ttitt.ru>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#ifndef CKMacros_h
#define CKMacros_h

// Equality
#define CK_IS_EQUAL(obj1, obj2) (obj1 == obj2 || [obj1 isEqual:obj2])

// Localization
#import "NSBundle+CKLocalizatoin.h"
#define CKLocalizedString(key, comment) \
[[NSBundle ck_mainBundle] localizedStringForKey:(key) value:@"" table:nil]

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

#define kABSocialProfileServiceTwitter      (__bridge NSString *)kABPersonSocialProfileServiceTwitter       // Twitter
#define kABSocialProfileServiceFacebook     (__bridge NSString *)kABPersonSocialProfileServiceFacebook      // Facebook
#define kABSocialProfileServiceLinkedIn     (__bridge NSString *)kABPersonSocialProfileServiceLinkedIn      // LinkedIn
#define kABSocialProfileServiceFlickr       (__bridge NSString *)kABPersonSocialProfileServiceFlickr        // Flickr
#define kABSocialProfileServiceMySpace      (__bridge NSString *)kABPersonSocialProfileServiceMyspace       // Myspace
#define kABSocialProfileServiceSinaWeibo    (__bridge NSString *)kABPersonSocialProfileServiceSinaWeibo     // SinaWeibo

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

#elif TARGET_OS_MAC

// Contact
#define kABPersonFirstNameProperty          (__bridge CFStringRef)kABFirstNameProperty
#define kABPersonMiddleNameProperty         (__bridge CFStringRef)kABMiddleNameProperty
#define kABPersonLastNameProperty           (__bridge CFStringRef)kABLastNameProperty
#define kABPersonNicknameProperty           (__bridge CFStringRef)kABNicknameProperty
#define kABPersonPrefixProperty             (__bridge CFStringRef)kABTitleProperty
#define kABPersonSuffixProperty             (__bridge CFStringRef)kABSuffixProperty

#define kABPersonOrganizationProperty       (__bridge CFStringRef)kABOrganizationProperty
#define kABPersonJobTitleProperty           (__bridge CFStringRef)kABJobTitleProperty
#define kABPersonDepartmentProperty         (__bridge CFStringRef)kABDepartmentProperty

#define kABPersonNoteProperty               (__bridge CFStringRef)kABNoteProperty

#define kABPersonPhoneProperty              (__bridge CFStringRef)kABPhoneProperty
#define kABPersonEmailProperty              (__bridge CFStringRef)kABEmailProperty
#define kABPersonAddressProperty            (__bridge CFStringRef)kABAddressProperty
#define kABPersonInstantMessageProperty     (__bridge CFStringRef)kABInstantMessageProperty
#define kABPersonSocialProfileProperty      (__bridge CFStringRef)kABSocialProfileProperty
#define kABPersonURLProperty                (__bridge CFStringRef)kABURLsProperty
#define kABPersonDateProperty               (__bridge CFStringRef)kABOtherDatesProperty

#define kABPersonBirthdayProperty           (__bridge CFStringRef)kABBirthdayProperty
#define kABPersonCreationDateProperty       (__bridge CFStringRef)kABCreationDateProperty
#define kABPersonModificationDateProperty   (__bridge CFStringRef)kABModificationDateProperty

// Address book
#define ABPropertyID    CFStringRef
#define ABMultiValueGetCount    ABMultiValueCount

// Fix for OSX
#define kABMultiStringPropertyType  0
#define kABMultiDictionaryPropertyType  0

#endif

#endif /* CKMacros_h */
