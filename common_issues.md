# Common Issues

If you're facing an issue, read this document before opening it on GitHub.

***

## Unable to Play Songs
_References: Too many_
### If all tracks are skipped, a song stops as soon as you play it, songs play in a random order, you see the "You discovered a Premium feature" popup when trying to play a song, or encounter other restrictions,
You can only use Spotify abroad for 14 days. Connect to a VPN server in any country, change your region at [accounts.spotify.com](https://accounts.spotify.com), then sign out and log back into Spotify with the VPN enabled.

***

There might be an issue not caused by EeveeSpotify. For example, Smart Shuffle is not affected by the tweak at all. If you encounter an error, enable Smart Shuffle again and avoid scrolling through songs excessively. Also, always test and refrain from reporting original Spotify issues, such as being unable to share lyrics on Instagram/Facebook when colors are changed, songs count truncated in liked songs or horizontal rotation UI bugs.

If you're experiencing a crash, install the debug tweak from Github Actions and open an issue with the crash log and console messages with "EeveeSpotify". Consider using [Cr4shed Rootless](https://github.com/crazymind90/Cr4shed-Rootless) to provide more detailed logs. If you have jailbreak and installed EeveeSpotify with TrollStore, disable tweak injection with Choicy.

## Sideloading

There might be an issue with your sideloading method. Widgets work only with TrollStore, and CarPlay only with TrollStore or a certificate with CarPlay entitlements. To navigate to a song from the lock screen, control center, or Dynamic Island, and to use Spatial Audio or Siri, change the app and bundle identifiers to match your provisioning profile (https://github.com/whoeevee/EeveeSpotify/issues/32).

## Feature Requests

EeveeSpotify does not accept large feature requests. Options to disable podcasts, add themes like Spicetify, enable true shuffle, and similar features also will not be implemented, so please refrain from opening issues about them. However, pull requests are always appreciated. If you can implement something useful, feel free to submit a PR; it will likely be merged.

Read the [Restrictions](https://github.com/whoeevee/EeveeSpotify?tab=readme-ov-file#restrictions) to learn about which Premium features are server-sided.

## Releases

EeveeSpotify versions are typically released alongside Spotify versions on the App Store. You can get the latest IPAs on [Github Releases](https://github.com/whoeevee/EeveeSpotify/releases) or [EeveeSpotify IPAs](https://t.me/SpotilifeIPAs). You can also add https://raw.githubusercontent.com/whoeevee/EeveeSpotify/swift/repo.json as a source to Scarlet, ESign, or other apps, and https://raw.githubusercontent.com/whoeevee/EeveeSpotify/swift/repo.altsource.json for TrollApps, AltStore, SideStore, and derivatives. If you would like to make your own IPA, make sure you've injected SwiftProtobuf, Orion, and CydiaSubstrate frameworks.

EeveeSpotify only supports iOS and iPadOS and is not planned to be supported on other platforms. You can easily search for different projects with lots of features.
