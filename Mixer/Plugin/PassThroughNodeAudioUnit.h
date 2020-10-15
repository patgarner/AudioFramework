//
//  PassThroughNodeAudioUnit.h
//  PassThroughNode
//
//  Created by Admin on 10/14/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface PassThroughNodeAudioUnit : AUAudioUnit
- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError;
@end
