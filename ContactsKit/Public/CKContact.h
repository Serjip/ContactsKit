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

@property (nonatomic, strong, readonly) NSString *identifier;

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *middleName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *nickname;
@property (nonatomic, strong, readonly) NSString *namePrefix;
@property (nonatomic, strong, readonly) NSString *nameSuffix;

@property (nonatomic, strong, readonly) NSString *company;
@property (nonatomic, strong, readonly) NSString *jobTitle;
@property (nonatomic, strong, readonly) NSString *department;

@property (nonatomic, strong, readonly) NSString *note;

@property (nonatomic, strong, readonly) NSData *imageData;
@property (nonatomic, strong, readonly) NSData *thumbnailData;

@property (nonatomic, strong, readonly) NSArray<CKPhone *> *phones;
@property (nonatomic, strong, readonly) NSArray<CKEmail *> *emails;
@property (nonatomic, strong, readonly) NSArray<CKAddress *> *addresses;
@property (nonatomic, strong, readonly) NSArray<CKMessenger *> *instantMessengers;
@property (nonatomic, strong, readonly) NSArray<CKSocialProfile *> *socialProfiles;
@property (nonatomic, strong, readonly) NSArray<CKURL *> *URLs;
@property (nonatomic, strong, readonly) NSArray<CKDate *> *dates;

@property (nonatomic, strong, readonly) NSDate *birthday;
@property (nonatomic, strong, readonly) NSDate *creationDate;
@property (nonatomic, strong, readonly) NSDate *modificationDate;

@property (nonatomic, assign, readonly) CKContactField fieldMask;

@end


@interface CKMutableContact : CKContact

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *namePrefix;
@property (nonatomic, strong) NSString *nameSuffix;

@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *jobTitle;
@property (nonatomic, strong) NSString *department;

@property (nonatomic, strong) NSString *note;

@property (nonatomic, strong) NSData *imageData;

@property (nonatomic, strong) NSArray<CKPhone *> *phones;
@property (nonatomic, strong) NSArray<CKEmail *> *emails;
@property (nonatomic, strong) NSArray<CKAddress *> *addresses;
@property (nonatomic, strong) NSArray<CKMessenger *> *instantMessengers;
@property (nonatomic, strong) NSArray<CKSocialProfile *> *socialProfiles;
@property (nonatomic, strong) NSArray<CKURL *> *URLs;
@property (nonatomic, strong) NSArray<CKDate *> *dates;

@property (nonatomic, strong) NSDate *birthday;

@end
