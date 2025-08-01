from flask import Flask, request, session, redirect, url_for, render_template_string, send_from_directory
from werkzeug.utils import secure_filename
import os
import time

app = Flask(__name__)
app.secret_key = 'super-secret-key'

# Upload config
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Main executor code and key system code
main_code = '''loadstring(game:HttpGet("https://pastebin.com/raw/4wkYxMxt"))()'''
ks_code = '''loadstring(game:HttpGet("https://pastebin.com/raw/4wkYxMxt"))()'''
za_code = '''loadstring(game:HttpGet("https://raw.githubusercontent.com/jxckplayxz/cool/refs/heads/main/aaa"))() -- btw this is just the loader so its useless :)'''
error_code = '''Bro why you tryna see source you a skid or sum? oh yea btw join our server --> https://discord.gg/zMPJxeMMrK'''

# HTML templates
home_page = '''...'''  # keep your current home_page string
locked_page = '''...'''  # keep your current locked_page string

@app.route('/')
def home():
    return render_template_string(home_page)

@app.route('/verify', methods=['POST'])
def verify():
    key = request.form.get('key')
    if key == "voidy-skid-off":
        session['verified'] = True
        return redirect('/212')
    return redirect('/')

def is_executor():
    user_agent = request.headers.get('User-Agent', '').lower()
    executor_keywords = ['synapse', 'roblox', 'krnl', 'fluxus', 'executor', 'delta']
    return any(exec in user_agent for exec in executor_keywords)

@app.route('/212')
def hidden():
    query_key = request.args.get("key", "")
    is_exec = is_executor()
    verified = session.get('verified')

    if not verified and not is_exec:
        return redirect('/')

    if is_exec:
        if query_key == "skidder":
            return render_template_string(locked_page, code=main_code, can_see_code=True)
        else:
            return render_template_string(locked_page, code="", can_see_code=False)

    return render_template_string(locked_page, code="", can_see_code=False)

@app.route('/script')
def execute():
    script_code = f'loadstring(game:HttpGet("https://{request.host}/error?key=skidder"))()'
    return f'''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Voidy X Script</title>
        <meta charset="UTF-8">
        <style>
            body {{
                background: radial-gradient(circle at center, #0f0f0f 0%, #1a1a1a 100%);
                color: white;
                font-family: 'Segoe UI', sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
            }}
            .container {{
                background: #121212;
                border: 2px solid #2b2b2b;
                border-radius: 30% 70% 70% 30% / 30% 30% 70% 70%;
                padding: 30px 40px;
                box-shadow: 0 0 25px rgba(0, 255, 255, 0.3);
                max-width: 600px;
                text-align: center;
            }}
            pre {{
                background: #222;
                padding: 15px;
                border-radius: 10px;
                overflow-x: auto;
                font-size: 14px;
            }}
            button {{
                margin-top: 15px;
                background: #00d4ff;
                border: none;
                padding: 10px 20px;
                font-size: 14px;
                color: black;
                font-weight: bold;
                border-radius: 8px;
                cursor: pointer;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="title">⚡ Voidy X Script</div>
            <pre id="scriptBox">{script_code}</pre>
            <button onclick="copyCode()">Copy Script</button>
        </div>
        <script>
            function copyCode() {{
                const code = document.getElementById('scriptBox').innerText;
                navigator.clipboard.writeText(code).then(() => {{
                    alert('Script copied to clipboard!');
                }});
            }}
        </script>
    </body>
    </html>
    '''

executed_keys = {}

@app.route('/track', methods=['POST'])
def track():
    key = request.form.get("key", "")
    executed_keys[key] = time.time()
    return "Tracked", 200

@app.route('/raw')
def raw():
    key = request.args.get("key", "")
    last_exec = executed_keys.get(key)

    if last_exec and time.time() - last_exec < 10:
        return ks_code, 200, {'Content-Type': 'text/plain'}
    else:
        return error_code, 200, {'Content-Type': 'text/plain'}

@app.route('/error')
def error():
    if is_executor() and request.args.get("key") == "skidder":
        return za_code, 200, {'Content-Type': 'text/plain'}
    return "Error page has been deleted or moved", 403

@app.route('/main')
def main():
    if is_executor() and request.args.get("key") == "skidder":
        return main_code, 200, {'Content-Type': 'text/plain'}
    return "Unauthorized", 403

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=20039)
