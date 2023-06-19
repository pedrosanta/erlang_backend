---
description: Endpoint used by the host to start a game from lobby
---

# /start\_game

The endpoint requires the following JSON:

```json
{
    "clientId": "client1",
    "serverId": "Server_1"
}
```

In case of success, the reply is a <mark style="color:green;">200 OK</mark>, with the response:

```json
{
    "Broadcasted": "205|3"
}
```

Otherwise the following responses will be given:

1.  <mark style="color:green;">200 OK</mark>,

    ```json
    {
        "Exists": false,
        "Error": "This game no longer exists."
    }
    ```
2.  &#x20;<mark style="color:red;">400 Bad Request</mark>,

    ```json
    {
        "Error": "Invalid or missing parameter"
    }
    ```
3.  <mark style="color:red;">400 Bad Request</mark>, &#x20;

    ```json
    {
        "Error": "Not Host"
    }
    ```
