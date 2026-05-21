#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.RomainPoyard.BuzzPlay";

/// The "blueGame" asset catalog color resource.
static NSString * const ACColorNameBlueGame AC_SWIFT_PRIVATE = @"blueGame";

/// The "greenGame" asset catalog color resource.
static NSString * const ACColorNameGreenGame AC_SWIFT_PRIVATE = @"greenGame";

/// The "purpleGame" asset catalog color resource.
static NSString * const ACColorNamePurpleGame AC_SWIFT_PRIVATE = @"purpleGame";

/// The "redGame" asset catalog color resource.
static NSString * const ACColorNameRedGame AC_SWIFT_PRIVATE = @"redGame";

/// The "yellowGame" asset catalog color resource.
static NSString * const ACColorNameYellowGame AC_SWIFT_PRIVATE = @"yellowGame";

/// The "ButtonTap" asset catalog image resource.
static NSString * const ACImageNameButtonTap AC_SWIFT_PRIVATE = @"ButtonTap";

/// The "buttonFloor" asset catalog image resource.
static NSString * const ACImageNameButtonFloor AC_SWIFT_PRIVATE = @"buttonFloor";

#undef AC_SWIFT_PRIVATE
