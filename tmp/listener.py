#!/usr/bin/env python3
"""
Simple webapp to listen for webhook calls from Netdata
and forward them to PagerDuty
"""
import os
import base64
import hashlib
import hmac
import json

import requests
from flask import Flask, request

pd_keys = {}
try:
    NETDATA_BEARER_TOKEN = os.environ["NETDATA_BEARER_TOKEN"]
    NETDATA_CHALLENGE_KEY = os.environ["NETDATA_CHALLENGE_KEY"]
    pd_keys["devops"] = os.environ["PD_ROUTING_KEY_DEVOPS"]
    PD_URL = os.environ["PD_URL"]
except KeyError as bollox:
    print("Critical :: Could not resolve a key envvar")
    print(bollox)

try:
    pd_keys["engineering"] = os.environ["PD_ROUTING_KEY_ENGINEERING"]
    pd_keys["trading"] = os.environ["PD_ROUTING_KEY_TRADING"]
except KeyError as bollox:
    print("Warning :: Could not resolve an optional envvar")
    print(bollox)

NETDATA_WEBHOOK_HOST = os.environ.get("NETDATA_WEBHOOK_HOST", "0.0.0.0")

try:
    NETDATA_WEBHOOK_PORT = int(os.environ.get("NETDATA_WEBHOOK_PORT", "8001"))
except ValueError as bollox:
    print("Could not convert NETDATA_WEBHOOK_PORT")
    print(bollox)

app = Flask(__name__)

# pylint: disable-msg=broad-exception-caught
# /webhook needs GET for challenge response otherwise just POSTs


@app.route("/webhook", methods=["GET", "POST"])
def webhook():
    """entry point for Netdata"""
    if "crc_token" in request.args:
        token = request.args.get("crc_token").encode("ascii")
        sha256_hash_digest = hmac.new(
            NETDATA_CHALLENGE_KEY.encode(), msg=token, digestmod=hashlib.sha256
        ).digest()
        reply = base64.b64encode(sha256_hash_digest).decode("ascii")
        response = {"response_token": "sha256=" + reply}
        return json.dumps(response), 200

    # print(request.headers.get("Content-Type"))  # TRACE

    headers = {"Content-Type": "application/json"}
    try:
        recv = request.get_json()
        msg = recv.get("message", "Unknown")
        severity = recv.get("severity", "error")

        if severity == "clear":
            event_action = "resolve"
            severity = "info"
        elif msg.startswith("Escalated to Critical,"):
            event_action = "trigger"
            severity = "critical"
        elif msg.startswith("Raised to Warning,"):
            event_action = "trigger"
            severity = "warning"
        elif msg.startswith("Recovered,"):
            event_action = "resolve"
            severity = "info"

        svc_name, svc_key = choose_key(pd_keys, msg)
        print(f"Routing to {svc_name}")

        payload = {
            "routing_key": svc_key,
            "event_action": event_action,  # oneOf(trigger, acknowledge, resolve)
            "payload": {
                "class": "CPU",
                "component": "MachineName",
                "severity": severity,  # oneOf(critical, error, warning, info)
                "source": "Netdata",
                "summary": msg,
            },
        }

        print(json.dumps(recv))
        print(json.dumps(payload))

        response = requests.post(
            PD_URL, data=json.dumps(payload), headers=headers, timeout=10
        )
        print(response.text)
        return "OK", 200
    except Exception as borked:
        print("Caught")
        print(borked)
        return "Failed", 200

    auth_header = request.headers.get("Authorization")
    if auth_header is None:
        return "Hello", 200
    return auth_header, 200


def choose_key(pdkeys: dict, msg: str) -> (str, str):
    """choose which service key to use"""
    for name, value in pdkeys.items():
        if f"{name}_" in msg:
            return (name, value)
    return ("devops", pdkeys["devops"])


if __name__ == "__main__":
    app.run(host=NETDATA_WEBHOOK_HOST, port=NETDATA_WEBHOOK_PORT)
