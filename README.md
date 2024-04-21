![Banner](Images/banner.png)

# EeveeSpotify

This branch contains the same tweak but rewritten in Objective-C by [asdfzxcvbn](https://github.com/asdfzxcvbn). Initially, there was an issue with the Swift (Orion) version: it caused IPA crashes, although the rootless tweak worked fine. Suspecting a bug in Orion, I attempted to resolve it by reinstalling Theos and rebuilding Orion, only to find that rewriting it in Objective-C was the solution.

After looking into it, I discovered that Orion is not the problem. Instead [pyzule](https://github.com/asdfzxcvbn/pyzule) wasn't injecting CydiaSubstrate for unknown reasons, resulting in ipa crashes.

However, the Objective-C version isn't stable. You might need to restart the app a lot to get Premium. Therefore, it's better to use the Swift version.
