//
//  CKEmail.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKLabel.h"

@interface CKEmail : CKLabel <NSMutableCopying>

@property (nonatomic, strong, readonly) NSString *address;

@end

@interface CKMutableEmail : CKEmail

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *originalLabel;

@end

extern NSString * const CKEmailiCloud;
