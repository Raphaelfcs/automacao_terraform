"""Cloud Run function (gatilho Pub/Sub): envia e-mail confirmando a gravação do pedido."""
import base64
import json
import os
import smtplib
from email.message import EmailMessage

import functions_framework


@functions_framework.cloud_event
def notify_order(cloud_event):
    data = base64.b64decode(cloud_event.data["message"]["data"]).decode()
    order = json.loads(data)

    msg = EmailMessage()
    msg["Subject"] = f"[Lab GKE] Pedido {order['order_id']} gravado com sucesso"
    msg["From"] = os.environ["SMTP_USER"]
    msg["To"] = os.environ["MAIL_TO"]
    msg.set_content(
        "Tudo certo! O pedido foi gravado no Cloud SQL e o evento passou pelo Pub/Sub.\n\n"
        f"Pedido: {order['order_id']}\nItem: {order['item']}\nQuantidade: {order['qty']}\n"
        f"Gravado em: {order['created_at']}\n"
    )
    with smtplib.SMTP(os.environ.get("SMTP_HOST", "smtp.gmail.com"), int(os.environ.get("SMTP_PORT", "587")), timeout=20) as s:
        s.starttls()
        s.login(os.environ["SMTP_USER"], os.environ["SMTP_PASSWORD"])
        s.send_message(msg)
    print(json.dumps({"severity": "INFO", "message": "email enviado", "order_id": order["order_id"]}))
