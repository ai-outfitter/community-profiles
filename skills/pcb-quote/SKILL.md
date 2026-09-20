---
name: pcb-quote
description: Upload an exact PCB package for supplier matching and record a complete, non-purchasing landed-cost quote without exposing credentials or delivery-address details.
---

# PCB quote

Turn a reviewed fabrication package into a supplier-accepted quote. This gate
proves upload, part matching, availability, assembly pricing, and landed cost;
it does not authorize manufacture or purchase.

## Procedure

1. Verify the package manifest and checksums immediately before upload. Record
   the source revision, board revision, Gerber archive checksum, BOM checksum,
   placement-file checksum, PCB quantity, and assembly quantity.
2. Use a dedicated browser session and an authenticated supplier account. Keep
   credentials, cookies, complete addresses, and payment data out of logs,
   screenshots, artifacts, and Git. A human may complete authentication.
3. Upload the exact Gerber archive. Require the detected layer count, board
   dimensions, and rendered outline to agree with the reviewed design.
4. Enable assembly and upload the complete populated BOM and placement file.
   Reconcile every fitted designator between the manifest, BOM, placement data,
   and supplier match result. Stop for any missing or unmatched designator,
   unavailable part, unapproved substitution, quantity mismatch, or placement
   error. DNP and separately installed parts must be explicitly declared.
5. Select the declared fabrication and assembly options. Continue through the
   shipping-cost stage using the approved destination country and postal
   region, but do not confirm checkout, submit payment, or place an order.
6. Record a machine-readable `supplier-quote.json` with:

   - supplier, quote identifier, quote time and expiry, currency, quantities,
     destination country/postal region, shipping method, and Incoterm;
   - matched BOM and placement counts plus every approved substitution;
   - separate amounts for PCB fabrication, components, assembly, setup/tooling,
     shipping, tariff/duty, tax, discounts, and other fees;
   - a status and evidence reference for every cost category, and a reconciled
     landed total.

   Use `0` only when the supplier explicitly quotes zero. A category may be
   `included` only when the supplier and Incoterm identify which quoted line
   contains it. `unknown`, blank, estimated-only, or not-yet-calculated costs
   make the quote incomplete.
7. Capture redacted supplier evidence for board preview, part matching, and the
   final cost breakdown. Recheck that screenshots contain no credentials,
   payment data, or complete delivery address before saving them.

## Verdict

Return `quote-complete` only when all designators match, all required parts are
available, every cost category is quoted as an amount or explicitly included,
and the line items reconcile to the landed total. Otherwise return
`quote-incomplete` with the exact missing evidence. Never describe a bare-board
price as a PCBA or landed-cost quote.

## Purchasing boundary

Stop before the action that confirms checkout, payment, or manufacture. An
accountable human must separately approve the supplier, exact revision,
quantity, substitutions, landed total, and destination before an order may be
submitted.
