//
//  LogMacro.h
//
//  Created by Alic on 14-6-24.
//
//

typedef enum {
    
    LEVEL_ALL,
    LEVEL_1,
    LEVEL_2,
    LEVEL_3,
    LEVEL_4,
    LEVEL_5,
    
}LOG_LEVEL;

extern void myLevelLog(int line,char *functname,char *file,LOG_LEVEL level, id formatstring,...);


#define DLog(format,...) myLevelLog(__LINE__,(char *)__FUNCTION__,(char *)__FILE__,LEVEL_ALL,format, ##__VA_ARGS__)

#define DLV1Log(format,...) myLevelLog(__LINE__,(char *)__FUNCTION__,(char *)__FILE__,LEVEL_1,format, ##__VA_ARGS__)
#define DLV2Log(format,...) myLevelLog(__LINE__,(char *)__FUNCTION__,(char *)__FILE__,LEVEL_2,format, ##__VA_ARGS__)
#define DLV3Log(format,...) myLevelLog(__LINE__,(char *)__FUNCTION__,(char *)__FILE__,LEVEL_3,format, ##__VA_ARGS__)
#define DLV4Log(format,...) myLevelLog(__LINE__,(char *)__FUNCTION__,(char *)__FILE__,LEVEL_4,format, ##__VA_ARGS__)
#define DLV5Log(format,...) myLevelLog(__LINE__,(char *)__FUNCTION__,(char *)__FILE__,LEVEL_5,format, ##__VA_ARGS__)

#define DLLog(LEVEL_,format,...) myLevelLog(__LINE__,(char *)__FUNCTION__,(char *)__FILE__,LEVEL_,format, ##__VA_ARGS__)


