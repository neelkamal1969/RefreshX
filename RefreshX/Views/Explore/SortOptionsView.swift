//
//  SortOptionsView.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//


import SwiftUI

struct SortOptionsView: View {
    @Binding var selectedSortOption: SortOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sort By")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(SortOption.allCases.filter {
                        $0 != .durationLongest && $0 != .durationShortest
                    }) { option in
                        Button(action: {
                            selectedSortOption = option
                            dismiss()
                        }) {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(Color("PrimaryText"))
                                
                                Spacer()
                                
                                if selectedSortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color("AccentColor"))
                                }
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if option != SortOption.allCases.last {
                            Divider()
                                .padding(.leading)
                        }
                    }
                }
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color("PrimaryBackground"))
        .cornerRadius(16)
    }
}
