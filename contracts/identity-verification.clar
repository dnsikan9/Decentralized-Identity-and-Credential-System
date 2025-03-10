;; Identity Verification Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-already-verified (err u101))
(define-constant err-not-found (err u102))

;; Data Maps
(define-map verified-identities principal (string-ascii 64))
(define-map authorized-verifiers principal bool)

;; Public Functions
(define-public (verify-identity (user principal) (identity-hash (string-ascii 64)))
  (begin
    (asserts! (is-authorized-verifier tx-sender) err-not-authorized)
    (asserts! (is-none (map-get? verified-identities user)) err-already-verified)
    (ok (map-set verified-identities user identity-hash))))

(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (ok (map-set authorized-verifiers verifier true))))

(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (ok (map-delete authorized-verifiers verifier))))

;; Read-only Functions
(define-read-only (get-identity (user principal))
  (map-get? verified-identities user))

(define-read-only (is-authorized-verifier (verifier principal))
  (default-to false (map-get? authorized-verifiers verifier)))

(define-read-only (is-identity-verified (user principal))
  (is-some (map-get? verified-identities user)))

