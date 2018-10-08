# FXAnimationEngine

[![中文](https://img.shields.io/badge/%E4%B8%AD%E6%96%87-Readme-lightgrey.svg)](https://shawnfoo.github.io/2017/07/20/%E7%9B%B4%E6%92%AD%E5%BA%94%E7%94%A8%E9%80%81%E7%A4%BC%E5%8A%A8%E7%94%BB%E7%89%B9%E6%95%88%E5%AE%9E%E7%8E%B0/)
![iOS 7.0+](https://img.shields.io/badge/iOS-7.0%2B-orange.svg)
![pod](https://img.shields.io/badge/Cocoapods-v1.0.1-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

An engine to display image frames in animation without causing high-memory usage. 


## Features

* Only the displaying image, rather than all of image frames, would occupy the memory.
* Supports image decode in background thread.
* Implemented by CADisplayLink.

## Previews

![](https://github.com/ShawnFoo/FXAnimationEngine/blob/develop/img/mhcb.gif?raw=true)

![](https://github.com/ShawnFoo/FXAnimationEngine/blob/develop/img/tianshi.gif?raw=true)

## Using Engine

import "CALayer+FXAnimationEngine.h" in your file first.

```
// load all image frames 
NSArray<UIImage *> *frames = ...;
```

#### FXKeyframeAnimation
```
FXKeyframeAnimation *animation = [FXKeyframeAnimation animationWithIdentifier:@"xxx"];
animation.delegate = self;
animation.frameImages = frames;
animation.duration = 5.5;
animation.repeats = 3;

// decode image asynchronously
[xxxView.layer fx_playAnimationAsyncDecodeImage:animation];
```

#### FXAnimationGroup
```
FXKeyframeAnimation *animation = [FXKeyframeAnimation animation];
animation.count = 50;  // [0, 49]
animation.duration = 4.2;

FXKeyframeAnimation *animation2 = [FXKeyframeAnimation animation];
animation2.count = 30; // [50, 79]
animation2.duration = 1.5;
animation2.repeats = 6; // repeat image between index 50 to index 79 six times

FXKeyframeAnimation *animation3 = [FXKeyframeAnimation animation];
animation.count = 20; // [80, 99]
animation.duration = 2;

FXAnimationGroup *animationGroup = [FXAnimationGroup animationWithIdentifier:@"xxxAnimation"];
animationGroup.animations = @[animation, animation2, animation3];
animationGroup.frames = frames;
animationGroup.delegate = self;

[xxxView.layer fx_playAnimation:animation];
```

#### FXAnimationDelegate

```
- (void)fxAnimationDidStart:(FXAnimation *)anim {
    // identify your animation by its "identifier" property
}

- (void)fxAnimationDidStop:(FXAnimation *)anim finished:(BOOL)finished {
    // ...
}
```

## Memory Usage Profile

#### Do The Math

For example, now you have 100 keyframe images and each one image is 160px * 320px. If every frame is 32-bit PNG, then one pixel will occupy 32 / (8 * 1024) KB. So one image will use 160 * 320 * 32 / (8 * 1024) KB memory, that is 200KB.
	
If you create your keyframe animation by Core Animation, all images will be loaded into memory(200KB * 100 / 1024 MB).
	
With FXAnimationEngine, creating a keyframe animation won't cause high-memory waterline, since only one image(200KB) occupies memory during animation.

#### Demo Allocation Test

FXKeyframeAnimation
![](http://wx4.sinaimg.cn/large/9161297cgy1fdzh58acisj20m2084mz0.jpg)

CAKeyframeAnimation
![](http://wx2.sinaimg.cn/large/9161297cgy1fdzh53wwd9j20vi0aktbz.jpg)

## How To Use Demo
This demo implements a living room using custom animation configuration to create FXKeyframeAnimation or CAKeyframeAnimation. 

## Installation
#### Cocoapods(iOS7+)

1. Add these lines below to your Podfile 
	
	```
	platform :ios, 'xxx'
	target 'xxx' do
	  pod 'FXAnimationEngine', '~> 1.0.0'
	end
	```
2. Install the pod by running `pod install`

#### Manually(iOS7+)
Drag `FXAnimationEngine` document with all files in it to your project

## License
FXAnimationEngine is provided under the MIT license. See LICENSE file for details.
