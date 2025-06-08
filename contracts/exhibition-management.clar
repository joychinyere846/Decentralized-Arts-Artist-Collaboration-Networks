;; Exhibition Management Contract
;; Manages art exhibitions and events

(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_EXHIBITION_NOT_FOUND (err u401))
(define-constant ERR_ARTWORK_EXISTS (err u402))
(define-constant ERR_EXHIBITION_CLOSED (err u403))

;; Exhibition counter
(define-data-var exhibition-counter uint u0)

;; Exhibition data structure
(define-map exhibitions
  { exhibition-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    curator: principal,
    venue: (string-ascii 100),
    start-date: uint,
    end-date: uint,
    status: (string-ascii 20),
    entry-fee: uint
  }
)

;; Exhibition artworks
(define-map exhibition-artworks
  { exhibition-id: uint, artwork-id: (string-ascii 50) }
  {
    artist: principal,
    title: (string-ascii 100),
    medium: (string-ascii 50),
    price: uint,
    available: bool
  }
)

;; Visitor registrations
(define-map visitor-registrations
  { exhibition-id: uint, visitor: principal }
  {
    registered-at: uint,
    fee-paid: uint
  }
)

;; Create exhibition
(define-public (create-exhibition
  (title (string-ascii 100))
  (description (string-ascii 500))
  (venue (string-ascii 100))
  (start-date uint)
  (end-date uint)
  (entry-fee uint))
  (let ((exhibition-id (+ (var-get exhibition-counter) u1)))
    (var-set exhibition-counter exhibition-id)
    (map-set exhibitions
      { exhibition-id: exhibition-id }
      {
        title: title,
        description: description,
        curator: tx-sender,
        venue: venue,
        start-date: start-date,
        end-date: end-date,
        status: "upcoming",
        entry-fee: entry-fee
      }
    )
    (ok exhibition-id)
  )
)

;; Add artwork to exhibition
(define-public (add-artwork
  (exhibition-id uint)
  (artwork-id (string-ascii 50))
  (title (string-ascii 100))
  (medium (string-ascii 50))
  (price uint))
  (let ((exhibition-data (unwrap! (map-get? exhibitions { exhibition-id: exhibition-id }) ERR_EXHIBITION_NOT_FOUND)))
    (asserts! (is-none (map-get? exhibition-artworks { exhibition-id: exhibition-id, artwork-id: artwork-id })) ERR_ARTWORK_EXISTS)
    (map-set exhibition-artworks
      { exhibition-id: exhibition-id, artwork-id: artwork-id }
      {
        artist: tx-sender,
        title: title,
        medium: medium,
        price: price,
        available: true
      }
    )
    (ok true)
  )
)

;; Register for exhibition
(define-public (register-visitor (exhibition-id uint))
  (let (
    (exhibition-data (unwrap! (map-get? exhibitions { exhibition-id: exhibition-id }) ERR_EXHIBITION_NOT_FOUND))
    (entry-fee (get entry-fee exhibition-data))
  )
    (map-set visitor-registrations
      { exhibition-id: exhibition-id, visitor: tx-sender }
      {
        registered-at: block-height,
        fee-paid: entry-fee
      }
    )
    (ok entry-fee)
  )
)

;; Open exhibition (curator only)
(define-public (open-exhibition (exhibition-id uint))
  (let ((exhibition-data (unwrap! (map-get? exhibitions { exhibition-id: exhibition-id }) ERR_EXHIBITION_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get curator exhibition-data)) ERR_UNAUTHORIZED)
    (map-set exhibitions
      { exhibition-id: exhibition-id }
      (merge exhibition-data { status: "open" })
    )
    (ok true)
  )
)

;; Get exhibition info
(define-read-only (get-exhibition (exhibition-id uint))
  (map-get? exhibitions { exhibition-id: exhibition-id })
)

;; Get artwork info
(define-read-only (get-artwork (exhibition-id uint) (artwork-id (string-ascii 50)))
  (map-get? exhibition-artworks { exhibition-id: exhibition-id, artwork-id: artwork-id })
)
