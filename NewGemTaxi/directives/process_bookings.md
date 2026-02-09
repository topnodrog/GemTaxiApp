# Directive: Processing Taxi Bookings

Goal: Convert raw booking emails into structured data for invoicing and driver deployment.

## Inputs
- Raw email text (Subject and Body)

## Tools
- `execution/extract_email_data.py`: Parses the raw text.
- `execution/update_invoice_sheet.py`: Appends data to Google Sheets.
- `execution/generate_driver_msg.py`: Formats the WhatsApp message.

## Parsing Logic
1. **Subject Line**: Extract the Job ID (e.g., "2104").
2. **Body Text**:
    - Identify "Joining Crew" (Pickups) and "Departing Crew" (Drop-offs).
    - Handle "Wait and Return" logic: If the text mentions waiting for a return trip, link the joining crew drop-off to the departing crew pickup.
    - Extract Passenger Name, Phone, Flight/Time, and Locations.
3. **Wait Logic**: If the email states "After dropping [A], please wait to pick-up [B]", mark the job as a "Wait for Return" status.

## Outputs
- Updated Google Sheet row.
- Formatted WhatsApp message string.

## Edge Cases
- Missing phone numbers: Use "N/A".
- Multiple legs: Ensure each leg is captured as a distinct part of the route.
- No Job ID: Generate a placeholder ID based on the timestamp.
