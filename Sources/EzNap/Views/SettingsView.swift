import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultPaddingH")   private var paddingH: Double = 60
    @AppStorage("defaultPaddingV")   private var paddingV: Double = 60
    @AppStorage("defaultCornerRadius") private var cornerRadius: Double = 12
    @AppStorage("defaultShadowRadius") private var shadowRadius: Double = 20
    @AppStorage("defaultShadowOpacity") private var shadowOpacity: Double = 0.4

    var body: some View {
        Form {
            Section("Defaults") {
                LabeledContent("Horizontal padding") {
                    Slider(value: $paddingH, in: 0...120, step: 4)
                    Text("\(Int(paddingH))pt").monospacedDigit().frame(width: 40)
                }
                LabeledContent("Vertical padding") {
                    Slider(value: $paddingV, in: 0...120, step: 4)
                    Text("\(Int(paddingV))pt").monospacedDigit().frame(width: 40)
                }
                LabeledContent("Corner radius") {
                    Slider(value: $cornerRadius, in: 0...32, step: 1)
                    Text("\(Int(cornerRadius))pt").monospacedDigit().frame(width: 40)
                }
            }

            Section("Shadow") {
                LabeledContent("Blur radius") {
                    Slider(value: $shadowRadius, in: 0...60, step: 2)
                    Text("\(Int(shadowRadius))pt").monospacedDigit().frame(width: 40)
                }
                LabeledContent("Opacity") {
                    Slider(value: $shadowOpacity, in: 0...1, step: 0.05)
                    Text("\(Int(shadowOpacity * 100))%").monospacedDigit().frame(width: 40)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 400)
    }
}

#Preview {
    SettingsView()
}
