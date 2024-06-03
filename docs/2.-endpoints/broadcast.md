---
description: Endpoint used to broadcast a message and save it on the log table
---

# /broadcast

The endpoint requires the following JSON:

```json
{
    "serverId": "Server_1",
    "clientId": "client1",
    "region": "example_region",
    "actionCode": 0,
    "messageBody": "Broadcast Example",
    "cost": 0.0,
    "deaths": 0,
    "infected": 0.0,
    "contactRate": 0.0,
    "vaccinationRate": 0.0,
    "budget": 0.0,
    "populationTotal": 0,
    "quarantined": 0,
    "susceptible": 0,
    "exposed": 0,
    "hospitalized": 0,
    "immunized": 0
}
```

In case of success, the reply is a <mark style="color:green;">200 OK</mark>, with the response:

```json
{
    "Broadcasted": "0|example_region|client1|Broadcast Example"
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
2.  <mark style="color:red;">400 Bad Request</mark>,

    ```json
    {
        "Error": "Invalid or missing parameter"
    }
    ```
3.  <mark style="color:red;">400 Bad Request</mark>,

    ```json
    {
        "Error": "Not part of this game"
    }
    ```
