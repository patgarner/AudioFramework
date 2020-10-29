//
//  NotificationExtension.swift
//  AudioFramework
//
//  Created by Admin on 9/22/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

extension Notification.Name{
    static let ExportMIDI = Notification.Name("ExportMIDI")
    static let StemProgress = Notification.Name("StemProgress")
    static let StemExportComplete = Notification.Name("StemExportComplete")
    static let AudioControllerMessage = Notification.Name("AudioControllerMessage")
}
