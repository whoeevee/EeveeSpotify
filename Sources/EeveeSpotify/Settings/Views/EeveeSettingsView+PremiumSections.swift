import SwiftUI

extension EeveeSettingsView {
    
    @ViewBuilder func PremiumSections() -> some View {
        
        Section(footer: patchType == .disabled ? nil : Text("""
You can select the Premium patching method you prefer. App restart is required after changing.

Static: The original method. On app start, the tweak composes cache data by inserting your username into a blank file with preset Premium parameters. When Spotify reloads user data, you'll be switched to the Free plan and see a popup with quick restart app and reset data actions.

Dynamic: This method intercepts requests to load user data, deserializes it, and modifies the parameters in real-time. It's much more stable and is recommended.

If you have an active Premium subscription, you can turn on Do Not Patch Premium. The tweak won't patch the data or restrict the use of Premium server-sided features.
""")) {
            Toggle(
                "Do Not Patch Premium",
                isOn: Binding<Bool>(
                    get: { patchType == .disabled },
                    set: { patchType = $0 ? .disabled : .requests }
                )
            )
            
            if patchType != .disabled {
                Picker(
                    "Patching Method",
                    selection: $patchType
                ) {
                    Text("Static").tag(PatchType.offlineBnk)
                    Text("Dynamic").tag(PatchType.requests)
                }
            }
        }
        
        if patchType == .requests {
            Section(
                footer: Text("Replace remote configuration with the dumped Premium one. It might fix some issues, such as appearing ads, but it's not guaranteed.")
            ) {
                Toggle(
                    "Overwrite Configuration",
                    isOn: $overwriteConfiguration
                )
            }
        }
    }
}
