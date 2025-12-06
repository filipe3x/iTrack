//
//  OnboardingView.swift
//  iTrack
//
//  Onboarding flow explaining app functionality and requesting permissions
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @StateObject private var healthKitManager = HealthKitManager.shared

    @State private var currentPage = 0
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)

                FeaturePage()
                    .tag(1)

                DisclaimerPage()
                    .tag(2)

                PermissionsPage(
                    onAuthorize: requestPermissions
                )
                .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            if currentPage < 3 {
                Button(action: {
                    withAnimation {
                        currentPage += 1
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func requestPermissions() {
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                await MainActor.run {
                    isPresented = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)

            Text("Welcome to iTrack")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Monitor your heart rate during sleep to detect nocturnal arousal events")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct FeaturePage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Features")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)

            FeatureRow(
                icon: "heart.fill",
                title: "Continuous Monitoring",
                description: "Track heart rate and HRV during your sleep window"
            )

            FeatureRow(
                icon: "bell.badge.fill",
                title: "Instant Alerts",
                description: "Get haptic and sound notifications when events are detected"
            )

            FeatureRow(
                icon: "chart.xyaxis.line",
                title: "Event Tracking",
                description: "Review and export your arousal event history"
            )

            FeatureRow(
                icon: "slider.horizontal.3",
                title: "Customizable",
                description: "Adjust sensitivity and thresholds to your needs"
            )
        }
        .padding()
    }
}

struct DisclaimerPage: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Important Disclaimer")
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                DisclaimerPoint(text: "iTrack is not a medical device")
                DisclaimerPoint(text: "Not intended for diagnosis or treatment")
                DisclaimerPoint(text: "Consult healthcare professionals for medical advice")
                DisclaimerPoint(text: "Detection accuracy may vary by individual")
            }
            .padding()

            Text("By continuing, you acknowledge these limitations")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct PermissionsPage: View {
    let onAuthorize: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Permissions")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("iTrack needs the following permissions to function:")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                PermissionRow(
                    icon: "heart.fill",
                    title: "HealthKit Access",
                    description: "Read heart rate and HRV data"
                )

                PermissionRow(
                    icon: "figure.walk.motion",
                    title: "Motion Access",
                    description: "Detect movement to reduce false alerts"
                )

                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Alert you when events are detected"
                )
            }

            Spacer()

            Button(action: onAuthorize) {
                Text("Grant Permissions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DisclaimerPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.orange)

            Text(text)
                .font(.body)
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
    }
}
