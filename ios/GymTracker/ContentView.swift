import SwiftUI

struct ContentView: View {
    @State private var store = WorkoutStore()
    @State private var timer = RestTimerManager()
    @State private var showResetConfirm = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                LazyVStack(spacing: 13) {
                    ForEach(Program.days[store.activeDay].exercises.indices, id: \.self) { ei in
                        ExerciseCardView(store: store, timer: timer, day: store.activeDay, index: ei)
                    }
                    Text("Everything you log is saved automatically.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.textGhost)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.bgMain.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if timer.isActive {
                RestTimerBar(timer: timer)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35), value: timer.isActive)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { timer.refreshFromClock() }
        }
        .confirmationDialog(
            "Clear all logged sets for this day?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset Day", role: .destructive) { store.resetDay(store.activeDay) }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Header

    private var header: some View {
        let day = Program.days[store.activeDay]
        let progress = store.dayProgress(day: store.activeDay)
        let fraction = progress.total > 0 ? Double(progress.done) / Double(progress.total) : 0

        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("8-WEEK ADVANCED · WOMEN")
                    .font(.condensed(12))
                    .tracking(1.9)
                    .foregroundStyle(Color.volt)
                Spacer()
                Button("RESET DAY") { showResetConfirm = true }
                    .font(.condensed(11))
                    .tracking(1.1)
                    .foregroundStyle(Color.textDim)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderCol))
            }
            .padding(.bottom, 8)

            Text(day.title.uppercased())
                .font(.condensed(34, .heavy))
                .foregroundStyle(.white)

            Text(day.focus)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.textDim)
                .padding(.top, 5)

            dayTabs
                .padding(.top, 14)

            HStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(red: 28/255, green: 31/255, blue: 36/255))
                        Capsule().fill(Color.volt)
                            .frame(width: geo.size.width * fraction)
                            .animation(.easeOut(duration: 0.25), value: fraction)
                    }
                }
                .frame(height: 8)
                Text("\(progress.done)/\(progress.total) SETS")
                    .font(.condensed(13))
                    .foregroundStyle(Color.volt)
            }
            .padding(.top, 13)

            settingsChips
                .padding(.top, 11)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.bgMain)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(red: 35/255, green: 38/255, blue: 43/255)).frame(height: 1)
        }
    }

    private var dayTabs: some View {
        HStack(spacing: 7) {
            ForEach(Program.days.indices, id: \.self) { i in
                let active = i == store.activeDay
                Button {
                    store.activeDay = i
                } label: {
                    VStack(spacing: 3) {
                        Text("DAY \(i + 1)")
                            .font(.condensed(15, .heavy))
                            .foregroundStyle(active ? Color.darkOnVolt : .white)
                        Text(Program.days[i].short)
                            .font(.condensed(9, .semibold))
                            .tracking(0.6)
                            .foregroundStyle(active ? Color.darkOnVolt.opacity(0.62) : Color.textFaint)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(active ? Color.volt : Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(active ? Color.volt : Color.borderCol)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var settingsChips: some View {
        HStack(spacing: 6) {
            chip("\(store.unitLabel) ⇄", on: true) {
                store.settings.useLb.toggle()
            }
            chip("AUTO-REST \(store.settings.autoRest ? "ON" : "OFF")", on: store.settings.autoRest) {
                store.settings.autoRest.toggle()
            }
            chip("BIG \(store.settings.bigNumbers ? "ON" : "OFF")", on: store.settings.bigNumbers) {
                store.settings.bigNumbers.toggle()
            }
            chip("SCREEN \(store.settings.keepAwake ? "ON" : "OFF")", on: store.settings.keepAwake) {
                store.settings.keepAwake.toggle()
            }
        }
    }

    private func chip(_ label: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.condensed(11))
                .tracking(0.9)
                .foregroundStyle(on ? Color.volt : Color.textDim)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(on ? Color.volt.opacity(0.12) : Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(on ? Color.volt.opacity(0.4) : Color.borderCol)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
