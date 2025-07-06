# EcoWear

**EcoWear** is a decentralized network for fashion designers and sustainable brands to showcase their eco-friendly collections, certifications, and practices. Built with Clarity smart contracts, it enables transparency, trust, and collaboration in the sustainable fashion industry.

---

## 🌿 Overview

EcoWear provides:
- Designer profiles with privacy controls
- Sustainable collection uploads with material details and optional sustainability scoring
- Eco-certification records verified by the platform
- Endorsements of sustainable practices by peers
- A fashion network for connections and verified collaborations

---

## 🔐 Features

### 🎨 Designer Profiles
- Name, bio, brand focus
- Privacy level: Public, Network-only, or Private
- Profile verification by platform admin

### 🧵 Sustainable Collections
- Track collection name, materials used, launch date, and optional sustainability score
- Privacy-controlled visibility

### ✅ Eco Certifications
- Add certifications issued by recognized organizations
- Optionally set expiry dates and verification status

### 🤝 Sustainability Endorsements
- Designers can endorse sustainable practices of others
- Includes messages and public/private visibility

### 🔗 Fashion Network
- Connect with other verified designers
- Invite, accept, and maintain network relationships

---

## 🛡️ Access Control

EcoWear enforces strict access rules using privacy levels:
- `Public`: Viewable by anyone
- `Network`: Viewable only by connected designers
- `Private`: Viewable only by the owner

---

## 🧩 Smart Contract Components

| Component                   | Description                                        |
|----------------------------|----------------------------------------------------|
| `designer-profiles`        | Stores designer information                        |
| `sustainable-collections`  | Tracks eco-friendly fashion lines                  |
| `eco-certifications`       | Manages certification records                      |
| `sustainability-endorsements` | Allows peer endorsements of practices         |
| `fashion-connections`      | Designer-to-designer networking                    |

---

## ⚙️ Admin Capabilities

- `verify-designer-profile`: Admin verifies designer identities
- `verify-eco-certification`: Admin verifies external eco-certifications
- `set-contract-owner`: Transfer platform ownership to a new principal

---

## 📜 Error Codes

| Code           | Meaning                        |
|----------------|--------------------------------|
| `u100`         | Not authorized                 |
| `u101`         | Designer not found             |
| `u102`         | Practice already endorsed      |
| `u103`         | Invalid privacy level          |
| `u104`         | Certification not found        |

---

## 🚀 Getting Started

1. **Deploy** the Clarity contract to the Stacks blockchain.
2. **Register** your designer profile using `create-designer-profile`.
3. **Add** sustainable collections or certifications.
4. **Connect** with other designers to grow your eco-network.
