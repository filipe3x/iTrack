//
//  MealTimingPromptView.swift
//  FixSleep WatchKit Extension
//
//  Prompt to collect last meal timing before starting sleep tracking
//

import SwiftUI

struct MealTimingPromptView: View {
    @Binding var isPresented: Bool
    var onMealTimeSelected: (MealTiming) -> Void

    @State private var selectedHoursAgo: Int = 3
    @State private var showTimePicker = false

    private let hoursOptions = [1, 2, 3, 4, 5, 6]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.Accent.chamomile)

                    Text("Ultima Refeicao")
                        .font(AppTheme.Typography.subtitle(weight: .medium))
                        .foregroundColor(AppTheme.Text.primary)

                    Text("Quando foi a sua ultima refeicao?")
                        .font(AppTheme.Typography.tiny())
                        .foregroundColor(AppTheme.Text.muted)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                // Quick selection buttons
                VStack(spacing: 8) {
                    ForEach(hoursOptions, id: \.self) { hours in
                        Button(action: {
                            selectHoursAgo(hours)
                        }) {
                            HStack {
                                Text("Ha \(hours)h")
                                    .font(AppTheme.Typography.caption(weight: .medium))
                                Spacer()
                                if selectedHoursAgo == hours {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.Accent.mint)
                                }
                            }
                            .foregroundColor(AppTheme.Text.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                selectedHoursAgo == hours
                                    ? AppTheme.Accent.mint.opacity(0.15)
                                    : Color.white.opacity(0.05)
                            )
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Action buttons
                VStack(spacing: 8) {
                    // Confirm button
                    Button(action: confirmSelection) {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Confirmar")
                                .font(AppTheme.Typography.caption(weight: .semibold))
                        }
                        .foregroundColor(AppTheme.Background.deep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.Accent.mint)
                        .cornerRadius(AppTheme.CornerRadius.full)
                    }
                    .buttonStyle(.plain)

                    // Don't know button
                    Button(action: selectUnknown) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 12))
                            Text("Nao Sei")
                                .font(AppTheme.Typography.caption(weight: .medium))
                        }
                        .foregroundColor(AppTheme.Text.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(AppTheme.CornerRadius.full)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(AppTheme.Background.deep)
    }

    private func selectHoursAgo(_ hours: Int) {
        selectedHoursAgo = hours
    }

    private func confirmSelection() {
        let mealTime = Calendar.current.date(
            byAdding: .hour,
            value: -selectedHoursAgo,
            to: Date()
        )
        let timing = MealTiming(lastMealTime: mealTime)
        onMealTimeSelected(timing)
        isPresented = false
    }

    private func selectUnknown() {
        onMealTimeSelected(.unknown)
        isPresented = false
    }
}

struct MealTimingPromptView_Previews: PreviewProvider {
    static var previews: some View {
        MealTimingPromptView(isPresented: .constant(true)) { _ in }
    }
}
