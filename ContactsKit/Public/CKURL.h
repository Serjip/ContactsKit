//
//  CKURL.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKLabel.h"

@interface CKURL : CKLabel <NSMutableCopying>

@property (nonatomic, strong, readonly) NSString *URLString;

@end

@interface CKMutableURL : CKURL

@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, strong) NSString *originalLabel;

@end

extern NSString * const CKURLHomePage;
