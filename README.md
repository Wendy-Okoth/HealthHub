# HealthHub  
Your Personal Wellness Companion

HealthHub is a holistic health and wellness platform designed to empower individuals to track, improve, and celebrate their well-being. Inspired by the need for inclusive, accessible health tools in Kenya and beyond, HealthHub brings together essential trackers, tips, and support into one mobile-first experience.

From sleep and hydration to menstrual cycles and mental check-ins, HealthHub is built for real people with real goals. Whether you're a student, professional, or caregiver, HealthHub helps you stay on top of your health journey—one tap at a time.

## Features

HealthHub supports both smartphones and desktops, offering a responsive and intuitive interface. The platform enables:

- Users to track steps, sleep, hydration, calories, and menstrual cycles  
- Daily check-ins to monitor mood and wellness goals  
- Access to curated wellness tips and reminders  
- Nearby clinic locator using map integration  
- Profile setup with gender, birthday, and wellness goals  
- Theme toggle for light, dark, and system modes  

## Technology Stack

| Layer       | Technologies                                                                 |
|-------------|-------------------------------------------------------------------------------|
| Frontend    | Flutter (mobile-first responsive design)                                     |
| Backend     | Supabase (authentication, database, storage)                                 |
| Database    | Supabase PostgreSQL                                                          |
| APIs        | Google Maps (location)                                                       |
| Deployment  |  Firebase Hosting (optional)                                                 |

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Wendy-Okoth/HealthHub.git
cd healthhub_app
```
### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Set up Supabase environment variables

```bash
Supabase.initialize(
  url: 'your-supabase-url',
  anonKey: 'your-anon-key',
);
```
### 4. Run the app
```bash
flutter run
```

## Future Advancements
- Push notifications for reminders and check-ins
- Cycle prediction and symptom logging for period tracker
- Sleep quality analysis and weekly health summaries
- Integration with wearable devices (e.g., step counters, sleep monitors)
- Nutrition database for Kenyan foods with portion accuracy
- Offline mode and data sync for low-connectivity regions
- Community support features and peer counseling integration

## Contributing
HealthHub is built with a mission to promote inclusive, data-driven wellness. Contributions are welcome from developers, designers, health professionals, and advocates passionate about digital health.

## License
This project is licensed under the MIT License.
