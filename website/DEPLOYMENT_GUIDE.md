# 🚀 Battwaa.online – Free Live Hosting & Domain Setup Guide

Yeh complete guide hai ke aap **Battwaa.online** domain par apni landing page aur backend API ko **100% FREE** live kaise host kar sakte hain.

---

## 1. Landing Page Ko Free Live Karna (Vercel / Cloudflare Pages / GitHub Pages)

### Option A: Cloudflare Pages (Recommended - Fastest & Unlimited Free Bandwidth)
1. [dash.cloudflare.com](https://dash.cloudflare.com) par free account banayein.
2. **Workers & Pages** -> **Create Application** -> **Pages** -> **Upload assets**.
3. `website/` folder ko drag & drop kar dein.
4. Project ban jane ke baad **Custom Domains** par click karein aur `Battwaa.online` add karein.
5. Cloudflare automatically SSL certificate (HTTPS) generate kar dega!

### Option B: Vercel (1-Click Deployment)
1. [vercel.com](https://vercel.com) par jayein aur GitHub se connect karein.
2. Repository select karein aur Root Directory `website` set karein.
3. Deploy par click karein.
4. Settings -> **Domains** mein jakar `Battwaa.online` aur `www.battwaa.online` add karein.
5. DNS Records ko apne domain registrar (jahan se domain li hai) mein add karein:
   - `A` Record: `@` -> `76.76.21.21`
   - `CNAME` Record: `www` -> `cname.vercel-dns.com`

---

## 2. Spring Boot + PostgreSQL Backend Ko Free Live Karna

Aapka backend (`backend/target/batwa-wallet-service-1.0.0.jar`) Spring Boot 3 + PostgreSQL par chalta hai. Free hosting ke liye best platforms:

### Option 1: Render.com (Free Tier)
1. [render.com](https://render.com) par free account banayein.
2. **New +** -> **PostgreSQL**: Free database create karein (Database Name, User, Password mil jayega).
3. **New +** -> **Web Service**: GitHub repo connect karein.
   - **Environment:** Java / Docker
   - **Build Command:** `./mvnw clean package -DskipTests` ya Dockerfile use karein.
   - **Environment Variables:**
     - `SPRING_DATASOURCE_URL`: (Render Postgres URL)
     - `SPRING_DATASOURCE_USERNAME`: (Postgres user)
     - `SPRING_DATASOURCE_PASSWORD`: (Postgres password)
     - `JWT_SECRET`: (Aapki secret key)
4. Deploy hone par aapko URL milegi: `https://batwa-backend.onrender.com`.
5. Custom Subdomain: `api.battwaa.online` connect kar sakte hain!

### Option 2: Railway.app / Koyeb (Free Cloud)
- Koyeb aur Railway par bhi 1-click Docker container deploy ho jata hai.

---

## 3. Flutter Mobile App Ko Live Backend Se Connect Karna

Jab aapka backend live ho jaye (`https://api.battwaa.online/api/v1`):
1. `mobile/lib/core/network/api_client.dart` mein `baseUrl` update karein:
   ```dart
   static const String baseUrl = 'https://api.battwaa.online/api/v1';
   ```
2. Release APK build karein:
   ```bash
   flutter build apk --release
   ```
3. Generated APK `mobile/build/app/outputs/flutter-apk/app-release.apk` ko `website/` folder mein `batwa-wallet-v1.0.0.apk` ke naam se rakh dein taake website par download button se directly download ho sake!
