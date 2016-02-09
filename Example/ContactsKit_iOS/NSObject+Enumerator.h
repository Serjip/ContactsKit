//
//  NSObject+Enumerator.h
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Enumerator)

+ (void)enumeratePropertiesUsingBlock:(void (^) (NSString *name, Class aClass))block;

@end
