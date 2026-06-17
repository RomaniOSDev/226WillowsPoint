import SwiftUI

enum GameViewFactory {
    @ViewBuilder
    static func view(for route: LevelRoute) -> some View {
        switch route.activityId {
        case "rune_trail":
            RuneTrailView(
                activityId: route.activityId,
                difficulty: route.difficulty,
                level: route.level,
                isDailyChallenge: route.isDailyChallenge
            )
        case "rune_river_run":
            RuneRiverRunView(
                activityId: route.activityId,
                difficulty: route.difficulty,
                level: route.level,
                isDailyChallenge: route.isDailyChallenge
            )
        case "rune_rhythm_quest":
            RuneRhythmQuestView(
                activityId: route.activityId,
                difficulty: route.difficulty,
                level: route.level,
                isDailyChallenge: route.isDailyChallenge
            )
        default:
            Text("Unknown activity")
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }
}
