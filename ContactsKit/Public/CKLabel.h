//
//  CKLabel.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKLabel : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, strong, readonly) NSString *originalLabel;
@property (nonatomic, copy, readonly) NSString *localizedLabel;

+ (NSString *)localizedStringForLabel:(NSString *)label;
+ (NSArray *)labels;
+ (NSArray *)localizedLabels;

@end

extern NSString * const CKLabelHome;
extern NSString * const CKLabelWork;
extern NSString * const CKLabelOther;
