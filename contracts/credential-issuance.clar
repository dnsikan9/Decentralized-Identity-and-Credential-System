;; Credential Issuance Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-already-issued (err u101))
(define-constant err-not-found (err u102))

;; Data Maps
(define-map credentials
  { id: uint, holder: principal }
  { issuer: principal, type: (string-ascii 64), metadata: (string-ascii 256) })
(define-map authorized-issuers principal bool)

;; Variables
(define-data-var credential-id-nonce uint u0)

;; Public Functions
(define-public (issue-credential (holder principal) (type (string-ascii 64)) (metadata (string-ascii 256)))
  (let ((new-id (+ (var-get credential-id-nonce) u1)))
    (asserts! (is-authorized-issuer tx-sender) err-not-authorized)
    (asserts! (is-none (map-get? credentials { id: new-id, holder: holder })) err-already-issued)
    (map-set credentials
      { id: new-id, holder: holder }
      { issuer: tx-sender, type: type, metadata: metadata })
    (var-set credential-id-nonce new-id)
    (ok new-id)))

(define-public (add-issuer (issuer principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (ok (map-set authorized-issuers issuer true))))

(define-public (remove-issuer (issuer principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (ok (map-delete authorized-issuers issuer))))

;; Read-only Functions
(define-read-only (get-credential (id uint) (holder principal))
  (map-get? credentials { id: id, holder: holder }))

(define-read-only (is-authorized-issuer (issuer principal))
  (default-to false (map-get? authorized-issuers issuer)))

