;; Revocation Registry Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-already-revoked (err u101))
(define-constant err-not-found (err u102))

;; Data Maps
(define-map revoked-credentials
  { id: uint, holder: principal }
  { revoker: principal, reason: (string-ascii 256) })
(define-map authorized-revokers principal bool)

;; Public Functions
(define-public (revoke-credential (id uint) (holder principal) (reason (string-ascii 256)))
  (begin
    (asserts! (is-authorized-revoker tx-sender) err-not-authorized)
    (asserts! (is-none (map-get? revoked-credentials { id: id, holder: holder })) err-already-revoked)
    (ok (map-set revoked-credentials
      { id: id, holder: holder }
      { revoker: tx-sender, reason: reason }))))

(define-public (add-revoker (revoker principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (ok (map-set authorized-revokers revoker true))))

(define-public (remove-revoker (revoker principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (ok (map-delete authorized-revokers revoker))))

;; Read-only Functions
(define-read-only (is-credential-revoked (id uint) (holder principal))
  (is-some (map-get? revoked-credentials { id: id, holder: holder })))

(define-read-only (get-revocation-info (id uint) (holder principal))
  (map-get? revoked-credentials { id: id, holder: holder }))

(define-read-only (is-authorized-revoker (revoker principal))
  (default-to false (map-get? authorized-revokers revoker)))

