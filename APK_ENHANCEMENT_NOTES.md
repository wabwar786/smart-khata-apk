# Smart Khata APK Enhancement Notes

Implemented in version 2.1.0+6:

- Professional purple/green theme inspired by Udhaar Book reference screenshots.
- New generated app icon asset and launcher icon workflow.
- Professional splash screen with 100% Free, Safe & Secure, Database Security First, and Powered by Wabwar Software House.
- First-time onboarding screens for Customers, Suppliers, Inventory, POS Invoice, and Online Shop.
- WhatsApp OTP login UI; APK calls backend OTP endpoints and does not store WhatsApp engine API key.
- Home dashboard with three tabs: Customers, Suppliers, Inventory.
- Customer add flow with contacts import and manual form.
- Supplier add flow with contacts import and manual form.
- After add customer/supplier, action screen asks what to do next.
- Fast POS screen with open-item calculator, inventory item sale, discount, payment mode, receipt/invoice preview.
- Inventory screen with stock value, low stock/reorder list, create item, stock in/out.
- Bottom navigation: Home, POS/Sale, Inventory, Your Shop.
- Your Shop module: shop profile, shop code, orders list, accept/reject/complete statuses.
- Android workflow adds INTERNET and READ_CONTACTS permissions.

Backend endpoints required for full functionality are included in the paired API package:

- POST /api/auth/request-otp
- POST /api/auth/verify-otp
- POST /api/pos/sale
- GET/POST /api/shop/profile
- GET /api/shop/orders
- PATCH /api/shop/orders/:publicId/status
- GET /api/shop/public/:shopCode
- POST /api/shop/public/:shopCode/orders
