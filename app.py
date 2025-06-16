from flask import Flask, request, send_from_directory, jsonify
import subprocess
import os
import tomllib
from pathlib import Path

app = Flask(__name__)
config_file = Path("config/config.toml")

@app.route("/")
def index():
    return send_from_directory("static", "index.html")

@app.route("/print", methods=["POST"])
def print_labels():
    data = request.json
    labels = data.get("labels", [])
    if not labels:
        return "No labels provided", 400

    command = ["ptouch-print"]
    for label in labels:
        # Keep only lines that are not truly empty
        non_empty_lines = [line for line in label if line != ""]
        if non_empty_lines:
            command.append("--text")
            for line in non_empty_lines:
                command.append(f'"{line}"')
            command.append("--pad 2")
            command.append("--cutmark")
            command.append("--pad 2")

    try:
        # Run command (remove the last --cutmark)
        if command[-2] == "--cutmark":
            command.pop()

        print("Running command:", " ".join(command))
        subprocess.run(" ".join(command), shell=True, check=True)
        return "Labels printed successfully!"
    except subprocess.CalledProcessError as e:
        return f"Printing failed: {e}", 500

@app.route("/shutdown", methods=["POST"])
def shutdown():
    if os.environ.get("DEV_MODE") == "1":
        print(ssh_login())
        print("DEV MODE: Simulated shutdown")
        return "Simulated shutdown (DEV MODE)", 200

    try:
        subprocess.run([            
            "ssh", "-i", "config/ssh-key/container_shutdown_key", #"/etc/ssh/shutdown_key",
            "-o", "StrictHostKeyChecking=no",
            ssh_login(), 
            "sudo /sbin/shutdown -h now"], 
            check=True)
        return "Shutting down...", 200
    except subprocess.CalledProcessError as e:
        return f"Error: {e}", 500

def ssh_login():
    return host_name() + "@" + ip_address()

def host_name():
    config = get_config_table()
    return config["host_name"]

def ip_address():
    config = get_config_table()
    return config["ip"]

def get_config_table():
    with open(str(config_file), "rb") as conf:
        data = tomllib.load(conf)
        return data["config"]

if __name__ == "__main__":
    # Run the app in debug mode if started in a devcontainer
    app.run(host="0.0.0.0", port=5000, debug=os.environ.get("DEV_MODE")=="1")
