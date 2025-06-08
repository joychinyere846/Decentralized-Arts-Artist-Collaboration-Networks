;; Artist Verification Contract
;; Validates and manages professional artist credentials

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ARTIST_EXISTS (err u101))
(define-constant ERR_ARTIST_NOT_FOUND (err u102))
(define-constant ERR_INVALID_VERIFICATION (err u103))

;; Artist data structure
(define-map artists
  { artist-address: principal }
  {
    name: (string-ascii 50),
    specialty: (string-ascii 30),
    verified: bool,
    verification-date: uint,
    portfolio-hash: (string-ascii 64)
  }
)

;; Verification requests
(define-map verification-requests
  { artist-address: principal }
  {
    requested-at: uint,
    documents-hash: (string-ascii 64),
    status: (string-ascii 20)
  }
)

;; Register as an artist
(define-public (register-artist (name (string-ascii 50)) (specialty (string-ascii 30)) (portfolio-hash (string-ascii 64)))
  (let ((artist-address tx-sender))
    (asserts! (is-none (map-get? artists { artist-address: artist-address })) ERR_ARTIST_EXISTS)
    (map-set artists
      { artist-address: artist-address }
      {
        name: name,
        specialty: specialty,
        verified: false,
        verification-date: u0,
        portfolio-hash: portfolio-hash
      }
    )
    (ok true)
  )
)

;; Request verification
(define-public (request-verification (documents-hash (string-ascii 64)))
  (let ((artist-address tx-sender))
    (asserts! (is-some (map-get? artists { artist-address: artist-address })) ERR_ARTIST_NOT_FOUND)
    (map-set verification-requests
      { artist-address: artist-address }
      {
        requested-at: block-height,
        documents-hash: documents-hash,
        status: "pending"
      }
    )
    (ok true)
  )
)

;; Verify artist (only contract owner)
(define-public (verify-artist (artist-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? artists { artist-address: artist-address })) ERR_ARTIST_NOT_FOUND)
    (map-set artists
      { artist-address: artist-address }
      (merge (unwrap-panic (map-get? artists { artist-address: artist-address }))
        { verified: true, verification-date: block-height }
      )
    )
    (map-set verification-requests
      { artist-address: artist-address }
      (merge (unwrap-panic (map-get? verification-requests { artist-address: artist-address }))
        { status: "approved" }
      )
    )
    (ok true)
  )
)

;; Get artist info
(define-read-only (get-artist (artist-address principal))
  (map-get? artists { artist-address: artist-address })
)

;; Check if artist is verified
(define-read-only (is-verified-artist (artist-address principal))
  (match (map-get? artists { artist-address: artist-address })
    artist-data (get verified artist-data)
    false
  )
)
