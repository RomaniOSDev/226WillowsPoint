import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var policyText = ""

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundPatternView()

        ScrollView {
          if policyText.isEmpty {
            ProgressView()
              .tint(Color("AppPrimary"))
              .padding(.top, 40)
          } else if let attributed = try? AttributedString(markdown: policyText) {
            CustomCard {
              Text(attributed)
                .foregroundStyle(Color("AppTextPrimary"))
                .tint(Color("AppPrimary"))
                .padding(16)
            }
            .padding(16)
          } else {
            CustomCard {
              Text(policyText)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(16)
            }
            .padding(16)
          }
        }
      }
      .navigationTitle("Privacy Policy")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            HapticManager.lightTap()
            dismiss()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(Color("AppTextSecondary"))
          }
        }
      }
      .toolbarBackground(Color("AppSurface"), for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
    .onAppear {
      loadPolicy()
    }
  }

  private func loadPolicy() {
    if let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
       let text = try? String(contentsOf: url, encoding: .utf8) {
      policyText = text
    } else {
      policyText = "# Privacy Policy\nThis app does NOT collect, store, or transmit any personal data."
    }
  }
}
