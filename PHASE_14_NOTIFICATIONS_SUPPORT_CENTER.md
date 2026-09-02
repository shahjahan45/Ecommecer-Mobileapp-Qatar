# Phase 14 — Notifications, Order Updates & Customer Support Center

Version: `1.14.0+44`

## Delivered
- Central `NotificationController` with unread/read lifecycle.
- Dynamic unread badge on Home and Account.
- Notification filters for Orders, Payments, Offers, and Account.
- Mark-all-read and swipe-to-dismiss behavior.
- Deep-link style navigation from order notifications into Order Details.
- Notification preference screen prepared for later push/email/backend mapping.
- Successful checkout automatically creates an unread order confirmation notification.
- Professional Help & Support center with support channels, FAQs, active request cards, and new request form.
- Local `SupportController` / `SupportTicket` architecture ready for a backend support-ticket API.
- Responsive and accessibility-oriented stable keys/semantics.

## Backend boundary
Notifications and support requests are local/demo state in this Flutter phase. A future Laravel/API phase should become the source of truth and provide push tokens, server-side notification delivery, ticket persistence, agent replies, attachment upload, and SLA/status synchronization.
