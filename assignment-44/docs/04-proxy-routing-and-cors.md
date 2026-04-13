# Proxy Routing & CORS

## Nginx Routing
- All traffic (/) → proxied to http://app:8080
- /health → returns 200 "healthy" (no proxy, direct)

## Proxy Headers Set
- Host: preserves original host header
- X-Real-IP: passes client IP to app
- X-Forwarded-For: full proxy chain IP
- Upgrade/Connection: supports WebSocket if needed

## Security Headers
- X-Frame-Options: SAMEORIGIN (prevents clickjacking)
- X-Content-Type-Options: nosniff (prevents MIME sniffing)
- X-XSS-Protection: 1; mode=block (XSS filter)

## CORS
The EpicBook is a server-side rendered app (Handlebars).
All HTML, CSS, JS and API calls originate from the same
origin — no cross-origin requests are made. CORS is
therefore not required for this application architecture.
If the frontend were decoupled (React SPA), CORS headers
would be added to the app service:
Access-Control-Allow-Origin: http://<VM_PUBLIC_IP>
