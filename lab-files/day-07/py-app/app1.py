from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route("/")
def hello():

    html = "<body bgcolor=\"{color}\"><h3>Welcome {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/></body>"
    return html.format(name=os.getenv("NAME", " Anonymous!"), color=os.getenv("COLOR", "red"), hostname=socket.gethostname())

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)