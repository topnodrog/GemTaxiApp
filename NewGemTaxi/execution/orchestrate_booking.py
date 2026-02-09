import subprocess
import json
import os
import sys

# Enforce UTF-8 for Windows terminal support with emojis
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

def orchestrate(email_file_path):
    print(f"--- Starting Orchestration for: {email_file_path} ---")
    
    # 1. Extraction
    print("Step 1: Extracting data from email...")
    try:
        extract_proc = subprocess.run(
            [sys.executable, "NewGemTaxi/execution/extract_email_data.py", email_file_path],
            capture_output=True,
            text=True,
            check=True,
            encoding='utf-8'
        )
        extracted_data = json.loads(extract_proc.stdout)
    except Exception as e:
        print(f"Error during extraction: {e}")
        return

    # 2. Update Invoice Sheet (Stubbed)
    print("Step 2: Updating invoice sheet...")
    try:
        # Create a temp file for the JSON data to pass to the next script
        temp_json = "NewGemTaxi/.tmp/current_booking.json"
        os.makedirs(os.path.dirname(temp_json), exist_ok=True)
        with open(temp_json, 'w', encoding='utf-8') as f:
            json.dump(extracted_data, f)
            
        subprocess.run(
            [sys.executable, "NewGemTaxi/execution/update_invoice_sheet.py", temp_json],
            check=True,
            encoding='utf-8'
        )
    except Exception as e:
        print(f"Error during sheet update: {e}")

    # 3. Generate Driver Message
    print("Step 3: Generating WhatsApp message...")
    try:
        msg_proc = subprocess.run(
            [sys.executable, "NewGemTaxi/execution/generate_driver_msg.py", temp_json],
            capture_output=True,
            text=True,
            check=True,
            encoding='utf-8'
        )
        whatsapp_msg = msg_proc.stdout
        print("\n--- FORMATTED WHATSAPP MESSAGE ---")
        print(whatsapp_msg)
        print("-----------------------------------\n")
    except Exception as e:
        print(f"Error during message generation: {e}")

    # 4. Save for Flutter App
    print("Step 4: Saving structured data for App integration...")
    data_dir = "NewGemTaxi/data"
    os.makedirs(data_dir, exist_ok=True)
    bookings_file = os.path.join(data_dir, "bookings.json")
    
    existing_bookings = []
    if os.path.exists(bookings_file):
        try:
            with open(bookings_file, 'r') as f:
                existing_bookings = json.load(f)
        except:
            existing_bookings = []
            
    # Append the new extracted data (if not already present by job_id)
    job_id = extracted_data.get("job_id")
    if not any(b.get("job_id") == job_id for b in existing_bookings):
        existing_bookings.append(extracted_data)
        
    with open(bookings_file, 'w') as f:
        json.dump(existing_bookings, f, indent=2)
    
    print(f"Successfully orchestrate booking {job_id}. Data saved to {bookings_file}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        orchestrate(sys.argv[1])
    else:
        # Create a sample email file for testing
        sample_email = "NewGemTaxi/.tmp/sample_email.txt"
        os.makedirs(os.path.dirname(sample_email), exist_ok=True)
        with open(sample_email, 'w') as f:
            f.write("""Subject: 2104 - Reservation - Lois M - ABW-AB - Sunday, January 4, 2026

Please pickup Dustin from the Toronto airport and drop him at the Lois M in Hamilton on Sunday, January 4. After dropping Dustin, please wait to pick-up Ryan and drop him at his home in Chatham.

Joining Crew:
AB - Dustin Gaulton
(709) 325-6011
AC603
0846

Departing Crew:
ABW - Ryan Pernites
(905) 699-2864
262 Greenfield Lane, Chatham, ON""")
        orchestrate(sample_email)
