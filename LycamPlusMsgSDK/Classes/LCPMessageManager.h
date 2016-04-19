//
//  LCPMessagManager.h
//  Pods
//
//  Created by no777 on 16/4/19.
//
//

#import <Foundation/Foundation.h>

@class LCPMessageManager;

@protocol LCPMessageManagerDelegate <NSObject>

-(void) managerConnecting:(LCPMessageManager*) manager ;
-(void) managerConnected:(LCPMessageManager*) manager ;
-(void) managerClosing:(LCPMessageManager*) manager ;
-(void) managerClosed:(LCPMessageManager*) manager ;
-(void) managerError:(LCPMessageManager*) manager ;
-(void) manager:(LCPMessageManager*) manager receiveMessage:(NSDictionary * ) msg withTopic:(NSString*) topic;
@end

@interface LCPMessageManager : NSObject
@property (strong, nonatomic) NSString *token;


@property (weak, nonatomic) id<LCPMessageManagerDelegate> delegate;

-(id) initWithToken:(NSString *) token withTopic:(NSString*)topic withConfig:(NSDictionary*) config;
-(void) connect;
-(NSInteger) send:(NSDictionary* ) obj;
@end
