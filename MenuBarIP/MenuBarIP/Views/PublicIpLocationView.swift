//
//  PublicIpLocationView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 21.08.2024.
//

import SwiftUI
import MapKit

struct PublicIpLocationView : View {
    @EnvironmentObject var appState: AppState
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    
    var body: some View {
        @State var location: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: appState.network.publicIpInfo?.latitude ?? 0,
            longitude: appState.network.publicIpInfo?.longitude ?? 0)
        
        @State var region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
        
        Map (
            position: $cameraPosition
        ) {
            Annotation(
                String(),
                coordinate: location) {
                VStack {
                    Image(Constants.iconIpPoint)
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text(appState.network.publicIpInfo?.asAddressString() ?? String())
                    .font(.system(size: 16))
                    .bold()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(10)
                }
                .isHidden(hidden: appState.network.publicIpInfo == nil)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapScaleView()
            MapZoomStepper()
            MapPitchSlider()
        }
        .onAppear() {
            appState.views.shownWindows.append(Constants.windowIdPublicIpLocation)
            AppHelper.setUpView(
                viewName: Constants.windowIdPublicIpLocation,
                onTop: true)
            cameraPosition = .region(region)
        }
        .onChange(of: appState.network.publicIpInfo) {
            withAnimation(.smooth(duration:  3.5)) {
                location = CLLocationCoordinate2D(
                    latitude: appState.network.publicIpInfo?.latitude ?? 0,
                    longitude: appState.network.publicIpInfo?.longitude ?? 0)
                
                region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta:  0.3, longitudeDelta:  0.3))
                cameraPosition = .region(region)
            }
        }
        .onDisappear() {
            appState.views.shownWindows.removeAll(where: {$0 == Constants.windowIdPublicIpLocation})
        }
        .animation(.easeInOut(duration: 0.5), value: appState.network.publicIpInfo)
        .ignoresSafeArea()
    }
}
