# LocationRegisterKit 📍

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0D96F6?style=for-the-badge&logo=swift&logoColor=white)
![CoreLocation](https://img.shields.io/badge/CoreLocation-6B7280?style=for-the-badge)
![CoreData](https://img.shields.io/badge/CoreData-6B7280?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**LocationRegisterKit** es un módulo desarrollado como **Swift Package** para manejar la lógica de geolocalización y registro de entradas y salidas en sucursales.  
Permite integrar toda la funcionalidad de **CoreLocation, Geofencing y CoreData** en cualquier app sin ensuciar la lógica de la UI.

---

## 🚀 Tecnologías utilizadas

- **Swift 5.9+**
- **SwiftUI**
- **Combine**
- **CoreLocation**
- **CoreData**
- **MapKit** (para simulaciones y mapas en las apps que lo consuman)
- Compatible con **iOS 17+**
- **Swift Package Manager**

---

## ✨ Funcionalidades principales

- 📍 **Detección de entrada y salida de sucursales** mediante geofencing.
- 🎯 **Filtro de precisión**: descarta ubicaciones imprecisas.
- 🚫 **Anti-jump**: evita falsos registros por saltos de GPS.
- 🔄 **Post-salida inteligente**: evalúa nuevas entradas inmediatamente.
- 🗄️ **Persistencia en CoreData**: historial de registros y sucursales.
- 🌐 **Integración sencilla** con cualquier app SwiftUI mediante ViewModels dedicados.

---

## 🧱 Arquitectura del módulo
```
LocationRegisterKit/
├── CoreData/
│ ├── DataController.swift
│ ├── Registro+CoreDataClass.swift
│ ├── Registro+CoreDataProperties.swift
│ ├── Sucursal+CoreDataClass.swift
│ └── Sucursal+CoreDataProperties.swift
│
├── Managers/
│ ├── GeofencingManager.swift
│ ├── LocationManager.swift
│ └── RegistroManager.swift
│
├── Models/
│ ├── AppUser.swift
│ ├── RegistroDTO.swift
│ └── SucursalDTO.swift
│
├── Repositories/
│ ├── RegistroRepository.swift
│ └── SucursalRepository.swift
│
├── Services/
│ ├── APIServiceMock.swift
│ ├── RegistroAPIMock.swift
│ ├── RegistroService.swift
│ └── SucursalService.swift
│
├── ViewModels/
│ ├── RegistroViewModel.swift
│ └── SucursalesViewModel.swift
│
├── Resources/
│ ├── iSucurgal.xcdatamodeld
│ ├── Obelisco.gpx
│ ├── Parque Patricios.gpx
│ ├── Plaza Galicia.gpx
│ └── sucursales.json
│
└── LocationRegisterKit.swift
```

---

## 🔧 Instalación

Agregar el paquete vía **Swift Package Manager**:

1. En Xcode: `File → Add Packages…`
2. Ingresar la URL del repositorio:  

https://github.com/matias-spinelli/LocationRegisterKit.git

3. Seleccionar la versión que desees usar (ej: `main` o un tag específico).

---

## 📚 Uso básico

```swift
import SwiftUI
import LocationRegisterKit
import CoreData

@main
struct MyApp: App {

    let dataController = DataController.shared
    let module = LocationRegisterKitModule.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, dataController.container.viewContext)

                // Inyectar los ViewModels y Managers del módulo
                .environmentObject(module.sucursalesViewModel)
                .environmentObject(module.registroViewModel)
                .environmentObject(module.geofencingManager)
                .environmentObject(module.locationManager)
                .environmentObject(module.registroManager)

                // Inicializar el módulo al iniciar la app
                .onAppear {
                    module.startModule()
                }
        }
    }
}
```

- LocationRegisterKitModule.shared centraliza toda la lógica del módulo.

- Sus ViewModels y Managers se inyectan en el entorno para que la UI pueda acceder a ellos.

- startModule() inicializa la detección de ubicación, geofencing y CoreData.

---

## 📦 Release Notes

**v1.0.0** – Primer release estable del módulo.
Incluye:

Geofencing de sucursales

Persistencia CoreData

ViewModels para consumo SwiftUI

Servicios mock para pruebas y desarrollo

---

## 🌟 Créditos

Proyecto creado por **Matías Spinelli**  ([@matias-spinelli](https://github.com/matias-spinelli))
Aplicación desarrollada en **Swift** como práctica para aprender CoreData, CoreLocation y SwiftPackageManager.

---

## 📜 Licencia

MIT License © 2025

📍 “La ubicación no es un lugar — es un contexto.”



