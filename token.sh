# A) logujemy się Basic-Auth do Grafany
cred='admin:Test123!'

# B) tworzymy service account
curl -u $cred -H 'Content-Type: application/json' \
     -d '{"name":"ci-service3","role":"Admin"}' \
     http://localhost:3000/api/serviceaccounts > sa.json

SA_ID=$(jq -r '.id' sa.json)

# C) generujemy token dla SA
curl -u $cred -H 'Content-Type: application/json' \
     -d '{"name":"ci-token","secondsToLive":0}' \
     http://localhost:3000/api/serviceaccounts/2/tokens > token.json

TOKEN=$(jq -r '.key' token.json)
echo $TOKEN
