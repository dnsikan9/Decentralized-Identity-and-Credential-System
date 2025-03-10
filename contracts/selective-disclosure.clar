;; Selective Disclosure Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-invalid-proof (err u101))

;; Data Maps
(define-map disclosure-permissions
  { holder: principal, viewer: principal, attribute: (string-ascii 64) }
  bool)

;; Public Functions
(define-public (set-disclosure-permission (viewer principal) (attribute (string-ascii 64)) (allowed bool))
  (ok (map-set disclosure-permissions
    { holder: tx-sender, viewer: viewer, attribute: attribute }
    allowed)))

(define-public (create-selective-proof (holder principal) (attribute (string-ascii 64)) (proof-data (string-ascii 256)))
  (begin
    (asserts! (is-allowed-viewer tx-sender holder attribute) err-not-authorized)
    ;; In a real implementation, we would verify the proof cryptographically
    ;; Here, we're just storing the proof data
    (ok proof-data)))

;; Read-only Functions
(define-read-only (is-allowed-viewer (viewer principal) (holder principal) (attribute (string-ascii 64)))
  (default-to false (map-get? disclosure-permissions { holder: holder, viewer: viewer, attribute: attribute })))

(define-read-only (verify-selective-proof (holder principal) (attribute (string-ascii 64)) (proof-data (string-ascii 256)))
  ;; In a real implementation, we would verify the proof cryptographically
  ;; Here, we're just checking if the proof exists
  (is-some (map-get? disclosure-permissions { holder: holder, viewer: tx-sender, attribute: attribute })))

