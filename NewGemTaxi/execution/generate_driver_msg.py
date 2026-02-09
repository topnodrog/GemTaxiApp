import json
import sys

def generate_msg(data):
    date = data.get("date", "N/A")
    lines = []
    lines.append("🚖 *New Job Alert*")
    lines.append(f"📅 Date: {date}")
    
    joining = [p for p in data.get("passengers", []) if p["type"] == "Joining"]
    departing = [p for p in data.get("passengers", []) if p["type"] == "Departing"]
    
    for i, pax in enumerate(joining):
        lines.append(f"✈️ Pickup {i+1}: Toronto Airport ({pax.get('flight_time', 'N/A')})")
        lines.append(f"👤 Pax: {pax.get('name')} ({pax.get('phone', 'N/A')})")
        lines.append(f"📍 Drop: Lois M (Hamilton)")
    
    if data.get("wait_for_return"):
        lines.append("---")
        lines.append("⏳ WAIT FOR RETURN")
        lines.append("---")
    
    for pax in departing:
        lines.append(f"👤 Pax: {pax.get('name')} ({pax.get('phone', 'N/A')})")
        lines.append(f"📍 Drop: {pax.get('address', 'N/A')}")
        
    return "\n".join(lines)

if __name__ == "__main__":
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r', encoding='utf-8') as f:
            data = json.load(f)
        print(generate_msg(data))
    else:
        # Demo mode
        sample_data = {
            "job_id": "2104",
            "date": "Sunday, January 4",
            "wait_for_return": True,
            "passengers": [
                {"type": "Joining", "name": "Dustin Gaulton", "phone": "709-325-6011", "flight_time": "Flight AC603 @ 0846"},
                {"type": "Departing", "name": "Ryan Pernites", "phone": "905-699-2864", "address": "262 Greenfield Lane, Chatham"}
            ]
        }
        print(generate_msg(sample_data))
