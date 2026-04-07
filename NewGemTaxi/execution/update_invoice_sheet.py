import os
import json
import sys
import gspread
from oauth2client.service_account import ServiceAccountCredentials

# Google Sheets Configuration
SHEET_ID = "YOUR_SPREADSHEET_ID_HERE" # User should replace this
SERVICE_ACCOUNT_FILE = "android/app/virtual-cairn-325907-edc3720342e5.json"

def update_sheet(data):
    print(f"Updating Google Sheet for Job ID: {data.get('job_id')}")
    
    # Authenticate and connect
    scope = ["https://spreadsheets.google.com/feeds", 'https://www.googleapis.com/auth/spreadsheets',
             "https://www.googleapis.com/auth/drive.file", "https://www.googleapis.com/auth/drive"]
    
    try:
        creds = ServiceAccountCredentials.from_json_keyfile_name(SERVICE_ACCOUNT_FILE, scope)
        client = gspread.authorize(creds)
        
        # NOTE: The service account email needs to be added as an Editor to the Google Sheet.
        # Find the email in the JSON file (client_email).
        sheet = client.open_by_key(SHEET_ID).sheet1
        
        date = data.get("date", "N/A")
        job_id = data.get("job_id", "N/A")
        wait_for_return = data.get("wait_for_return", False)
        
        for pax in data.get("passengers", []):
            route = ""
            if pax.get("type") == "Joining":
                route = "Airport -> Lois M"
            elif pax.get("type") == "Departing":
                route = "Lois M -> Home"
                
            status = "Wait for Return" if wait_for_return else "Pending"
            
            # Row format matching the stub
            row = [date, job_id, pax.get("name", "N/A"), route, "", status]
            
            # Append row to the sheet
            sheet.append_row(row)
            print(f"Successfully added row for: {pax.get('name')}")
            
        return True
    except Exception as e:
        print(f"Failed to update Google Sheet: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Enforce UTF-8 to handle emojis/special characters if necessary
        if hasattr(sys.stdout, 'reconfigure'):
            sys.stdout.reconfigure(encoding='utf-8')
            
        with open(sys.argv[1], 'r', encoding='utf-8') as f:
            data = json.load(f)
        update_sheet(data)
    else:
        print("No input data provided.")
