//
//  CKPhone.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKLabel.h"

@interface CKPhone : CKLabel <NSMutableCopying>

@property (nonatomic, strong, readonly) NSString *number;

@end

@interface CKMutablePhone : CKPhone

@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *originalLabel;

@end

extern NSString * const CKPhoneiPhone;
extern NSString * const CKPhoneMobile;
extern NSString * const CKPhoneMain;
extern NSString * const CKPhoneHomeFax;
extern NSString * const CKPhoneWorkFax;
extern NSString * const CKPhoneOtherFax;
extern NSString * const CKPhonePager;
