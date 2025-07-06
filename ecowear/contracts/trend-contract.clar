;; Sustainable Fashion Network Contract
;; A platform for fashion designers and sustainable brands to showcase eco-friendly practices and certifications

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-DESIGNER-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-ENDORSED (err u102))
(define-constant ERR-INVALID-PRIVACY-LEVEL (err u103))
(define-constant ERR-CERTIFICATION-NOT-FOUND (err u104))

;; Privacy levels
(define-constant PRIVACY-PUBLIC u0)
(define-constant PRIVACY-FASHION-NETWORK u1)
(define-constant PRIVACY-PRIVATE u2)

;; Data structures
(define-map designer-profiles
  principal
  {
    designer-name: (string-ascii 50),
    bio: (string-ascii 500),
    brand-focus: (string-ascii 200),
    privacy-level: uint,
    joined-at: uint,
    is-verified: bool
  })

(define-map sustainable-collections
  { designer: principal, collection-id: uint }
  {
    collection-name: (string-ascii 100),
    materials-used: (string-ascii 100),
    launch-date: uint,
    sustainability-score: (optional uint),
    collection-description: (string-ascii 500),
    privacy-level: uint
  })

(define-map eco-certifications
  { designer: principal, certification-id: uint }
  {
    certification-name: (string-ascii 100),
    certifying-org: (string-ascii 100),
    issue-date: uint,
    expiry-date: (optional uint),
    certification-url: (string-ascii 200),
    privacy-level: uint,
    is-verified: bool
  })

(define-map sustainability-endorsements
  { endorser: principal, endorsee: principal, practice: (string-ascii 50) }
  {
    endorsement-message: (string-ascii 200),
    timestamp: uint,
    is-public: bool
  })

(define-map fashion-connections
  { designer1: principal, designer2: principal }
  {
    status: (string-ascii 20), ;; "pending", "accepted", "blocked"
    initiated-by: principal,
    timestamp: uint
  })

;; Counters for unique IDs
(define-data-var collection-id-counter uint u0)
(define-data-var certification-id-counter uint u0)

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Designer profile management functions
(define-public (create-designer-profile (designer-name (string-ascii 50)) (bio (string-ascii 500)) (brand-focus (string-ascii 200)) (privacy-level uint))
  (begin
    (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
    (ok (map-set designer-profiles tx-sender {
      designer-name: designer-name,
      bio: bio,
      brand-focus: brand-focus,
      privacy-level: privacy-level,
      joined-at: block-height,
      is-verified: false
    }))))

(define-public (update-designer-profile (designer-name (string-ascii 50)) (bio (string-ascii 500)) (brand-focus (string-ascii 200)) (privacy-level uint))
  (begin
    (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
    (asserts! (is-some (map-get? designer-profiles tx-sender)) ERR-DESIGNER-NOT-FOUND)
    (ok (map-set designer-profiles tx-sender {
      designer-name: designer-name,
      bio: bio,
      brand-focus: brand-focus,
      privacy-level: privacy-level,
      joined-at: (default-to block-height (get joined-at (map-get? designer-profiles tx-sender))),
      is-verified: (default-to false (get is-verified (map-get? designer-profiles tx-sender)))
    }))))

;; Sustainable collection functions
(define-public (add-sustainable-collection (collection-name (string-ascii 100)) (materials-used (string-ascii 100)) (launch-date uint) (sustainability-score (optional uint)) (collection-description (string-ascii 500)) (privacy-level uint))
  (let ((collection-id (+ (var-get collection-id-counter) u1)))
    (begin
      (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
      (asserts! (is-some (map-get? designer-profiles tx-sender)) ERR-DESIGNER-NOT-FOUND)
      (var-set collection-id-counter collection-id)
      (ok (map-set sustainable-collections { designer: tx-sender, collection-id: collection-id } {
        collection-name: collection-name,
        materials-used: materials-used,
        launch-date: launch-date,
        sustainability-score: sustainability-score,
        collection-description: collection-description,
        privacy-level: privacy-level
      })))))

;; Eco certification functions
(define-public (add-eco-certification (certification-name (string-ascii 100)) (certifying-org (string-ascii 100)) (issue-date uint) (expiry-date (optional uint)) (certification-url (string-ascii 200)) (privacy-level uint))
  (let ((certification-id (+ (var-get certification-id-counter) u1)))
    (begin
      (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
      (asserts! (is-some (map-get? designer-profiles tx-sender)) ERR-DESIGNER-NOT-FOUND)
      (var-set certification-id-counter certification-id)
      (ok (map-set eco-certifications { designer: tx-sender, certification-id: certification-id } {
        certification-name: certification-name,
        certifying-org: certifying-org,
        issue-date: issue-date,
        expiry-date: expiry-date,
        certification-url: certification-url,
        privacy-level: privacy-level,
        is-verified: false
      })))))

(define-public (verify-eco-certification (designer principal) (certification-id uint))
  (let ((certification (map-get? eco-certifications { designer: designer, certification-id: certification-id })))
    (begin
      (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
      (asserts! (is-some certification) ERR-CERTIFICATION-NOT-FOUND)
      (ok (map-set eco-certifications { designer: designer, certification-id: certification-id }
        (merge (unwrap-panic certification) { is-verified: true }))))))

;; Sustainability endorsement functions
(define-public (endorse-sustainability-practice (endorsee principal) (practice (string-ascii 50)) (endorsement-message (string-ascii 200)) (is-public bool))
  (begin
    (asserts! (is-some (map-get? designer-profiles tx-sender)) ERR-DESIGNER-NOT-FOUND)
    (asserts! (is-some (map-get? designer-profiles endorsee)) ERR-DESIGNER-NOT-FOUND)
    (asserts! (is-none (map-get? sustainability-endorsements { endorser: tx-sender, endorsee: endorsee, practice: practice })) ERR-ALREADY-ENDORSED)
    (ok (map-set sustainability-endorsements { endorser: tx-sender, endorsee: endorsee, practice: practice } {
      endorsement-message: endorsement-message,
      timestamp: block-height,
      is-public: is-public
    }))))

;; Fashion connection functions
(define-public (send-fashion-network-invite (to-designer principal))
  (begin
    (asserts! (is-some (map-get? designer-profiles tx-sender)) ERR-DESIGNER-NOT-FOUND)
    (asserts! (is-some (map-get? designer-profiles to-designer)) ERR-DESIGNER-NOT-FOUND)
    (ok (map-set fashion-connections { designer1: tx-sender, designer2: to-designer } {
      status: "pending",
      initiated-by: tx-sender,
      timestamp: block-height
    }))))

(define-public (accept-fashion-network-invite (from-designer principal))
  (let ((connection (map-get? fashion-connections { designer1: from-designer, designer2: tx-sender })))
    (begin
      (asserts! (is-some connection) ERR-DESIGNER-NOT-FOUND)
      (asserts! (is-eq (get status (unwrap-panic connection)) "pending") ERR-NOT-AUTHORIZED)
      (ok (map-set fashion-connections { designer1: from-designer, designer2: tx-sender }
        (merge (unwrap-panic connection) { status: "accepted" }))))))

;; Read-only functions with privacy controls
(define-read-only (get-designer-profile (designer principal))
  (let ((profile (map-get? designer-profiles designer)))
    (if (is-some profile)
      (let ((profile-data (unwrap-panic profile)))
        (if (or (is-eq (get privacy-level profile-data) PRIVACY-PUBLIC)
                (is-eq designer tx-sender)
                (is-fashion-connected designer tx-sender))
          profile
          none))
      none)))

(define-read-only (get-sustainable-collection (designer principal) (collection-id uint))
  (let ((collection (map-get? sustainable-collections { designer: designer, collection-id: collection-id })))
    (if (is-some collection)
      (let ((collection-data (unwrap-panic collection)))
        (if (can-view-fashion-data designer (get privacy-level collection-data))
          collection
          none))
      none)))

(define-read-only (get-eco-certification (designer principal) (certification-id uint))
  (let ((certification (map-get? eco-certifications { designer: designer, certification-id: certification-id })))
    (if (is-some certification)
      (let ((certification-data (unwrap-panic certification)))
        (if (can-view-fashion-data designer (get privacy-level certification-data))
          certification
          none))
      none)))

(define-read-only (get-sustainability-endorsement (endorser principal) (endorsee principal) (practice (string-ascii 50)))
  (let ((endorsement (map-get? sustainability-endorsements { endorser: endorser, endorsee: endorsee, practice: practice })))
    (if (is-some endorsement)
      (let ((endorsement-data (unwrap-panic endorsement)))
        (if (or (get is-public endorsement-data)
                (is-eq endorsee tx-sender)
                (is-fashion-connected endorsee tx-sender))
          endorsement
          none))
      none)))

;; Helper functions
(define-read-only (is-fashion-connected (designer1 principal) (designer2 principal))
  (or (is-eq (get status (default-to { status: "none", initiated-by: designer1, timestamp: u0 } 
                          (map-get? fashion-connections { designer1: designer1, designer2: designer2 }))) "accepted")
      (is-eq (get status (default-to { status: "none", initiated-by: designer2, timestamp: u0 } 
                          (map-get? fashion-connections { designer1: designer2, designer2: designer1 }))) "accepted")))

(define-read-only (can-view-fashion-data (data-owner principal) (privacy-level uint))
  (or (is-eq privacy-level PRIVACY-PUBLIC)
      (is-eq data-owner tx-sender)
      (and (is-eq privacy-level PRIVACY-FASHION-NETWORK) (is-fashion-connected data-owner tx-sender))))

;; Admin functions
(define-public (verify-designer-profile (designer principal))
  (let ((profile (map-get? designer-profiles designer)))
    (begin
      (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
      (asserts! (is-some profile) ERR-DESIGNER-NOT-FOUND)
      (ok (map-set designer-profiles designer
        (merge (unwrap-panic profile) { is-verified: true }))))))

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner new-owner))))