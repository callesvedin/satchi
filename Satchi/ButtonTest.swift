//
//  ButtonTest.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-09-05.
//

import SwiftUI

struct ButtonTest: View {
    var body: some View {
        HStack {
            Button(action: {print("Continue pressed\n")},
                   label:  {
                Image(systemName: "pause.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
                    .font(.system(size: 40))
            })
            .padding(15)


            Button(action: {print("Continue pressed\n")},
                   label:  {
                Image(systemName: "stop.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .font(.system(size: 40))
            })
            .padding(15)
            Button(action: {print("Continue pressed\n")},
                   label:  {
                Image(systemName: "play.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
                    .font(.system(size: 40))
            })
            .padding(15)


        }.background(Color.gray)
    }
}

struct ButtonTest_Previews: PreviewProvider {
    static var previews: some View {
        ButtonTest()
    }
}

