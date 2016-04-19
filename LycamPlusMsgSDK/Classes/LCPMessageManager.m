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

@interface LCPMessageManager() <MQTTSessionManagerDelegate>
@property (strong, nonatomic) MQTTSessionManager *manager;
@property (strong, nonatomic) NSString *base;
@property (strong, nonatomic) NSString *topic;
@property (strong, nonatomic) NSDictionary *mqttSettings;
@end
#define DEFAULT_QOS_LEVEL MQTTQosLevelAtLeastOnce
@implementation LCPMessageManager

-(id) initWithToken:(NSString *) token withTopic:(NSString*)topic withConfig:(NSDictionary*) config{
    if(self = [super init]){
        self.token = token;
        self.base = @"LCP";
        self.topic = topic;
       
        self.mqttSettings = @{@"appname":@"LCP",
                              @"host":@"mqtt.lycam.tv",
                              @"port":@(1883),
                              @"tls":@(NO)
                              };
        if(config){
            self.mqttSettings = config;
        }
        NSString * base = [self.mqttSettings objectForKey:@"appname"];
        if(base){
            self.base = base;
        }
        
    }
    return self;
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
        
        self.manager.subscriptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEFAULT_QOS_LEVEL]
                                                                 forKey:[NSString stringWithFormat:@"%@/%@", self.base,self.topic]];
        [self.manager connectTo:self.mqttSettings[@"host"]
                           port:[self.mqttSettings[@"port"] intValue]
                            tls:[self.mqttSettings[@"tls"] boolValue]
                      keepalive:60
                          clean:true
                           auth:false
                           user:[UIDevice currentDevice].name
                           pass:self.token
                      willTopic:[NSString stringWithFormat:@"%@/%@", self.base,self.topic]
                           will:[@"offline" dataUsingEncoding:NSUTF8StringEncoding]
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:FALSE
                   withClientId:nil];
    } else {
        [self.manager connectToLast];
    }
    [self.manager addObserver:self
                   forKeyPath:@"state"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
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
                if ([self.delegate respondsToSelector:@selector(managerError:)]) {
                    [self.delegate managerError:self];
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
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    /*
     * MQTTClient: process received message
     */
    
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [self toArrayOrNSDictionary:jsonData];
    NSString *senderString = [topic substringFromIndex:self.base.length + 1];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(manager:receiveMessage:withTopic:)]) {
            [self.delegate manager:self receiveMessage:obj withTopic:topic];
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

- (NSInteger)send:(NSDictionary* ) obj {
    /*
     * MQTTClient: send data to broker
     */
    NSData * jsonData = [self toJSONData:obj];
    
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                            
                                                 encoding:NSUTF8StringEncoding];
    

   NSInteger mID = [self.manager sendData:jsonData
                     topic:[NSString stringWithFormat:@"%@/%@", self.base,self.topic]
                       qos:DEFAULT_QOS_LEVEL
                    retain:FALSE];
    return mID;
}

@end
