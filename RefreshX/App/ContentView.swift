//
//  ContentView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isShowingSplash = true
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.8
    @State private var mainContentOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Main content with transition
            Group {
                if dataManager.isLoggedIn {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    AuthView()
                        .transition(.opacity)
                }
            }
            .opacity(mainContentOpacity)
            .zIndex(isShowingSplash ? 0 : 1)
            
            // Splash screen
            if isShowingSplash {
                SplashScreenView(
                    isAnimating: $isAnimating,
                    scale: $scale
                )
                .zIndex(1)
                .transition(.opacity)
                .onAppear {
                    // Start animation sequence
                    withAnimation(Animation.easeOut(duration: 1.5)) {
                        isAnimating = true
                        scale = 1.0
                    }
                    
                    // Pre-load and fade in main content beneath splash screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                        withAnimation(.easeIn(duration: 1.5)) {
                            mainContentOpacity = 1
                        }
                    }
                    
                    // Hide splash after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                        withAnimation(.easeOut(duration: 1.2)) {
                            isShowingSplash = false
                        }
                    }
                }
            }
        }
    }
}

// Splash Screen View
struct SplashScreenView: View {
    @Binding var isAnimating: Bool
    @Binding var scale: CGFloat
    @State private var pulseOpacity: Double = 0.7
    @State private var logoOpacity: Double = 1.0
    @State private var textOpacity: Double = 1.0
    @State private var backgroundOpacity: Double = 1.0
    @State private var rotation3D: Double = 0  // Moved rotation state here
    
    var body: some View {
        ZStack {
            // Solid Background with a slight gradient
            Color("PrimaryBackground")
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("PrimaryBackground"),
                                    Color("AccentColor").opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
            
            // Animated background elements
            ZStack {
                // Top left decoration
                Circle()
                    .fill(Color("AccentColor").opacity(0.15))
                    .frame(width: 200, height: 200)
                    .offset(x: -100, y: -250)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isAnimating)
                    .opacity(backgroundOpacity)
                
                // Bottom right decoration
                Circle()
                    .fill(Color("AccentColor").opacity(0.12))
                    .frame(width: 250, height: 250)
                    .offset(x: 120, y: 300)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(Animation.easeInOut(duration: 4.5).repeatForever(autoreverses: true).delay(0.5), value: isAnimating)
                    .opacity(backgroundOpacity)
            }
            
            // Main content
            VStack(spacing: 60) {
                // Logo container with glow
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color("AccentColor").opacity(0.3))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .opacity(isAnimating ? pulseOpacity : 0)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                        .opacity(logoOpacity)
                        .onAppear {
                            // Pulse animation
                            withAnimation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                                pulseOpacity = 0.4
                            }
                            
                            // Single rotation animation
                            withAnimation(Animation.easeInOut(duration: 2.0).delay(0.5)) {
                                rotation3D = 360  // One full rotation
                            }
                            
                            // Fade out logo at the end
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    logoOpacity = 0
                                    textOpacity = 0
                                    backgroundOpacity = 0
                                }
                            }
                        }
                    
                    // Logo with 3D rotation
                    Image("appImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: Color("AccentColor").opacity(0.6), radius: isAnimating ? 20 : 5, x: 0, y: 0)
                        .scaleEffect(scale)
                        .opacity(logoOpacity)
                        .rotation3DEffect(
                            .degrees(rotation3D),
                            axis: (x: 0, y: 1, z: 0.2),
                            anchor: .center,
                            anchorZ: 0,
                            perspective: 1.0
                        )
                }
                .padding(.top, 40)
                
                VStack(spacing: 25) {
                    // App name with shadow
                    Text("RefreshX")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryText"))
                        .shadow(color: Color("AccentColor").opacity(0.3), radius: 4, x: 0, y: 2)
                        .opacity(isAnimating && textOpacity > 0 ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 40)
                        .animation(.spring(response: 1.5, dampingFraction: 0.7).delay(1.2), value: isAnimating)
                    
                    // Tagline
                    Text("Take a break. Stay healthy.")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryText"))
                        .opacity(isAnimating && textOpacity > 0 ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.spring(response: 1.5, dampingFraction: 0.7).delay(1.8), value: isAnimating)
                }
                .opacity(textOpacity)
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color("AccentColor"))
                            .frame(width: 10, height: 10)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .opacity((isAnimating ? 1.0 : 0.3) * textOpacity)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.3),
                                value: isAnimating
                            )
                    }
                }
                .padding(.top, 60)
                .opacity(isAnimating && textOpacity > 0 ? 1.0 : 0.0)
                .animation(.easeOut(duration: 1.5).delay(2.5), value: isAnimating)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager.shared)
    }
}
