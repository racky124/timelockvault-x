(define-trait sip010-ft-standard
  (
    (transfer (uint principal principal) (response bool uint))
    (get-balance (principal) (response uint uint))
    (get-decimals () (response uint uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-name () (response (string-ascii 32) uint))
    (get-total-supply () (response uint uint))
  )
)

(define-map locks
  { user: principal, token: (optional principal) }
  { amount: uint, unlock-height: uint }
)

(define-constant ERR_LOCK_EXISTS u100)
(define-constant ERR_NO_LOCK u101)
(define-constant ERR_NOT_UNLOCKED u102)
(define-constant ERR_TRANSFER_FAILED u103)

;; Lock STX tokens
(define-public (lock-stx (amount uint) (duration uint))
  (begin
    (asserts! (is-none (map-get? locks { user: tx-sender, token: none })) (err ERR_LOCK_EXISTS))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set locks { user: tx-sender, token: none }
      { amount: amount, unlock-height: (+ stacks-block-height duration) }
    )
    (ok true)
  )
)

;; Withdraw STX after time lock
(define-public (withdraw-stx)
  (let
    (
      (lock (map-get? locks { user: tx-sender, token: none }))
    )
    (match lock l
      (begin
        (asserts! (>= stacks-block-height (get unlock-height l)) (err ERR_NOT_UNLOCKED))
        (try! (stx-transfer? (get amount l) (as-contract tx-sender) tx-sender))
        (map-delete locks { user: tx-sender, token: none })
        (ok true)
      )
      (err ERR_NO_LOCK)
    )
  )
)

;; Lock SIP-010 token
(define-public (lock-token (token <sip010-ft-standard>) (amount uint) (duration uint))
  (let
    (
      (token-contract (contract-of token))
    )
    (begin
      (asserts! (is-none (map-get? locks { user: tx-sender, token: (some (contract-of token)) })) (err ERR_LOCK_EXISTS))
      (try! (contract-call? token transfer amount tx-sender (as-contract tx-sender)))
      (map-set locks { user: tx-sender, token: (some token-contract) }
        { amount: amount, unlock-height: (+ stacks-block-height duration) }
      )
      (ok true)
    )
  )
)

;; Withdraw SIP-010 token
(define-public (withdraw-token (token <sip010-ft-standard>))
  (let
    (
      (token-contract (contract-of token))
      (lock (map-get? locks { user: tx-sender, token: (some token-contract) }))
    )
    (match lock l
      (begin
        (asserts! (>= stacks-block-height (get unlock-height l)) (err ERR_NOT_UNLOCKED))
        (try! (contract-call? token transfer (get amount l) (as-contract tx-sender) tx-sender))
        (map-delete locks { user: tx-sender, token: (some token-contract) })
        (ok true)
      )
      (err ERR_NO_LOCK)
    )
  )
)
