import os
import json
import sys
# import gspread # This would be used in a real environment
# from oauth2client.service_account import ServiceAccountCredentials

def update_sheet(data):
    # This is a stub for the actual Google Sheets update logic.
    # In a real scenario, we'd use service account credentials.
    
    print(f"Updating Google Sheet for Job ID: {data.get('job_id')}")
    
    entries = []
    date = data.get("date")
    job_id = data.get("job_id")
    
    for pax in data.get("passengers", []):
        route = ""
        if pax["type"] == "Joining":
            route = "Airport -> Lois M" # Simplified mapping
        else:
            route = "Lois M -> Home"
            
        entry = {
            "Date": date,
            "Job ID": job_id,
            "Passenger": pax.get("name"),
            "Route": route,
            "Rate": "",
            "Status": "Wait for Return" if data.get("wait_for_return") else "Pending"
        }
        entries.append(entry)
        print(f"Added row: {entry}")

    return True

if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            data = json.load(f)
        update_sheet(data)
    else:
        print("No input data provided.")
