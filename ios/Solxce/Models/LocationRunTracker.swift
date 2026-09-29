// Models/LocationRunTracker.swift
import Foundation
import CoreLocation
import MapKit
import Combine

/// Real-time GPS location and running tracker inspired by Strava & Nike Run Club
@MainActor
final class LocationRunTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // MARK: - Published Properties
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    // Live Running Metrics
    @Published var elapsedSeconds: Int = 0
    @Published var totalDistanceMeters: Double = 0.0
    @Published var currentSpeedMps: Double = 0.0 // meters per second
    @Published var splits: [RunSplit] = [] // Mile splits
    
    private var lastLocation: CLLocation?
    private var timerSubscription: AnyCancellable?
    private var simulatedTimerSubscription: AnyCancellable?
    
    // Fallback simulation when running inside simulator or GPS is still acquiring
    @Published var isSimulatedMovement: Bool = false
    private var simulationHeading: Double = 45.0 // heading in degrees
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 3.0 // Update every 3 meters
        locationManager.activityType = .fitness
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Live Metric Calculations
    var totalDistanceMiles: Double {
        totalDistanceMeters * 0.000621371
    }
    
    /// Current speed converted to miles per hour
    var currentSpeedMph: Double {
        guard currentSpeedMps > 0.2 else { return 0.0 }
        return currentSpeedMps * 2.23694
    }
    
    /// Instantaneous pace based on current GPS speed
    var currentPaceFormatted: String {
        guard currentSpeedMph > 0.5 else { return "--'--\" /mi" }
        let paceMinutes = 60.0 / currentSpeedMph
        let mins = Int(paceMinutes)
        let secs = Int((paceMinutes - Double(mins)) * 60)
        return String(format: "%d'%02d\" /mi", mins, max(0, min(59, secs)))
    }
    
    /// Average pace across the entire elapsed run
    var averagePaceMinutesPerMile: Double {
        guard totalDistanceMiles > 0.01 else { return 0.0 }
        return (Double(elapsedSeconds) / 60.0) / totalDistanceMiles
    }
    
    var averagePaceFormatted: String {
        guard totalDistanceMiles > 0.01 else { return "--'--\" /mi" }
        let pace = averagePaceMinutesPerMile
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\" /mi", mins, max(0, min(59, secs)))
    }
    
    var formattedElapsedTime: String {
        let hrs = elapsedSeconds / 3600
        let mins = (elapsedSeconds % 3600) / 60
        let secs = elapsedSeconds % 60
        if hrs > 0 {
            return String(format: "%02d:%02d:%02d", hrs, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }
    
    var estimatedCaloriesBurned: Int {
        Int(totalDistanceMiles * 110)
    }
    
    // MARK: - Run Session Controls
    func startRun(useSimulatorFallbackIfNoGps: Bool = true) {
        requestPermission()
        
        isTracking = true
        isPaused = false
        elapsedSeconds = 0
        totalDistanceMeters = 0.0
        routeCoordinates.removeAll()
        splits.removeAll()
        lastLocation = nil
        
        locationManager.startUpdatingLocation()
        
        // Timer for elapsed seconds
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isTracking, !self.isPaused else { return }
                self.elapsedSeconds += 1
                self.checkMileSplits()
            }
            
        // If in preview / simulator or no GPS yet after starting, enable smooth route simulation fallback
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            startSimulation(startCoord: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        } else {
            // Check if coordinates arrive; if simulator or static, provide fallback movement when runner taps simulate
            if currentCoordinate == nil {
                // Default start point (e.g. scenic park trail)
                let startPoint = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                self.currentCoordinate = startPoint
                self.routeCoordinates.append(startPoint)
            }
        }
    }
    
    func pauseRun() {
        isPaused = true
        locationManager.stopUpdatingLocation()
        currentSpeedMps = 0.0
    }
    
    func resumeRun() {
        isPaused = false
        locationManager.startUpdatingLocation()
        if isSimulatedMovement {
            resumeSimulation()
        }
    }
    
    func stopAndFinalizeRun() -> (distanceMiles: Double, durationSecs: Int, calories: Int, avgPace: String, route: [CLLocationCoordinate2D]) {
        isTracking = false
        isPaused = false
        locationManager.stopUpdatingLocation()
        timerSubscription?.cancel()
        timerSubscription = nil
        simulatedTimerSubscription?.cancel()
        simulatedTimerSubscription = nil
        
        let finalDistance = max(0.01, totalDistanceMiles)
        let finalDuration = max(1, elapsedSeconds)
        let finalCals = estimatedCaloriesBurned
        let finalPace = averagePaceFormatted
        let finalRoute = routeCoordinates
        
        return (finalDistance, finalDuration, finalCals, finalPace, finalRoute)
    }
    
    func reset() {
        isTracking = false
        isPaused = false
        locationManager.stopUpdatingLocation()
        timerSubscription?.cancel()
        timerSubscription = nil
        simulatedTimerSubscription?.cancel()
        simulatedTimerSubscription = nil
        elapsedSeconds = 0
        totalDistanceMeters = 0.0
        currentSpeedMps = 0.0
        routeCoordinates.removeAll()
        lastLocation = nil
        isSimulatedMovement = false
    }
    
    // MARK: - Simulation Mode (Treadmill / Indoors / Simulator Testing)
    func toggleSimulation(targetMph: Double = 6.8) {
        if isSimulatedMovement {
            isSimulatedMovement = false
            simulatedTimerSubscription?.cancel()
            simulatedTimerSubscription = nil
        } else {
            isSimulatedMovement = true
            let initial = currentCoordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            startSimulation(startCoord: initial, speedMph: targetMph)
        }
    }
    
    private func startSimulation(startCoord: CLLocationCoordinate2D, speedMph: Double = 6.8) {
        isSimulatedMovement = true
        var current = startCoord
        if routeCoordinates.isEmpty {
            routeCoordinates.append(current)
            currentCoordinate = current
        }
        
        let mps = speedMph * 0.44704
        currentSpeedMps = mps
        
        simulatedTimerSubscription?.cancel()
        simulatedTimerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isTracking, !self.isPaused else { return }
                
                // Add minor random curve to simulate realistic outdoor running path
                self.simulationHeading += Double.random(in: -4.0...4.0)
                let headingRad = self.simulationHeading * .pi / 180.0
                
                // Distance in meters moved per second
                let metersMoved = mps
                self.totalDistanceMeters += metersMoved
                
                // Earth radius approx 6,378,137m
                let dLat = (metersMoved * cos(headingRad)) / 111111.0
                let dLon = (metersMoved * sin(headingRad)) / (111111.0 * cos(current.latitude * .pi / 180.0))
                
                current = CLLocationCoordinate2D(latitude: current.latitude + dLat, longitude: current.longitude + dLon)
                self.currentCoordinate = current
                self.routeCoordinates.append(current)
            }
    }
    
    private func resumeSimulation() {
        if let last = currentCoordinate {
            startSimulation(startCoord: last, speedMph: currentSpeedMph > 0 ? currentSpeedMph : 6.8)
        }
    }
    
    private func checkMileSplits() {
        let currentCompletedMiles = Int(totalDistanceMiles)
        if currentCompletedMiles > splits.count && currentCompletedMiles > 0 {
            let previousSplitDurationSum = splits.reduce(0) { $0 + $1.splitDurationSeconds }
            let splitDuration = elapsedSeconds - previousSplitDurationSum
            let splitPaceMinutes = Double(splitDuration) / 60.0
            let mins = Int(splitPaceMinutes)
            let secs = Int((splitPaceMinutes - Double(mins)) * 60)
            let formatted = String(format: "%d'%02d\"", mins, max(0, min(59, secs)))
            
            let split = RunSplit(
                mileNumber: currentCompletedMiles,
                splitDurationSeconds: splitDuration,
                formattedPace: formatted
            )
            splits.append(split)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            // Filter inaccurate points
            guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 35 else { return }
            
            self.currentCoordinate = location.coordinate
            
            if self.isTracking && !self.isPaused && !self.isSimulatedMovement {
                if let last = self.lastLocation {
                    let deltaMeters = location.distance(from: last)
                    if deltaMeters > 1.5 { // Only record significant steps
                        self.totalDistanceMeters += deltaMeters
                        self.routeCoordinates.append(location.coordinate)
                        
                        // Use native GPS speed if valid (> 0.2 m/s), else compute from delta
                        if location.speed > 0.2 {
                            self.currentSpeedMps = location.speed
                        } else {
                            let timeDelta = location.timestamp.timeIntervalSince(last.timestamp)
                            if timeDelta > 0 {
                                self.currentSpeedMps = deltaMeters / timeDelta
                            }
                        }
                    }
                } else {
                    self.routeCoordinates.append(location.coordinate)
                }
                self.lastLocation = location
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handled gracefully without interrupting user flow
    }
}

// MARK: - Mile Split Model
struct RunSplit: Identifiable, Hashable {
    let id = UUID()
    let mileNumber: Int
    let splitDurationSeconds: Int
    let formattedPace: String
}
