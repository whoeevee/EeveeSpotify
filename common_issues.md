# Common Issues

If you're facing an issue, read this document before opening it on GitHub.

**EeveeSpotify currently doesn't accept feature requests. Option to disable podcasts, themes like Spicetify, true shuffle and other similar features won't be implemented, so kindly refrain from opening issues about those. However, some features (particularly basic, highly requested ones related to EeveeSpotify, like Genius Fallback) could be implemented.**

Read the [Restrictions](https://github.com/whoeevee/EeveeSpotify?tab=readme-ov-file#restrictions) to learn about which Premium features are server-sided and cannot be implemented in the tweak.

EeveeSpotify only supports iOS and iPadOS and is not planned to be supported on other platforms. You can easily search for different projects with lots of features.

There might be an issue not caused by EeveeSpotify. For example, Smart Shuffle is not affected by the tweak at all. If you encounter an error, enable Smart Shuffle again and avoid scrolling through songs excessively. Also, always test and refrain from reporting original Spotify issues, such as being unable to share lyrics on Instagram/Facebook when colors are changed, songs count truncated in liked songs or horizontal rotation UI bugs.

There might be an issue with your sideloading method. Widgets work only with TrollStore, and CarPlay only with TrollStore or a certificate with CarPlay entitlements. To navigate to a song from the lock screen, control center, or Dynamic Island, and to use Spatial Audio or Siri, change the app and bundle identifiers to match your provisioning profile (https://github.com/whoeevee/EeveeSpotify/issues/32).

EeveeSpotify versions are often, but not always, released alongside Spotify versions on the App Store. You can get the latest IPAs on [Github Releases](https://github.com/whoeevee/EeveeSpotify/releases) or [EeveeSpotify IPAs](https://t.me/SpotilifeIPAs), and also add https://raw.githubusercontent.com/whoeevee/EeveeSpotify/swift/repo.json as a source to Scarlet, ESign, or other apps (excluding AltStore and probably SideStore). If you would like to make your own IPA, make sure you've injected SwiftProtobuf, Orion, and CydiaSubstrate frameworks.

If you're experiencing a crash, install the debug IPA from Github Releases and open an issue with the crash log and console messages with "EeveeSpotify". Consider using [Cr4shed Rootless](https://github.com/crazymind90/Cr4shed-Rootless) to provide more detailed logs. If you have jailbreak and installed EeveeSpotify with TrollStore, disable tweak injection with Choicy.

## Unable to Play Songs
_References: https://github.com/whoeevee/EeveeSpotify/issues/67, https://github.com/whoeevee/EeveeSpotify/issues/152_
#### If all tracks are skipped, a song stops as soon as you play it, or you see the "You discovered a Premium feature" popup when trying to play a song
Connect to a VPN server in any country, change your region at [accounts.spotify.com](https://accounts.spotify.com), then sign out and log back into Spotify with the VPN enabled.

## Unable to Sign In
_References: https://github.com/whoeevee/EeveeSpotify/issues/147, https://github.com/whoeevee/EeveeSpotify/issues/157_
#### If you see the "You're offline. Check your connection and try again." message when trying to log into your account with EeveeSpotify v4.0 or newer
That's likely due to an active VPN connection. Try using another one, or disable the VPN, after which you should be able to sign in.
