// ExploreView.swift

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCategory: FocusArea? = nil
    @State private var showFavorites: Bool = false
    @State private var searchText: String = ""
    @State private var selectedSortOption: SortOption = .dateAddedNewest
    @State private var showSortOptions: Bool = false
    
    // Animation states
    @State private var isLoading: Bool = true
    @State private var animateCards: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if searchText.isEmpty {
                                // Recommended articles section
                                recommendedArticlesSection
                                
                                // Category filters
                                categoriesSection
                                
                                // Articles list based on filter
                                filteredArticlesSection
                            } else {
                                // Search results
                                searchResultsSection
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
                .navigationTitle("Explore")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        sortButton
                    }
                }
                .onAppear {
                    // Simulate loading and trigger animations
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isLoading = false
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            animateCards = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showSortOptions) {
                SortOptionsView(
                    selectedSortOption: $selectedSortOption
                )
                .presentationDetents([.height(300)])
            }
        }
    }
    
    // MARK: - Computed Properties
    
    // All articles filtered by current criteria
    private var filteredArticles: [Article] {
        dataManager.getArticles(
            for: selectedCategory,
            favoritesOnly: showFavorites,
            sortedBy: selectedSortOption
        )
    }
    
    // Articles for search results
    private var searchResults: [Article] {
        if searchText.isEmpty {
            return []
        }
        
        return dataManager.getArticles().filter { article in
            article.title.lowercased().contains(searchText.lowercased()) ||
            article.author.lowercased().contains(searchText.lowercased()) ||
            article.description.lowercased().contains(searchText.lowercased())
        }
    }
    
    // Recent articles for the recommended section
    private var recentArticles: [Article] {
        Array(dataManager.getArticles(sortedBy: .dateAddedNewest).prefix(4))
    }
    
    // MARK: - UI Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search articles", text: $searchText)
                .font(.system(size: 16))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color("FieldBackground"))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var sortButton: some View {
        Button(action: {
            showSortOptions = true
        }) {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(Color("AccentColor"))
        }
    }
    
    private var recommendedArticlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.blue)
                Text("Recommended Articles")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recentArticles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            RecommendedArticleCard(article: article)
                                .frame(width: 280, height: 200)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(recentArticles.firstIndex(where: { $0.id == article.id }) ?? 0) * 0.1),
                                    value: animateCards
                                )
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Topics For You")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // All category
                CategoryButton(
                    title: "All",
                    icon: "rectangle.grid.2x2.fill",
                    isSelected: selectedCategory == nil && !showFavorites
                ) {
                    withAnimation {
                        selectedCategory = nil
                        showFavorites = false
                    }
                }
                
                // Topic categories
                ForEach(FocusArea.allCases) { area in
                    if area != .wellness {
                        CategoryButton(
                            title: area == .eye ? "Eye Care" :
                                   area == .back ? "Neck & Back" : "Hand Care",
                            icon: area.icon,
                            isSelected: selectedCategory == area
                        ) {
                            withAnimation {
                                selectedCategory = area
                                showFavorites = false
                            }
                        }
                    }
                }
                
                // Wellness category
                CategoryButton(
                    title: "Wellness",
                    icon: "heart.fill",
                    isSelected: selectedCategory == .wellness
                ) {
                    withAnimation {
                        selectedCategory = .wellness
                        showFavorites = false
                    }
                }
                
                // Favorites
                CategoryButton(
                    title: "Favorites",
                    icon: "star.fill",
                    isSelected: showFavorites
                ) {
                    withAnimation {
                        showFavorites = true
                        selectedCategory = nil
                    }
                }
            }
        }
    }
    
    private var filteredArticlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !filteredArticles.isEmpty {
                ForEach(filteredArticles) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        ArticleListItem(article: article)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                }
            } else {
                if showFavorites {
                    EmptyStateView(
                        title: "No Favorites Yet",
                        message: "Articles you mark as favorites will appear here",
                        icon: "star.fill"
                    )
                } else if selectedCategory != nil {
                    EmptyStateView(
                        title: "No Articles Found",
                        message: "No articles in this category yet",
                        icon: selectedCategory?.icon ?? "doc.fill"
                    )
                } else {
                    EmptyStateView(
                        title: "No Articles",
                        message: "Check back later for new content",
                        icon: "doc.fill"
                    )
                }
            }
        }
    }
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search Results")
                .font(.title3)
                .fontWeight(.bold)
            
            if searchResults.isEmpty {
                EmptyStateView(
                    title: "No Results",
                    message: "Try a different search term",
                    icon: "magnifyingglass"
                )
            } else {
                ForEach(searchResults) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        ArticleListItem(article: article)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                }
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(DataManager.shared)
    }
}
