import SwiftUI

enum CodexFilter: String, CaseIterable {
    case all = "All"
    case common = "Common"
    case rare = "Rare"
    case ancient = "Ancient"
}

struct RuneCodexView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var selectedRune: RuneDefinition?
    @State private var filter: CodexFilter = .all

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var filteredRunes: [RuneDefinition] {
        switch filter {
        case .all: return RuneDefinition.catalog
        case .common: return RuneDefinition.catalog.filter { $0.rarity == .common }
        case .rare: return RuneDefinition.catalog.filter { $0.rarity == .rare }
        case .ancient: return RuneDefinition.catalog.filter { $0.rarity == .ancient }
        }
    }

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundPatternView()

        ScrollView {
          VStack(alignment: .leading, spacing: 18) {
            ScreenHeaderView(
              title: "Rune Codex",
              subtitle: "Discover runes by completing levels, daily trials, and path chapters.",
              badge: "\(storage.discoveredRuneCount)/\(RuneDefinition.catalog.count)"
            )

            HStack(spacing: 10) {
              ProgressRingView(
                progress: Double(storage.discoveredRuneCount) / Double(RuneDefinition.catalog.count),
                size: 60
              )
              VStack(alignment: .leading, spacing: 8) {
                Text("Collection")
                  .font(.caption.bold())
                  .foregroundStyle(Color("AppTextSecondary"))
                LinearProgressBar(
                  progress: Double(storage.discoveredRuneCount) / Double(RuneDefinition.catalog.count)
                )
                HStack(spacing: 12) {
                  StatPillCell(icon: "book.closed.fill", value: "\(storage.discoveredRuneCount)", label: "Found", accent: true)
                  StatPillCell(icon: "flame.fill", value: "\(storage.dailyChallengeStreak)", label: "Daily")
                }
              }
            }
            .padding(14)
            .depthCard(cornerRadius: 16, elevation: .raised)
            .depthTopSheen(cornerRadius: 16)

            filterPicker

            LazyVGrid(columns: columns, spacing: 12) {
              ForEach(filteredRunes) { rune in
                Button {
                  HapticManager.lightTap()
                  selectedRune = rune
                } label: {
                  CodexRuneCellView(rune: rune, isDiscovered: storage.isRuneDiscovered(rune.id))
                }
                .buttonStyle(ScaleButtonStyle())
              }
            }
          }
          .padding(16)
          .padding(.bottom, 100)
        }
      }
      .sheet(item: $selectedRune) { rune in
        RuneDetailSheet(rune: rune, isDiscovered: storage.isRuneDiscovered(rune.id))
      }
    }
  }

  private var filterPicker: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(CodexFilter.allCases, id: \.rawValue) { item in
          Button {
            HapticManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) { filter = item }
          } label: {
            Text(item.rawValue)
              .font(.caption.bold())
              .foregroundStyle(filter == item ? Color("AppBackground") : Color("AppTextSecondary"))
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background {
                if filter == item {
                  Capsule().fill(AppGradients.primaryVertical)
                } else {
                  Capsule().fill(AppGradients.surface)
                }
              }
              .compositingGroup()
              .shadow(color: filter == item ? Color("AppPrimary").opacity(0.3) : Color.clear, radius: 4, y: 2)
          }
          .buttonStyle(ScaleButtonStyle())
        }
      }
    }
  }
}

struct RuneDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let rune: RuneDefinition
    let isDiscovered: Bool

  var body: some View {
    NavigationStack {
      ZStack {
        Color("AppBackground").ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {
            CustomCard(glow: isDiscovered) {
              VStack(spacing: 20) {
                ZStack {
                  Circle()
                    .fill(Color("AppPrimary").opacity(0.12))
                    .frame(width: 120, height: 120)
                  if isDiscovered {
                    RuneSymbolView(symbol: rune.symbol, size: 72, color: Color("AppPrimary"))
                  } else {
                    Image(systemName: "lock.fill")
                      .font(.largeTitle)
                      .foregroundStyle(Color("AppTextSecondary"))
                  }
                }

                VStack(spacing: 8) {
                  Text(isDiscovered ? rune.name : "Undiscovered Rune")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))

                  Text(rune.rarity.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Color("AppPrimary").opacity(0.15))
                    .clipShape(Capsule())
                }

                Text(isDiscovered ? rune.lore : "Complete levels and trials to reveal this rune's story.")
                  .font(.body)
                  .foregroundStyle(Color("AppTextSecondary"))
                  .multilineTextAlignment(.center)
              }
              .padding(24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer(minLength: 40)
          }
        }
      }
      .navigationTitle("Rune Detail")
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
  }
}
