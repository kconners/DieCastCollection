//
//  MyLibrary.swift
//  DieCastCollection
//
//  Created by Kaylen Conners on 9/15/23.
//

import SwiftUI

struct MyLibrary: View {
    var body: some View {
        NavigationStack(){
            VStack {
                Text("Hot Wheels")
                    .font(.largeTitle)
                    .bold()
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    
    
       
}

struct MyLibrary_Previews: PreviewProvider {
    static var previews: some View {
        MyLibrary()
    }
}
