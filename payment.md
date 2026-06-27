Title: Get payment methods (Step 1)

URL Source: http://fawaterak-api.readme.io/reference/initiatepayment

Markdown Content:
Endpoint

This is your first step for integration , you will send request for our end point to receive the payment methods which assigned to you.

The "InitiatePayment" endpoint is a GET request. It is used to retrieve all enabled Payment Methods of your portal account with the commission charge that the customer may pay on the gateway.

PLEASE USE THE BELOW END POINT:

[https://staging.fawaterk.com/api/v2/getPaymentmethods](https://staging.fawaterk.com/api/v2/getPaymentmethods)

also below is sample request and response codes

```
<?php
$curl = curl_init();
curl_setopt_array($curl, array(
  CURLOPT_URL => 'https://staging.fawaterk.com/api/v2/getPaymentmethods',
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_ENCODING => '',
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_TIMEOUT => 0,
  CURLOPT_FOLLOWLOCATION => true,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => 'GET',
  CURLOPT_HTTPHEADER => array(
    'Content-Type: application/json',
    'Authorization: Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd'
  ),
));
$response = curl_exec($curl);
curl_close($curl);
```

```
var client = new RestClient("https://staging.fawaterk.com/api/v2/getPaymentmethods");
client.Timeout = -1;
var request = new RestRequest(Method.GET);
request.AddHeader("content-type", "application/json");
request.AddHeader("Authorization", "Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd");
IRestResponse response = client.Execute(request);
Console.WriteLine(response.Content);
```

```
var myHeaders = new Headers();
myHeaders.append("content-type", "application/json");
myHeaders.append("Authorization", "Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd");

var requestOptions = {
  method: 'GET',
  headers: myHeaders,
  redirect: 'follow'
};

fetch("https://staging.fawaterk.com/api/v2/getPaymentmethods", requestOptions)
  .then(response => response.text())
  .then(result => console.log(result))
  .catch(error => console.log('error', error));
```

```
import requests
import json

url = "https://staging.fawaterk.com/api/v2/getPaymentmethods"

payload={}
headers = {
  'content-type': 'application/json',
  'Authorization': 'Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd'
}

response = requests.request("GET", url, headers=headers, data=payload)

print(response.text)
import requests
import json

url = "https://dev.fawaterk.com/api/v2/getPaymentmethods"

payload={}
headers = {
  'content-type': 'application/json',
  'Authorization': 'Bearer 0b3fefb44fd628870b751793224d6334fea5d38300641e36aa'
}

response = requests.request("GET", url, headers=headers, data=payload)

print(response.text)
```

Response Body

```
{
    "status": "success",
    "data": [
        {
            "paymentId": 2,
            "name_en": "Visa-Mastercard",
            "name_ar": "فيزا -ماستر كارد",
            "redirect": "true",
            "logo": "https://app.fawaterak.xyz/clients/payment_options/mastercard-visa.png"
        },
        {
            "paymentId": 3,
            "name_en": "Fawry",
            "name_ar": "فوري",
            "redirect": "false",
            "logo": "https://app.fawaterak.xyz/clients/payment_options/fawry.png"
        },
        {
            "paymentId": 4,
            "name_en": "Meeza",
            "name_ar": "ميزا",
            "redirect": "false",
            "logo": "https://app.fawaterak.xyz/clients/payment_options/MeezaDigitalSmall.png"
        }
     
    ]
}
```

1.please note that if redirect attribute equal to "TRUE" then you will receive a link you need to redirect to it to complete the payment process.

2.Kindly note that Meeza (Mobile wallets ) tested by real payments only.

*   [Table of Contents](http://fawaterak-api.readme.io/reference/initiatepayment#)
*       *   [IMPORTANT NOTES](http://fawaterak-api.readme.io/reference/initiatepayment#important-notes)


Title: Execute Payment (Step 2)

URL Source: http://fawaterak-api.readme.io/reference/inetail-payment-1

Markdown Content:
```
<?php
$curl = curl_init();
curl_setopt_array($curl, array(
  CURLOPT_URL => 'https://staging.fawaterk.com/api/v2/invoiceInitPay',
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_ENCODING => '',
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_TIMEOUT => 0,
  CURLOPT_FOLLOWLOCATION => true,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => 'POST',
  CURLOPT_POSTFIELDS =>'{
    "payment_method_id": 2,
    "cartTotal": "50",
    "currency": "EGP",
    "invoice_number" : "123",
    "customer": {
        "first_name": "mohammad",
        "last_name": "hamza",
        "email": "test@fawaterk.com",
        "phone": "01xxxxxxxxx",
        "address": "test address"
    },
    "redirectionUrls": {
         "successUrl" : "https://dev.fawaterk.com/success",
         "failUrl": "https://dev.fawaterk.com/fail",
         "pendingUrl": "https://dev.fawaterk.com/pending"   
    },
    "cartItems": [
        {
            "name": "this is test oop 112252",
            "price": "25",
            "quantity": "1"
        },
        {
            "name": "this is test oop 112252",
            "price": "25",
            "quantity": "1"
        }
    ]
}',
  CURLOPT_HTTPHEADER => array(
    'Content-Type: application/json',
    'Authorization: Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd'
  ),
));
$response = curl_exec($curl);
curl_close($curl);
```

```
var client = new RestClient("https://staging.fawaterk.com/api/v2/invoiceInitPay");
client.Timeout = -1;
var request = new RestRequest(Method.POST);
request.AddHeader("Authorization", "Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd");
request.AddHeader("Content-Type", "application/json");
var body = @"{" + "\n" +
@"    ""payment_method_id"": 4," + "\n" +
@"    ""cartTotal"": ""100""," + "\n" +
@"    ""currency"": ""EGP""," + "\n" +
@"    ""customer"": {" + "\n" +
@"        ""first_name"": ""test""," + "\n" +
@"        ""last_name"": ""test""," + "\n" +
@"        ""email"": ""test@test.com""," + "\n" +
@"        ""phone"": ""01000000000""," + "\n" +
@"        ""address"": ""test address""" + "\n" +
@"    }," + "\n" +
@"    ""redirectionUrls"": {" + "\n" +
@"        ""successUrl"": ""https://dev.fawaterk.com/success""," + "\n" +
@"        ""failUrl"": ""https://dev.fawaterk.com/fail""," + "\n" +
@"        ""pendingUrl"": ""https://dev.fawaterk.com/pending""" + "\n" +
@"    }," + "\n" +
@"    ""cartItems"": [" + "\n" +
@"        {" + "\n" +
@"            ""name"": ""test""," + "\n" +
@"            ""price"": ""100""," + "\n" +
@"            ""quantity"": ""1""" + "\n" +
@"        }" + "\n" +
@"    ]" + "\n" +
@"}";
request.AddParameter("application/json", body,  ParameterType.RequestBody);
IRestResponse response = client.Execute(request);
Console.WriteLine(response.Content);
```

```
const payload = {
  payment_method_id: 4,
  cartTotal: "100",
  currency: "EGP",
  customer: {
    first_name: "test",
    last_name: "test",
    email: "test@test.test",
    phone: "01000000000",
    address: "test address",
  },
  redirectionUrls: {
    successUrl: "https://dev.fawaterk.com/success",
    failUrl: "https://dev.fawaterk.com/fail",
    pendingUrl: "https://dev.fawaterk.com/pending",
  },
  cartItems: [
    {
      name: "test",
      price: "100",
      quantity: "1",
    },
  ],
};

fetch("https://staging.fawaterk.com/api/v2/invoiceInitPay", {
  method: "POST",
  headers: {
    Authorization:
      "Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd",
    "Content-Type": "application/json",
  },
  body: JSON.stringify(payload),
})
  .then(function (response) {
    if (!response.ok) {
      return response.text().then(function (text) {
        throw new Error("HTTP " + response.status + ": " + text);
      });
    }
    return response.json();
  })
  .then(function (data) {
    console.log(JSON.stringify(data));
  })
  .catch(function (error) {
    console.log(error);
  });
```

```
import requests
import json

url = "https://staging.fawaterk.com/api/v2/invoiceInitPay"

payload = json.dumps({
  "payment_method_id": 4,
  "cartTotal": "100",
  "currency": "EGP",
  "customer": {
    "first_name": "test",
    "last_name": "test",
    "email": "test@test.com",
    "phone": "01000000000",
    "address": "test address"
  },
  "redirectionUrls": {
    "successUrl": "https://dev.fawaterk.com/success",
    "failUrl": "https://dev.fawaterk.com/fail",
    "pendingUrl": "https://dev.fawaterk.com/pending"
  },
  "cartItems": [
    {
      "name": "test",
      "price": "100",
      "quantity": "1"
    }
  ]
})
headers = {
  'Authorization': 'Bearer d83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd',
  'Content-Type': 'application/json'
}

response = requests.request("POST", url, headers=headers, data=payload)

print(response.text)
```