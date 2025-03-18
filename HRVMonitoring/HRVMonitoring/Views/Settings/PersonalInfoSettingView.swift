//
//  SettingView.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/3/25.
//

import SwiftUI

struct PersonalInfoSettingView: View {
    var name: String
    var description: String
    @Binding var show: Bool
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .frame(height: 60)
            .overlay {
                VStack {
                    Button(
                        action: {
                            show = !show
                        },
                        label: {
                            ZStack {
                                VStack {
                                    HStack {
                                        Text(name)
                                            .font(.headline)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(description)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                }
                                HStack {
                                    Spacer()
                                    Image(systemName: "hand.point.up")
                                }
                            }
                            
                        }
                    )
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .padding([.leading, .trailing], 20)
    }
}

#Preview {
    PersonalInfoSettingView(
        name: "Personal Information",
        description: "Change personal information.",
        show: .constant(false)
    )
}
