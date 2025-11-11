from flask import Flask, render_template, request, jsonify
import requests
import json
import os

app = Flask(__name__)

# === CONFIG ===
REPO = "YOURUSERNAME/s_xmate4-messages"   # ← CHANGE
TOKEN = "YOUR_GITHUB_TOKEN"               # ← PASTE TOKEN
FILE_PATH = "messages.json"
API_URL = f"https://api.github.com/repos/{REPO}/contents/{FILE_PATH}"

HEADERS = {
    "Authorization": f"token {TOKEN}",
    "Accept": "application/vnd.github.v3+json"
}

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/send", methods=["POST"])
def send():
    data = request.json
    try:
        # Get current file
        r = requests.get(API_URL, headers=HEADERS)
        if r.status_code != 200:
            return jsonify({"error": "File not found"}), 404
        content = r.json()
        sha = content["sha"]
        current = json.loads(requests.get(content["download_url"]).text)

        # Generate new message
        new_id = current.get("last_id", 0) + 1
        msg = {
            "id": new_id,
            "type": data["type"],
            "timestamp": data.get("timestamp")
        }
        if data["type"] == "message":
            msg["text"] = data["text"]
            msg["color"] = data.get("color", [255, 100, 100])
        elif data["type"] == "effect":
            msg["effect"] = data["effect"]

        current["last_id"] = new_id
        current["messages"].append(msg)

        # Update on GitHub
        update_payload = {
            "message": f"Add global message {new_id}",
            "content": requests.post(
                "https://api.github.com/markdown",
                json={"text": json.dumps(current, indent=2)},
                headers=HEADERS
            ).text,  # not used
            "sha": sha,
            "branch": "main"
        }
        # Actually encode content in base64
        import base64
        update_payload["content"] = base64.b64encode(json.dumps(current, indent=2).encode()).decode()

        requests.put(API_URL, json=update_payload, headers=HEADERS)
        return jsonify({"status": "sent", "id": new_id})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    os.makedirs("templates", exist_ok=True)
    app.run(host="127.0.0.1", port=5000)