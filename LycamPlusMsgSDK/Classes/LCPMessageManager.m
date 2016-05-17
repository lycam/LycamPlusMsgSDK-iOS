//
//  LCPMessagManager.m
//  Pods
//
//  Created by no777 on 16/4/19.
//
//

#import "LCPMessageManager.h"
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>

NSString * const kLCPMSGServerHost = @"host";
NSString * const kLCPMSGServerPort = @"port";
NSString * const kLCPMSGAppName = @"appname";
NSString * const kLCPMSGTls = @"tls";

NSString * const kLCPServiceAPIDomain=@"api.lycam.tv";

@interface MQTTSessionManager()
@property (nonatomic) double reconnectTime;
-(void) reconnect;
@end


@interface LCPMessageManager() <MQTTSessionManagerDelegate>
@property (strong, nonatomic) MQTTSessionManager *manager;
@property (strong, nonatomic) NSString *base;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> * subscriptions;

@property (strong, nonatomic) NSDictionary *mqttSettings;
@property (strong, nonatomic) NSTimer *reconnectTimer;
@property (nonatomic) double reconnectTime;


@end
#define DEFAULT_QOS_LEVEL MQTTQosLevelExactlyOnce
@implementation LCPMessageManager

-(id) initWithToken:(NSString *) token
         withConfig:(NSDictionary*) config{
    return [self initWithToken:token withChannel:nil withConfig:config];
}

-(id) initWithToken:(NSString *) token
        withChannel:(NSString*) channel
         withConfig:(NSDictionary*) config
{
    if(self = [super init]){
        self.token = token;
        self.base = @"LCP";
        self.reconnectTime=2;
        
        self.mqttSettings = @{kLCPMSGAppName:@"LCP",
                              kLCPMSGServerHost:@"mqtt.lycam.tv",
                              kLCPMSGServerPort:@(1883),
                              kLCPMSGTls:@(NO)
                              };
        if(config){
            self.mqttSettings = config;
        }

        NSString * base = [self.mqttSettings objectForKey:@"appname"];
        if(base){
            self.base = base;
        }
        if(channel)
            self.subscriptions = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:DEFAULT_QOS_LEVEL]
                                                             forKey:[NSString stringWithFormat:@"%@:%@", self.base,channel]];
        
        else
            self.subscriptions = [[NSMutableDictionary alloc] init];
        
        
    }
    return self;
}


-(void) subscribeChannel:(NSString*) chan{


    if(chan){
        NSString * topic = [NSString stringWithFormat:@"%@:%@", self.base,chan];
        [self.subscriptions setObject:[NSNumber numberWithInt:DEFAULT_QOS_LEVEL] forKey:topic];
        [self setSubscriptions];
    }
}

-(void) unsubscribeChannel:(NSString*) chan{
    
    
    if(chan){
        NSString * topic = [NSString stringWithFormat:@"%@:%@", self.base,chan];
        [self.subscriptions removeObjectForKey:topic];
        [self setSubscriptions];
    }
    
}

- (void)setSubscriptions
{
    [self.manager setSubscriptions:self.subscriptions];
}



-(void) disconnect{
    [self.manager disconnect];
}
-(void) connect{
    /*
     * MQTTClient: create an instance of MQTTSessionManager once and connect
     * will is set to let the broker indicate to other subscribers if the connection is lost
     */
    if (!self.manager) {
        self.manager = [[MQTTSessionManager alloc] init];
        self.manager.delegate = self;
        
        self.manager.subscriptions = self.subscriptions;
        
//        self.manager.subscriptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEFAULT_QOS_LEVEL]
//                                    forKey:[NSString stringWithFormat:@"%@:%@", self.base,@"channel1"]];
        
        
        [self.manager connectTo:self.mqttSettings[@"host"]
                           port:[self.mqttSettings[@"port"] intValue]
                            tls:[self.mqttSettings[@"tls"] boolValue]
                      keepalive:30
                          clean:true
                           auth:true
                           user:[UIDevice currentDevice].name
                           pass:self.token
                      willTopic:[NSString stringWithFormat:@"%@/willTopic", self.base]
                           will:[@"offline" dataUsingEncoding:NSUTF8StringEncoding]
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:FALSE
                   withClientId:[UIDevice currentDevice].identifierForVendor.UUIDString];
        
        
        [self.manager addObserver:self
                       forKeyPath:@"state"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:nil];
    } else {
        [self.manager connectToLast];
    }

}
-(void) reconnect{
    [self.reconnectTimer invalidate];
    self.reconnectTimer = [NSTimer timerWithTimeInterval:self.reconnectTime
                                                  target:self
                                                selector:@selector(doReconnect)
                                                userInfo:Nil repeats:FALSE];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.reconnectTimer
              forMode:NSDefaultRunLoopMode];
    
    
}
-(void) doReconnect{
    self.manager.reconnectTime = 0.5;
    [self.manager reconnect];
}

-(void) dealloc{
    [self.manager removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    switch (self.manager.state) {
        case MQTTSessionManagerStateClosed:
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(managerClosed:)]) {
                    [self.delegate managerClosed:self];
                }
            }
            

            break;
        case MQTTSessionManagerStateClosing:
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(managerClosing:)]) {
                    [self.delegate managerClosing:self];
                }
            }

            break;
        case MQTTSessionManagerStateConnected:
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(managerConnected:)]) {
                    [self.delegate managerConnected:self];
                }
            }
            break;
        case MQTTSessionManagerStateConnecting:
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(managerConnecting:)]) {
                    [self.delegate managerConnecting:self];
                }
            }
            break;
        case MQTTSessionManagerStateError:
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(manager:error:)]) {
                    [self.delegate manager:self error:self.manager.lastErrorCode];
                }
            }
            break;
        case MQTTSessionManagerStateStarting:
        default:
//            self.status.text = @"not connected";
//            self.disconnect.enabled = false;
//            self.connect.enabled = true;
            break;
    }
}



/*
 * MQTTSessionManagerDelegate
 */
- (void)handleMessage:(NSData *)data
              onTopic:(NSString *)topic
             retained:(BOOL)retained {
    /*
     * MQTTClient: process received message
     */
    
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [self toArrayOrNSDictionary:jsonData];
    NSString *senderString = [topic substringFromIndex:self.base.length + 1];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(manager:receiveMessage:withTopic:withRetained:)]) {
            [self.delegate manager:self receiveMessage:obj withTopic:topic withRetained:retained];
        }
    }
    
//    [self.chat insertObject:[NSString stringWithFormat:@"%@:\n%@", senderString, dataString] atIndex:0];
//    [self.tableView reloadData];
}









// 将JSON串转化为字典或者数组

- (id)toArrayOrNSDictionary:(NSData *)jsonData{
    
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                     
                                                    options:NSJSONReadingAllowFragments
                     
                                                      error:&error];
    
    
    
    if (jsonObject != nil && error == nil){
        
        return jsonObject;
        
    }else{
        
        // 解析错误
        
        return nil;
        
    }
    
    
}

// 将字典或者数组转化为JSON串



- (NSData *)toJSONData:(id)theData{
    
    
    
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                        
                                                       options:NSJSONWritingPrettyPrinted
                        
                                                         error:&error];
    
    
    
    if ([jsonData length] > 0 && error == nil){
        
        return jsonData;
        
    }else{
        
        return nil;
        
    }
    
}
-(NSString*) makeTopic:(NSString*) channel{
    return [NSString stringWithFormat:@"%@:%@", self.base,channel];
}

- (NSInteger)send:(NSDictionary* ) obj withChannel:(NSString *) channel{
    /*
     * MQTTClient: send data to broker
     */
    NSData * jsonData = [self toJSONData:obj];
    
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                            
                                                 encoding:NSUTF8StringEncoding];
    

    NSInteger mID = [self.manager sendData:jsonData
                                     topic:[self makeTopic:channel]
                       qos:DEFAULT_QOS_LEVEL
                    retain:FALSE];
    return mID;
}

@end
