# Archived

This repo will not be maintained going forward. Please use, create issues on, and make PRs to the fork of this repo located [here.](https://github.com/PMSwift/PMKVObserver)

# PMKVObserver

[![Version](https://img.shields.io/badge/version-v4.1.3-blue.svg)](https://github.com/postmates/PMKVObserver/releases/latest)
![Platforms](https://img.shields.io/badge/platforms-ios%20%7C%20osx%20%7C%20watchos%20%7C%20tvos-lightgrey.svg)
![Languages](https://img.shields.io/badge/languages-swift%20%7C%20objc-orange.svg)
![License](https://img.shields.io/badge/license-MIT%2FApache-blue.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)][Carthage]
[![CocoaPods](https://img.shields.io/cocoapods/v/PMKVObserver.svg)](http://cocoadocs.org/docsets/PMKVObserver)

[Carthage]: https://github.com/carthage/carthage

PMKVObserver provides a safe block-based wrapper around Key-Value Observing, with APIs for both Obj-C and Swift. Features include:

* Thread-safety. Observers can be registered on a different thread than KVO notifications are sent on, and can be cancelled on yet another thread. An observer can even be cancelled from two threads simultaneously.
* Automatic unregistering when the observed object deallocates.
  * Note: nested key paths are not supported at this time and manual cancellation should be used; [more info here](https://github.com/postmates/PMKVObserver/issues/20)
* Support for providing an observing object that is given to the block, and automatic unregistering when this observing object deallocates. This lets you call methods on `self` without retaining it or dealing with a weak reference.
* Thread-safety for the automatic deallocation. This protects against receiving messages on another thread while the object is deallocating.
* First-class support for both Obj-C and Swift, including strong typing in the Swift API.

## Examples

### Swift

```swift
// Observe an object for as long as the object is alive.
_ = KVObserver(object: user, keyPath: \User.fullName) { object, _, _ in
    // `object` has the same type as `user`
    print("User's full name changed to \(object.fullName)")
}

// Convenience methods for working with the change dictionary
_ = KVObserver(object: user, keyPath: \User.fullName, options: [.old, .new]) { _, change, _ in
    // unfortunately we don't know what the type of fullName is, so change uses Any
    let old = change.old as? String
    let new = change.new as? String
    if old != new {
        print("User's full name changed to \(new ?? "nil")")
    }
}

// Unregistering can be done from within the block, even in an .initial callback
_ = KVObserver(object: user, keyPath: \User.fullName, options: [.initial]) { object, _, kvo in
    guard !object.fullName.isEmpty else { return }
    print("User's full name is \(object.fullName)")
    kvo.cancel()
}

// Or you can unregister externally
let token = KVObserver(object: user, keyPath: \User.fullName) { object, _, _ in
    print("User's full name changed to \(object.fullName)")
}
// ... sometime later ...
token.cancel()

// You can also pass an observing object and KVO will be unregistered when that object deallocates
_ = KVObserver(observer: self, object: user, keyPath: \User.fullName) { observer, object, _, _ in
    // `observer` has the same type as `self`
    observer.nameLabel.text = object.fullName
}
```

### Objective-C

Objective-C provides all the same functionality as Swift, albeit without the strong-typing of the observer/object.

```objc
// Observe an object for as long as the object is alive.
[PMKVObserver observeObject:self.user keyPath:@"fullName" options:0
                      block:^(id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, PMKVObserver * _Nonnull kvo) {
    NSLog(@"User's full name changed to %@", [object fullName]);
}];

// Change dictionary is provided, but without the convenience methods.
[PMKVObserver observeObject:self.user keyPath:@"fullName"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      block:^(id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, PMKVObserver * _Nonnull kvo) {
    NSString *old = change[NSKeyValueChangeOldKey];
    NSString *new = change[NSKeyValueChangeNewKey];
    if (old != new && (new == nil || ![old isEqualToString:new])) {
        NSLog(@"User's full name changed to %@", new);
    }
}];

// Unregistering and observing object support is also provided (see Swift examples).
```

## Requirements

Installing as a framework requires a minimum of iOS 8, OS X 10.9, watchOS 2.0, or tvOS 9.0.

If you install by copying the source into your project, it should work on iOS 7 or later (iOS 6 if you remove KVObserver.swift), and OS X 10.7 or later. Please note that it has not been tested on these versions.

PMKVObserver requires Xcode 9 or higher.

## Installation

After installing with any mechanism, you can use this by adding `import PMKVObserver` (Swift) or `@import PMKVObserver;` (Objective-C) to your code.

### Carthage

To install using [Carthage][], add the following to your Cartfile:

```
github "postmates/PMKVObserver" ~> 4.0
```

### CocoaPods

To install using [CocoaPods][], add the following to your Podfile:

```
pod 'PMKVObserver', '~> 4.0'
```

[CocoaPods]: https://cocoapods.org

### Manual Installation

You may also install manually by adding the framework to your workspace, or by adding the 3 files KVObserver.h, KVObserver.m, and (optionally) KVObserver.swift to your project.

## License

Licensed under either of
 * Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
   http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or
   http://opensource.org/licenses/MIT) at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you shall be dual licensed as above, without any additional terms or conditions.

## Version History

#### v4.1.3 (2020-04-01)

- Work around bug with Swift compiler 5.1.5 and above relating to properties of type `Any?` ([#25][], [SR-12486][]).

[#25]: https://github.com/postmates/PMKVObserver/issues/25 "Swift 5.1.5 and 5.2 break observation of properties of type Any?"
[SR-12486]: https://bugs.swift.org/browse/SR-12486 "`Value.self is Any.Protocol` broke in 5.1, got bad warning in 5.2"

#### v4.1.2 (2019-01-24)

- Fix compatibility with Swift compiler versions other than 4.2 when observing optional values and KVO delivers an `NSNull` value.

#### v4.1.1 (2018-11-28)

- Add `.object` and `.keyPath` properties to `PMKVObserver`. The `.keyPath` property is named `.objcKeyPath` in Swift.

#### v4.1.0 (2018-11-27)

- Handle observing optional values better. We now make stronger guarantees about when `.old` and `.new` are non-`nil`.

#### v4.0.0 (2018-09-05)

* Set Swift version to 4.
* Work around Xcode 10 issue with value conversions involving `Any` in the `KVObserver.Change` object ([SR-8704][]).
* Handle `RawRepresentable` types in `KVObserver.Change`'s `.old` and `.new` properties.

  **Note:** Optional `RawRepresentable` types (such as those produced by a path like `\.foo?.bar`) are only supported in Swift 4.1 and later.

[SR-8704]: https://bugs.swift.org/browse/SR-8704

#### v3.0.2 (2018-05-22)

* Squelch some warnings when building with CocoaPods.

#### v3.0.1 (2017-09-13)

* Set Swift version back to Swift 3.2. The new `KeyPath` stuff is usable from 3.2 so there's no reason to require 4. PMVKObserver will still compile with Swift 3.1, but the `KeyPath` APIs won't be available unless compiling with Swift 3.2.

#### v3.0.0 (2017-09-12)

* Convert to Swift 4.
* Add new initializers that use Swift 4 `KeyPath`s.
* Make `Change.rawDict` and `Change.kind` non-optional.

#### v2.0.2 (2017-07-25)

* Switch to an unfair lock in teardown. This uses `os_unfair_lock` on platforms that support it, otherwise it uses an unfair mutex.

#### v2.0.1 (2016-09-15)

* Fix CocoaPods.

#### v2.0.0 (2016-09-08)

* Update for Swift 3.0.

#### v1.0.5 (2016-09-08)

* Update for Swift 2.3.

#### v1.0.4 (2016-03-02)

* Update CocoaPods podspec to split Swift support into a subspec.

#### v1.0.3 (2015-01-28)

* Add property `cancelled` to `PMKVObserver`.

#### v1.0.2 (2016-01-26)

* Switch to dual-licensed as MIT or Apache 2.0.

#### v1.0.1 (2015-12-17)

* Stop leaking our `pthread_mutex_t`s.

#### v1.0 (2015-12-17)

Initial release.
