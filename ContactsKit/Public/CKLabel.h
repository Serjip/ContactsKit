//
//  CKLabel.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKLabel : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, strong, readonly) NSString *originalLabel;
@property (nonatomic, strong, readonly) NSString *localizedLabel;

@end
