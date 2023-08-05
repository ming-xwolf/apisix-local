
## rebuild apisix
``` shell
export NAME=apisix
export VERSION=3.2.0.l1
./build_docker.sh build
```

## 

docker pull apache/apisix-dashboard:3.0.0-centos

docker pull apache/apisix:3.2.0-debian
docker pull apache/apisix:3.2.0-centos
apache/apisix:2.10.0-alpine

### view routes
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes" -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X GET
```
---
### create route1 - IP 
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/1" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "methods": ["GET"],
  "uri": "/route1",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "192.168.3.34:9081": 1,
      "192.168.3.34:9082": 2
    }
  }
}'
```
### view the route1
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/1" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X GET
```
### test the route1
``` shell
curl -i -X GET "http://apisix-gateway-hello-openshift.apps-crc.testing/route1"
```
---
### create route2 - openshift route
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/2" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "methods": ["GET"],
  "uri": "/route2",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "baidu.com:80" : 1
    }
  }
}'
```
### view the route2
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/2" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X GET
```
### test the route2
``` shell
curl -i -X GET "http://apisix-gateway-hello-openshift.apps-crc.testing/route2"
```

### create 1 upstreams
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/upstreams/1" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "type": "roundrobin",
  "nodes": {
    "httpbin.org:80": 1
  }
}'
```

```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/upstreams/2" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "type": "roundrobin",
  "nodes": {
    "192.168.3.34:9081": 1
  }
}'
```

### create 1 routes using upstream id
``` shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/1" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "methods": ["POST"],
  "uri": "/anything/*",
  "upstream_id": "1"
}'
```

``` shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/test" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "methods": ["POST"],
  "uri": "/test",
  "upstream_id": "2"
}'
```

### view the routes
``` shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X GET
```
``` shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/jas" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X DELETE
```


### enable limit plugin
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/1" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "methods": ["GET"],
  "uri": "/anything/*",
  "plugins": {
        "limit-count": {
            "count": 2,
            "time_window": 60,
            "rejected_code": 503,
            "key_type": "var",
            "key": "remote_addr"
        }
    },
  "upstream_id": "1"
}'
```

### enable key-auth

create an consumer with unique key:

```shell
curl http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/consumers -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "username": "jack",
    "plugins": {
        "key-auth": {
            "key": "auth-one"
        }
    }
}'
```

create a route
```shell
curl "http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/2" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "methods": ["GET"],
  "uri": "/anythingd/*",
  "upstream_id": "1"
}'
```
query
```shell
curl  "http://apisix-gateway-hello-openshift.apps-crc.testing/anythingd/a"
```

## setup route 2 - jwt-auth
### create Consumer object

secret user
```shell
curl http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/consumers \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "username": "jack",
    "plugins": {
        "jwt-auth": {
            "key": "user-key",
            "secret": "my-secret-key"
        }
    }
}'
```

public/private key user
```shell
curl http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/consumers -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "username": "kerouac",
    "plugins": {
        "jwt-auth": {
            "key": "user-key",
            "public_key": "-----BEGIN PUBLIC KEY-----\n……\n-----END PUBLIC KEY-----",
            "private_key": "-----BEGIN RSA PRIVATE KEY-----\n……\n-----END RSA PRIVATE KEY-----",
            "algorithm": "RS256"
        }
    }
}'
```
view the consumer object

```shell
curl http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/consumers \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X GET
```

create routes to authenticate requests
```shell
curl http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/2 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "methods": ["GET"],
    "uri": "/index.html",
    "plugins": {
        "jwt-auth": {}
    },
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "127.0.0.1:1980": 1
        }
    }
}'
```

setup a Route for an API that signs the token using the public-api plugin:
```shell
curl http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/routes/jas -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "uri": "/apisix/plugin/jwt/sign",
    "plugins": {
        "public-api": {}
    }
}'
```

get a token
```shell
curl http://apisix-gateway-hello-openshift.apps-crc.testing/apisix/plugin/jwt/sign?key=user-key -i
```

```shell
curl http://apisix-gateway-hello-openshift.apps-crc.testing/index.html -i
```

delete consumers
```shell
curl http://apisix-admin-hello-openshift.apps-crc.testing/apisix/admin/consumers/supperman \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X DELETE
```
