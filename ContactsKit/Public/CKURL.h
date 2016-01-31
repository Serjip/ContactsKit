//
//  CKURL.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKLabel.h"

@interface CKURL : CKLabel

@property (nonatomic, strong, readonly) NSString *URLString;

@end

@interface CKMutableURL : CKMutableLabel

@property (nonatomic, strong) NSString *URLString;

@end

extern NSString * const CNURLAddressHomePage;
