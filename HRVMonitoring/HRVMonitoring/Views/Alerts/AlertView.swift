//
//  AlertView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(.hrvTertiary, lineWidth: 3)
            .background(.hrvSecondary)
            .cornerRadius(20)
            .padding([.leading, .trailing], 20)
            .frame(height: 150)
            .overlay{
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.hrvAlertText)
                            .font(.title3)
                            .padding(.leading, 45)
                        Text("Medical Event Detected")
                            .font(.title3)
                            .fontWeight(Font.Weight.heavy)
                            .foregroundColor(.hrvAlertText)
                        Spacer()
                        Image(systemName: "x.circle")
                            .foregroundColor(.hrvAlertText)
                            .font(.title3)
                            .padding(.trailing, 35)
                        
                    }
                        .padding(.top, 20)
                    HStack {
                        Text("Ongoing - 163 BPM")
                            .padding(.leading, 75)
                            .font(.body)
                            .fontWeight(Font.Weight.medium)
                            .foregroundStyle(.hrvAlertText)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Button {} label: {
                            Text("Help")
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .font(.title3)
                                .background(.hrvPrimary)
                                .cornerRadius(16)
                        }
                            .padding(.leading, 75)
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
    }
}

#Preview {
    AlertView()
}
