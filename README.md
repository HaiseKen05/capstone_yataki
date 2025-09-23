# **Capstone Yataki Mobile App**  
Mobile application for the [Capstone Team Yataki](https://github.com/HaiseKen05/Capstone-TeamYataki), designed to provide **real-time monitoring**, **data visualization**, and **predictive analytics** for telemetry data such as **Steps**, **Voltage**, **Current**, and **Battery Health**.

This mobile app serves as the companion application to the [Capstone Yataki Web Application](https://github.com/HaiseKen05/Capstone-TeamYataki), providing portable access and additional mobile-exclusive features.

---

## **📖 Table of Contents**
- [Overview](#overview)
- [Team Members](#team-members)
- [Advisors](#advisors)
- [Device Description](#device-description)
- [Features](#-features)
- [Tech Stack](#%EF%B8%8F-tech-stack)
- [Project Structure](#-project-structure)
- [Installation Guide](#-installation-guide)
- [Usage Guide](#-usage-guide)
- [Future Improvements](#-future-improvements)
- [Contributing](#-contributing)
- [License](#-license)

---

## **Overview**
The **Capstone Yataki Mobile App** enables users to:
- Monitor telemetry data in real time from sensors and devices.
- Forecast trends such as energy usage or performance using **machine learning**.
- View detailed reports and analytics directly from a mobile device.
- Track **battery health** and system status for preventive maintenance.

> **Goal:**  
> To create a portable and efficient way to access and analyze telemetry data without relying solely on the web application, improving accessibility and field usage.

---

## **Team Members**
| **Name**                 | **Role**            |
|--------------------------|---------------------|
| Hannah Jean Torring       | Team Leader         |
| Keith Zacharrie Espinosa  | Full Stack Developer|
| Kent John Olarana         | System Analyst      |
| Mc Harly Misa             | System Analyst      |

---

## **Advisors**
| **Name**     |
|--------------|
| Niño Abao    |
| Joel Lim     |

---

## **Device Description**
This project integrates with IoT-based sensors to capture telemetry data, including:
- **Steps Count** – Captured via motion sensors.
- **Voltage** – Battery voltage tracking for performance and safety.
- **Current** – Monitoring of energy consumption and load.
- **Battery Health** – Tracks the state of health (SoH) and remaining capacity.

The device communicates with the mobile app via an **API** hosted by the backend server, ensuring data synchronization and secure transmission.

---

## **🚀 Features**

### 🧾 Data Management 
- **Automatic Data Logging** via ESP32.
- Data fields include:
    `Steps`
    `Raw_Voltage`
    `Raw_Current`
    `Battery_Health`

### 📈 Dashboard and Visualization
- **Real-Time Graphs** for:
- Voltage
- Current
- Steps
---

### 📉 Forecasting
- **Predictive Analytics** powered by **Linear Regression**:
- Predict next day’s voltage and current.
- Identify the month with the highest predicted energy usage.
- Background process to **auto-update predictions daily**.
---

### 🔋 Battery Health Monitoring *(Mobile Exclusive Feature)*
- Real-time tracking of **battery health percentage**.
- Alerts when battery performance drops below safe thresholds.
- Extended diagnostic data for long-term battery care.
---

### 💻 Web Application Companion
- For administrative tasks and deeper analytics, check the **Web App repository**:
[Capstone Yataki Web Application](https://github.com/HaiseKen05/Capstone-TeamYataki)
---

## **🛠️ Tech Stack**

| Layer        | Technologies                          |
|--------------|--------------------------------------|
| **Backend**  | Python, Flask, SQLAlchemy, Pandas, scikit-learn |
| **Frontend** | Flutter (Mobile), HTML5, Bootstrap 5, Jinja2, Chart.js |
| **Database** | SQLite (or any SQLAlchemy-compatible database) |
| **Security** | bcrypt, Flask Sessions |

---

## **📂 Project Structure**

capstone_yataki_mobile/

|

├── lib/ # Flutter Source Code

│ ├── screens/ # App screens (Dashboard, Forecast, etc.) 

│ ├── widgets/ # Reusable UI components

│ ├── services/ # API integration logic

│ └── main.dart # Entry point

|

├── assets/ # Images, icons, and static files

├── test/ # Automated tests

├── README.md # Project documentation 

└── pubspec.yaml # Flutter dependencies


---
## **⚙️ Installation Guide**

### **1. Clone the Repository**
```bash
git clone https://github.com/HaiseKen05/capstone_yataki.git
cd capstone_yataki
```

### **2. Install Flutter Dependencies**
```bash
flutter pub get
```

### **3. Configure Backend URL**
- Under .env you should see 
```bash
BASE_URL=http://<<YOUR_SERVER_IP>>:5000/api/v1
HANDSHAKE_URL=http://<<YOUR_SERVER_IP>>:5000/handshake
```
- Under server.config.dart, you should be able to see this as well
```bash
return url ?? "http://<<YOUR SERVER'S IP>>:5000"; // default
```
> Replace <YOUR_SERVER_IP> with the IP address of your Flask backend server.

### **4. Run the App**
```bash
flutter run
```

## 📖 Usage Guide
- Initial Setup

- Power up the IoT device (e.g., ESP32).

- Ensure the device is connected to Wi-Fi and sending data to the backend.
- Using the Mobile App
- Launch the app on your device.
- Log in using your account credentials.
- View the Dashboard for:
- Real-time data visualization
- Summary statistics
- Navigate to the Forecasting tab to check predictions.
- Check Battery Health to monitor performance.
  
---

## 🚧 Future Improvements
- Implementing manual server selection for migration

## 🤝 Contributing

We welcome contributions!
To get started:

-Fork the repository.
-Create a feature branch (git checkout -b feature/YourFeature).
-Commit changes (git commit -m 'Add new feature').
-Push to branch (git push origin feature/YourFeature).
-Submit a Pull Request.

## 📜 License

This project is licensed under the MIT License.
You are free to use, modify, and distribute this project as long as proper credit is given.

This version:
- Is fully markdown-compliant and GitHub-rendering ready.
- Has clean sections with headings, tables, and code blocks.
- Can be **pasted directly** into a `README.md` file without additional formatting.

