//
//  CKAddress.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKAddress : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, strong, readonly) NSString *street;
@property (nonatomic, strong, readonly) NSString *city;
@property (nonatomic, strong, readonly) NSString *state;
@property (nonatomic, strong, readonly) NSString *zip;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *ISOCountryCode;

@end
