//
//  FXAnimaionEngineMacro.h
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/2/10.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#ifndef FXAnimaionEngineMacro_h
#define FXAnimaionEngineMacro_h

#ifdef __OBJC__

#ifdef DEBUG
#define FXLogD(format, ...) NSLog((@"\nFXAnimation: %s [Line %d]\n" format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define FXLogD(...) do {} while(0)
#endif

#ifdef DEBUG
#define FXExceptionName @"FXAnimationEngineException"
#define FXException(format, ...) @throw [NSException \
exceptionWithName:FXExceptionName \
reason:[NSString stringWithFormat:format, ##__VA_ARGS__]  \
userInfo:nil];
#else
#define FXException(...) do {} while(0)
#endif
#define FXSubclassNoImplementException FXException(@"Please override this method(%s [Line %d]) in subclass", __PRETTY_FUNCTION__, __LINE__);

#define FXRunBlockSafe(block, ...) {\
if (block) {\
block(__VA_ARGS__);\
}\
}

#endif /* __OBJC__ */

#endif /* FXAnimaionEngineMacro_h */
