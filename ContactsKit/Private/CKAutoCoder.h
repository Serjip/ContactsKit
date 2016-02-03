//
//  CKAutoCoder.h
//  ContactsKit
//
//  Created by Sergey Popov on 03.02.16.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (AutoCoder)

- (void)enumerateIvarsUsingBlock:(void (^)(NSString *name, const char *type, void *address))block;

@end

@interface NSCoder (AutoCoder)

- (void)encodeIvars:(id)object ignoreIvars:(const void *)firstIvar, ...;
- (void)decodeIvars:(id)object ignoreIvars:(const void *)firstIvar, ...;

@end
