//
//  main.m
//  ConsoleUserWarden
//  Version 1.0.7
//
//  By Mark J Swift
//
//  Calls external commands when the console user changes
//
//  External commands are
//    ConsoleUserWarden-UserLoggedIn
//    ConsoleUserWarden-UserLoggedOut
//    ConsoleUserWarden-UserSwitch

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#undef    kSCPropUsersConsoleUserName
#define    kSCPropUsersConsoleUserName    CFSTR("Name")

#undef    kSCPropUsersConsoleSessionInfo
#define    kSCPropUsersConsoleSessionInfo    CFSTR("SessionInfo")

@interface GlobalVars : NSObject
{
    NSString *_activeConsoleUserName;
    NSMutableArray *_activeConsoleUsersArray;
}

+ (GlobalVars *)sharedInstance;

@property(strong, nonatomic, readwrite) NSString *activeConsoleUserName;
@property(strong, nonatomic, readwrite) NSMutableArray *activeConsoleUsersArray;

@end

@implementation GlobalVars

@synthesize activeConsoleUserName = _activeConsoleUserName;
@synthesize activeConsoleUsersArray = _activeConsoleUsersArray;

+ (GlobalVars *)sharedInstance {
    static GlobalVars *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // Note [[NSString alloc] init] doesn't return a useful object
        _activeConsoleUserName = nil;
        _activeConsoleUsersArray = [[NSMutableArray alloc] init];
   }
    return self;
}

@end


@interface NSString (ShellExecution)
- (NSString*)runAsCommand;
@end

@implementation NSString (ShellExecution)

- (NSString*)runAsCommand {
    //  NSPipe* pipe = [NSPipe pipe];
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"%@", self]]];
    //  [task setStandardOutput:pipe];
    
    //  NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    //  return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    return NULL;
}

@end

SCDynamicStoreRef session;

void myLog(NSString* logString)
{
    NSLog(@"%@", logString);

    // Setup date stuff
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss z"];

    logString = [NSString stringWithFormat:@"%@ - %@\n", [dateFormatter stringFromDate:[NSDate date]], logString];

    NSString * logFilePath = @"/private/tmp/ConsoleUserWarden.log";
    logFilePath = [logFilePath stringByStandardizingPath];
        
    NSFileHandle* logFileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    if ( !logFileHandle ) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
        logFileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    }
    if ( logFileHandle ) {
        [logFileHandle seekToEndOfFile];
        [logFileHandle writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
        [logFileHandle closeFile];
    }

}

void ConsoleUserCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info)
{
    CFIndex         i;
    CFIndex         changedKeyCount;
    CFStringRef     state_users_consoleuser_KeyName = NULL;
    NSString        *currentConsoleUserName = @"none";
    NSString        *previousConsoleUserName = @"none";
    CFArrayRef      sessioninfo        = NULL;
    CFIndex         c;
    CFIndex         j;
    CFDictionaryRef sessionvalue;
    NSString        *SessionUserName = NULL;
    NSMutableArray  *currentConsoleUsersArray = [[NSMutableArray alloc]init];
    NSMutableArray  *previousConsoleUsersArray = [[NSMutableArray alloc]init];
    NSUInteger      arrayLength;

    NSString        * exepath = [[NSBundle mainBundle] executablePath];
    CFBooleanRef    loginCompleted;

    GlobalVars *globals = [GlobalVars sharedInstance];
    
//    myLog([NSString stringWithFormat:@"---"]);

    // The key that we are interested in "State:/Uers/ConsoleUser"
    state_users_consoleuser_KeyName = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompUsers, kSCEntUsersConsoleUser);
    
    // Run through the list of changed keys (there should only be one - "State:/Users/ConsoleUser")
    changedKeyCount = CFArrayGetCount(changedKeys);
    
//    myLog([NSString stringWithFormat:@"changedKeyCount: '%ld'", changedKeyCount]);

    for (i=0; i < changedKeyCount; i++) {
        CFStringRef changedKeyName = CFArrayGetValueAtIndex(changedKeys, i);
        
//        myLog([NSString stringWithFormat:@"changedKeyName: '%@'", changedKeyName]);

        // We are only interested in "State:/Users/ConsoleUser"
        if (CFStringCompare(changedKeyName, state_users_consoleuser_KeyName, 0) == kCFCompareEqualTo) {
            
            // Get the previous console user from our global vars
            previousConsoleUserName=globals.activeConsoleUserName;
 //           myLog([NSString stringWithFormat:@"previousConsoleUserName: '%@'", previousConsoleUserName]);

            // Get the previous console users string from our global vars
            [previousConsoleUsersArray setArray:globals.activeConsoleUsersArray];
            
 //           arrayLength = [previousConsoleUsersArray count];
 //           for (j=0; j<arrayLength; j++) {
 //               myLog([NSString stringWithFormat:@"previousConsoleUsersArray[%ld]: '%@'", j, [previousConsoleUsersArray objectAtIndex:j]]);

 //           }

 //           myLog([NSString stringWithFormat:@"debug1"]);

            // Get the /Users/ConsoleUser Key property
            CFPropertyListRef changedKeyProp = SCDynamicStoreCopyValue(store, (CFStringRef) changedKeyName);
            
            if (changedKeyProp != NULL) {
                // Get the current console user from the Key property
                currentConsoleUserName = [(__bridge NSDictionary *)changedKeyProp valueForKey:@"Name"];
                
                // Build a string containing all the current console users separated by '/' characters
                sessioninfo = CFDictionaryGetValue(changedKeyProp, kSCPropUsersConsoleSessionInfo);
                if (sessioninfo != NULL) {
                    c = CFArrayGetCount(sessioninfo);
//                    myLog([NSString stringWithFormat:@"session count: '%ld'", c]);

                    for (j=0; j<c; j++) {
//                       myLog([NSString stringWithFormat:@"session index: '%ld'", j]);
                       sessionvalue = CFArrayGetValueAtIndex(sessioninfo, j);
                        if (sessionvalue != NULL) {
                            SessionUserName = (NSString *)CFDictionaryGetValue(sessionvalue, CFSTR("kCGSSessionUserNameKey"));
                            if(SessionUserName)
                            {
//                                myLog([NSString stringWithFormat:@"SessionUserName: '%@'", SessionUserName]);
                                loginCompleted = CFDictionaryGetValue(sessionvalue,CFSTR("kCGSessionLoginDoneKey"));

                                    if (loginCompleted == kCFBooleanTrue) {
                                        [currentConsoleUsersArray addObject:SessionUserName];
 //                                       myLog([NSString stringWithFormat:@"session index: %ld, loginCompleted", j]);
                                   }

                            }
                            //CFRelease(sessionvalue); // not sure why I don't need to do this
                        }
                        
                    }
                    //CFRelease(sessioninfo); // not sure why I don't need to do this
                    
                }
                CFRelease(changedKeyProp);
                
            } else {
                currentConsoleUserName = @"none";
            }
            
            // Handle null value
            if (!currentConsoleUserName) {
                currentConsoleUserName = @"none";
            }
            
            // Set the current console user from our global vars
            globals.activeConsoleUserName = currentConsoleUserName;
//            myLog([NSString stringWithFormat:@"currentConsoleUserName: '%@'", currentConsoleUserName]);

            // Set the current console users string from our global vars
            [globals.activeConsoleUsersArray setArray:currentConsoleUsersArray];

//            arrayLength = [currentConsoleUsersArray count];
//            for (j=0; j<arrayLength; j++) {
//                myLog([NSString stringWithFormat:@"currentConsoleUsersArray[%ld]: '%@'", j, [currentConsoleUsersArray objectAtIndex:j]]);
//            }

//            myLog([NSString stringWithFormat:@"-debug2"]);

            // Check for user switch
            if ([currentConsoleUserName compare:previousConsoleUserName] != NSOrderedSame) {
                // current console user is not the same as the previous console user
                
                if ([currentConsoleUserName compare:@"none"] != NSOrderedSame) {
                // current console user is not 'none'
          
                    if ([currentConsoleUserName compare:@"loginwindow"] != NSOrderedSame) {
                    // current console user is not 'loginwindow'
              
                        if ([previousConsoleUserName compare:@"none"] != NSOrderedSame) {
                        // previous console user is not 'none'
                  
                            if ([previousConsoleUserName compare:@"loginwindow"] != NSOrderedSame) {
                            // previous console user is not 'loginwindow'
                      
                                [[NSString stringWithFormat:@"%@-UserSwitch '%@' '%@'", exepath, currentConsoleUserName, previousConsoleUserName] runAsCommand];
//                                myLog([NSString stringWithFormat:@"User switch: to '%@' from '%@'", currentConsoleUserName, previousConsoleUserName]);
                        
                            }
                        }
                    }
                }
            }
            
            // Check for log out
            arrayLength = [previousConsoleUsersArray count];
            for (j=0; j<arrayLength; j++) {
                if (![currentConsoleUsersArray containsObject:[previousConsoleUsersArray objectAtIndex:j]]) {
                    // previous entry is not in current list of users
                    [[NSString stringWithFormat:@"%@-UserLoggedOut '%@'", exepath, [previousConsoleUsersArray objectAtIndex:j]] runAsCommand];
 //                   myLog([NSString stringWithFormat:@"User logged out: '%@'", [previousConsoleUsersArray objectAtIndex:j]]);
                }
            }

            // Check for log in
            arrayLength = [currentConsoleUsersArray count];
            for (j=0; j<arrayLength; j++) {
                if (![previousConsoleUsersArray containsObject:[currentConsoleUsersArray objectAtIndex:j]]) {
                    // current entry is not in previous list of users
                    [[NSString stringWithFormat:@"%@-UserLoggedIn '%@'", exepath, [currentConsoleUsersArray objectAtIndex:j]] runAsCommand];
//                    myLog([NSString stringWithFormat:@"User logged in: '%@'", [currentConsoleUsersArray objectAtIndex:j]]);
                }
            }

//            myLog([NSString stringWithFormat:@"-debug3"]);

            continue;
        }
        
    }
    CFRelease(state_users_consoleuser_KeyName);
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        CFStringRef         key;
        CFMutableArrayRef    keys = NULL;
        CFMutableArrayRef    patterns = NULL;
        CFRunLoopSourceRef    rls;
        
        GlobalVars *globals = [GlobalVars sharedInstance];
        globals.activeConsoleUserName = @"none";
        
        SCDynamicStoreContext context = {0, NULL, NULL, NULL, NULL};
        session = SCDynamicStoreCreate(NULL, CFSTR("ConsoleUserWarden"), ConsoleUserCallback, &context);
        
        keys = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        patterns = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        
        // Key to track changes to State:/Users/ConsoleUser
        key = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompUsers, kSCEntUsersConsoleUser);
        
        CFArrayAppendValue(keys, key);
        
        // If we were tracking changes via patterns, we would do something like this:
        //
        /* Pattern to track changes to State,/Network/Interface/[^/]+/Link */
        //key = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompInterface, kSCCompAnyRegex, kSCEntNetLink);
        //
        //CFArrayAppendValue(patterns, key);
        
        SCDynamicStoreSetNotificationKeys(session, keys, patterns);
        
        rls = SCDynamicStoreCreateRunLoopSource(NULL, session, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
        
        // Run the RunLoop
        
        CFRunLoopRun();
        
        // release the objects (never gets called)
        CFRelease(key);
        CFRelease(keys);
        CFRelease(patterns);
        CFRelease(rls);
        
    }
    return 0;
}
