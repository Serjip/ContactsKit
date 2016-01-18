//
//  CKTypes.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#ifndef AddressBook_CKTypes_h
#define AddressBook_CKTypes_h

@class CKContact;

typedef NS_ENUM(NSUInteger, CKAddressBookAccess)
{
    CKAddressBookAccessUnknown = 0,
    CKAddressBookAccessGranted = 1,
    CKAddressBookAccessDenied  = 2
};

typedef NS_OPTIONS(NSUInteger , CKContactField)
{
    CKContactFieldFirstName        = 1 << 0,
    CKContactFieldLastName         = 1 << 1,
    CKContactFieldCompany          = 1 << 2,
    CKContactFieldJobTitle         = 1 << 3,
    CKContactFieldPhones           = 1 << 4,
    CKContactFieldEmails           = 1 << 5,
    CKContactFieldPhoto            = 1 << 6,
    CKContactFieldThumbnail        = 1 << 7,
    CKContactFieldCompositeName    = 1 << 8,
    CKContactFieldAddresses        = 1 << 9,
    CKContactFieldRecordID         = 1 << 10,
    CKContactFieldBirthday         = 1 << 11,
    CKContactFieldCreationDate     = 1 << 12,
    CKContactFieldModificationDate = 1 << 13,
    CKContactFieldMiddleName       = 1 << 14,
    CKContactFieldSocialProfiles   = 1 << 15,
    CKContactFieldNote             = 1 << 16,
    CKContactFieldURLs             = 1 << 17,
    CKContactFieldDefault          = CKContactFieldFirstName | CKContactFieldLastName |
                                     CKContactFieldPhones,
    CKContactFieldAll              = NSUIntegerMax
};

#endif
