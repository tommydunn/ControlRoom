Control Room is a macOS app that lets you control the simulators for iOS, tvOS, and watchOS – their UI appearance, status bar configuration, and more. It wraps Apple’s own **simctl** command-line tool, so you’ll need Xcode installed.

Some features, such as sending example push notifications or move between light and dark mode, require Xcode 11.4 or later.


## Installation

To try Control Room yourself, download the code and build it through Xcode. It’s built using SwiftUI, so you’ll need macOS Catalina in order to run it. You will also need Xcode installed, because it relies on the **simctl** command being present – if you see an error that you’re missing the command line tools, go to Xcode's Preferences, choose the Locations tab, then make sure Xcode is selected for Command Line Tools.

**Warning:** SwiftUI on macOS is a little flaky at times, so I highly recommend you update to the very latest macOS version if you want to avoid any surprises.


## Credits

Control Room was originally designed and built by Paul Hudson, and is copyright © Paul Hudson 2020. Control Room is licensed under the MIT license; for the full license please see the LICENSE file. Many other folks have contributed features, fixes, and more to make Control Room what it is today.

Control Room is built on top of Apple’s **simctl** command – the team who built that deserve the real credit here.

Swift, the Swift logo, and Xcode are trademarks of Apple Inc., registered in the U.S. and other countries.
