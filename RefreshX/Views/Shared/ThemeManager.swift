//
//  ThemeManager.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//
import SwiftUI
import Combine

/// Theme manager to handle app-wide appearance settings
class ThemeManager: ObservableObject {
    // Singleton instance
    static let shared = ThemeManager()
    
    // Published properties that will trigger UI updates
    @Published var isDarkMode: Bool = false
    @Published var useLargeText: Bool = false
    @Published var useReadAloud: Bool = false
    @Published var soundEnabled: Bool = true
    
    // Text size category
    @Published var textSizeCategory: ContentSizeCategory = .large
    
    // For cancelling subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Set initial values from UserDefaults for persistence across app launches
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        useLargeText = UserDefaults.standard.bool(forKey: "useLargeText")
        useReadAloud = UserDefaults.standard.bool(forKey: "useReadAloud")
        soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        
        // Set initial text size
        textSizeCategory = useLargeText ? .accessibilityLarge : .large
        
        // Listen for theme change notifications
        NotificationCenter.default.publisher(for: NSNotification.Name("ThemeChanged"))
            .sink { [weak self] notification in
                if let darkMode = notification.userInfo?["darkMode"] as? Bool {
                    self?.setDarkMode(enabled: darkMode)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Update dark mode setting
    func setDarkMode(enabled: Bool) {
        isDarkMode = enabled
        UserDefaults.standard.set(enabled, forKey: "isDarkMode")
        
        // Apply to UIKit appearance using modern approach for iOS 15+
        DispatchQueue.main.async {
            // Get all connected scenes
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    // Apply to all windows in this scene
                    for window in windowScene.windows {
                        window.overrideUserInterfaceStyle = enabled ? .dark : .light
                    }
                }
            }
        }
    }
    
    /// Update large text setting
    func setLargeText(enabled: Bool) {
        useLargeText = enabled
        UserDefaults.standard.set(enabled, forKey: "useLargeText")
        
        // Update text size category
        textSizeCategory = enabled ? .accessibilityLarge : .large
    }
    
    /// Update read aloud setting
    func setReadAloud(enabled: Bool) {
        useReadAloud = enabled
        UserDefaults.standard.set(enabled, forKey: "useReadAloud")
    }
    
    /// Update sound setting
    func setSoundEnabled(enabled: Bool) {
        soundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "soundEnabled")
    }
    
    /// Sync theme manager with user settings
    func syncWithUserSettings(_ settings: UserSettings?) {
        guard let settings = settings else { return }
        
        setDarkMode(enabled: settings.darkModeEnabled)
        setLargeText(enabled: settings.largeTextEnabled)
        setReadAloud(enabled: settings.readAloudEnabled)
        setSoundEnabled(enabled: settings.soundEnabled)
    }
}

// MARK: - SwiftUI extensions for Theme Support

// Environment key for theme manager
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// View modifier to apply theme
struct ThemeModifier: ViewModifier {
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .environment(\.sizeCategory, themeManager.textSizeCategory)
    }
}

extension View {
    func withAppTheme() -> some View {
        self.modifier(ThemeModifier())
    }
}
