//
//  NSObject+Enumerator.m
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "NSObject+Enumerator.h"
#import <objc/runtime.h>

@implementation NSObject (Enumerator)

+ (void)enumeratePropertiesUsingBlock:(void (^) (NSString *name, Class aClass))block
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for (unsigned int i = 0; i < count; i++)
    {
        objc_property_t p = properties[i];
        NSString *name =  @(property_getName(p));
        NSString *attributes = @(property_getAttributes(p));
        NSString *type = [attributes componentsSeparatedByString:@","].firstObject;
        type = [type substringFromIndex:1];
        
        if ([type hasPrefix:@"@"])
        {
            type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
            block(name, NSClassFromString(type));
        }
    }
    free(properties);
}

@end
