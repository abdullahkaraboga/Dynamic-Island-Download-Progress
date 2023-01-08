//
//  Home.swift
//  DynamicIslandDownloadProgress
//
//  Created by Abdullah Karaboğa on 6.01.2023.
//

import SwiftUI

struct Home: View {
    @StateObject var progressBar: DynamicProgress = .init()
    @State var sampleProgress: CGFloat = 0

    var body: some View {
        Button("\(progressBar.isAdded ? "Stop" : "Start") Download") {

            if progressBar.isAdded{
                progressBar.removeProgressView()
            }else{
                let config = ProgressConfig(title: "Test Video", progressImage: "arrow.up", expandedImage: "clock.badge.checkmark.fill", tint: .yellow, rotationEnabled: true)
                progressBar.addProgressView(config: config)
            }

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 100)
            .onReceive(Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()) {
            _ in
            if progressBar.isAdded {
                sampleProgress += 0.1
                progressBar.updateProgressView(to: sampleProgress / 100)
            }else{
                sampleProgress = 0
            }
        }
            .statusBarHidden(progressBar.hideStatusBar)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

class DynamicProgress: NSObject, ObservableObject {

    @Published var isAdded: Bool = false
    @Published var hideStatusBar: Bool = false

    func addProgressView(config: ProgressConfig) {

        if rootController().view.viewWithTag(1009) == nil {

            let swiftUIView = DynamicProgressView(config: config).environmentObject(self)

            let hostingView = UIHostingController(rootView: swiftUIView)
            hostingView.view.frame = screenSize()
            hostingView.view.backgroundColor = .clear
            hostingView.view.tag = 1009
            rootController().view.addSubview(hostingView.view)
            isAdded = true

        } else {
            print("already added")
        }
    }

    func updateProgressView(to: CGFloat) {

        NotificationCenter.default.post(name: NSNotification.Name("UPDATE_PROGRESS"), object: nil, userInfo: ["progress": to])
    }

    func removeProgressView() {
        
        if let view = rootController().view.viewWithTag(1009){
            view.removeFromSuperview()
            isAdded = false
            print("Removed")
        }

    }
    
    func removeProgressWithAnimations(){
        NotificationCenter.default.post(name: NSNotification.Name("CLOSE_PROGRESS_VIEW"), object: nil)
    }

    func screenSize() -> CGRect {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }

        return window.screen.bounds
    }

    func rootController() -> UIViewController {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = window.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}

struct DynamicProgressView: View {
    var config: ProgressConfig
    @EnvironmentObject var progressBar: DynamicProgress
    @State var showProgressView: Bool = false
    @State var progress: CGFloat = 0
    @State var showAlertView: Bool = false
    var body: some View {
        Canvas { ctx, size in

            ctx.addFilter(.alphaThreshold(min: 0.5, color: .black))
            ctx.addFilter(.blur(radius: 5.5))

            ctx.drawLayer { context in

                for index in [1, 2] {
                    if let resolvedImage = ctx.resolveSymbol(id: index) {
                        context.draw(resolvedImage, at: CGPoint(x: size.width / 2, y: 11 + 18))
                    }
                }

            }

        } symbols: {

            ProgressComponents().tag(1)
            ProgressComponents(isCircle: true).tag(2)
        }
            .overlay(alignment: .top, content: {

            ProgressView()
                .offset(y: 11)

        })
            .overlay(alignment: .top, content: {

            CustomAlertView()
        })


            .ignoresSafeArea()

            .allowsHitTesting(false)

            .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showProgressView = true
            }
        }
            .onReceive(NotificationCenter.default.publisher(for: .init("CLOSE_PROGRESS_VIEW")), perform: { _ in
                showProgressView = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.67){
                    progressBar.removeProgressView()
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .init("UPDATE_PROGRESS")))
        { output in
            if let info = output.userInfo, let progress = info["progress"] as? CGFloat {

                if progress < 1.0 {
                    self.progress = progress

                    if (progress * 100).rounded() == 100.0 {
                        showProgressView = false
                        showAlertView = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            progressBar.hideStatusBar = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3 ){
                            showAlertView = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                progressBar.hideStatusBar = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 ){
                                progressBar.removeProgressView()
                            }
                        }
                    }
                }

            }

        }
    }


    @ViewBuilder
    func ProgressView() -> some View {
        ZStack {
            let rotation = (progress > 1 ? 1 : (progress < 0 ? 0 : progress))
            Image(systemName: config.progressImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fontWeight(.semibold)
                .frame(width: 12, height: 12)
                .foregroundColor(config.tint)
                .rotationEffect(.init(degrees: config.rotationEnabled ? Double(rotation * 360) : 0))

            ZStack {
                Circle().stroke(.white.opacity(0.25), lineWidth: 4)


                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(config.tint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.init(degrees: -90))
            }
                .frame(width: 23, height: 23)
        }
            .frame(width: 37, height: 37)
            .frame(width: 126, alignment: .trailing)
            .offset(x: showProgressView ? 45 : 0)
            .opacity(showProgressView ? 1 : 0)
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7,
                                          blendDuration: 0.7), value: showProgressView)

    }


    @ViewBuilder
    func CustomAlertView() -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            Capsule()
                .fill(.black)
                .frame(width: showAlertView ? size.width : 126 , height: showAlertView ? size.height: 37)
                .overlay(content: {
                    HStack(spacing: 13) {
                        Image(systemName: config.expandedImage)
                            .symbolRenderingMode(.multicolor)
                            .font(.largeTitle)
                            .foregroundStyle(.white,.blue,.white)
                        
                        HStack(spacing: 6) {
                            Text("Downloaded")
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Downloaded")
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .lineLimit(1)
                        .contentTransition(.opacity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y:12)
                    }
                    .padding(.horizontal,12)
                    .blur(radius: showAlertView ? 0 : 5)
                    .opacity(showAlertView ? 1 : 0 )
                })
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
        }
            .frame(height: 65)
            .padding(.horizontal, 18)
            .offset(y: 11)
            .animation(.interactiveSpring(response: 0.5,dampingFraction: 0.7, blendDuration: 0.7).delay(showAlertView ? 0.35 : 0), value: showAlertView)
    }

    @ViewBuilder
    func ProgressComponents(isCircle: Bool = false) -> some View {
        if isCircle {

            Circle()
                .fill(.black)
                .frame(width: 37, height: 37)
                .frame(width: 126, alignment: .trailing)
                .fontWeight(.semibold)
                .offset(x: showProgressView ? 45 : 0)
                .scaleEffect(showProgressView ? 1 : 0.55, anchor: .trailing)
                .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: showProgressView)

        } else {
            Capsule()
                .fill(.black)
                .frame(width: 126, height: 36)
                .offset(y:1)
        }
    }
}
