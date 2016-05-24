//
//  CKContact.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
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

#import <Foundation/Foundation.h>

@class CKURL, CKPhone, CKSocialProfile, CKAddress, CKEmail, CKMessenger, CKDate;

typedef NS_OPTIONS(NSUInteger , CKContactField)
{
    CKContactFieldFirstName         = 1 << 1,
    CKContactFieldLastName          = 1 << 2,
    CKContactFieldMiddleName        = 1 << 3,
    CKContactFieldNickname          = 1 << 4,
    CKContactFieldNamePrefix        = 1 << 5,
    CKContactFieldNameSuffix        = 1 << 6,
    
    CKContactFieldCompany           = 1 << 10,
    CKContactFieldJobTitle          = 1 << 11,
    CKContactFieldDepartment        = 1 << 12,
    
    CKContactFieldNote              = 1 << 15,
    
    CKContactFieldImageData         = 1 << 20,
    CKContactFieldThumbnailData     = 1 << 21,
    
    CKContactFieldPhones            = 1 << 30,
    CKContactFieldEmails            = 1 << 31,
    CKContactFieldAddresses         = 1 << 31,
    CKContactFieldInstantMessengers = 1 << 33,
    CKContactFieldSocialProfiles    = 1 << 34,
    CKContactFieldURLs              = 1 << 35,
    CKContactFieldDates             = 1 << 36,
    
    CKContactFieldBirthday          = 1 << 40,
    
    CKContactFieldCreationDate      = 1 << 45,
    CKContactFieldModificationDate  = 1 << 46,
    
    CKContactFieldDefault          = CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldPhones,
    CKContactFieldAll              = NSUIntegerMax
};

@interface CKContact : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

@property (strong, nonatomic, readonly) NSString *identifier;

@property (strong, nonatomic, readonly) NSString *firstName;
@property (strong, nonatomic, readonly) NSString *middleName;
@property (strong, nonatomic, readonly) NSString *lastName;
@property (strong, nonatomic, readonly) NSString *nickname;
@property (strong, nonatomic, readonly) NSString *namePrefix;
@property (strong, nonatomic, readonly) NSString *nameSuffix;

@property (strong, nonatomic, readonly) NSString *company;
@property (strong, nonatomic, readonly) NSString *jobTitle;
@property (strong, nonatomic, readonly) NSString *department;

@property (strong, nonatomic, readonly) NSString *note;

@property (strong, nonatomic, readonly) NSData *imageData;
@property (strong, nonatomic, readonly) NSData *thumbnailData;

@property (strong, nonatomic, readonly) NSArray<CKPhone *> *phones;
@property (strong, nonatomic, readonly) NSArray<CKEmail *> *emails;
@property (strong, nonatomic, readonly) NSArray<CKAddress *> *addresses;
@property (strong, nonatomic, readonly) NSArray<CKMessenger *> *instantMessengers;
@property (strong, nonatomic, readonly) NSArray<CKSocialProfile *> *socialProfiles;
@property (strong, nonatomic, readonly) NSArray<CKURL *> *URLs;
@property (strong, nonatomic, readonly) NSArray<CKDate *> *dates;

@property (strong, nonatomic, readonly) NSDate *birthday;
@property (strong, nonatomic, readonly) NSDate *creationDate;
@property (strong, nonatomic, readonly) NSDate *modificationDate;

@property (assign, nonatomic, readonly) CKContactField fieldMask;

@end


@interface CKMutableContact : CKContact

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *middleName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *namePrefix;
@property (strong, nonatomic) NSString *nameSuffix;

@property (strong, nonatomic) NSString *company;
@property (strong, nonatomic) NSString *jobTitle;
@property (strong, nonatomic) NSString *department;

@property (strong, nonatomic) NSString *note;

@property (strong, nonatomic) NSData *imageData;

@property (strong, nonatomic) NSArray<CKPhone *> *phones;
@property (strong, nonatomic) NSArray<CKEmail *> *emails;
@property (strong, nonatomic) NSArray<CKAddress *> *addresses;
@property (strong, nonatomic) NSArray<CKMessenger *> *instantMessengers;
@property (strong, nonatomic) NSArray<CKSocialProfile *> *socialProfiles;
@property (strong, nonatomic) NSArray<CKURL *> *URLs;
@property (strong, nonatomic) NSArray<CKDate *> *dates;

@property (strong, nonatomic) NSDate *birthday;

@end
