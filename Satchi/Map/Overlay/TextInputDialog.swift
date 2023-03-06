//
//  TextInputDialog.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-05-04.
//

import SwiftUI

struct TextInputDialog: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var value: String

    var prompt: String = ""
    @State var fieldValue: String

    init(prompt: String, value: Binding<String>) {
        _value = value
        self.prompt = prompt
        _fieldValue = State<String>(initialValue: value.wrappedValue)
    }

    var body: some View {
        VStack {
            Text(prompt).frame(width: 100)

            TextField("", text: $fieldValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200, alignment: .center)

            HStack {
                Button("Save") {
                    self.value = fieldValue
                    self.presentationMode.wrappedValue.dismiss()
                }
            }.padding()
        }
        .padding()
    }
}

#if DEBUG
struct TextInputDialog_Previews: PreviewProvider {
    static var previews: some View {
        var name = "Stensö"
        TextInputDialog(prompt: "Track name:",
                        value: Binding<String>.init(get: { name }, set: {name = $0}))
            .frame(width: 100, height: 100, alignment: .center)
    }
}
#endif
