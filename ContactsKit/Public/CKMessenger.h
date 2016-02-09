//
//  CKMessenger.h
//  ContactsKit
//
//  Created by Sergey P on 05.02.16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CKMessengerService)
{
    CKMessengerServiceUnknown  = 0,
    CKMessengerServiceAIM,          // AIM
    CKMessengerServiceFacebook,     // Facebook
    CKMessengerServiceGaduGadu,     // Gadu-Gadu
    CKMessengerServiceGoogleTalk,   // Google Talk
    CKMessengerServiceICQ,          // ICQ
    CKMessengerServiceJabber,       // Jabber
    CKMessengerServiceMSN,          // MSN
    CKMessengerServiceQQ,           // QQ
    CKMessengerServiceSkype,        // Skype
    CKMessengerServiceYahoo,        // Yahoo!
};

@interface CKMessenger : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *service;
@property (nonatomic, assign, readonly) CKMessengerService serviceType;

@end

@interface CKMutableMessenger : CKMessenger

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *service;
@property (nonatomic, assign) CKMessengerService serviceType;

@end