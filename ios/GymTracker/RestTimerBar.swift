import SwiftUI

struct RestTimerBar: View {
    var timer: RestTimerManager
    @State private var pulsing = false

    var body: some View {
        VStack(spacing: 11) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.22))
                    Capsule().fill(Color.darkOnTimer.opacity(0.4))
                        .frame(width: geo.size.width * timer.progress)
                }
            }
            .frame(height: 5)

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(timer.label)
                        .font(.condensed(12, .heavy))
                        .tracking(1.4)
                        .foregroundStyle(Color.darkOnTimer.opacity(0.62))
                    Text(timer.exerciseName)
                        .font(.condensed(14))
                        .foregroundStyle(Color.darkOnTimer)
                        .lineLimit(1)
                        .frame(maxWidth: 130, alignment: .leading)
                }

                Text(formatClock(timer.remaining))
                    .font(.condensed(40, .heavy))
                    .monospacedDigit()
                    .foregroundStyle(Color.darkOnTimer)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 7) {
                    controlButton(timer.isRunning || timer.remaining <= 0 ? "PAUSE" : "RESUME", minWidth: 58) {
                        timer.togglePause()
                    }
                    controlButton("+15") { timer.addFifteen() }
                    controlButton("✕") { timer.stop() }
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(timer.isFinished ? Color.volt : Color.restOrange)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.5), radius: 17, y: 10)
        .scaleEffect(pulsing ? 0.93 : 1)
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
        .onChange(of: timer.isFinished) { _, finished in
            if finished {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.15)) { pulsing = false }
            }
        }
    }

    private func controlButton(_ label: String, minWidth: CGFloat = 0, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.condensed(13, .heavy))
                .foregroundStyle(Color.darkOnTimer)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .frame(minWidth: minWidth)
                .background(Color.darkOnTimer.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
    }
}
