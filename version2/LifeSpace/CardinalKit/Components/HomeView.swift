//
//  HomeView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 5/18/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showingSurveyAlert = false
    @State private var showingSurvey = false
    @State private var trackingOn = true
    @State private var date = Date()
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2022, month: 5, day: 1)
        let endComponents = DateComponents(year: 2022, month: 5, day: 18)
        return calendar.date(from:startComponents)! ... calendar.date(from:endComponents)!
    }()
    
    var surveyActive: Bool {
        // if it's after 7pm today in the user's local time, the survey is active
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 19
    }
    
    var body: some View {
        ZStack {
            //map on the bottom layer
            MapManagerViewWrapper()
            
            //overlay buttons on map
            VStack {
                
                HStack {
                    Spacer()
                    DatePicker(
                        "",
                        selection: $date,
                        in: dateRange,
                        displayedComponents: [.date]
                    ).padding()
                }
                
                Spacer()
                
                Button("Take Daily Survey"){
                    if(surveyActive){
                        self.showingSurvey.toggle()
                    } else {
                        self.showingSurveyAlert.toggle()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color("primaryRed"))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding(5)
                .alert(isPresented: $showingSurveyAlert){
                    Alert(title: Text("Survey Not Available"), message: Text("Please come back after 7:00 PM to complete your daily survey!"), dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $showingSurvey){
                    CKTaskViewController(tasks: DailySurveyTask(showInstructions: false))
                }
                
                Toggle("Track My Location", isOn: $trackingOn)
                    .onChange(of: trackingOn) { value in
                        AlternovaLocationFetcher.shared.startStopTracking()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("primaryRed"))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(5)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
