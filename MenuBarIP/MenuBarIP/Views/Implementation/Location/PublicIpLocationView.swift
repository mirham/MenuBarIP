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
    
    private var currentLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: appState.network.publicIp?.latitude ?? 0,
            longitude: appState.network.publicIp?.longitude ?? 0
        )
    }
    
    private var currentRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: currentLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        )
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            Annotation(String(), coordinate: currentLocation) {
                ipAnnotation
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapScaleView()
            MapZoomStepper()
            MapPitchSlider()
        }
        .onAppear {
            appState.views.shownWindows.append(Constants.windowIdPublicIpLocation)
            AppHelper.activateView(viewId: Constants.windowIdPublicIpLocation)
            cameraPosition = .region(currentRegion)
        }
        .onChange(of: appState.network.publicIp) {
            withAnimation(.smooth(duration: 3.5)) {
                cameraPosition = .region(currentRegion)
            }
        }
        .onDisappear {
            appState.views.shownWindows.removeAll { $0 == Constants.windowIdPublicIpLocation }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.network.publicIp)
        .ignoresSafeArea()
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var ipAnnotation: some View {
        VStack {
            Image(Constants.iconIpPoint)
                .resizable()
                .frame(width: 50, height: 50)
            Text(appState.network.publicIp?.asPhysicalAddressString() ?? String())
                .font(.system(size: 16))
                .bold()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
        }
        .isHidden(hidden: appState.network.publicIp == nil)
    }
}
