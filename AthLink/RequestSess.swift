//
//  RequestSess.swift
//  AthLink
//
//  Created by RyanAubrey on 2/12/25.
//

import SwiftUI

struct RequestSess: View {
    @EnvironmentObject var rootView: RootViewObj
    @State var fileImport: Bool = false
    @State var message: String = ""
    
    var body: some View {
        VStack {
            //top section
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                    .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                Text("Send \(rootView.selectedSession?.firstName ?? "") a request\n with your needs.")
                    .bold()
                    .padding(.top,25)
            }
            ScrollView(.vertical) {
                //message
                TextField("Give any request(optional)", text: $message)
                    .frame(width: .infinity, height: 150)
                    .cornerRadius(15)
                    .border(.secondary)
                    .padding()
                    .multilineTextAlignment(.center)
                //Button
                VStack {
                    Text("Add attachments(optional):")
                    Button(action:{
                        fileImport = true
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(maxWidth: 50, maxHeight: 50)
                                .cornerRadius(10)
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(maxWidth: 30, maxHeight: 30)
                                .foregroundColor(.black)
                        }
                    }
                    .fileImporter(isPresented: $fileImport, allowedContentTypes: [.pdf,.image], allowsMultipleSelection: true) { result in
                        switch result {
                        case .success(let files):
                            files.forEach { file in
                                let gotAccess = file.startAccessingSecurityScopedResource()
                                if !gotAccess { return }
                                //add functionality
                                file.stopAccessingSecurityScopedResource()
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                //DataFields
                VStack(alignment: .leading) {
                    //Session Time
                    HStack {
                        Text("Session time (optional):")
                        Button(action: {
                            
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    //Training Location
                    HStack {
                        Text("Session location (optional):")
                        Button(action: {
                            
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    //Sport
                    HStack {
                        Text("Sport:")
                    }
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    //Session Type
                    HStack {
                        Text("Session Type:")
                    }
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                }
                .padding()
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    RequestSess()
        .environmentObject(RootViewObj())
}
