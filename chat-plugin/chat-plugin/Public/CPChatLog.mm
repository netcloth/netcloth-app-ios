







#import "CPChatLog.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <FCFileManager/FCFileManager.h>
#import "MessageObjects.h"
#import "CPInnerState.h"
#import "CPBridge.h"
#import <SSZipArchive/SSZipArchive.h>

static const DDLogLevel ddLogLevel =  DDLogLevelVerbose;

static NSInteger lastLoginUserId;

@implementation CPChatLog

+ (void)enableFileLog {
    
    if ([CPInnerState.shared loginUser] == nil) {
        return;
    }
    NSInteger uid = CPInnerState.shared.loginUser.userId;
    if (uid == lastLoginUserId) {
        return;
    }
    lastLoginUserId = uid;
    
    NSString *logDoc = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"%ld/logs",(long)uid]];
    DDLogFileManagerDefault* logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logDoc];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    
    fileLogger.rollingFrequency = 60 * 60 * 24; 
    fileLogger.maximumFileSize = 1 * 1024 * 1024; 
    fileLogger.logFileManager.maximumNumberOfLogFiles = 30;
    
    [DDLog.sharedInstance addLogger:fileLogger withLevel:DDLogLevelVerbose];
}

+ (NSData *)zipLogs {
    
    if ([CPInnerState.shared loginUser] == nil) {
        return nil;
    }
    NSInteger uid = CPInnerState.shared.loginUser.userId;
    NSString *logDoc = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"%ld/logs",(long)uid]];
    NSString *zippath = [FCFileManager pathForDocumentsDirectoryWithPath:[NSString stringWithFormat:@"%ld/logs.zip",(long)uid]];
    
    BOOL r =  [SSZipArchive createZipFileAtPath:zippath withContentsOfDirectory:logDoc];
    if (r) {
        return  [NSData dataWithContentsOfFile:zippath];
    }
    
    return nil;
}



void LogFormat(NSString *format, ...) {
    va_list arglist;
    if (format) {
        va_start(arglist,format);
        NSString *statement = [[NSString alloc]
                        initWithFormat:format arguments:arglist];
        va_end(arglist);
        
        DDLogInfo(statement);
    }
}

+ (void)recordSendMsg:(NCProtoNetMsg *)pack {
    LogFormat(@"Send: %@",pack.name);
}

+ (void)recordRecieveMsg:(NCProtoNetMsg *)pack {
    LogFormat(@"Rec: %@",pack.name);
}

@end
