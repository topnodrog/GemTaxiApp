import json
import sys

def generate_msg(data):
    date = data.get("date", "N/A")
    job_id = data.get("job_id", "N/A")
    lines = []
    
    # Header Section
    lines.append("─────────────────────────────")
    lines.append(f"🚖 *NEW JOB ALERT : #{job_id}*")
    lines.append("─────────────────────────────")
    lines.append(f"📅 *Date:* {date}")
    lines.append(f"🔄 *Wait & Return:* {'✅ YES' if data.get('wait_for_return') else '❌ NO'}")
    lines.append("")
    
    joining = [p for p in data.get("passengers", []) if p.get("type") == "Joining"]
    departing = [p for p in data.get("passengers", []) if p.get("type") == "Departing"]
    
    # Joining Passengers
    if joining:
        lines.append("✈️ *JOINING (PICKUP FROM AIRPORT)*")
        for i, pax in enumerate(joining):
            lines.append(f"  • *Passenger {i+1}:* {pax.get('name')} 📞 {pax.get('phone', 'N/A')}")
            lines.append(f"  • *Flight:* {pax.get('flight_time', 'N/A')}")
            lines.append(f"  • *Drop-off:* Lois M (Hamilton)")
            lines.append("")
        
    if data.get("wait_for_return"):
        lines.append("⏳ *[ PLEASE WAIT FOR RETURN TRIP ]*")
        lines.append("")
        
    # Departing Passengers
    if departing:
        lines.append("🏠 *DEPARTING (RETURN TRIP)*")
        for i, pax in enumerate(departing):
            lines.append(f"  • *Passenger {i+1}:* {pax.get('name')} 📞 {pax.get('phone', 'N/A')}")
            lines.append(f"  • *Drop-off:* {pax.get('address', 'N/A')}")
            lines.append("")
            
    lines.append("─────────────────────────────")
    lines.append("Please accept this job in the app.")
    
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
