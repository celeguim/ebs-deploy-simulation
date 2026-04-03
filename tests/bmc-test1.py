import http.client
import json
import requests

base_url = "dnv-dev-is.onbmc.com"
conn = http.client.HTTPSConnection(base_url)

###################################################################################
## LOGIN
payload = json.dumps(
    {"userName": "CELLUI", "password": "AGGDURQBA4YFFATDGA7VTDGA7VQKC7"}
)

headers = {
    "default-bundle-scope": "com.bmc.case-lib",
    "X-Requested-By": "XMLHttpRequest",
    "Content-Type": "application/json",
}

conn.request("POST", "/api/rx/authentication/loginrequest", payload, headers)
res = conn.getresponse()
data = res.read()
token = data.decode("utf-8")
print(token)


###################################################################################
## GET INCIDENT
query_params = {
    "q": "('Incident Number' LIKE \"INC000000697516\")",
    "fields": "values(Entry ID, Incident Number, Status, Short Description, Description, Detailed Decription, Assigned Group, Submitter, Submit Date, Last Modified Date, First Name, Last Name)",
}

headers = {
    "default-bundle-scope": "com.bmc.case-lib",
    "X-Requested-By": "XMLHttpRequest",
    "Content-Type": "application/json",
    "Cookie": f"AR-JWT={token}",
}

url = "https://dnv-dev-is.onbmc.com/api/arsys/v1/entry/HPD:Help Desk"
response = requests.get(url=url, params=query_params, headers=headers)
print(response.url)
data = response.text
print(data)
print(response.json().get('entries')[0].get('values'))