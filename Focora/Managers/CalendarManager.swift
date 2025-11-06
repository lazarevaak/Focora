//
//  CalendarManager.swift
//  Focora
//
//  Created by Sergey on 06.11.2025.
//

import EventKit
import Foundation
internal import Combine

@MainActor
final class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    @Published var hasCalendarAccess: Bool = false
    @Published var calendars: [EKCalendar] = []
    @Published var calendarEvents: [EKEvent] = []
    
    private init() {
        checkCalendarAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkCalendarAuthorizationStatus() {
        if #available(macOS 14.0, *) {
            let status = EKEventStore.authorizationStatus(for: .event)
            hasCalendarAccess = (status == .fullAccess)
        } else {
            let status = EKEventStore.authorizationStatus(for: .event)
            hasCalendarAccess = (status == .authorized)
        }
        
        if hasCalendarAccess {
            loadCalendars()
        }
    }
    
    func requestCalendarAccess() async -> Bool {
        if #available(macOS 14.0, *) {
            let status = EKEventStore.authorizationStatus(for: .event)
            
            switch status {
            case .fullAccess:
                hasCalendarAccess = true
                loadCalendars()
                return true
                
            case .writeOnly:
                do {
                    let granted = try await eventStore.requestFullAccessToEvents()
                    hasCalendarAccess = granted
                    if granted {
                        loadCalendars()
                    }
                    return granted
                } catch {
                    print("Calendar access error: \(error)")
                    return false
                }
                
            case .denied, .restricted:
                hasCalendarAccess = false
                return false
                
            case .notDetermined:
                do {
                    let granted = try await eventStore.requestFullAccessToEvents()
                    hasCalendarAccess = granted
                    if granted {
                        loadCalendars()
                    }
                    return granted
                } catch {
                    print("Calendar access error: \(error)")
                    return false
                }
                
            @unknown default:
                return false
            }
        } else {
            let status = EKEventStore.authorizationStatus(for: .event)
            
            switch status {
            case .authorized:
                hasCalendarAccess = true
                loadCalendars()
                return true
                
            case .denied, .restricted:
                hasCalendarAccess = false
                return false
                
            case .notDetermined:
                do {
                    let granted = try await eventStore.requestAccess(to: .event)
                    hasCalendarAccess = granted
                    if granted {
                        loadCalendars()
                    }
                    return granted
                } catch {
                    print("Calendar access error: \(error)")
                    return false
                }
                
            @unknown default:
                return false
            }
        }
    }
    
    private func loadCalendars() {
        calendars = eventStore.calendars(for: .event)
    }
    
    func fetchUpcomingEvents(daysAhead: Int = 30) -> [EKEvent] {
        guard hasCalendarAccess else { return [] }
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: startDate) ?? startDate
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        calendarEvents = events
        return events
    }
    
    func createEvent(
        title: String,
        startDate: Date,
        duration: TimeInterval = 3600,
        notes: String? = nil,
        calendar: EKCalendar? = nil
    ) -> Result<EKEvent, Error> {
        guard hasCalendarAccess else {
            return .failure(CalendarError.noAccess)
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(duration)
        event.notes = notes
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return .success(event)
        } catch {
            return .failure(error)
        }
    }
    
    func deleteEvent(_ event: EKEvent) -> Bool {
        do {
            try eventStore.remove(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to delete event: \(error)")
            return false
        }
    }
    
    func updateEvent(_ event: EKEvent) -> Bool {
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to update event: \(error)")
            return false
        }
    }
}


enum CalendarError: Error {
    case noAccess
    case saveFailed
    case notFound
}
