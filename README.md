 
# Wasselni Admin Dashboard

**A Flutter Web Admin Dashboard for Managing Delivery Operations**

Wasselni Admin is a web-based administration dashboard built with Flutter to manage and monitor the Wasselni delivery platform. It provides administrators with a centralized interface to manage orders, customers, drivers, service areas, pricing, and business reports.

---

## Overview

Wasselni Admin aims to simplify delivery operations by providing administrators with real-time access to platform data and essential management tools.

The dashboard integrates with Firebase to manage authentication and retrieve application data, while Riverpod handles state management and data flow throughout the application.

## Features

### Dashboard
- Overview of platform activities.
- Key business statistics.
- Recent orders monitoring.

### Authentication & Authorization
- Admin login using Firebase Authentication.
- Admin access verification using Firebase Custom Claims.
- Protected dashboard access.
- Secure logout functionality.

### Order Management
- View and monitor customer orders.
- Access detailed order information.
- Track order statuses and delivery progress.

### Driver Management
- View registered drivers.
- Monitor driver approval and activation status.
- Approve drivers.
- Activate and deactivate drivers.
- View driver-related information.

### Customer Management
- View registered customers.
- Search and filter customers.
- Access customer profiles.
- View customer order history.
- Monitor customer order statistics.

### Reports & Analytics
- Monitor total orders.
- Track completed and cancelled orders.
- Calculate delivery revenue.
- Visualize order statistics using charts.
- Filter reports by time period.

### Pricing & Service Areas
- Manage available service cities and areas.
- Add, edit, and delete service areas.
- Activate and deactivate service areas.
- Configure delivery pricing:
  - Base Price.
  - Price Per Kilometer.
  - Minimum Delivery Price.
- Store and retrieve pricing configurations through Firestore.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Web application development |
| Dart | Programming language |
| Riverpod | State management |
| Firebase Authentication | Admin authentication |
| Cloud Firestore | Database and real-time data |
| fl_chart | Data visualization |
| Material Design | User interface components |
| Git & GitHub | Version control |

---

### Architecture Principles
- Feature-based project organization.
- Repository Pattern for separating data access from presentation.
- Riverpod for reactive state management.
- Reusable UI components.
- Separation of business logic and UI.

---

## Firebase Integration

The application uses Firebase services for backend integration.

**Firebase Authentication**
- Handles administrator sign-in and sign-out.
- Uses Firebase Custom Claims to identify authorized administrators.

**Cloud Firestore**
- Stores and retrieves application data.
- Provides real-time streams for supported dashboard sections.
- Stores pricing settings and service area configurations.

---

## Security

The dashboard uses Firebase Authentication and Firebase Custom Claims for administrator authorization.

Firestore Security Rules are used to control access to application data.


---

## Future Improvements

- Driver performance analytics.
- Advanced order filtering and search.
- Export reports to PDF and Excel.
- More detailed revenue analytics.
- Interactive delivery area management.
- Real-time notifications for administrative events.
- Improved dashboard analytics and visualizations.

---

## Project Status

**Active Development**

Wasselni Admin is part of the Wasselni delivery platform ecosystem and is being developed to support centralized management of delivery operations.

