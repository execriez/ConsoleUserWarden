//
//  main.m
//  ConsoleUserWarden
//  Version 1.0.2
//
//  Created on 29/04/2017 by Mark J Swift
//  Pu together by modifying some of my other projects; which in turn were created by googling example code.
//
//  Calls an external commands via bash when network state changes between up and down
//  External commands are ConsoleUserWarden-NetworkUp and ConsoleUserWarden-NetworkDown

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface GlobalVars : NSObject
{
    NSString *_activeConsoleUserName;
}

+ (GlobalVars *)sharedInstance;

@property(strong, nonatomic, readwrite) NSString *activeConsoleUserName;

@end

@implementation GlobalVars

@synthesize activeConsoleUserName = _activeConsoleUserName;

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
    
    NSString        * exepath = [[NSBundle mainBundle] executablePath];
    
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    // The key that we are interested in "State:/Network/Global/IPv4" "State:/Users/ConsoleUser"
    state_users_consoleuser_KeyName = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompUsers, kSCEntUsersConsoleUser);
    
    // Run through the list of changed keys (there should only be one - "State:/Users/ConsoleUser")
    changedKeyCount = CFArrayGetCount(changedKeys);
    for (i=0; i < changedKeyCount; i++) {
        CFStringRef changedKeyName = CFArrayGetValueAtIndex(changedKeys, i);
        
        // We are only interested in "State:/Users/ConsoleUser"
        if (CFStringCompare(changedKeyName, state_users_consoleuser_KeyName, 0) == kCFCompareEqualTo) {
            
            // Get the previous primary interface from our global vars
            previousConsoleUserName=globals.activeConsoleUserName;
            
            // Get the /Network/Global/IPv4 Key property
            CFPropertyListRef changedKeyProp = SCDynamicStoreCopyValue(store, (CFStringRef) changedKeyName);
            
            // Get the current primary interface from the Key property
            if (changedKeyProp) {
                currentConsoleUserName = [(__bridge NSDictionary *)changedKeyProp valueForKey:@"Name"];
            } else {
                currentConsoleUserName = @"none";
            }
            
            // Handle null value
            if (!currentConsoleUserName) {
                currentConsoleUserName = @"none";
            }
            
            // Set the current primary interface
            globals.activeConsoleUserName = currentConsoleUserName;
            
            // Only do something if the primary interface value has changed
            if ([previousConsoleUserName compare:currentConsoleUserName] != NSOrderedSame) {
                if ([currentConsoleUserName compare:@"none"] == NSOrderedSame) {
                    [[NSString stringWithFormat:@"%@-NoConsoleUser '%@' '%@'", exepath, currentConsoleUserName, previousConsoleUserName] runAsCommand];
                    NSLog(@"No Console User: new '%@', old '%@'", currentConsoleUserName, previousConsoleUserName);
                } else {
                    [[NSString stringWithFormat:@"%@-NewConsoleUser '%@' '%@'", exepath, currentConsoleUserName, previousConsoleUserName] runAsCommand];
                    NSLog(@"New Console User: new '%@', old '%@'", currentConsoleUserName, previousConsoleUserName);
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
        
        SCDynamicStoreContext context = {0, NULL, NULL, NULL, NULL};
        session = SCDynamicStoreCreate(NULL, CFSTR("ConsoleUserWarden"), ConsoleUserCallback, &context);
        
        keys = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        patterns = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        
        // Key to track changes to State:/Users/ConsoleUser
        key = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompUsers, kSCEntUsersConsoleUser);
        
        CFArrayAppendValue(keys, key);
        CFRelease(key);
        
        // If we were tracking changes via patterns, we would do something like this:
        //
        /* Pattern to track changes to State,/Network/Interface/[^/]+/Link */
        //key = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompInterface, kSCCompAnyRegex, kSCEntNetLink);
        //
        //CFArrayAppendValue(patterns, key);
        //CFRelease(key);
        
        SCDynamicStoreSetNotificationKeys(session, keys, patterns);
        CFRelease(keys);
        CFRelease(patterns);
        
        rls = SCDynamicStoreCreateRunLoopSource(NULL, session, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
        CFRelease(rls);
        
        // Run the RunLoop
        
        CFRunLoopRun();
        
    }
    return 0;
}
