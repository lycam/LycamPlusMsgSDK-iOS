//
//  LCPMessagManager.h
//  Pods
//
//  Created by no777 on 16/4/19.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kLCPMSGServerHost;
extern NSString * const kLCPMSGServerPort;
extern NSString * const kLCPMSGAppName;
extern NSString * const kLCPMSGTls;

@class LCPMessageManager;

@protocol LCPMessageManagerDelegate <NSObject>

-(void) managerConnecting:(LCPMessageManager*) manager ;
-(void) managerConnected:(LCPMessageManager*) manager ;
-(void) managerClosing:(LCPMessageManager*) manager ;
-(void) managerClosed:(LCPMessageManager*) manager ;
-(void) manager:(LCPMessageManager*)manager error: (NSError*) error;
-(void) manager:(LCPMessageManager*) manager receiveMessage:(NSDictionary * )msg withTopic:(NSString*) topic withRetained:(BOOL) retained;
@end

@interface LCPMessageManager : NSObject
@property (strong, nonatomic) NSString *token;


@property (weak, nonatomic) id<LCPMessageManagerDelegate> delegate;

-(id) initWithToken:(NSString *) token
        withChannel:(NSString*) channel
         withConfig:(NSDictionary*) config;

-(id) initWithToken:(NSString *) token
         withConfig:(NSDictionary*) config;

-(void) connect;

-(void) disconnect;
-(void) reconnect;

//订阅频道
-(void) subscribeChannel:(NSString*) channel ;

-(NSString*) makeTopic:(NSString*) channel;

//发送消息到指定频道
- (NSInteger)send:(NSDictionary* ) obj
      withChannel:(NSString *) channel;

@end
