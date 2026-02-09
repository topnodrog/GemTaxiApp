import re
import json
import sys

def extract_data(email_text):
    data = {
        "job_id": None,
        "date": None,
        "passengers": []
    }

    # Extract Job ID from Subject (simplified, assuming it's in the text or passed as part of metadata)
    # For now, let's look for a 4-digit number at the start of a line or in brackets
    job_id_match = re.search(r"(\d{4})", email_text)
    if job_id_match:
        data["job_id"] = job_id_match.group(1)

    # Extract Date
    date_match = re.search(r"on\s+(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday),\s+([A-Z][a-z]+\s+\d{1,2}(?:,\s+\d{4})?)", email_text)
    if date_match:
        data["date"] = f"{date_match.group(1)}, {date_match.group(2)}"

    # Parse Crew sections
    joining_match = re.search(r"Joining Crew:(.*?)((?=Departing Crew:)|$)", email_text, re.DOTALL)
    departing_match = re.search(r"Departing Crew:(.*?)((?=Joining Crew:)|$)", email_text, re.DOTALL)

    def parse_crew_block(block_text, trip_type):
        if not block_text:
            return []
        
        # Split by passenger name (assuming format: [Prefix] - [Name])
        pax_splits = re.split(r"\n(?=[A-Z]{2,}\s+-\s+)", block_text.strip())
        pax_list = []
        
        for pax_text in pax_splits:
            pax = {"type": trip_type}
            # Name and Initials
            name_match = re.search(r"-\s+(.*)", pax_text)
            if name_match:
                pax["name"] = name_match.group(1).split("\n")[0].strip()
            
            # Phone - match first, then remove to avoid conflicts with flight/time
            phone_match = re.search(r"\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}", pax_text)
            if phone_match:
                pax["phone"] = phone_match.group(0)
                remaining_text = pax_text.replace(pax["phone"], "")
            else:
                remaining_text = pax_text
            
            # Flight/Time - specifically look for flight codes (2 chars + digits) or 4 digit times
            flight_match = re.search(r"([A-Z]{2}\d{2,4})", remaining_text)
            time_match = re.search(r"(?<!-)\b(\d{4})\b", remaining_text) # Avoid picking up parts of phone
            
            pax["flight_time"] = f"{flight_match.group(1) if flight_match else ''} {time_match.group(1) if time_match else ''}".strip()
            
            # Address (for departing) - Look for street address (digits) following a newline or start
            address_match = re.search(r"(?:\n|^)(\d+\s+.*,\s+.*,\s+ON)", remaining_text)
            if address_match:
                pax["address"] = address_match.group(1).strip()
            
            pax_list.append(pax)
        return pax_list

    if joining_match:
        data["passengers"].extend(parse_crew_block(joining_match.group(1), "Joining"))
    if departing_match:
        data["passengers"].extend(parse_crew_block(departing_match.group(1), "Departing"))

    # Extract Route context from the natural language part
    # "pickup Dustin from the Toronto airport and drop him at the Lois M in Hamilton on Sunday, January 4."
    route_match = re.search(r"pickup (.*?) from the (.*?) and drop him at the (.*?) in (.*?)(?=\s+on|$)", email_text, re.IGNORECASE)
    if route_match:
        data["route_context"] = {
            "pickup_name": route_match.group(1).strip(),
            "pickup_loc": route_match.group(2).strip(),
            "drop_loc": route_match.group(3).strip(),
            "drop_city": route_match.group(4).strip()
        }
    
    # Wait and Return logic
    if "wait to pick-up" in email_text.lower():
        data["wait_for_return"] = True

    return data

if __name__ == "__main__":
    input_text = None
    output_file = None
    
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            input_text = f.read()
        if len(sys.argv) > 2:
            output_file = sys.argv[2]
    else:
        # Sample for demonstration if no file provided
        input_text = """From: Moe Aminzadeh <gemtaxi@gmail.com>
Subject: Re: 2104 - Reservation - Lois M - ABW-AB - Sunday, January 4, 2026

Please pickup Dustin from the Toronto airport and drop him at the Lois M in Hamilton on Sunday, January 4.  After dropping Dustin, please wait to pick-up Ryan and drop him at his home in Chatham.

Joining Crew:
AB - Dustin Gaulton
(709) 325-6011
AC603
0846

Departing Crew:
ABW - Ryan Pernites
(905) 699-2864
262 Greenfield Lane, Chatham, ON"""

    result = extract_data(input_text)
    json_result = json.dumps(result, indent=2)
    
    if output_file:
        with open(output_file, 'w') as f:
            f.write(json_result)
        print(f"Data extracted to {output_file}")
    else:
        print(json_result)
