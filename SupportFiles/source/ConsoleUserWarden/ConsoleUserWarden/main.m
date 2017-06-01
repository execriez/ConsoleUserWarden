//
//  main.m
//  ConsoleUserWarden
//  Version 1.0.5
//
//  By Mark J Swift
//
//  Calls a external commands via bash when the console user changes
//  External commands are ConsoleUserWarden-UserLoggedIn, ConsoleUserWarden-UserLoggedOut and ConsoleUserWarden-UserSwitch

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#undef	kSCPropUsersConsoleUserName
#define	kSCPropUsersConsoleUserName	CFSTR("Name")

#undef	kSCPropUsersConsoleSessionInfo
#define	kSCPropUsersConsoleSessionInfo	CFSTR("SessionInfo")

@interface GlobalVars : NSObject
{
    NSString *_activeConsoleUserName;
    NSString *_activeConsoleUsersString;
}

+ (GlobalVars *)sharedInstance;

@property(strong, nonatomic, readwrite) NSString *activeConsoleUserName;
@property(strong, nonatomic, readwrite) NSString *activeConsoleUsersString;

@end

@implementation GlobalVars

@synthesize activeConsoleUserName = _activeConsoleUserName;
@synthesize activeConsoleUsersString = _activeConsoleUsersString;

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
        // Note not using _activeConsoleUserName = [[NSString alloc] init] as it doesnt return a useful object
        _activeConsoleUserName = nil;
        _activeConsoleUsersString = nil;
    }
    return self;
}

@end


@interface NSString (ShellExecution)
- (NSString*)runAsCommand;
@end

@implementation NSString (ShellExecution)

- (NSString*)runAsCommand {
    NSPipe* pipe = [NSPipe pipe];
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"%@", self]]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}

@end

SCDynamicStoreRef session;

void ConsoleUserCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info)
{
    CFIndex         i;
    CFIndex         changedKeyCount;
    CFStringRef		state_users_consoleuser_KeyName = NULL;
    NSString        *currentConsoleUserName = @"none";
    NSString        *previousConsoleUserName = @"none";
    CFArrayRef		sessioninfo		= NULL;
    CFIndex         c;
    CFIndex         j;
    CFDictionaryRef sessionvalue;
    NSString        *SessionUserName = NULL;
    NSString        *currentConsoleUsersString = @"/";
    NSString        *previousConsoleUsersString = @"/";
    
    NSString        * exepath = [[NSBundle mainBundle] executablePath];
    
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    // The key that we are interested in "State:/Users/ConsoleUser"
    state_users_consoleuser_KeyName = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompUsers, kSCEntUsersConsoleUser);
    
    // Run through the list of changed keys (there should only be one - "State:/Users/ConsoleUser")
    changedKeyCount = CFArrayGetCount(changedKeys);
    for (i=0; i < changedKeyCount; i++) {
        CFStringRef changedKeyName = CFArrayGetValueAtIndex(changedKeys, i);
        
        // We are only interested in "State:/Users/ConsoleUser"
        if (CFStringCompare(changedKeyName, state_users_consoleuser_KeyName, 0) == kCFCompareEqualTo) {
            
            // Get the previous console user from our global vars
            previousConsoleUserName=globals.activeConsoleUserName;
            
            // Get the previous console users string from our global vars
            previousConsoleUsersString=globals.activeConsoleUsersString;
            
            // Get the /Users/ConsoleUser Key property
            CFPropertyListRef changedKeyProp = SCDynamicStoreCopyValue(store, (CFStringRef) changedKeyName);
            
            currentConsoleUsersString = @"/";
            
            if (changedKeyProp != NULL) {
                // Get the current console user from the Key property
                currentConsoleUserName = [(__bridge NSDictionary *)changedKeyProp valueForKey:@"Name"];
                
                // Build a string containing all the current console users separated by '/' characters
                sessioninfo = CFDictionaryGetValue(changedKeyProp, kSCPropUsersConsoleSessionInfo);
                if (sessioninfo != NULL) {
                    c = CFArrayGetCount(sessioninfo);
                    for (j=0; j<c; j++) {
                        sessionvalue = CFArrayGetValueAtIndex(sessioninfo, j);
                        if (sessionvalue != NULL) {
                            SessionUserName = (NSString *)CFDictionaryGetValue(sessionvalue, CFSTR("kCGSSessionUserNameKey"));
                            if(SessionUserName)
                            {
                                currentConsoleUsersString = [NSString stringWithFormat:@"%@%@/", currentConsoleUsersString, SessionUserName];
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

            // Set the current console user
            globals.activeConsoleUserName = currentConsoleUserName;
            globals.activeConsoleUsersString = currentConsoleUsersString;
            
            // Only do something if the console user value has changed
            if ([currentConsoleUserName compare:previousConsoleUserName] != NSOrderedSame) {
                // current console user is not the same as the previous console user
 
                
                NSLog(@"New Console User: new user '%@', old user '%@' new list '%@', old list '%@'", currentConsoleUserName, previousConsoleUserName, currentConsoleUsersString, previousConsoleUsersString);

                
                if ([currentConsoleUserName compare:@"none"] == NSOrderedSame) {
                    // current console user is 'none'
                    
                    if ([@"/init/none/loginwindow/" rangeOfString:previousConsoleUserName].location == NSNotFound) {
                        // current console user is 'none', previous console user not 'none' (or none equivalents)
                        [[NSString stringWithFormat:@"%@-UserLoggedOut '%@'", exepath, previousConsoleUserName] runAsCommand];
                        NSLog(@"User logged out: '%@'", previousConsoleUserName);
                    }
                    
                } else {
                    // current console user is not 'none'
                    
                    if ([@"/init/" rangeOfString:currentConsoleUserName].location == NSNotFound) {
                        // current console user is not 'none' or 'init'
                        
                        if ([@"/loginwindow/" rangeOfString:currentConsoleUserName].location != NSNotFound) {
                            // current console user is 'loginwindow'
                            
                            if ([@"/init/none/loginwindow/" rangeOfString:previousConsoleUserName].location == NSNotFound) {
                                // current console user is 'loginwindow', previous console user not 'none' (or none equivalents)
                                
                                if ([currentConsoleUsersString rangeOfString:previousConsoleUserName].location == NSNotFound) {
                                    // previous console user is no longer logged in
                                    
                                    [[NSString stringWithFormat:@"%@-UserLoggedOut '%@'", exepath, previousConsoleUserName] runAsCommand];
                                    NSLog(@"User logged out: '%@'", previousConsoleUserName);
                                }
                           }
                           
                        } else {
                            // current console user is not 'none', 'init' or 'loginwindow' (i.e an actual user)
                           
                            if ([@"/init/none/loginwindow/" rangeOfString:previousConsoleUserName].location != NSNotFound) {
                                    // previous console user was 'init', 'none' or 'loginwindow'
                                    
                                if ([previousConsoleUsersString rangeOfString:currentConsoleUserName].location == NSNotFound) {
                                    // current console user has just logged in
                                        
                                    [[NSString stringWithFormat:@"%@-UserLoggedIn '%@'", exepath, currentConsoleUserName] runAsCommand];
                                    NSLog(@"User logged in: '%@'", currentConsoleUserName);

                                } else {
                                    // current console user was already logged in
                                        
                                    [[NSString stringWithFormat:@"%@-UserSwitch '%@' '%@'", exepath, currentConsoleUserName, previousConsoleUserName] runAsCommand];
                                    NSLog(@"User switch: to '%@' from '%@'", currentConsoleUserName, previousConsoleUserName);
                                }

                                    
                            } else {
                                // previous console user was not 'init', 'none' or 'loginwindow' (i.e an actual user)
                                    
                                [[NSString stringWithFormat:@"%@-UserSwitch '%@' '%@'", exepath, currentConsoleUserName, previousConsoleUserName] runAsCommand];
                                NSLog(@"User switch: to '%@' from '%@'", currentConsoleUserName, previousConsoleUserName);
                            
                            }
                            
                        }
                    }
                   
                }
            }
            
            continue;
        }
        
    }
    CFRelease(state_users_consoleuser_KeyName);
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        CFStringRef         key;
        CFMutableArrayRef	keys = NULL;
        CFMutableArrayRef	patterns = NULL;
        CFRunLoopSourceRef	rls;
        
        GlobalVars *globals = [GlobalVars sharedInstance];
        globals.activeConsoleUserName = @"init";
        globals.activeConsoleUsersString = @"/";
        
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
