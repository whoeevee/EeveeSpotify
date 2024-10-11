import SwiftUI
import UIKit

struct EeveePatchingSettingsView: View {
    @State var patchType = UserDefaults.patchType
    @State var overwriteConfiguration = UserDefaults.overwriteConfiguration

    var body: some View {
        List {
            Section(
                footer: patchType == .disabled
                    ? nil
                    : Text(
                        "patching_description"
                            .localizeWithFormat("restart_is_required_description".localized)
                    )
            ) {
                Toggle(
                    "do_not_patch_premium".localized,
                    isOn: Binding<Bool>(
                        get: { patchType == .disabled },
                        set: { patchType = $0 ? .disabled : .requests }
                    )
                )
            }
            
            .onChange(of: patchType) { newPatchType in
                UserDefaults.patchType = newPatchType
                OfflineHelper.resetData()
            }
            
            .onChange(of: overwriteConfiguration) { overwriteConfiguration in
                UserDefaults.overwriteConfiguration = overwriteConfiguration
                OfflineHelper.resetData()
            }
            
            if patchType == .requests {
                Section(
                    footer: Text("overwrite_configuration_description".localized)
                ) {
                    Toggle(
                        "overwrite_configuration".localized,
                        isOn: $overwriteConfiguration
                    )
                }
            }
            
            if !UIDevice.current.isIpad {
                Spacer()
                    .frame(height: 40)
                    .listRowBackground(Color.clear)
                    .modifier(ListRowSeparatorHidden())
            }
        }
        .listStyle(GroupedListStyle())
        .animation(.default, value: patchType)
    }
}
