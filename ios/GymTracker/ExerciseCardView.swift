import SwiftUI

struct ExerciseCardView: View {
    var store: WorkoutStore
    var timer: RestTimerManager
    let day: Int
    let index: Int

    private var exercise: Exercise { Program.days[day].exercises[index] }
    private var allDone: Bool { store.exerciseDone(day: day, exercise: index) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 9) {
                    Text(exercise.name.uppercased())
                        .font(.condensed(21))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    chipsRow
                }
                Spacer(minLength: 0)
                doneBadge
            }

            VStack(spacing: 9) {
                ForEach(0..<exercise.sets, id: \.self) { si in
                    SetRowView(store: store, timer: timer, day: day, exercise: index, set: si)
                }
            }
            .padding(.top, 12)
        }
        .padding(15)
        .background(allDone ? Color.cardDone : Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(allDone ? Color.volt.opacity(0.45) : Color.borderCol)
        )
    }

    private var chipsRow: some View {
        HStack(spacing: 7) {
            Text("TARGET \(exercise.reps)")
                .font(.condensed(12))
                .foregroundStyle(Color.volt)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.volt.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.volt.opacity(0.25)))

            Button {
                timer.start(name: exercise.name, seconds: exercise.rest)
            } label: {
                Text("REST \(formatRest(exercise.rest))")
                    .font(.condensed(12))
                    .foregroundStyle(Color.restText)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.restOrange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.restOrange.opacity(0.28)))
            }
            .buttonStyle(.plain)

            Link(destination: exercise.watchURL) {
                Text("▶ WATCH")
                    .font(.condensed(12))
                    .foregroundStyle(Color.watchBlue)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(red: 70/255, green: 140/255, blue: 1).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 70/255, green: 140/255, blue: 1).opacity(0.32))
                    )
            }
        }
    }

    private var doneBadge: some View {
        Text("✓")
            .font(.system(size: 17, weight: .heavy))
            .foregroundStyle(Color.darkOnVolt)
            .frame(width: 30, height: 30)
            .background(allDone ? Color.volt : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .opacity(allDone ? 1 : 0)
            .animation(.spring(duration: 0.3), value: allDone)
    }
}

struct SetRowView: View {
    var store: WorkoutStore
    var timer: RestTimerManager
    let day: Int
    let exercise: Int
    let set: Int

    private var entry: SetEntry { store.entry(day: day, exercise: exercise, set: set) }
    private var big: Bool { store.settings.bigNumbers }
    private var fieldHeight: CGFloat { big ? 62 : 54 }
    private var fieldFontSize: CGFloat { big ? 30 : 24 }

    var body: some View {
        HStack(spacing: 8) {
            Text("SET \(set + 1)")
                .font(.condensed(13, .heavy))
                .foregroundStyle(entry.done ? Color.volt : Color.textFaint)
                .frame(width: 42, alignment: .leading)

            numberField(
                text: Binding(
                    get: { store.entry(day: day, exercise: exercise, set: set).weight },
                    set: { newValue in store.update(day: day, exercise: exercise, set: set) { $0.weight = newValue } }
                ),
                suffix: store.unitLabel,
                keyboard: .decimalPad
            )

            numberField(
                text: Binding(
                    get: { store.entry(day: day, exercise: exercise, set: set).reps },
                    set: { newValue in store.update(day: day, exercise: exercise, set: set) { $0.reps = newValue } }
                ),
                suffix: "REPS",
                keyboard: .numberPad
            )

            Button {
                let nowDone = store.toggleSet(day: day, exercise: exercise, set: set)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if nowDone && store.settings.autoRest {
                    timer.start(
                        name: Program.days[day].exercises[exercise].name,
                        seconds: Program.days[day].exercises[exercise].rest
                    )
                }
            } label: {
                Text(entry.done ? "✓" : "")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(Color.darkOnVolt)
                    .frame(width: big ? 58 : 52, height: fieldHeight)
                    .background(entry.done ? Color.volt : Color.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(entry.done ? Color.volt : Color.borderCol, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func numberField(text: Binding<String>, suffix: String, keyboard: UIKeyboardType) -> some View {
        TextField("–", text: text)
            .keyboardType(keyboard)
            .multilineTextAlignment(.center)
            .font(.condensed(fieldFontSize))
            .foregroundStyle(.white)
            .frame(height: fieldHeight)
            .frame(maxWidth: .infinity)
            .background(Color.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.borderCol))
            .overlay(alignment: .trailing) {
                Text(suffix)
                    .font(.condensed(10))
                    .tracking(0.8)
                    .foregroundStyle(Color.textFaint)
                    .padding(.trailing, 9)
                    .allowsHitTesting(false)
            }
    }
}
