//
//  Home.swift
//  DynamicIslandDownloadProgress
//
//  Created by Abdullah Karaboğa on 6.01.2023.
//

import SwiftUI

struct Home: View {
    var body: some View {
//        Button("Start Download") {
//
//        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//            .padding(.top, 100)
        
        DynamicProgressView()
//
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

struct DynamicProgressView: View {
    var body: some View {
        Canvas { ctx, size in

            ctx.addFilter(.alphaThreshold(min: 0.5, color: .black))
            ctx.addFilter(.blur(radius: 5.5))

            ctx.drawLayer { context in
                
                for index in [1,2] {
                    if let resolvedImage = ctx.resolveSymbol(id: index){
                        context.draw(resolvedImage, at: CGPoint(x:size.width / 2, y: size.height / 2))
                    }
                }

            }

        } symbols: {
            
            ProgressComponents().tag(1)
            ProgressComponents(isCircle: true).tag(2)

        }
    }

    @ViewBuilder

    func ProgressComponents(isCircle: Bool = false) -> some View {
        if isCircle {
            
            Circle()
                .fill(.black)
                .frame(width: 37,height: 37)
                .frame(width: 126,alignment: .trailing)
                .offset(x: 45)

        } else {
            Capsule()
                .fill(.black)
                .frame(width: 126,height: 36)
        }
    }
}
