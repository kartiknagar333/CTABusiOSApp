# CTABusiOSApp
An iOS application written in Swift that lets you browse Chicago Transit Authority (CTA) bus routes, view stops for a selected route, and see real-time arrival predictions.

## Features

- **Home Screen** – Browse all CTA bus routes.  
- **Stop Screen** – View all stops for the selected route.  
- **Prediction Screen** – See real-time arrival predictions for the next buses.  

## Built With

- **SwiftUI**  
  Declarative UI for most views and navigation.

- **UIKit → Storyboards & Auto Layout**  
  Legacy screens built in Interface Builder using Storyboard scenes, with Auto Layout constraints to handle dynamic sizing and orientation changes.

- **Foundation → URLSession**  
  Native networking via `async/await` for calling the CTA API.

- **Foundation → JSONDecoder & Codable**  
  JSON parsing into Swift model structs.
  
- **HomeScreen [Routes]**
<div align="center">
  <img src="https://github.com/user-attachments/assets/1046f5a6-7043-4c43-8f0f-3efc9c84c0d8" alt="Home" width="380" height="720" />
</div>
<br>

- **StopScreen**
<div align="center">
  <img src="https://github.com/user-attachments/assets/562a2267-bee9-405f-b4c5-3263d8121d04" alt="Home" width="380" height="720" />
</div>
<br>

- **PredicationBusScreen**
<div align="center">
  <img src="https://github.com/user-attachments/assets/6767cf51-2486-4226-8045-716020ec7e50" alt="Home" width="380" height="720" />
</div>
<br>

