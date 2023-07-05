//
//  Notification.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 27/06/23.
//

import UserNotifications

func checkForPermission() {
    print ("Se llamo a la fucion check Notification")
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.getNotificationSettings{ settings in
        switch settings.authorizationStatus {
        case .authorized:
            print ("Tenemos autorizacion")
            dispatchNotification()
        case .denied:
            print ("Esta denegado")
            return
        case .notDetermined:
            print ("Vamos a pedir permiso")
            notificationCenter.requestAuthorization(options: [.alert,.sound]){ didAllow, error in
                if didAllow {
                    print ("Se obtuvo permiso y se manda a notificar")
                    dispatchNotification()
                }
            }
        default:
            return
        }
    }
}

func dispatchNotification() {
    // Crear contenido de la notificación
    print ("Estamos creando la notificacion")
    let content = UNMutableNotificationContent()
    content.title = "Mi Notificación"
    content.body = "¡Hola! Esta es una notificación de ejemplo."
    content.sound = UNNotificationSound.default

    // Configurar la notificación para que se muestre después de 5 segundos
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 59, repeats: false)

    // Crear solicitud de notificación
    let request = UNNotificationRequest(identifier: "MiNotificacion", content: content, trigger: trigger)

    // Agregar la solicitud de notificación al centro de notificaciones
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print ("Error al agregar la solicitud de notificación:", error)
        } else {
            print ("Notificación enviada exitosamente")
        }
    }
}
