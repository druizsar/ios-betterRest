//
//  ContentView.swift
//  BetterRest
//
//  Created by David Ruiz on 3/02/23.
//

import SwiftUI
import CoreML

let secondsInHour = 3600
let secondsInMinute = 60

struct ContentView: View {
    // State vars
    @State private var sleepAmount = 8.0
    @State private var coffeeamount = 1
    @State private var wakeUp = defaultWakeTime
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        
                } header: {
                    Text("When do you want to wake up ?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }
                
                Section {
                    Picker("Cups", selection: $coffeeamount){
                        ForEach(1..<10){
                            Text("\($0) cups of coffe")
                        }
                    }.pickerStyle(.wheel)
                } header: {
                    Text("Daily coffee intake")
                        .font(.headline)
                }
                
                Section{
                    Text(alertMessage)
                        .font(.title2)
                } header: {
                    Text(alertTitle)
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
                    .font(.headline)
            }
            .alert(alertTitle, isPresented: $showAlert){
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
        
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * secondsInHour
            let minutes = (components.minute ?? 0) * secondsInMinute
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeamount + 1))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertTitle = "Sorry, there was a problem calculating your bedtime"
        }
        
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
