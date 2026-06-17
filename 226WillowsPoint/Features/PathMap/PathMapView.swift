import SwiftUI

struct PathMapView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var selectedChapter: PathChapter = .whisperingGrove

    private var chapterNodes: [PathMapNode] {
        PathMapNode.allNodes.filter { $0.chapter == selectedChapter }
    }

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundPatternView()

        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            ScreenHeaderView(
              title: "Path Weaver",
              subtitle: "Weave through three chapters of the enchanted forest.",
              badge: "\(storage.completedPathNodeCount)/\(PathMapNode.allNodes.count)"
            )

            HStack(spacing: 8) {
              StatPillCell(
                icon: "checkmark.circle.fill",
                value: "\(storage.completedPathNodeCount)",
                label: "Cleared",
                accent: true
              )
              StatPillCell(
                icon: "map.fill",
                value: "\(PathMapNode.allNodes.count)",
                label: "Total"
              )
              StatPillCell(
                icon: "percent",
                value: "\(Int(overallProgress * 100))",
                label: "Done"
              )
            }

            chapterPicker

            chapterIntroCard

            pathMapCanvas

            SectionHeaderView(title: "Chapter Nodes", trailing: chapterNodesLabel)

            ForEach(chapterNodes) { node in
              pathNodeRow(node)
            }
          }
          .padding(16)
          .padding(.bottom, 100)
        }
      }
      .navigationDestination(for: LevelRoute.self) { route in
        GameViewFactory.view(for: route)
      }
    }
  }

  private var overallProgress: Double {
    guard !PathMapNode.allNodes.isEmpty else { return 0 }
    return Double(storage.completedPathNodeCount) / Double(PathMapNode.allNodes.count)
  }

  private var chapterNodesLabel: String {
    let done = chapterNodes.filter { storage.isPathNodeCompleted($0.id) }.count
    return "\(done)/\(chapterNodes.count)"
  }

  private var chapterPicker: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        ForEach(PathChapter.allCases) { chapter in
          Button {
            HapticManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
              selectedChapter = chapter
            }
          } label: {
            ChapterTabCell(
              chapter: chapter,
              isSelected: selectedChapter == chapter,
              progress: storage.chapterProgress(chapter)
            )
          }
          .buttonStyle(ScaleButtonStyle())
        }
      }
    }
  }

  private var chapterIntroCard: some View {
    CustomCard {
      HStack(spacing: 12) {
        ProgressRingView(progress: storage.chapterProgress(selectedChapter), size: 44, showLabel: false)
        VStack(alignment: .leading, spacing: 4) {
          Text(selectedChapter.rawValue)
            .font(.subheadline.bold())
            .foregroundStyle(Color("AppTextPrimary"))
          Text(selectedChapter.intro)
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(14)
    }
  }

  private var pathMapCanvas: some View {
    GeometryReader { geo in
      ZStack {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .fill(AppGradients.surface)

        Canvas { context, size in
          for node in chapterNodes {
            if let prerequisite = node.prerequisiteId,
               let fromNode = PathMapNode.node(withId: prerequisite) {
              drawConnection(from: fromNode, to: node, in: size, context: &context)
            }
          }
        }

        ForEach(chapterNodes) { node in
          pathNodeOverlay(node, in: geo.size)
        }
      }
    }
    .frame(height: 400)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .strokeBorder(AppGradients.subtleBorder, lineWidth: 1)
    }
    .compositingGroup()
    .shadow(color: Color.black.opacity(0.35), radius: 10, y: 5)
  }

  @ViewBuilder
  private func pathNodeRow(_ node: PathMapNode) -> some View {
    let unlocked = storage.isPathNodeUnlocked(node.id)
    let completed = storage.isPathNodeCompleted(node.id)

    if unlocked {
      NavigationLink(value: node.route) {
        PathNodeListCell(node: node, isUnlocked: true, isCompleted: completed)
      }
      .buttonStyle(.plain)
      .simultaneousGesture(TapGesture().onEnded {
        HapticManager.mediumTap()
      })
    } else {
      PathNodeListCell(node: node, isUnlocked: false, isCompleted: false)
    }
  }

  @ViewBuilder
  private func pathNodeOverlay(_ node: PathMapNode, in size: CGSize) -> some View {
    let unlocked = storage.isPathNodeUnlocked(node.id)
    let completed = storage.isPathNodeCompleted(node.id)
    let point = mapPoint(for: node, in: size)

    if unlocked {
      NavigationLink(value: node.route) {
        ZStack {
          Circle()
            .fill(completed ? AppGradients.primaryVertical : AppGradients.surface)
            .frame(width: 40, height: 40)
            .overlay {
              Circle()
                .strokeBorder(
                  completed
                    ? AnyShapeStyle(Color("AppAccent").opacity(0.5))
                    : AnyShapeStyle(AppGradients.subtleBorder),
                  lineWidth: 1
                )
            }
          Image(systemName: completed ? "checkmark" : "play.fill")
            .font(.caption.bold())
            .foregroundStyle(completed ? Color("AppBackground") : Color("AppPrimary"))
        }
      }
      .buttonStyle(.plain)
      .simultaneousGesture(TapGesture().onEnded { HapticManager.mediumTap() })
      .position(point)
    } else {
      Circle()
        .fill(Color("AppTextSecondary").opacity(0.2))
        .frame(width: 32, height: 32)
        .overlay {
          Image(systemName: "lock.fill")
            .font(.system(size: 10))
            .foregroundStyle(Color("AppTextSecondary"))
        }
        .position(point)
    }
  }

  private func mapPoint(for node: PathMapNode, in size: CGSize) -> CGPoint {
    CGPoint(x: node.normalizedPosition.x * size.width, y: node.normalizedPosition.y * size.height)
  }

  private func drawConnection(from: PathMapNode, to: PathMapNode, in size: CGSize, context: inout GraphicsContext) {
    let start = mapPoint(for: from, in: size)
    let end = mapPoint(for: to, in: size)
    var path = Path()
    path.move(to: start)
    path.addLine(to: end)
    let active = storage.isPathNodeCompleted(from.id)
    context.stroke(
      path,
      with: .color(active ? Color("AppPrimary").opacity(0.55) : Color("AppTextSecondary").opacity(0.2)),
      style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: active ? [] : [5, 4])
    )
  }
}
